from select import select
import json
import sys



def vim_echo(msg):
    cmd = ["ex", "echo \"{}\"".format(msg)]
    print(json.dumps(cmd), file=sys.stdout)
    sys.stdout.flush()

vim_echo("GDB server started")

while True:
    ready, _, _ = select([sys.stdin], [], [], 2)

    if not ready:
        continue

    index, msg = json.loads(sys.stdin.readline())
    msg = str(msg)

    vim_echo(msg)
