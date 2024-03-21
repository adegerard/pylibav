from pylibav.libav.libavutil.avutil cimport *
from pylibav.libav.libavutil.channel_layout cimport *
from pylibav.libav.libavutil.dict cimport *
from pylibav.libav.libavutil.error cimport *
from pylibav.libav.libavutil.frame cimport *
from pylibav.libav.libavutil.samplefmt cimport *
from pylibav.libav.libavutil.motion_vector cimport *
from pylibav.libav.libavcodec.avcodec cimport *
from pylibav.libav.libavdevice.avdevice cimport *
from pylibav.libav.libavformat.avformat cimport *
from pylibav.libav.libswresample.swresample cimport *
from pylibav.libav.libswscale.swscale cimport *
from pylibav.libav.libavfilter.avfilter cimport *
from pylibav.libav.libavfilter.avfiltergraph cimport *
from pylibav.libav.libavfilter.buffersink cimport *
from pylibav.libav.libavfilter.buffersrc cimport *


cdef extern from "stdio.h" nogil:

    cdef int snprintf(char *output, int n, const char *format, ...)
    cdef int vsnprintf(char *output, int n, const char *format, va_list args)
