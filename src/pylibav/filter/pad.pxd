cimport libav as lib

from pylibav.filter.context cimport FilterContext
from pylibav.filter.filter cimport Filter
from pylibav.filter.link cimport FilterLink


cdef class FilterPad:

    cdef readonly Filter filter
    cdef readonly FilterContext context
    cdef readonly bint is_input
    cdef readonly int index

    cdef const lib.AVFilterPad *base_ptr


cdef class FilterContextPad(FilterPad):

    cdef FilterLink _link


cdef tuple alloc_filter_pads(Filter, const lib.AVFilterPad *ptr, bint is_input, FilterContext context=?)
