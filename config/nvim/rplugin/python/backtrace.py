import logging

logger = logging.getLogger("dbug")
error, debug, info, warn = (logger.error, logger.debug, logger.info, logger.warning)

class Backtrace(object):
    def __init__(self, vim):
        self.vim = vim

        self.buf = self.vim.api.create_buf(True, False)
        self.buf.name = "dbug-backtrace"
        self.buf.api.set_option("bt", "nofile")

    def update(self, data):
        # clear window
        self.vim.api.buf_set_lines(self.buf, 0, -1, False, [])

        n = 0
        for line in data:
            text = "{:<30s} {:<s}:{:s}".format(line['func'], line['file'], line['line'])
            self.vim.api.buf_set_lines(self.buf, n, n, True, [text])
            n = n + 1
            #debug("--> " + str(line))

