import json
import sys


class VimError(Exception):
    """ Exception returned by Vim class"""
    pass


class Vim:
    """
    This class is a convenience class to interface with vim editor. There are
    two types of informations exchanges:
     * messages (from vim)
     * commands (to vim)

    Messages are sent by vim when using the function ch_sendexpr(). They
    have the format:
        [{number}, {expr}]

    where number is incrementing each message sent. If the server sends a
    response it should have the same number and the format:
        [{number}, {response}]

    Commands are sent by the server to vim using the json format. There are
    several commands that vim supports but we only use the following:
        ["ex",      {ex_command}]
        ["expr",    {expression}]
        ["call",    {func}, {arg_list}]

    The last two types have also the variant:
        ["expr",    {expression}, {number}]
        ["call",    {func}, {arg_list}, {number}]

    where number is a negative integer that is decremented each subsequent
    command. In this case a response can be sent by vim in the form:
        [{number}, {response}]

    where {number} represents the same negative index sent in the command.
    """

    def __init__(self):
        self.msg_buffer = []    # stored messages
        self.rsp_buffer = []    # stored command responses
        self.msg_index  =  1    # next expected message index
        self.rsp_index  = -1    # next expected command response

    def _read(self):
        index, data = json.loads(sys.stdin.readline())

        if index == 0:
            raise VimError("received vim message with index 0")

        if index < 0:   # This is a command response
            if index != self.rsp_index:
                raise VimError("received vim command response with index %d; expecting %d" % (index, self.rsp_index))

            self.rsp_buffer.insert(0, data)

        else:           # This is a message
            if index != self.msg_index:
                raise VimError("received vim message with index %d; expecting %d" % (index, self.msg_index))

            self.msg_buffer.insert(0, data)
            self.msg_index += 1

    def recv_msg(self):
        while not self.msg_buffer:
            self._read()

        return self.msg_buffer.pop()

    def recv_rsp():
        while not self.rsp_buffer:
            self._read()

        return self.cmd_buffer.pop()

    def _write(self, cmd):
        print(json.dumps(cmd), file=sys.stdout)
        sys.stdout.flush()

    def redraw(self, arg=""):
        cmd = ["redraw", arg]
        self._write(cmd)

    def execute(self, expr):
        cmd = ["ex", expr]
        self._write(cmd)

    def eval(self, expr, reply=True):
        cmd = ["expr", expr]

        if reply:
            self.rsp_index -= 1
            cmd.append(self.rsp_index)

        self._write(cmd)

        if reply:
            return self.recv_rsp()

    def call(self, func, *args, reply=True):
        cmd = ["call", func, args]

        if reply:
            self.rsp_index -= 1
            cmd.append(self.rsp_index)

        self._write(cmd)

        if reply:
            return self.recv_rsp()

    def echo(self, msg):
        self.execute("echo \"{}\"".format(msg))
