from aal.gir import Aal
from aal.wrapper import AalWrapper

class Parser(AalWrapper):
    SUPPORTED_TYPES = (Aal.LammpsTextDumpParser, )

    def __init__(self):
        super().__init__()

    @classmethod
    def lammps(cls):
        res = cls()
        res._object = Aal.LammpsTextDumpParser()
        return res
