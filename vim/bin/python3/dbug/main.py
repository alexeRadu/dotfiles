from pygdbmi.gdbcontroller import GdbController
import logging
import pprint
from vim import Vim


handler = logging.FileHandler('/tmp/dbug.log', 'w')
handler.formatter = logging.Formatter('%(msecs)6d %(levelname)-5s   %(message)s')
logger = logging.getLogger(__name__)
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)

gdbmi = GdbController()
vim = Vim()

vim.echo("GDB server started")
logger.info("\n\n\n\n\n")
logger.info("GDB server started")


class Breakpoint(object):
    def __init__(self, filepath, line, number):
        self.filepath = filepath
        self.line     = str(line)
        self.number   = str(number)

    def location(self):
        return "%s:%s" % (self.filepath, self.line)

    def place(self):
        expr = "sign place %s line=%s name=dbg_bp file=%s" % (self.number, self.line, self.filepath)
        vim.execute(expr)
        vim.redraw()

    def unplace(self):
        expr = "sign unplace %s" % (self.number)
        vim.execute(expr)
        vim.redraw()


class BreakpointDB(object):
    def __init__(self):
        # TODO: investigate better solution for storing breakpoints
        self.breakpoints = []

    def add(self, bkpt):
        self.breakpoints.append(bkpt)

    def remove(self, bp):
        self.breakpoints.remove(bp)

    def get(self, location):
        for bp in self.breakpoints:
            if bp.location() == location:
                return bp

bpdb = BreakpointDB()

gdb_is_running = False
gdb_is_debugging = False
bp_number = None
bp_line = None
result = None
pc = None

def parse_response(response):
    global result
    global bp_number
    global bp_line

    unused = []
    result = None
    bp_number = None
    bp_line = None

    for r in response:
        if r["type"] == "notify":
            if r["message"] == "stopped":
                gdb_is_running = False
            elif r["message"] == "running":
                gdb_is_running = True
            elif r["message"] == "library-loaded":
                libinfo = r["payload"]
                logger.debug("Gdb: library loaded: %s" % (libinfo["target-name"]))
            elif r["message"] == "library-unloaded":
                libinfo = r["payload"]
                logger.debug("Gdb: library unloaded: %s" % (libinfo["target-name"]))
            elif r["message"] == "thread-created":
                gdb_is_debugging = True
                logger.debug("Gdb: started debugging")
            elif r["message"] == "thread-exited":
                gdb_is_debugging = False
                logger.debug("Gdb: debugging stopped")
            elif r["message"] in ["thread-group-exited",
                                  "thread-group-started",
                                  "thread-group-added",
                                  "breakpoint-modified"]:   # TODO: treat this?
                pass
            else:
                unused.append(r)

        elif r["type"] == "log":
            logger.debug("GDB: %s" % (r["payload"]))

        elif r["type"] == "result":
            result = r["message"]

            if r["payload"] and "bkpt" in r["payload"]:
                bp_number = r["payload"]["bkpt"]["number"]
                bp_line = r["payload"]["bkpt"]["line"]

        elif r["type"] == "console":
            # ignore cosole output for now
            pass

        else:
            unused.append(r)

    if unused:
        logger.debug("From GDB - not treated:\n" + pprint.pformat(unused))


try:
    while True:
        msg = vim.recv_msg()

        if msg["name"] == "load-target":
            filepath = msg["path"]

            response = gdbmi.write("-file-exec-and-symbols %s" % (filepath))
            parse_response(response)

            if not result or result == "error":
                logger.error("GDB unable to load exec and symbols file: %s" % filepath)
                continue

            logger.debug("GDB loaded exec and symbols file: %s" % filepath)

        elif msg["name"] == "toggle-breakpoint":
            filepath = msg["filename"]
            line = msg["line"]
            location = "%s:%d" % (filepath, line)

            bp = bpdb.get(location)

            if not bp:
                response = gdbmi.write("-break-insert %s" % (location))
                parse_response(response)

                if not result or result == "error":
                    continue

                location = "%s:%s" % (filepath, bp_line)

                bp = bpdb.get(location)
                if not bp:
                    bp = Breakpoint(filepath, bp_line, bp_number)

                    bp.place()
                    bpdb.add(bp)

                    logger.debug("Added breakpoint at %s:%s" % (bp.filepath, bp.line))

                    continue

                gdbmi.write("-break-remove %s" % (bp_number))
                parse_response(response)

            response = gdbmi.write("-break-delete %s" % (bp.number))
            parse_response(response)

            if not result or result == "error":
                continue

            bp.unplace()
            bpdb.remove(bp)

            logger.debug("Removed breakpoint at %s:%s" % (bp.filepath, bp.line))

        elif msg["name"] == "continue":

            if not gdb_is_debugging:
                cmd = "-exec-run"
            else:
                cmd = "-exec-continue"

            response = gdbmi.write(cmd)
            parse_response(response)

        else:
            logger.debug("Unknown message name: " + msg["name"])

except:
    logger.exception("Unexpected exception")
