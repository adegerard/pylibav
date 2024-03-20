from libc.stdint cimport int64_t, uint8_t
from ..libav cimport AVIOContext


cdef int pyio_read(void *opaque, uint8_t *buf, int buf_size) noexcept nogil

cdef int pyio_write(void *opaque, uint8_t *buf, int buf_size) noexcept nogil

cdef int64_t pyio_seek(void *opaque, int64_t offset, int whence) noexcept nogil

cdef void pyio_close_gil(AVIOContext *pb)

cdef void pyio_close_custom_gil(AVIOContext *pb)


cdef class PyIOFile:

    # File-like source.
    cdef readonly object file
    cdef object fread
    cdef object fwrite
    cdef object fseek
    cdef object ftell
    cdef object fclose

    # Custom IO for above.
    cdef AVIOContext *iocontext
    cdef unsigned char *buffer
    cdef long pos
    cdef bint pos_is_valid
