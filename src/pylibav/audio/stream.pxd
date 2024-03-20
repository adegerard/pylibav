from pylibav.packet cimport Packet
from pylibav.stream cimport Stream

from .frame cimport AudioFrame


cdef class AudioStream(Stream):
    cpdef encode(self, AudioFrame frame=?)
    cpdef decode(self, Packet packet=?)
