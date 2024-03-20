from pylibav.frame import Frame
from pylibav.packet import Packet
from pylibav.stream import Stream

class DataStream(Stream):
    def encode(self, frame: Frame | None = None) -> list[Packet]: ...
    def decode(self, packet: Packet | None = None, count: int = 0) -> list[Frame]: ...
