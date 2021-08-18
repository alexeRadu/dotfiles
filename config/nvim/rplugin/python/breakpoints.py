import logging

logger = logging.getLogger("dbug")
error, debug, info, warn = (logger.error, logger.debug, logger.info, logger.warning)


class Breakpoint(object):
    def __init__(self, filename, line, number=None):
        self.filename = filename
        self.line = line
        self.number = number

    def __repr__(self):
        return f"{self.filename}:{self.line}"

    def __eq__(self, bp):
        return self.filename == bp.filename and self.line == bp.line

    def update(self, desc):
        pass

    def place(self, vim):
        vim.command(f"sign place {self.number + 2} line={self.line} name=dbg_bp file={self.filename}")

    def unplace(self, vim):
        vim.command(f"sign unplace {self.number + 2}")


class BreakpointList(object):
    def __init__(self, vim):
        self.vim = vim
        self.bps = []

        self.buf = self.vim.api.create_buf(True, False)
        self.buf.name = "dbug-breakpoints"
        self.buf.api.set_option("bt", "nofile")

    def __contains__(self, bp):
        for b in self.bps:
            if bp == b:
                return True

        return False

    def remove(self, bp):
        for b in self.bps:
            if bp == b:
                self.bps.remove(b)
                b.unplace(self.vim)
                self.refresh()
                return b

    def add(self, bp):
        self.bps.append(bp)
        bp.place(self.vim)
        info(f"Breakpoint inserted at '{str(bp)}'")

        self.refresh()

    def purge(self):
        for b in self.bps:
            b.unplace(self.vim)
        self.bps = []

        self.vim.api.buf_set_lines(self.buf, 0, -1, False, [])

    def refresh(self):
        self.vim.api.buf_set_lines(self.buf, 0, -1, False, [])

        debug('refresh')

        line = 0
        for bp in self.bps:
            text = f"{bp.number}  {str(bp)}"
            self.vim.api.buf_set_lines(self.buf, line, line, True, [text])
            line = line + 1
