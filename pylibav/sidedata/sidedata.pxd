
cimport libav as lib

from pylibav.buffer cimport Buffer
from pylibav.dictionary cimport _Dictionary, wrap_dictionary
from pylibav.frame cimport Frame


cdef class SideData(Buffer):

    cdef Frame frame
    cdef lib.AVFrameSideData *ptr
    cdef _Dictionary metadata


cdef SideData wrap_side_data(Frame frame, int index)

cdef class _SideDataContainer:

    cdef Frame frame

    cdef list _by_index
    cdef dict _by_type
