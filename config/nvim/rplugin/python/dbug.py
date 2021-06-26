import logging
import os
import pynvim
import threading
from pygdbmi.gdbcontroller import GdbController
import os
import sys

# for adding additional files to this plugin
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from log import setup_logging

setup_logging()

logger = logging.getLogger("dbug")
error, debug, info, warn = (logger.error, logger.debug, logger.info, logger.warning)

@pynvim.plugin
class DbugPlugin(object):
    def __init__(self, vim):
        self.vim = vim
        self.gdb = None
        self.thread = None
        self.run = False
        self.breakpoints = {}
        self.pc = None

    def target_connect_remote(self, remote):
        info("Connecting remotely to %s" % remote)
        self.gdb.write("-target-select remote %s" % remote, read_response=False)

    def target_disconnect(self):
        info("Disconnecting from target")
        self.gdb.write("-target-disconnect", read_response=False)

    def load_exec_and_symbol_file(self, fname):
        if not os.path.isfile(fname):
            error("File '%s' doesn't exist" % (fname))

        info("Using '%s' as both executable and symbols file" % fname)
        self.gdb.write("-file-exec-and-symbols %s" % (fname), read_response=False)

    def gdb_start(self):
        gdb_path = self.vim.vars.get('dbug_gdb_path')
        if not gdb_path or not os.path.isfile(gdb_path):
            self.vim.command("echom \"Dbg: Using the default gdb installation\"")

            # TODO: check if gdb is installed: `which gdb` on Linux (and try on
            # windows as well)
            gdb_path = "gdb"

        self.gdb = GdbController([gdb_path, "--interpreter=mi3"])

        # Start the thread that listens for responses
        self.thread = threading.Thread(target=self.parse_response)
        self.run = True
        self.thread.start()

        info("Started GDB debugger %s" % (gdb_path))

    def gdb_stop(self):
        # Stop the listening thread
        self.run = False
        self.thread.join()

        # Gracefully disconnect and exit
        self.target_disconnect()
        self.gdb.exit()
        self.gdb = None

        info("GDB debugger has stopped")

    def _pr_msg(self, hdr, messages):
        for msg in messages.split('\\n'):
            msg = msg.replace('\\"', '"')
            debug("%s: %s" % (hdr, msg))

    def _place_bp(self, no, bp):
        self.vim.command("sign place %d line=%d name=dbg_bp file=%s" % (no + 2, bp['line'], bp['file']))
        info("Placed breakpoint '%d' at '%s:%d'" % (no, bp['file'], bp['line']))

    def _update_pc(self, pc):
        old_pc = None
        if self.pc:
            old_pc = self.pc
            pc["number"] = (old_pc["number"] % 2) + 1
        else:
            pc["number"] = 1

        self.pc = pc

        buf_is_open = False
        for buf in self.vim.api.list_bufs():
            if buf.name == pc['file']:
                self.vim.api.win_set_buf(0, buf)
                self.vim.api.win_set_cursor(0, (pc['line'], 0))
                buf_is_open = True
                break

        if not buf_is_open:
            self.vim.command("e %s" % pc['file'])
            self.vim.api.win_set_cursor(0, (pc['line'], 0))

        for no, bp in self.breakpoints.items():
            if bp["line"] == pc["line"] and bp["file"] == pc["file"]:
                self.vim.command("sign unplace %d" % (no + 2))
                break

        self.vim.command("sign place %d line=%d name=dbg_pc file=%s" % (pc['number'], pc['line'], pc['file']))
        self.vim.command("normal! zz")
        debug("Update PC at '%s:%d'" % (pc["file"], pc["line"]))

        # Update the old_pc here because first removing the sing and then placing
        # when in the same file can cause flicker since the gutter is resized
        if old_pc:
            self.vim.command("sign unplace %s" % old_pc['number'])
            for no, bp in self.breakpoints.items():
                if bp["line"] == old_pc["line"] and bp["file"] == old_pc["file"]:
                    self.vim.command("sign place %d line=%d name=dbg_bp file=%s" % (no + 2, bp['line'], bp['file']))
                    break

    def parse_response(self):
        debug("Started response parser thread")

        while self.run:
            response = self.gdb.get_gdb_response(timeout_sec=5, raise_error_on_timeout=False)
            if response:
                for r in response:
                    if r['type'] in ['console', 'log', 'output']:
                        self._pr_msg("gdb-%s" % r['type'], r['message'] or r['payload'])

                    elif r['type'] in ['notify', 'result']:
                        self._pr_msg("gdb-%s" % r['type'], r['message'])

                        if r['payload']:
                            for k, v in r['payload'].items():
                                if k in ['bkpt']:
                                    bkpt_no = int(v['number'])
                                    bkpt = {'line': int(v['line']), 'file': v['fullname']}

                                    self.breakpoints[bkpt_no] = bkpt
                                    self.vim.async_call(self._place_bp, bkpt_no, bkpt)
                                elif k in ['frame']:
                                    if 'line' in v and 'fullname' in v:
                                        # info("%s: %s" % (k, str(v)))
                                        pc = {'line': int(v['line']), 'file': v['fullname']}
                                        self.vim.async_call(self._update_pc, pc)
                                elif k in ['msg']:
                                    self._pr_msg("gdb-%s" % r['type'], v)
                                else:
                                    pass
                                    #debug("%s: %s" % (k, str(v)))
                    else:
                        pass
                        #debug(str(r))

        debug("Response parser thread stopped")

    @pynvim.command('Dbg', sync=True)
    def dbg(self):
        self.gdb_start()

        remote_address = self.vim.vars.get('dbug_remote_hint')
        if remote_address:
            self.target_connect_remote(remote_address)

        fname = self.vim.vars.get('dbug_file')
        if fname:
            self.load_exec_and_symbol_file(fname)

        load_on_start = self.vim.vars.get('dbug_load_on_start')
        if load_on_start:
            self.dbg_load()

    @pynvim.command('DbgStop', sync=False)
    def dbg_stop(self):
        if self.pc:
            self.vim.command("sign unplace %d" % self.pc["number"])
            self.pc = None

        if len(self.breakpoints):
            for no in self.breakpoints:
                self.vim.command("sign unplace %d" % (no + 2))
        self.breakpoints = {}

        self.gdb_stop()


    @pynvim.command('DbgFile', nargs='?', complete="file", sync=True)
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

    @pynvim.command('DbgRun', sync=True)
    def dbg_run(self):
        self.gdb.write("-exec-continue", read_response=False)

    @pynvim.command('DbgStep', sync=True)
    def dbg_step(self):
        self.gdb.write("-exec-step", read_response=False)

    @pynvim.command('DbgNext', sync=True)
    def dbg_next(self):
        self.gdb.write("-exec-next", read_response=False)

    @pynvim.command('DbgBreakpoint', sync=True)
    def dbg_breakpoint_toggle(self):
        line  = self.vim.current.window.api.get_cursor()[0]
        fname = self.vim.current.buffer.api.get_name()
        location = "%s:%d" % (fname, line)

        for no, bp in self.breakpoints.items():
            if bp['line'] == line and bp['file'] == fname:
                info("Removing breakpoint %d at '%s'" % (no, location))
                self.gdb.write("-break-delete %d" % no, read_response=False)
                self.vim.command("sign unplace %d" % (no + 2))
                del self.breakpoints[no]
                return

        info("Inserting breakpoint at '%s'" % location)
        self.gdb.write("-break-insert %s" % location, read_response=False)
