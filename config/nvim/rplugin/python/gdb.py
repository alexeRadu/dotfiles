import logging
from pygdbmi.gdbcontroller import GdbController
import os
import threading

logger = logging.getLogger("dbug")
error, debug, info, warn = (logger.error, logger.debug, logger.info, logger.warning)

class Gdb(object):
    def __init__(self, vim):
        self.vim  = vim
        self.ctrl = None
        self.thread = None
        self.running = False
        self.breakpoints = {}
        self.pc = None
        self.next_watch_no = 1
        self.watches = {}
        self.watch_buf = self.vim.api.create_buf(True, False)
        self.watch_buf.name = "dbug-watch-expressions"
        self.vim.api.buf_set_keymap(self.watch_buf, 'n', '<leader>d', ':DbgWatchDelete<cr>', {'nowait': True})

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

        # clear all breakpoint signs (if any)
        if len(self.breakpoints):
            for no in self.breakpoints:
                self.vim.command("sign unplace %d" % (no + 2))
        self.breakpoints = {}

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

    def bp_toggle(self, fname, line):
        location = "%s:%d" % (fname, line)

        for no, bp in self.breakpoints.items():
            if bp['line'] == line and bp['file'] == fname:
                info("Removing breakpoint %d at '%s'" % (no, location))
                self.ctrl.write("-break-delete %d" % no, read_response=False)
                self.vim.command("sign unplace %d" % (no + 2))
                del self.breakpoints[no]
                return

        info("Inserting breakpoint at '%s'" % location)
        self.ctrl.write("-break-insert %s" % location, read_response=False)

    def bp_list(self):
        self.ctrl.write("-break-list", read_response=False)

    def stack_info(self):
        self.ctrl.write("-stack-info-frame", read_response=False)

    def expr_watch(self, expr):
        expr_no = self.next_watch_no
        self.next_watch_no = self.next_watch_no + 1

        expr_name = "var%d" % (expr_no)

        self.watches[expr_no] = {"name": expr_name, "expr": expr}

        self.ctrl.write("-var-create %s @ %s" % (expr_name, expr), read_response=False)

    def expr_update(self):
        self.ctrl.write("-var-update *", read_response=False)

    def _pr_watch(self, watch):
        line = watch['line']
        text = "{:<30s} {:<30s}[{:s}]".format(watch['expr'], watch['value'], watch['type'])
        self.vim.api.buf_set_lines(self.watch_buf, line, line, True, [text])

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

            # clear buffer
            nlines = self.vim.api.buf_line_count(self.watch_buf)
            self.vim.api.buf_set_lines(self.watch_buf, 0, nlines - 1, False, [])

            # update with remaining watches
            for n, w in self.watches.items():
                self._pr_watch(w)

            debug("Watch '{:s}' deleted".format(watch["expr"]))

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

    def parse_response(self):
        debug("Started response parser thread")

        while self.running:
            response = self.ctrl.get_gdb_response(timeout_sec=1, raise_error_on_timeout=False)
            if response:
                for r in response:
                    if r['type'] in ['console', 'log', 'output']:
                        self._pr_msg("gdb-%s" % r['type'], r['message'] or r['payload'])

                    elif r['type'] in ['notify', 'result']:
                        self._pr_msg("gdb-%s" % r['type'], r['message'])

                        if r['payload']:
                            #debug("%s" % (r['payload']))

                            if 'name' in r['payload'] and 'var' in r['payload']['name']:
                                n = int(r['payload']['name'].split('var')[1])

                                self.watches[n]['value'] = r['payload']['value']
                                self.watches[n]['type']  = r['payload']['type']

                                self.vim.async_call(self._update_watches, n)

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
                                elif k in ['BreakpointTable']:
                                    for bp in v["body"]:
                                        bp_no = int(bp['number'])
                                        bp = {'line': int(bp['line']), 'file': bp['fullname']}

                                        if bp_no not in self.breakpoints:
                                            self.breakpoints[bp_no] = bp
                                            self.vim.async_call(self._place_bp, bp_no, bp)
                                        else:
                                            debug("Breakpoint %d already set '%s:%d'" % (bp_no, bp['file'], bp['line']))
                                elif k in ['msg']:
                                    self._pr_msg("gdb-%s" % r['type'], v)
                                else:
                                    pass
                                    #debug("%s: %s" % (k, str(v)))
                    else:
                        pass
                        #debug(str(r))
        debug("Response parser thread stopped")
