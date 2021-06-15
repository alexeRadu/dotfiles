import logging
import os
import pynvim
import threading
from pygdbmi.gdbcontroller import GdbController

@pynvim.plugin
class DbugPlugin(object):
    def __init__(self, vim):
        self.vim = vim
        self.gdb = None
        self.thread = None
        self.run = False
        self.breakpoints = {}

        handler = logging.FileHandler('/tmp/dbug.log', 'w')
        handler.formatter = logging.Formatter('%(msecs)6d %(levelname)-5s   %(message)s')
        self.logger = logging.getLogger(__name__)
        self.logger.addHandler(handler)
        self.logger.setLevel(logging.DEBUG)

    def target_connect_remote(self, remote):
        self.logger.info("Connecting remotely to %s" % remote)
        self.gdb.write("-target-select remote %s" % remote, read_response=False)

    def target_disconnect(self):
        self.logger.info("Disconnecting from target")
        self.gdb.write("-target-disconnect", read_response=False)

    def load_exec_and_symbol_file(self, fname):
        if not os.path.isfile(fname):
            self.logger.error("File '%s' doesn't exist" % (fname))

        self.logger.info("Using '%s' as both executable and symbols file" % fname)
        self.gdb.write("-file-exec-and-symbols %s" % (fname), read_response=False)

    def _pr_msg(self, messages):
        for msg in messages.split('\\n'):
            msg = msg.replace('\\"', '"')
            self.logger.debug("GDB: %s" % msg)

    def _place_bp(self, no, bp):
        self.vim.command("sign place %d line=%d name=dbg_bp file=%s" % (no, bp['line'], bp['file']))
        self.logger.info("Placed breakpoint '%d' at '%s:%d'" % (no, bp['file'], bp['line']))

    def parse_response(self):
        self.logger.debug("Started response parser thread")

        while self.run:
            response = self.gdb.get_gdb_response(timeout_sec=5, raise_error_on_timeout=False)
            if response:
                for r in response:
                    if r['type'] in ['console', 'log', 'output']:
                        self._pr_msg(r['message'] or r['payload'])

                    elif r['type'] in ['notify', 'result']:
                        self._pr_msg(r['message'])

                        if r['payload']:
                            for k, v in r['payload'].items():
                                if k in ['bkpt']:
                                    bkpt_no = int(v['number'])
                                    bkpt = {'line': int(v['line']), 'file': v['fullname']}

                                    self.breakpoints[bkpt_no] = bkpt
                                    self.vim.async_call(self._place_bp, bkpt_no, bkpt)
                                else:
                                    self.logger.info("%s: %s" % (k, str(v)))
                    else:
                        self.logger.info(str(r))

        self.logger.debug("Response parser thread stopped")

    @pynvim.command('Dbg', sync=True)
    def dbg(self):
        gdb_path = self.vim.vars.get('dbug_gdb_path')
        self.gdb = GdbController([gdb_path, "--interpreter=mi3"])

        self.thread = threading.Thread(target=self.parse_response)
        self.run = True
        self.thread.start()

        self.logger.info("Started GDB debugger %s" % (gdb_path))

        remote_address = self.vim.vars.get('dbug_remote_hint')
        if remote_address:
            self.target_connect_remote(remote_address)

        fname = self.vim.vars.get('dbug_file')
        if fname:
            self.load_exec_and_symbol_file(fname)

    @pynvim.command('DbgStop', sync=False)
    def dbg_stop(self):
        self.run = False
        self.thread.join()
        self.target_disconnect()
        self.gdb.exit()
        self.gdb = None
        self.logger.info("GDB debugger has stopped")

    @pynvim.command('DbgFile', nargs='?', sync=True)
    def dbg_file(self, args):
        if len(args) == 0:
            fname = self.vim.vars.get('dbug_file')
        else:
            fname = args[0]

        self.load_exec_and_symbol_file(fname)

    @pynvim.command('DbgRemote', nargs='?', sync=True)
    def dbg_remote(self, args):
        if len(args) == 0:
            address = self.vim.vars.get('dbug_remote_hint')
        else:
            address = args[0]

        self.target_connect_remote(address)

    @pynvim.command('DbgLoad', sync=False)
    def dbg_load(self):
        self.gdb.write("-target-download", read_response=False)

    @pynvim.command('DbgBreakpoint', nargs='?', sync=True)
    def dbg_breakpoint_add(self, location):
        if not location:
            line  = self.vim.current.window.api.get_cursor()[0]
            fname = self.vim.current.buffer.api.get_name()
            location = "%s:%d" % (fname, line)

        self.logger.info("Inserting breakpoint @location: %s" % location)
        self.gdb.write("-break-insert %s" % location, read_response=False)
