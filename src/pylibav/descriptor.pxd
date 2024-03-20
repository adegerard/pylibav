cimport libav

cdef class Descriptor:

    # These are present as:
    # - AVCodecContext.av_class (same as avcodec_get_class())
    # - AVFormatContext.av_class (same as avformat_get_class())
    # - AVFilterContext.av_class (same as avfilter_get_class())
    # - AVCodec.priv_class
    # - AVOutputFormat.priv_class
    # - AVInputFormat.priv_class
    # - AVFilter.priv_class

    cdef const libav.AVClass *ptr

    cdef object _options  # Option list cache.


cdef Descriptor wrap_avclass(const libav.AVClass*)
