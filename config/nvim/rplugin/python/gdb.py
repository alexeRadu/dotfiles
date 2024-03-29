import logging
from pygdbmi.gdbcontroller import GdbController
import os
import sys
import threading

logger = logging.getLogger("dbug")
error, debug, info, warn = (logger.error, logger.debug, logger.info, logger.warning)

# for adding additional files to this plugin
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from backtrace import Backtrace
from breakpoints import Breakpoint, BreakpointList

class Gdb(object):
    def __init__(self, vim):
        self.vim  = vim
        self.ctrl = None
        self.thread = None
        self.running = False
        self.pc = None
        self.next_watch_no = 1

        # --- watches
        self.watches = {}
        self.watch_buf = self.vim.api.create_buf(True, False)
        self.watch_buf.name = "dbug-watch-expressions"
        self.watch_buf.api.set_option("bt", "nofile")
        #self.watch_buf.api.set_option("readonly", True)
        self.vim.api.buf_set_keymap(self.watch_buf, 'n', 'd', ':DbgWatchDelete<cr>', {'nowait': True})

        self.bt = Backtrace(vim)
        self.bpl = BreakpointList(vim)

    def start(self):
        if self.running:
            self.stop()

        gdb_path = self.vim.vars.get('dbug_gdb_path')
        if not gdb_path or not os.path.isfile(gdb_path):
            self.vim.command("echom \"Dbg: Using the default gdb installation\"")

            # TODO: check if gdb is installed: `which gdb` on Linux (and try on
            # windows as well)
            gdb_path = "gdb"

        self.ctrl = GdbController([gdb_path, "--interpreter=mi3"])

        # Start the thread that listens for responses
        self.thread = threading.Thread(target=self.parse_response)
        self.running = True
        self.thread.start()

        self.ctrl.write("-enable-pretty-printing", read_response=False)

        info("Started GDB debugger %s" % (gdb_path))

    def stop(self):
        # clear the PC sign (if any)
        if self.pc:
            self.vim.command("sign unplace %d" % self.pc["number"])
            self.pc = None

        self.bpl.purge()

        # Stop the listening thread
        self.running = False
        self.thread.join()

        # Gracefully disconnect and exit
        self.target_disconnect()
        self.ctrl.exit()
        self.ctrl = None

        info("GDB debugger has stopped")

    def target_connect_remote(self, remote):
        info("Connecting remotely to %s" % remote)
        self.ctrl.write("-target-select remote %s" % remote, read_response=False)

    def target_disconnect(self):
        info("Disconnecting from target")
        self.ctrl.write("-target-disconnect", read_response=False)

    def load_exec_and_symbol_file(self, fname):
        if not os.path.isfile(fname):
            error("File '%s' doesn't exist" % (fname))

        info("Using '%s' as both executable and symbols file" % fname)
        self.ctrl.write("-file-exec-and-symbols %s" % (fname), read_response=False)

    def download(self):
        self.ctrl.write("-target-download", read_response=False)

    def run(self):
        self.ctrl.write("-exec-run", read_response=False)

    def cont(self):
        self.ctrl.write("-exec-continue", read_response=False)

    def step(self):
        self.ctrl.write("-exec-step", read_response=False)

    def next(self):
        self.ctrl.write("-exec-next", read_response=False)

    ### BREAKPOINTS {{{1
    def bp_toggle(self, fname, line):
        bp = Breakpoint(fname, line)

        if bp in self.bpl:
            bp = self.bpl.remove(bp)
            self.ctrl.write(f"-break-delete {bp.number}", read_response=False)
        else:
            self.ctrl.write(f"-break-insert {str(bp)}", read_response=False)

    def bp_list(self):
        self.ctrl.write("-break-list", read_response=False)

    ### PROGRAM-COUNTER (PC) {{{1
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

        #for no, bp in self.breakpoints.items():
        #    if bp["line"] == pc["line"] and bp["file"] == pc["file"]:
        #        self.vim.command("sign unplace %d" % (no + 2))
        #        break

        self.vim.command("sign place %d line=%d name=dbg_pc file=%s" % (pc['number'], pc['line'], pc['file']))
        self.vim.command("normal! zz")
        debug("Update PC at '%s:%d'" % (pc["file"], pc["line"]))

        # Update the old_pc here because first removing the sing and then placing
        # when in the same file can cause flicker since the gutter is resized
        if old_pc:
            self.vim.command("sign unplace %s" % old_pc['number'])
            #for no, bp in self.breakpoints.items():
            #    if bp["line"] == old_pc["line"] and bp["file"] == old_pc["file"]:
            #        self.vim.command("sign place %d line=%d name=dbg_bp file=%s" % (no + 2, bp['line'], bp['file']))
            #        break


    ### STACK {{{1
    ### Commands {{{2
    def stack_info(self):
        self.ctrl.write("-stack-info-frame", read_response=False)

    def stack_list(self):
        self.ctrl.write("-stack-list-frames", read_response=False)

    ### WATCHES {{{1
    ### Commands {{{2
    def expr_watch(self, expr):
        expr_no = self.next_watch_no
        self.next_watch_no = self.next_watch_no + 1

        expr_name = "var%d" % (expr_no)

        self.watches[expr_no] = {"name": expr_name, "expr": expr}

        self.ctrl.write("-var-create %s @ %s" % (expr_name, expr), read_response=False)

    def expr_update(self):
        self.ctrl.write("-var-update *", read_response=False)

    def watch_del(self, line):
        watch = None
        for n, w in self.watches.items():
            if line == w["line"]:
                watch = w
                del self.watches[n]
                break

        if watch:
            # update line numbers for each watch
            for n, w in self.watches.items():
                if w['line'] > watch['line']:
                    self.watches[n]['line'] = w['line'] - 1

            self._watch_refresh()
            debug("Watch '{:s}' deleted".format(watch["expr"]))
    ### Utilities {{{2
    def _pr_watch(self, watch):
        line = watch['line']
        text = "{:<30s} {:<30s}[{:s}]".format(watch['expr'], watch['value'], watch['type'])
        self.vim.api.buf_set_lines(self.watch_buf, line, line, True, [text])

    def _watch_refresh(self):
        self.vim.api.buf_set_lines(self.watch_buf, 0, -1, False, [])
        for n, w in self.watches.items():
            self._pr_watch(w)

    ### Handles {{{2
    def _update_watches(self, n):
        watch = self.watches[n]

        if 'line' not in watch:
            last_line = 0
            for n, w in self.watches.items():
                if 'line' in w and w['line'] >= last_line:
                    last_line = w['line'] + 1
            self.watches[n]['line'] = last_line
            watch = self.watches[n]

        self._pr_watch(watch)
        info("Updated watch '%s' on line %d" % (watch['expr'], watch['line']))

    def _watch_update(self, var):
        response = self.ctrl.write("-var-evaluate-expression %s" % (var), read_response=True)
        for r in response:
            for k, v in r.items():
                if k in ['payload']:
                    n = int(var.split("var")[1])
                    self.watches[n]["value"] = v['value']
                    self.vim.async_call(self._watch_refresh)

                    debug("Watch's %s value changed to %s" % (var, v['value']))

    ### PRINT FUNCTIONS {{{1
    ### Used for logging messages from GDB; they exist because the string has
    ### to be modified (escaped) before printed to the screen

    def _info(self, hdr, msg):
        if msg:
            for m in msg.split('\\n'):
                m = m.replace('\\"', '"')
                info("%s: %s" % (hdr, m))

    def _debug(self, hdr, msg):
        if msg:
            for m in msg.split('\\n'):
                m = m.replace('\\"', '"')
                debug("%s: %s" % (hdr, m))

    ### PARSING THE RESPONSE {{{1
    ### This function if run by a thread, waits in a loop for messages from GDB
    ### and then calls the corresponding handling functions

    def parse_response(self):
        debug("Started response parser thread")

        while self.running:
            response = self.ctrl.get_gdb_response(timeout_sec=1, raise_error_on_timeout=False)

            # The response is a list of dictionaries with each entry in the list
            # of the form:
            # {'type': '', 'message': '', 'payload': ''}
            #
            # where:
            # type    := 'console' | 'log' | 'output' | 'result' | 'notify'
            # message := None | 'Some message'
            # payload := None | 'Some message' | a dictionary/list carrying more information
            #
            # the other fields are ignored

            for r in response:
                # debug(r)

                # The information that is printed on the screen can be found in the
                # 'message' field (if not None) and in the 'payload' field if it is
                # of string type; additionally it can be found int r['payload']['msg']
                # if 'payload' is a dictionary
                self._info(f"gdb-{r['type']}[m]", r['message'] if r['message'] else None)
                self._info(f"gdb-{r['type']}[p]", r['payload'] if type(r['payload']) == type('') else None)
                self._info(f"gdb-{r['type']}", r['payload']['msg'] if type(r['payload']) == type({}) and 'msg' in r['payload'] else None)

                if r['type'] in ['notify', 'result'] and type(r['payload']) == type({}):
                    # When the 'payload' field is a dictionary is as a response to a command
                    # and carries additional information that is used
                    # The contents of the 'payload' is dependent on the command sent and

                    for k, v in r['payload'].items():
                        # ---> Breakpoints
                        if k in ['bkpt']:
                            bp =  Breakpoint(v['fullname'], int(v['line']), int(v['number']))
                            self.vim.async_call(self.bpl.add, bp)

                        elif k in ['BreakpointTable']:
                            debug('---BreakpointTable')
                            for b in v["body"]:
                                bp =  Breakpoint(b['fullname'], int(b['line']), int(b['number']))

                                if bp not in self.bpl:
                                    self.vim.async_call(self.bpl.add, bp)

                        # ---> Program Counter (PC)
                        elif k in ['frame'] and 'line' in v and 'fullname' in v:
                            pc = {'line': int(v['line']), 'file': v['fullname']}
                            self.vim.async_call(self._update_pc, pc)

                            # Update any watch that may be used
                            self.ctrl.write("-var-update *", read_response=False)

                        # ---> Watches
                        elif k in ['name'] and 'var' in r['payload']['name']:
                            n = int(r['payload']['name'].split('var')[1])

                            self.watches[n]['value'] = r['payload']['value']
                            self.watches[n]['type']  = r['payload']['type']

                            self.vim.async_call(self._update_watches, n)

                        elif k in ['changelist']:
                            for w in v:
                                self._watch_update(w['name'])

                        # ---> Backtrace
                        elif k in ['stack']:
                            self.vim.async_call(self.bt.update, v)

        debug("Response parser thread stopped")

# vim: fdm=marker
