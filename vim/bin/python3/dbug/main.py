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

class BreakpointDB(object):
    def __init__(self):
        self.breakpoints = []

    def __contains__(self, item):
        for bp in self.breakpoints:
            if bp["filename"] == item["filename"] and bp["line"] == item["line"]:
                return True

        return False

    def get(self, item):
        for bp in self.breakpoints:
            if bp["filename"] == item["filename"] and bp["line"] == item["line"]:
                self.breakpoints.remove(bp)
                return bp

        return None

    def add(self, bp):
        self.breakpoints.append(bp)


bpdb = BreakpointDB()


def get_result(response):
    for msg in response:
        if msg["type"] == "result":
            return msg

gdb_is_running = False
gdb_is_debugging = False
result = None
pc = None

def parse_response(response):
    global result

    unused = []
    result = None

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
            if msg not in bpdb:
                location = msg["filename"] + ":" +  str(msg["line"])
                response = gdbmi.write("-break-insert " + location)
                logger.debug("gdb response: \n" + pprint.pformat(response))

                result = get_result(response)
                if result["message"] != "done":
                    continue

                bp = {"filename": msg["filename"], "line": msg["line"]}
                bp["number"] = int(result["payload"]["bkpt"]["number"])
                bpdb.add(bp)

                expr = "sign place %d line=%d name=dbg_bp file=%s" % (bp["number"], bp["line"], bp["filename"])
                vim.execute(expr)
                vim.redraw()

            else:
                bp = bpdb.get(msg)

                response = gdbmi.write("-break-delete %d" % (bp["number"]))
                logger.debug("gdb response: \n" + pprint.pformat(response))

                result = get_result(response)
                if result["message"] != "done":
                    continue

                expr = "sign unplace %d" % (bp["number"])
                vim.execute(expr)
                vim.redraw()
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
