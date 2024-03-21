from .libav cimport (
    AVInputFormat,
    AVOutputFormat,
)


cdef class ContainerFormat:
    cdef readonly str name

    cdef AVInputFormat *iptr
    cdef AVOutputFormat *optr


cdef ContainerFormat build_container_format(AVInputFormat*, AVOutputFormat*)
