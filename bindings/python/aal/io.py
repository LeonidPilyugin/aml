from aal.gir import Aal
from aal.wrapper import AalWrapper
from aal.parser import Parser
from aal.data.frame import Frame

class Io(AalWrapper):
    SUPPORTED_TYPES = (Aal.Io, )

    def __init__(self, parser):
        super().__init__()
        self._object = Aal.Io.create(parser._object)

    def load_frames(self, path):
        frames = self._object.load_frames(path)
        for i in range(len(frames)):
            frames[i] = Frame.from_aal(frames[i])
        return frames

    def dump_frames(self, frames, path):
        for i in range(len(frames)):
            frames[i] = frames[i]._object
        self._object.dump_frames(frames, path)

    @property
    def parser(self):
        return Parser.from_aal(self._object.get_parser())

    @parser.setter
    def parser(self, value):
        self._object.set_parser(value._object)
