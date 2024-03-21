from pylibav.libav cimport (
    AVFilterPad,
)
from .context cimport FilterContext
from .filter cimport Filter
from .link cimport FilterLink


cdef class FilterPad:

    cdef readonly Filter filter
    cdef readonly FilterContext context
    cdef readonly bint is_input
    cdef readonly int index

    cdef const AVFilterPad *base_ptr


cdef class FilterContextPad(FilterPad):

    cdef FilterLink _link


cdef tuple alloc_filter_pads(Filter, const AVFilterPad *ptr, bint is_input, FilterContext context=?)
