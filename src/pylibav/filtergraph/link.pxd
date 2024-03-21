from pylibav.libav cimport AVFilterLink
from pylibav.filtergraph.graph cimport Graph
from pylibav.filtergraph.pad cimport FilterContextPad

cdef class FilterLink:

    cdef readonly Graph graph
    cdef AVFilterLink *ptr

    cdef FilterContextPad _input
    cdef FilterContextPad _output


cdef FilterLink wrap_filter_link(Graph graph, AVFilterLink *ptr)
