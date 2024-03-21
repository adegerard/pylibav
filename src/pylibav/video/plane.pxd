from .plane cimport Plane

cdef class VideoPlane(Plane):
    cdef readonly size_t buffer_size
    cdef readonly unsigned int width
    cdef readonly unsigned int height
