cimport libav as lib

from pylibav.codec.context cimport CodecContext
from pylibav.container.core cimport Container
from pylibav.frame cimport Frame
from pylibav.packet cimport Packet


cdef class Stream:
    cdef lib.AVStream *ptr

    # Stream attributes.
    cdef readonly Container container
    cdef readonly dict metadata
    cdef readonly int nb_side_data
    cdef readonly dict side_data

    # CodecContext attributes.
    cdef readonly CodecContext codec_context

    # Private API.
    cdef _init(self, Container, lib.AVStream*, CodecContext)
    cdef _finalize_for_output(self)
    cdef _get_side_data(self, lib.AVStream *stream)
    cdef _set_time_base(self, value)
    cdef _set_id(self, value)


cdef Stream wrap_stream(Container, lib.AVStream*, CodecContext)
