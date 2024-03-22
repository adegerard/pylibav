from pylibav.libav cimport AVPacket
from .core cimport Container

cdef class OutputContainer(Container):
    cdef bint _started
    cdef bint _done
    cdef AVPacket *packet_ptr

    cpdef start_encoding(self)
