from aal.gir import Aal
from aal.wrapper import AalWrapper

class Atom(AalWrapper):
    SUPPORTED_TYPES = (Aal.Atom, )
    
    def __init__(self):
        super().__init__()
        self._object = Aal.Atom.create()

    def __getitem__(self, key):
        return self._object.get_prop(key)

    def __setitem__(self, key, value):
        self._object.set_prop(key, value)

    def __delitem__(self, key):
        self._object.del_prop(key)

    @property
    def keys(self):
        return self._object.get_prop_ids()

    def copy(self):
        return Atom.from_aal(self._object.copy())
