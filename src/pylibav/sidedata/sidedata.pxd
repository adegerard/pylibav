from ..buffer cimport Buffer
from ..dictionary cimport _Dictionary
from ..frame cimport Frame
from ..libav cimport AVFrameSideData


cdef class SideData(Buffer):
    cdef Frame frame
    cdef AVFrameSideData *ptr
    cdef _Dictionary metadata


cdef SideData wrap_side_data(Frame frame, int index)


cdef class _SideDataContainer:
    cdef Frame frame
    cdef list _by_index
    cdef dict _by_type
