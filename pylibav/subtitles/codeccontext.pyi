from typing import Literal

from pylibav.codec.context import CodecContext

class SubtitleCodecContext(CodecContext):
    type: Literal["subtitle"]
