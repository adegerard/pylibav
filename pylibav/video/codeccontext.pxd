
from pylibav.codec.context cimport CodecContext
from pylibav.video.format cimport VideoFormat
from pylibav.video.frame cimport VideoFrame
from pylibav.video.reformatter cimport VideoReformatter


cdef class VideoCodecContext(CodecContext):

    cdef VideoFormat _format
    cdef _build_format(self)

    cdef int last_w
    cdef int last_h
    cdef readonly VideoReformatter reformatter

    # For encoding.
    cdef readonly int encoded_frame_count

    # For decoding.
    cdef VideoFrame next_frame
