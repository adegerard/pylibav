from .libav cimport (
    AVPacket,
    AVRational,
)
from .buffer cimport Buffer
from .bytesource cimport ByteSource
from .stream cimport Stream


cdef class Packet(Buffer):
    cdef AVPacket* ptr

    cdef Stream _stream

    # We track our own time.
    cdef AVRational _time_base
    cdef _rebase_time(self, AVRational)

    # Hold onto the original reference.
    cdef ByteSource source
    cdef size_t _buffer_size(self)
    cdef void* _buffer_ptr(self)
