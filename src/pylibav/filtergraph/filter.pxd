from pylibav.libav cimport (
    AVFilter
)
from pylibav.descriptor cimport Descriptor


cdef class Filter:

    cdef const AVFilter *ptr

    cdef object _inputs
    cdef object _outputs
    cdef Descriptor _descriptor


cdef Filter wrap_filter(const AVFilter *ptr)
