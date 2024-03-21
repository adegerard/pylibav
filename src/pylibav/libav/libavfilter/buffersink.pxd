from pylibav.libav.libavcodec.avcodec cimport AVFrame
from pylibav.libav.libavfilter.avfilter cimport AVFilterContext


cdef extern from "libavfilter/buffersink.h" nogil:

    int av_buffersink_get_frame(
        AVFilterContext *ctx,
        AVFrame *frame
    )
