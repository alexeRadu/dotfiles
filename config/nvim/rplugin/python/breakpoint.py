import logging

logger = logging.getLogger("dbug")
error, debug, info, warn = (logger.error, logger.debug, logger.info, logger.warning)

class Breakpoint(object):
    def __init__(self, file, line, number=0):
        self.file = file
        self.line = line
        self.number = number

    def __repr__(self):
        return f'<breakpoint {self.number} at {self.file}:{self.line}>'

    def __str__(self):
        return f'{self.file}:{self.line}'

    def __eq__(self, other):
        debug("really?!")
        return self.line == other.line and self.file == other.file

    def place(self, vim):
        vim.command(f'sign place {self.number + 2} line={self.line} name=dbg_bp file={self.file}')


class BPList(object):
    def __init__(self, vim):
        self.vim = vim
        self.breakpoints = []

    def __contains__(self, item):
        for bp in self.breakpoints:
            if bp is item:
                return True
        return False

    def place(self):
        pass

    def unplace(self):
        pass

    def add(self, bp):
        self.breakpoints.append(bp)
        bp.place(self.vim)
        debug(f'Adding Breakpoint {bp.number} at {bp}')

    def remove(self, bp):
        pass

    def update(self, bps):
        pass

