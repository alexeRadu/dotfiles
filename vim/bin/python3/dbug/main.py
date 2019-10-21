import logging
from vim import vim, VimSign
from util import BreakpointDB, Breakpoint
import sys


handler = logging.FileHandler('/tmp/dbug.log', 'w')
handler.formatter = logging.Formatter('%(msecs)6d %(levelname)-5s   %(message)s')
logger = logging.getLogger(__name__)
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)


bpdb = BreakpointDB()
from gdb import Gdb


try:
    logger.info("\n\n\n\n\n")

    if len(sys.argv) == 1:
        gdb = Gdb()
        logger.info("GDB server started")
    elif len(sys.argv) == 2:
        gdb_path = sys.argv[1]
        gdb = Gdb(gdb_path = gdb_path)
        logger.info("GDB server started %s" % (gdb_path))

    while True:
        msg = vim.recv_msg()

        if msg["name"] == "file":
            filepath = msg["path"]

            gdb.file_and_exec_symbols(filepath)

        elif msg["name"] == "remote":
            address = msg["address"]

            gdb.remote(address)

        elif msg["name"] == "load":
            gdb.load()

        elif msg["name"] == "toggle-breakpoint":
            filepath = msg["filename"]
            line = msg["line"]
            location = "%s:%d" % (filepath, line)

            bp = bpdb.get(location)

            if not bp:
                if not gdb.insert_bp(location):
                    continue

                location = "%s:%s" % (filepath, gdb.bp_line)

                bp = bpdb.get(location)
                if not bp:
                    bp = Breakpoint(filepath, gdb.bp_line, gdb.bp_number)

                    bp.place()
                    bpdb.add(bp)

                    logger.debug("Added breakpoint at %s:%s" % (bp.filepath, bp.line))
                    continue

                gdb.delete_bp(bp_number)

            if not gdb.delete_bp(bp.number):
                continue

            bp.unplace()
            bpdb.remove(bp)

            logger.debug("Removed breakpoint at %s:%s" % (bp.filepath, bp.line))

        elif msg["name"] == "run":
            if not gdb.insert_bp("main"):
                continue

            bp_number = gdb.bp_number

            gdb.go()
            gdb.delete_bp(bp_number)

        elif msg["name"] == "continue":
            gdb.go()

        elif msg["name"] == "step":
            gdb.step()

        elif msg["name"] == "run-untill":
            filepath = msg["filename"]
            line = msg["line"]
            location = "%s:%d" % (filepath, line)

            if not gdb.insert_bp(location):
                continue

            bp_number = gdb.bp_number

            gdb.go()
            gdb.delete_bp(bp_number)

        else:
            logger.debug("Unknown message name: " + msg["name"])

except:
    logger.exception("Unexpected exception")
