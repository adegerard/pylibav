from pylibav.libav cimport (
    AVFilterContext
)

from pylibav.filtergraph.filter cimport Filter
from pylibav.filtergraph.graph cimport Graph


cdef class FilterContext:

    cdef AVFilterContext *ptr
    cdef readonly Graph graph
    cdef readonly Filter filter

    cdef object _inputs
    cdef object _outputs

    cdef bint inited


cdef FilterContext wrap_filter_context(Graph graph, Filter filter, AVFilterContext *ptr)
