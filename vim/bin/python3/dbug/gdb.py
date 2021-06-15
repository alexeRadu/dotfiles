from vim import vim, VimSign
from pygdbmi.gdbcontroller import GdbController
import pprint
import logging

logger = logging.getLogger("__main__")


class Gdb:
    def __init__(self, gdb_path = None):
        if gdb_path:
            self.gdbmi = GdbController([gdb_path, "--interpreter=mi3"])
        else:
            self.gdbmi = GdbController()

        self.pc = VimSign("", "", 1000, "dbg_pc")
        self.bp_number = None
        self.bp_line = None
        self.result = None

        self.timeout = 3

    def __write(self, cmd):
        return self.gdbmi.write(cmd, timeout_sec = self.timeout)

    def file_and_exec_symbols(self, filepath):
        response = self.__write("-file-exec-and-symbols %s" % (filepath))
        logger.info("Response: " + str(response))
        self.__parse_response(response)

        if not self.result or self.result == "error":
            logger.error("GDB unable to load exec and symbols file: %s" % filepath)
            return

        logger.debug("GDB loaded exec and symbols file: %s" % filepath)

    def remote(self, address):
        response = self.__write("-target-select remote %s" % (address))
        self.__parse_response(response)

        if not self.result or self.result == "error":
            logger.error("GDB unable to target remote to %s" % (address))
            return

        logger.debug("GDB connect to remote %s" % (address))

    def load(self):
        response = self.__write("-target-download")
        self.__parse_response(response)

        if self.result and self.result == "error":
            logger.error("GDB unable to do target download")
            return

    def insert_bp(self, location):
        logger.info("Inserting breakpoint @location: " + location)
        response = self.__write("-break-insert %s" % (location))
        self.__parse_response(response)

        if not self.result or self.result == "error":
            return False

        return True

    def delete_bp(self, number):
        logger.info("Deleting breakpoint: " + number)
        response = self.__write("-break-delete %s" % (number))
        self.__parse_response(response)

    def go(self):
        response = self.__write("-exec-continue")
        self.__parse_response(response)

        logger.info("Continue")

    def pause(self):
        #self.gdbmi.interrupt_gdb()
        self.__write("-exec-interrupt --all")
        response = self.gdbmi.get_gdb_response(timeout_sec=self.timeout)
        self.__parse_response(response)
        logger.info("Pause")

    def step(self):
        response = self.__write("-exec-step")
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
                        self.pc.filepath = p["frame"].get("fullname", None)
                        self.pc.line     = p["frame"].get("line", None)

                        if self.pc.filepath and self.pc.line:
                            # open file and move cursor on line
                            vim.execute(":e %s" % (self.pc.filepath))
                            vim.execute(":%s" % (self.pc.line))
                            self.pc.place()

                    if "reason" in p and p["reason"] == "signal-received":
                        vim.echo("GDB: Segmentation fault")
                        pass

                elif r["message"] == "library-loaded":
                    libinfo = r["payload"]
                    logger.debug("Gdb: library loaded: %s" % (libinfo["target-name"]))

                elif r["message"] == "library-unloaded":
                    libinfo = r["payload"]
                    logger.debug("Gdb: library unloaded: %s" % (libinfo["target-name"]))

                elif r["message"] in ["thread-group-exited",
                                      "thread-group-started",
                                      "thread-group-added",
                                      "thread-created",
                                      "thread-exited",
                                      "running",
                                      "breakpoint-modified"]:   # TODO: treat this?
                    pass

                else:
                    unused.append(r)

            elif r["type"] == "log":
                logger.debug("GDB: %s" % (r["payload"]))

            elif r["type"] == "result":
                self.result = r["message"]

                if r["payload"] and "bkpt" in r["payload"]:
                    self.bp_number = r["payload"]["bkpt"].get("number", None)
                    self.bp_line   = r["payload"]["bkpt"].get("line", None)

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

