from pylibav.plane cimport Plane
from pylibav.video.format cimport VideoFormatComponent


cdef class VideoPlane(Plane):

    cdef readonly size_t buffer_size
    cdef readonly unsigned int width, height
