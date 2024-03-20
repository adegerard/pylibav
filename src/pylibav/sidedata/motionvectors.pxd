from ..libav cimport AVMotionVector
from .sidedata cimport SideData


cdef class _MotionVectors(SideData):

    cdef dict _vectors
    cdef int _len


cdef class MotionVector:

    cdef _MotionVectors parent
    cdef AVMotionVector *ptr
