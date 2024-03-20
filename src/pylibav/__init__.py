import os
import sys

__version__ = "0.0.1"

# MUST import the core before anything else in order to initalize the underlying
# library that is being wrapped.
from ._core import (
    library_versions,
    time_base,
)
# # Capture logging (by importing it).
# from logging import logging

# For convenience, IMPORT ALL OF THE THINGS (that are constructable by the user).
from audio.format import AudioFormat
from audio.frame import AudioFrame
from audio.layout import AudioLayout
from audio.resampler import AudioResampler
from .codec.codec import (
    Codec,
    codecs_available,
)
from .codec.context import CodecContext
from .container import open
from .format import ContainerFormat, formats_available
from .packet import Packet
from .error import *  # noqa: F403; This is limited to exception types.
from .video.format import VideoFormat
from .video.frame import VideoFrame

# Backwards compatibility
AVError = FFmpegError  # noqa: F405


__all__ = [
    "time_base",
    "library_versions",

    "Codec",
    "codecs_available",

    "CodecContext",
]