from select import select
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

vim_echo("GDB server started")
logger.info("GDB server started")

while True:
    ready, _, _ = select([sys.stdin], [], [], 2)

    if not ready:
        continue

    index, msg = json.loads(sys.stdin.readline())

    msg = str(msg)
    logger.debug("Rcvd: %d - %s" % (index, msg))

    vim_echo(msg)
