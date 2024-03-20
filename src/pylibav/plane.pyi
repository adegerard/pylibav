from pylibav.buffer import Buffer
from pylibav.frame import Frame

class Plane(Buffer):
    frame: Frame
    index: int

    def __init__(self, frame: Frame, index: int) -> None: ...
