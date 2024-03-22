from pylibav.stream cimport Stream


cdef class StreamContainer:
    cdef list _streams

    cdef readonly tuple video
    cdef readonly tuple audio
    cdef readonly tuple subtitles
    cdef readonly tuple data
    cdef readonly tuple other

    cdef add_stream(self, Stream stream)
