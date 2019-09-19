from select import select
from pygdbmi.gdbcontroller import GdbController
import logging
import json
import sys



def vim_echo(msg):
    cmd = ["ex", "echo \"{}\"".format(msg)]
    print(json.dumps(cmd), file=sys.stdout)
    sys.stdout.flush()

handler = logging.FileHandler('/tmp/dbug.log', 'w')
handler.formatter = logging.Formatter('%(msecs)6d %(levelname)-5s   %(message)s')
logging.root.addHandler(handler)
logging.root.setLevel(logging.DEBUG)

logger = logging.getLogger(__name__)

gdbmi = GdbController()

vim_echo("GDB server started")
logger.info("GDB server started")

while True:
    ready, _, _ = select([sys.stdin], [], [], 2)

    if not ready:
        continue

    index, msg = json.loads(sys.stdin.readline())

    logger.debug("Rcvd: %d - %s" % (index, str(msg)))
    vim_echo(str(msg))

    if type(msg) is dict and "type" in msg and msg["type"] == "gdb":
        response = gdbmi.write(msg["cmd"])
        logger.debug("gdb response: " + str(response))

