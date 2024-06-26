from pylibav.libav cimport (
    AVCodecDescriptor,
    avcodec_descriptor_get
)
from pylibav.stream cimport Stream


cdef class DataStream(Stream):
    def __repr__(self):
        return (
            f"<pylibav.{self.__class__.__name__} #{self.index} {self.type or '<notype>'}/"
            f"{self.name or '<nocodec>'} at 0x{id(self):x}>"
        )

    def encode(self, frame=None):
        return []

    def decode(self, packet=None, count=0):
        return []

    @property
    def name(self):
        cdef const AVCodecDescriptor *desc = avcodec_descriptor_get(self.ptr.codecpar.codec_id)
        if desc == NULL:
            return None
        return desc.name
