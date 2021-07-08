import logging
import os
import pynvim
import threading
import os
import sys

# for adding additional files to this plugin
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from log import setup_logging
from gdb import Gdb

setup_logging()

logger = logging.getLogger("dbug")
error, debug, info, warn = (logger.error, logger.debug, logger.info, logger.warning)

@pynvim.plugin
class DbugPlugin(object):
    def __init__(self, vim):
        self.vim = vim
        self.gdb = Gdb(vim)

    @pynvim.command('Dbg', sync=True)
    def dbg(self):
        self.gdb.start()

        remote_address = self.vim.vars.get('dbug_remote_hint')
        if remote_address:
            self.gdb.target_connect_remote(remote_address)

        fname = self.vim.vars.get('dbug_file')
        if fname:
            self.gdb.load_exec_and_symbol_file(fname)

        self.gdb.download()
        self.gdb.stack_info()
        self.gdb.bp_list()

    @pynvim.command('DbgAttach', sync=True)
    def dbg_attach(self):
        self.gdb.start()

        remote_address = self.vim.vars.get('dbug_remote_hint')
        if remote_address:
            self.gdb.target_connect_remote(remote_address)

        fname = self.vim.vars.get('dbug_file')
        if fname:
            self.gdb.load_exec_and_symbol_file(fname)

        self.gdb.stack_info()
        self.gdb.bp_list()

    @pynvim.command('DbgStart', sync=True)
    def dbg_start(self):
        self.gdb.start()

    @pynvim.command('DbgStop', sync=False)
    def dbg_stop(self):
        self.gdb.stop()

    @pynvim.command('DbgFile', nargs='?', complete="file", sync=True)
    def dbg_file(self, args):
        if len(args) == 0:
            fname = self.vim.vars.get('dbug_file')
        else:
            fname = args[0]

        self.gdb.load_exec_and_symbol_file(fname)

    @pynvim.command('DbgRemote', nargs='?', sync=True)
    def dbg_remote(self, args):
        if len(args) == 0:
            address = self.vim.vars.get('dbug_remote_hint')
        else:
            address = args[0]

        self.gdb.target_connect_remote(address)

    @pynvim.command('DbgLoad', sync=False)
    def dbg_load(self):
        self.gdb.download()

    @pynvim.command('DbgRun', sync=True)
    def dbg_run(self):
        self.gdb.run()

    @pynvim.command('DbgContinue', sync=True)
    def dbg_continue(self):
        self.gdb.cont()

    @pynvim.command('DbgStep', sync=True)
    def dbg_step(self):
        self.gdb.step()

    @pynvim.command('DbgNext', sync=True)
    def dbg_next(self):
        self.gdb.next()

    @pynvim.command('DbgBreakpoint', sync=True)
    def dbg_breakpoint_toggle(self):
        line  = self.vim.current.window.api.get_cursor()[0]
        fname = self.vim.current.buffer.api.get_name()
        self.gdb.bp_toggle(fname, line)

    @pynvim.command('DbgBreakpointList', sync=True)
    def dbg_breakpoint_list(self):
        self.gdb.bp_list()

    @pynvim.command('DbgWatchExpression', nargs='1', sync=True)
    def dbg_expr_watch(self, args):
        self.gdb.expr_watch(args[0])

    @pynvim.command('DbgExpressionUpdate', sync=True)
    def dbg_expr_update(self):
        self.gdb.expr_update()

    @pynvim.command('DbgWatchDelete', range=True, sync=True)
    def dbg_watch_del(self, args):
        line = int(args[0]) - 1
        self.gdb.watch_del(line)

    @pynvim.command('DbgBacktrace', sync=True)
    def dbg_backtrace(self):
        self.gdb.stack_list()
