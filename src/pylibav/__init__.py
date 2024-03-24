import os
import sys

__version__ = "0.0.1"

libs_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), 'lib'))
if os.path.isdir(libs_dir):
    print(f"adding: {libs_dir}")
    os.add_dll_directory(libs_dir)

# MUST import the core before anything else in order to initalize the underlying
# library that is being wrapped.
from pylibav._core import (
    library_versions,
    time_base,
)
# # Capture logging (by importing it).
# from pylibav.logging import logging

# For convenience, IMPORT ALL OF THE THINGS (that are constructable by the user).
# from pylibav.audio.format import AudioFormat
# from pylibav.audio.frame import AudioFrame
# from pylibav.audio.layout import AudioLayout
# from pylibav.audio.resampler import AudioResampler
from pylibav.codec.codec import (
    Codec,
    available_codecs,
)
from pylibav.codec.context import CodecContext
from pylibav.container import open
from pylibav.format import ContainerFormat, available_formats
from pylibav.packet import Packet
from pylibav.error import *  # noqa: F403; This is limited to exception types.
from pylibav.video.format import VideoFormat
from pylibav.video.frame import VideoFrame

# Backwards compatibility
AVError = FFmpegError  # noqa: F405


__all__ = [
    "time_base",
    "library_versions",

    "Codec",
    "available_codecs",

    "CodecContext",
]