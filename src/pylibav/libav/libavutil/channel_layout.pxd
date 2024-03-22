from libc.stdint cimport uint64_t


cdef extern from "libavutil/channel_layout.h" nogil:

    # This is not a comprehensive list.
    cdef uint64_t AV_CH_LAYOUT_MONO
    cdef uint64_t AV_CH_LAYOUT_STEREO
    cdef uint64_t AV_CH_LAYOUT_2POINT1
    cdef uint64_t AV_CH_LAYOUT_4POINT0
    cdef uint64_t AV_CH_LAYOUT_5POINT0_BACK
    cdef uint64_t AV_CH_LAYOUT_5POINT1_BACK
    cdef uint64_t AV_CH_LAYOUT_6POINT1
    cdef uint64_t AV_CH_LAYOUT_7POINT1


    cdef enum AVChannelOrder:
        AV_CHANNEL_ORDER_UNSPEC
        AV_CHANNEL_ORDER_NATIVE
        AV_CHANNEL_ORDER_CUSTOM
        AV_CHANNEL_ORDER_AMBISONIC
        FF_CHANNEL_ORDER_NB


    cdef enum AVChannel:
        AV_CHAN_NONE = -1
        AV_CHAN_FRONT_LEFT
        AV_CHAN_FRONT_RIGHT
        AV_CHAN_FRONT_CENTER
        AV_CHAN_LOW_FREQUENCY
        AV_CHAN_BACK_LEFT
        AV_CHAN_BACK_RIGHT
        AV_CHAN_FRONT_LEFT_OF_CENTER
        AV_CHAN_FRONT_RIGHT_OF_CENTER
        AV_CHAN_BACK_CENTER
        AV_CHAN_SIDE_LEFT
        AV_CHAN_SIDE_RIGHT
        AV_CHAN_TOP_CENTER
        AV_CHAN_TOP_FRONT_LEFT
        AV_CHAN_TOP_FRONT_CENTER
        AV_CHAN_TOP_FRONT_RIGHT
        AV_CHAN_TOP_BACK_LEFT
        AV_CHAN_TOP_BACK_CENTER
        AV_CHAN_TOP_BACK_RIGHT
        AV_CHAN_STEREO_LEFT
        AV_CHAN_STEREO_RIGHT
        AV_CHAN_WIDE_LEFT
        AV_CHAN_WIDE_RIGHT
        AV_CHAN_SURROUND_DIRECT_LEFT
        AV_CHAN_SURROUND_DIRECT_RIGHT
        AV_CHAN_LOW_FREQUENCY_2
        AV_CHAN_TOP_SIDE_LEFT
        AV_CHAN_TOP_SIDE_RIGHT
        AV_CHAN_BOTTOM_FRONT_CENTER
        AV_CHAN_BOTTOM_FRONT_LEFT
        AV_CHAN_BOTTOM_FRONT_RIGHT
        AV_CHAN_UNUSED
        AV_CHAN_UNKNOWN
        AV_CHAN_AMBISONIC_BASE
        AV_CHAN_AMBISONIC_END


    ctypedef struct AVChannelCustom:
        AVChannel id
        char[16] name
        void *opaque


    cdef union U:
        uint64_t mask
        AVChannelCustom *map


    ctypedef struct AVChannelLayout:
        AVChannelOrder order
        int nb_channels
        U u
        void *opaque
