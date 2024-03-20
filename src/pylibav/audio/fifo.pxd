from libc.stdint cimport int64_t, uint64_t
from ..libav cimport (
    AVAudioFifo
)

from pylibav.audio.frame cimport AudioFrame


cdef class AudioFifo:

    cdef AVAudioFifo *ptr

    cdef AudioFrame template

    cdef readonly uint64_t samples_written
    cdef readonly uint64_t samples_read
    cdef readonly double pts_per_sample

    cpdef write(self, AudioFrame frame)
    cpdef read(self, int samples=*, bint partial=*)
    cpdef read_many(self, int samples, bint partial=*)
