import numpy as np
from aal.gir import Aal
from aal.wrapper import AalWrapper

class Vector(AalWrapper):
    SUPPORTED_TYPES = (Aal.Vector, )

    def __init__(self, size: int):
        super().__init__()
        self._object = Aal.Vector.create(size)

    @classmethod
    def from_numpy(cls, array: np.ndarray):
        result = Vector(array.size)
        result._object.set_array(array.tolist())

    @property
    def size(self) -> int:
        return self._object.get_size()

    def __getitem__(self, x) -> float:
        return self._object.get_val(x)

    def __setitem__(self, x, value):
        self._object.set_val(x, value)        

    def to_numpy(self) -> np.ndarray:
        return np.asarray(self._object.to_array())

    def copy(self):
        result = Vector(self.size)
        result._object = self._object.copy()
        return result

