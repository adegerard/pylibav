from .frame cimport VideoFrame
from pylibav.libav cimport (
    SwsContext,
    AVPixelFormat,
)


cdef class VideoReformatter:

    cdef SwsContext *ptr

    cdef _reformat(self, VideoFrame frame, int width, int height,
                   AVPixelFormat format, int src_colorspace,
                   int dst_colorspace, int interpolation,
                   int src_color_range, int dst_color_range)
