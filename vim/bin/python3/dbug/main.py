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

try:
    while True:
        msg = vim.recv_msg()

        if msg["name"] == "load-target":
            response = gdbmi.write("-file-exec-and-symbols " + msg["path"])
            logger.debug("gdb response: \n" + pprint.pformat(response))

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
        else:
            logger.debug("Unknown message name: " + msg["name"])

except:
    logger.exception("Unexpected exception")