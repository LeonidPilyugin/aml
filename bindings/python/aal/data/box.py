from typing import Tuple, Iterable
from aal.gir import Aal
from aal.wrapper import AalWrapper
from aal.math.vector import Vector
from aal.math.matrix import Matrix

class Box(AalWrapper):
    SUPPORTED_TYPES = (Aal.Box, )

    @property
    def volume(self):
        return self._object.get_volume()


class ParallelepipedBox(Box):
    SUPPORTED_TYPES = (Aal.ParallelepipedBox, )

    def __init__(self, origin: Vector, edge: Matrix, boundaries: Iterable[bool]):
        super().__init__()
        self._object = Aal.ParallelepipedBox.create(edge._object, origin._object, list(boundaries))

    @property
    def edge(self) -> Matrix:
        return Matrix.from_aal(self._object.get_edge())

    @edge.setter
    def edge(self, matrix: Matrix):
        self._object.set_edge(matrix._object)

    @property
    def origin(self) -> Vector:
        return Vector.from_aal(self._object.get_origin())

    @origin.setter
    def origin(self, vector: Vector):
        self._object.set_origin(vector._object)

    @property
    def boundaries(self) -> Tuple[bool]:
        return tuple(self._object.get_boundaries())

    @boundaries.setter
    def boundaries(self, value):
        self._object.set_boundaries(value)
