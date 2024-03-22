from typing import Any, Iterator, overload

# from pylibav.audio.frame import AudioFrame
# from pylibav.audio.stream import AudioStream
from pylibav.packet import Packet
from pylibav.stream import Stream
# from pylibav.subtitles.stream import SubtitleStream
# from pylibav.subtitles.subtitle import SubtitleSet
from pylibav.video.frame import VideoFrame
from pylibav.video.stream import VideoStream

from .core import Container

class InputContainer(Container):
    start_time: int
    duration: int | None
    bit_rate: int
    size: int

    def __enter__(self) -> InputContainer: ...
    def close(self) -> None: ...
    def demux(self, *args: Any, **kwargs: Any) -> Iterator[Packet]: ...
    @overload
    def decode(self, *args: VideoStream) -> Iterator[VideoFrame]: ...
    @overload
    # def decode(self, *args: AudioStream) -> Iterator[AudioFrame]: ...
    # @overload
    # def decode(self, *args: SubtitleStream) -> Iterator[SubtitleSet]: ...
    # @overload
    # def decode(
    #     self, *args: Any, **kwargs: Any
    # ) -> Iterator[VideoFrame | AudioFrame | SubtitleSet]: ...
    def seek(
        self,
        offset: int,
        *,
        backward: bool = True,
        any_frame: bool = False,
        # stream: Stream | VideoStream | AudioStream | None = None,
        stream: Stream | VideoStream | None = None,
        unsupported_frame_offset: bool = False,
        unsupported_byte_offset: bool = False,
    ) -> None: ...
    def flush_buffers(self) -> None: ...
