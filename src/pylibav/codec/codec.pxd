from pylibav.libav cimport (
    AVCodec,
    AVCodecDescriptor,
)

cdef class Codec:
    cdef const AVCodec *ptr
    cdef const AVCodecDescriptor *desc
    cdef readonly bint is_encoder

    cdef _init(self, name=?)


cdef Codec wrap_codec(const AVCodec *ptr)
