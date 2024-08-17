from enum import Enum, auto
import numpy as np
from aal.gir import Aal
from aal.wrapper import AalWrapper

class Property(AalWrapper):
    SUPPORTED_TYPES = (Aal.Property, )

    @property
    def id(self):
        return self._object.get_id()

class FrameProperty(Property):
    SUPPORTED_TYPES = (Aal.FrameProperty, )

    def __init__(self, id, data):
        super().__init__()
        self._object = Aal.FrameProperty.create(id, data)

    @property
    def data(self):
        return self._object.get_data()

    @data.setter
    def data(self, value):
        self._object.set_data(value)

class PerAtomProperty(Property):
    SUPPORTED_TYPES = (Aal.PerAtomProperty, )

    class DType(Enum):
        INT = auto()
        DOUBLE = auto()
        STRING = auto()

    def __init__(self, id, array):
        super().__init__()

        if isinstance(int, array[0]):
            self._object = Aal.IntPerAtomProperty.create(id, array)
        elif isinstance(float, array[0]):
            self._object = Aal.DoublePerAtomProperty.create(id, array)
        elif isinstance(str, array[0]):
            self._object = Aal.StringPerAtomProperty.create(id, array)
        else: raise NotImplementedError()

    @classmethod
    def from_numpy(cls, id, arr):
        return cls(id, arr.tolist())

    @property
    def type(self):
        if isinstance(self._object, Aal.IntPerAtomProperty):
            return PerAtomProperty.DType.INT
        if isinstance(self._object, Aal.DoublePerAtomProperty):
            return PerAtomProperty.DType.DOUBLE
        if isinstance(self._object, Aal.StringPerAtomProperty):
            return PerAtomProperty.DType.STRING
        raise NotImplementedError()

    @property
    def size(self):
        return self._object.get_size()

    @size.setter
    def size(self, value):
        self._object.set_size(value)

    def get_array(self):
        return self._object.get_array()

    def set_array(self, value):
        self._object.set_array(value)

    def __getitem__(self, index):
        return self._object.get_val(index)

    def __setitem__(self, index, value):
        self._object.set_val(index, value)

    def __delitem__(self, index):
        self._object.del_val(index)

    def to_numpy(self):
        return np.asarray(self._object.get_array())

    def copy(self):
        return PerAtomProperty.from_aal(self._object.copy())

