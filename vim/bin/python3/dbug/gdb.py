from vim import vim, VimSign
from pygdbmi.gdbcontroller import GdbController
import pprint
import logging

logger = logging.getLogger("__main__")


class Gdb:
    def __init__(self, gdb_path = None):
        if gdb_path:
            self.gdbmi = GdbController(gdb_path)
        else:
            self.gdbmi = GdbController()

        self.pc = VimSign("", "", 1000, "dbg_pc")
        self.bp_number = None
        self.bp_line = None
        self.result = None

    def file_and_exec_symbols(self, filepath):
        response = self.gdbmi.write("-file-exec-and-symbols %s" % (filepath))
        self.__parse_response(response)

        if not self.result or self.result == "error":
            logger.error("GDB unable to load exec and symbols file: %s" % filepath)
            return

        logger.debug("GDB loaded exec and symbols file: %s" % filepath)

    def target_remote(self, address):
        response = self.gdbmi.write("-target-select remote %s" % (address))
        self.__parse_response(response)

        if not self.result or self.result == "error":
            logger.error("GDB unable to target remote to %s" % (address))
            return

        logger.debug("GDB connect to remote %s" % (address))

    def target_load(self):
        response = self.gdbmi.write("-target-download")
        self.__parse_response(response)

        if self.result and self.result == "error":
            logger.error("GDB unable to do target download")
            return

        logger

    def insert_bp(self, location):
        response = self.gdbmi.write("-break-insert %s" % (location))
        self.__parse_response(response)

        if not self.result or self.result == "error":
            return False

        return True

    def delete_bp(self, number):
        response = self.gdbmi.write("-break-delete %s" % (number))
        self.__parse_response(response)

    def go(self):
        response = self.gdbmi.write("-exec-continue")
        self.__parse_response(response)

        logger.info("Continue")

    def step(self):
        response = self.gdbmi.write("-exec-step")
        self.__parse_response(response)

        logger.info("Step")

    def __parse_response(self, response):
        global vim

        unused = []
        self.result = None
        self.bp_number = None
        self.bp_line = None

        for r in response:
            if r["type"] == "notify":
                if r["message"] == "stopped":
                    p = r["payload"]

                    if 'frame' in p:
                        self.pc.filepath = p["frame"]["fullname"]
                        self.pc.line     = p["frame"]["line"]

                        # open file and move cursor on line
                        vim.execute(":e %s" % (self.pc.filepath))
                        vim.execute(":%s" % (self.pc.line))
                        self.pc.place()

                    if "reason" in p and p["reason"] == "signal-received":
                        vim.echo("GDB: Segmentation fault")
                        pass

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
                self.result = r["message"]

                if r["payload"] and "bkpt" in r["payload"]:
                    self.bp_number = r["payload"]["bkpt"]["number"]
                    self.bp_line   = r["payload"]["bkpt"]["line"]

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

