import os
import sys

# Some Python versions distributed by Conda have a buggy `os.add_dll_directory`
# which prevents binary wheels from finding the FFmpeg DLLs in the `pylibav.libs`
# directory. We work around this by adding `pylibav.libs` to the PATH.
if (
    os.name == "nt"
    and sys.version_info[:2] in ((3, 8), (3, 9))
    and os.path.exists(os.path.join(sys.base_prefix, "conda-meta"))
):
    os.environ["PATH"] = (
        os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir, "pylibav.libs"))
        + os.pathsep
        + os.environ["PATH"]
    )

# MUST import the core before anything else in order to initalize the underlying
# library that is being wrapped.
from pylibav._core import time_base, library_versions

# Capture logging (by importing it).
from av import logging

# For convenience, IMPORT ALL OF THE THINGS (that are constructable by the user).
from pylibav.about import __version__
from pylibav.audio.fifo import AudioFifo
from pylibav.audio.format import AudioFormat
from pylibav.audio.frame import AudioFrame
from pylibav.audio.layout import AudioLayout
from pylibav.audio.resampler import AudioResampler
from pylibav.codec.codec import Codec, codecs_available
from pylibav.codec.context import CodecContext
from pylibav.container import open
from pylibav.format import ContainerFormat, formats_available
from pylibav.packet import Packet
from pylibav.error import *  # noqa: F403; This is limited to exception types.
from pylibav.video.format import VideoFormat
from pylibav.video.frame import VideoFrame

# Backwards compatibility
AVError = FFmpegError  # noqa: F405
