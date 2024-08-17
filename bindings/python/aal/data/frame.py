from aal.gir import Aal
from aal.wrapper import AalWrapper
from aal.data.box import Box, ParallelepipedBox
from aal.data.atoms import Atoms
from aal.data.property import FrameProperty

class Frame(AalWrapper):
    SUPPORTED_TYPES = (Aal.Frame, )

    def __init__(self, box, atoms):
        super().__init__()
        self._object = Aal.Frame.create(box._object, atoms._object)

    @property
    def box(self):
        box = self._object.get_box()
        if isinstance(box, Aal.ParallelepipedBox):
            return ParallelepipedBox.from_aal(box)
        return Box.from_aal(box)

    @property
    def atoms(self):
        return Atoms.from_aal(self._object.get_atoms())

    def __getitem__(self, key):
        return FrameProperty.from_aal(self._object.get_prop(key))

    def __setitem__(self, key, value):
        self._object.set_prop(key, value._object)

    def __delitem__(self, key):
        self._object.del_prop(key)

    @property
    def keys(self):
        return self._object.get_prop_ids()
