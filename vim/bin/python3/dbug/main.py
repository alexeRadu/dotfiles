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
    def __init__(self, filepath, line):
        self.filepath = filepath
        self.line     = line
        self.number   = None

    def location(self):
        return "%s:%d" % (self.filepath, self.line)

    def insert(self):
        global bkpt_info

        response = gdbmi.write("-break-insert %s" % (bp.location()))
        parse_response(response)

        if bkpt_info:
            self.number = bkpt_info["number"]

    def inserted(self):
        return True if self.number != None else False

    def remove(self):
        response = gdbmi.write("-break-delete %s" % (self.number))
        parse_response(response)

    def place(self):
        expr = "sign place %s line=%d name=dbg_bp file=%s" % (self.number, self.line, self.filepath)
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

    def get(self, filepath, line):
        bkpt = Breakpoint(filepath, line)

        for bp in self.breakpoints:
            if bp.location() == bkpt.location():
                return bp

        self.breakpoints.append(bkpt)
        return bkpt

    def remove(self, bp):
        self.breakpoints.remove(bp)

bpdb = BreakpointDB()

gdb_is_running = False
gdb_is_debugging = False
bkpt_info = None
result = None
pc = None

def parse_response(response):
    global result
    global bkpt_info

    unused = []
    result = None
    bkpt_info = None

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
                bkpt_info = r["payload"]["bkpt"]
                unused.append(r)

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

            bp = bpdb.get(filepath, line)

            if not bp.inserted():
                bp.insert()

                if not result or result == "error":
                    continue

                bp.place()
            else:
                bp.remove()

                if not result or result == "error":
                    continue

                bp.unplace()
                bpdb.remove(bp)

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
