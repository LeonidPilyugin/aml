from abc import ABCMeta
from aal.exception import AalException

class AalWrapper(metaclass=ABCMeta):
    SUPPORTED_TYPES = ()

    def __init__(self):
        self._object = None

    @classmethod
    def from_aal(cls, obj):
        for t in cls.SUPPORTED_TYPES:
            if isinstance(obj, t):
                break
        else:
            raise AalException(f"Unsupported object type: {type(obj)} instead of {cls.SUPPORTED_TYPES}")

        res = cls.__new__(cls)
        res._object = obj
        return res
