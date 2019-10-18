from pygdbmi.gdbcontroller import GdbController
import logging
import pprint
from vim import Vim
import sys


handler = logging.FileHandler('/tmp/dbug.log', 'w')
handler.formatter = logging.Formatter('%(msecs)6d %(levelname)-5s   %(message)s')
logger = logging.getLogger(__name__)
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)


logger.info("\n\n\n\n\n")

try:
    if len(sys.argv) == 1:
        gdbmi = GdbController()
        logger.info("GDB server started")
    elif len(sys.argv) == 2:
        gdb_path = sys.argv[1]
        gdbmi = GdbController(gdb_path = gdb_path)
        logger.info("GDB server started %s" % (gdb_path))
except:
    logger.exception("Unexpected exception")


vim = Vim()

class VimSign():
    def __init__(self, filepath, line, number, name):
        self.filepath = filepath
        self.line     = str(line)
        self.number   = str(number)
        self.name     = name
        self.placed    = False

    def place(self):
        if self.placed:
            self.unplace()

        expr = "sign place %s line=%s name=%s file=%s" % (self.number, self.line, self.name, self.filepath)
        vim.execute(expr)
        vim.redraw()

        self.placed = True

    def unplace(self):
        if self.placed:
            expr = "sign unplace %s" % (self.number)
            vim.execute(expr)
            vim.redraw()

            self.placed = False


class Breakpoint(VimSign):
    def __init__(self, filepath, line, number):
        super().__init__(filepath, line, number, "dbg_bp")

    def location(self):
        return "%s:%s" % (self.filepath, self.line)


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

bp_number = None
bp_line = None
result = None
pc = VimSign("", "", 1000, "dbg_pc")

def parse_response(response):
    global result
    global bp_number
    global bp_line
    global pc

    unused = []
    result = None
    bp_number = None
    bp_line = None

    for r in response:
        if r["type"] == "notify":
            if r["message"] == "stopped":
                p = r["payload"]

                if 'frame' in p:
                    pc.filepath = p["frame"]["fullname"]
                    pc.line     = p["frame"]["line"]

                    pc.place()

                if "reason" in p and p["reason"] == "signal-received":
                    vim.echo("GDB: Segmentation fault")
                    pass

                unused.append(r)


            elif r["message"] == "running":
                pass

            elif r["message"] == "library-loaded":
                libinfo = r["payload"]
                logger.debug("Gdb: library loaded: %s" % (libinfo["target-name"]))

            elif r["message"] == "library-unloaded":
                libinfo = r["payload"]
                logger.debug("Gdb: library unloaded: %s" % (libinfo["target-name"]))

            elif r["message"] == "thread-created":
                logger.debug("Gdb: started debugging")

            elif r["message"] == "thread-exited":
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

        elif r["type"] == "output":
            if r["stream"] == "stdout":
                logger.info("%s" % (r["payload"]))

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

        elif msg["name"] == "target-remote":
            remote = msg["remote"]
            port = msg["port"]
            address = "%s:%s" % (remote, port)

            response = gdbmi.write("-target-select remote %s" % (address))
            parse_response(response)

            if not result or result == "error":
                logger.error("GDB unable to target remote to %s" % (address))
                continue

            logger.debug("GDB connect to remote %s" % (address))

        elif msg["name"] == "target-load":
            response = gdbmi.write("-target-download")
            parse_response(response)

            if result and result == "error":
                logger.error("GDB unable to do target download")
                continue

            logger.debug("GDB target download successfully")

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
            response = gdbmi.write("-exec-continue")
            parse_response(response)

            logger.info("Continue")

        else:
            logger.debug("Unknown message name: " + msg["name"])

except:
    logger.exception("Unexpected exception")
