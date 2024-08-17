from typing import Tuple
import numpy as np
from aal.gir import Aal
from aal.wrapper import AalWrapper

class Matrix(AalWrapper):
    SUPPORTED_TYPES = (Aal.Matrix, )

    def __init__(self, rows: int, columns: int):
        super().__init__()
        self._object = Aal.Matrix.create(rows, columns)

    @staticmethod
    def from_numpy(array: np.ndarray):
        result = Matrix(1, 1)
        result._object.set_array(array.reshape((array.size)).tolist(), array.shape[0])
        return result

    @property
    def size(self) -> Tuple[int, int]:
        return (self._object.get_rows_number(), self._object.get_columns_number())

    @property
    def rows(self) -> int:
        return self._object.get_rows_number()

    @property
    def columns(self) -> int:
        return self._object.get_columns_number()

    def __getitem__(self, c) -> float:
        x, y = c
        return self._object.get_val(x, y)

    def __setitem__(self, c, value):
        x, y = c
        self._object.set_val(x, y, value)        

    def to_numpy(self) -> np.ndarray:
        return np.asarray(self._object.to_array()).reshape((self.rows, self.columns))

    def copy(self):
        result = Matrix(self.rows, self.columns)
        result._object = self._object.copy()
        return result

    @property
    def det(self) -> float:
        return self._object.det()

    @property
    def is_diagonal(self) -> bool:
        return self._object.is_diagonal()

