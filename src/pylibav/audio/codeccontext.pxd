
from pylibav.audio.frame cimport AudioFrame
from pylibav.audio.resampler cimport AudioResampler
from pylibav.codec.context cimport CodecContext


cdef class AudioCodecContext(CodecContext):

    # Hold onto the frames that we will decode until we have a full one.
    cdef AudioFrame next_frame

    # For encoding.
    cdef AudioResampler resampler
