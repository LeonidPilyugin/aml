from aal.gir import Aal
from aal.wrapper import AalWrapper
from aal.data.atom import Atom
from aal.data.property import PerAtomProperty

class Atoms(AalWrapper):
    SUPPORTED_TYPES = (Aal.Atoms, )
    
    def __init__(self, size: int):
        super().__init__()
        self._object = Aal.Atoms.create(size)

    @property
    def size(self) -> int:
        return self._object.get_size()

    @size.setter
    def size(self, value: int):
        self._object.set_size(value)

    def __getitem__(self, key):
        if isinstance(key, str):
            return PerAtomProperty.from_aal(self._object.get_prop(key))
        elif isinstance(key, int):
            return Atom.from_aal(self._object.get_atom(key))

    def __setitem__(self, key, value):
        if isinstance(key, str):
            self._object.set_prop(key, value._object)
        elif isinstance(key, int):
            self._object.set_atom(key, value._object)

    def __delitem__(self, key):
        if isinstance(key, str):
            self._object.del_prop(key)
        elif isinstance(key, int):
            self._object.del_atom(key)

    def append(self, atom):
        self._object.append_atom(atom._object)

    @property
    def keys(self):
        return self._object.get_prop_ids()
