from pylibav.container.core cimport Container
from pylibav.stream cimport Stream


cdef class InputContainer(Container):
    cdef flush_buffers(self)
