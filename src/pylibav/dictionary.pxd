from pylibav.libav cimport AVDictionary

cdef class _Dictionary:

    cdef AVDictionary *ptr

    cpdef _Dictionary copy(self)


cdef _Dictionary wrap_dictionary(AVDictionary *input_)
