from vim import VimSign


class Breakpoint(VimSign):
    def __init__(self, filepath, line, number):
        super().__init__(filepath, line, number, "dbg_bp")

    def location(self):
        return "%s:%s" % (self.filepath, self.line)


class BreakpointDB(object):
    def __init__(self):
        # TODO: investigate better solution for storing breakpoints
        self.breakpoints = []

    def add(self, bkpt):
        self.breakpoints.append(bkpt)

    def remove(self, bp):
        self.breakpoints.remove(bp)

    def get(self, location):
        for bp in self.breakpoints:
            if bp.location() == location:
                return bp
