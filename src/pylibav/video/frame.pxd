from libc.stdint cimport uint8_t
from pylibav.libav cimport AVPixelFormat
from pylibav.frame cimport Frame
from pylibav.video.format cimport VideoFormat
from pylibav.video.reformatter cimport VideoReformatter


cdef class VideoFrame(Frame):

    # This is the buffer that is used to back everything in the AVFrame.
    # We don't ever actually access it directly.
    cdef uint8_t *_buffer
    cdef object _np_buffer

    cdef VideoReformatter reformatter

    cdef readonly VideoFormat format

    cdef _init(self, AVPixelFormat format, unsigned int width, unsigned int height)
    cdef _init_user_attributes(self)


cdef VideoFrame alloc_video_frame()
