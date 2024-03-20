from fractions import Fraction
from typing import Literal

from pylibav.audio.format import AudioFormat
from pylibav.descriptor import Descriptor
from pylibav.enum import EnumFlag
from pylibav.video.format import VideoFormat

from .context import CodecContext

class Properties(EnumFlag):
    NONE: int
    INTRA_ONLY: int
    LOSSY: int
    LOSSLESS: int
    REORDER: int
    BITMAP_SUB: int
    TEXT_SUB: int

class Capabilities(EnumFlag):
    NONE: int
    DARW_HORIZ_BAND: int
    DR1: int
    HWACCEL: int
    DELAY: int
    SMALL_LAST_FRAME: int
    HWACCEL_VDPAU: int
    SUBFRAMES: int
    EXPERIMENTAL: int
    CHANNEL_CONF: int
    NEG_LINESIZES: int
    FRAME_THREADS: int
    SLICE_THREADS: int
    PARAM_CHANGE: int
    AUTO_THREADS: int
    VARIABLE_FRAME_SIZE: int
    AVOID_PROBING: int
    HARDWARE: int
    HYBRID: int
    ENCODER_REORDERED_OPAQUE: int
    ENCODER_FLUSH: int

class UnknownCodecError(ValueError): ...

class Codec:
    is_decoder: bool
    descriptor: Descriptor
    name: str
    long_name: str
    type: Literal["video", "audio", "data", "subtitle", "attachment"]
    id: int
    frame_rates: list[Fraction] | None
    audio_rates: list[int] | None
    video_formats: list[VideoFormat] | None
    audio_formats: list[AudioFormat] | None
    properties: Properties
    capabilities: Capabilities

    def __init__(self, name: str, mode: Literal["r", "w"]) -> None: ...
    def create(self) -> CodecContext: ...

class codec_descriptor:
    name: str
    options: tuple[int, ...]

codecs_available: set[str]

def dump_codecs() -> None: ...
