from pylibav.libav cimport (
    AVPixelFormat,
    AVPixFmtDescriptor,
    AVComponentDescriptor,
)


cdef class VideoFormat:

    cdef AVPixelFormat pix_fmt
    cdef const AVPixFmtDescriptor *ptr
    cdef readonly unsigned int width, height

    cdef readonly tuple components

    cdef _init(self, AVPixelFormat pix_fmt, unsigned int width, unsigned int height)

    cpdef chroma_width(self, int luma_width=?)
    cpdef chroma_height(self, int luma_height=?)


cdef class VideoFormatComponent:

    cdef VideoFormat format
    cdef readonly unsigned int index
    cdef const AVComponentDescriptor *ptr


cdef VideoFormat get_video_format(AVPixelFormat c_format, unsigned int width, unsigned int height)

cdef AVPixelFormat get_pix_fmt(const char *name) except AVPixelFormat.AV_PIX_FMT_NONE
