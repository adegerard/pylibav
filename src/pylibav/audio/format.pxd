from ..libav cimport AVSampleFormat


cdef class AudioFormat:

    cdef AVSampleFormat sample_fmt

    cdef _init(self, AVSampleFormat sample_fmt)


cdef AudioFormat get_audio_format(AVSampleFormat format)
