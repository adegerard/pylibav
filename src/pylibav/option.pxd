from .libav cimport (
    AVOption
)

cdef class BaseOption:
    cdef const AVOption *ptr


cdef class Option(BaseOption):
    cdef readonly tuple choices


cdef class OptionChoice(BaseOption):
    cdef readonly bint is_default


cdef Option wrap_option(tuple choices, const AVOption *ptr)

cdef OptionChoice wrap_option_choice(const AVOption *ptr, bint is_default)
