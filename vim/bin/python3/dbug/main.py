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

        elif msg["name"] == "set-breakpoint":
            location = msg["filename"] + ":" +  str(msg["line"])
            response = gdbmi.write("-break-insert " + location)
            logger.debug("gdb response: \n" + pprint.pformat(response))

            result = get_result(response)
            if result["message"] == "done":
                expr = "sign place 1 line=%d name=dbg_bp file=%s" % (msg["line"], msg["filename"])
                vim.execute(expr)
                vim.redraw()
        else:
            logger.debug("Unknown message name: " + msg["name"])

except:
    logger.exception("Unexpected exception")
