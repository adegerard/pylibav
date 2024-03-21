from pylibav.libav.libavfilter.avfilter cimport AVFilterContext
from pylibav.libav.libavcodec.avcodec cimport AVFrame


cdef extern from "libavfilter/buffersrc.h" nogil:

    int av_buffersrc_write_frame(
        AVFilterContext *ctx,
        const AVFrame *frame
    )
