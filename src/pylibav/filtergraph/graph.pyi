from fractions import Fraction
from typing import Any

# from ..audio.format import AudioFormat
# from ..audio.frame import AudioFrame
# from ..audio.layout import AudioLayout
# from ..audio.stream import AudioStream
from pylibav.video.format import VideoFormat
from pylibav.video.frame import VideoFrame
from pylibav.video.stream import VideoStream

from .context import FilterContext
from .filter import Filter


class Graph:
    configured: bool

    def __init__(self) -> None: ...
    def configure(self, auto_buffer: bool = True, force: bool = False) -> None: ...
    def add(
        self, filter: str | Filter, args: Any = None, **kwargs: str
    ) -> FilterContext: ...
    def add_buffer(
        self,
        template: VideoStream | None = None,
        width: int | None = None,
        height: int | None = None,
        format: VideoFormat | None = None,
        name: str | None = None,
        time_base: Fraction | None = None,
    ) -> FilterContext: ...
    # def add_abuffer(
    #     self,
    #     template: AudioStream | None = None,
    #     sample_rate: int | None = None,
    #     format: AudioFormat | None = None,
    #     layout: AudioLayout | None = None,
    #     channels: int | None = None,
    #     name: str | None = None,
    #     time_base: Fraction | None = None,
    # ) -> FilterContext: ...
    # def push(self, frame: None | AudioFrame | VideoFrame) -> None: ...
    # def pull(self) -> VideoFrame | AudioFrame: ...
    def push(self, frame: None | VideoFrame) -> None: ...
    def pull(self) -> VideoFrame: ...
