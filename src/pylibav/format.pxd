from pylibav.libav cimport (
    AVInputFormat,
    AVOutputFormat,
)


cdef class ContainerFormat:
    cdef readonly str name

    cdef const AVInputFormat *iptr
    cdef const AVOutputFormat *optr


cdef ContainerFormat build_container_format(
    const AVInputFormat*,
    const AVOutputFormat*
)
