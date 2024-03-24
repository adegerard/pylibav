from enum import IntEnum
import os
from pathlib import Path, PosixPath
import platform
import struct
import sys


IS_PLATFORM_WINDOWS = bool(sys.platform == "win32")
IS_PLATFORM_LINUX = bool(sys.platform == "linux")


def get_platform_tag() -> str:
    """return platform tag"""
    machine = platform.machine()
    if IS_PLATFORM_LINUX:
        return f"manylinux_{machine}"

    elif IS_PLATFORM_WINDOWS:
        if struct.calcsize("P") * 8 == 64:
            return "win_amd64"
        else:
            return "win32"
    else:
        raise Exception(f"Unsupported platform {sys.platform}")


def path_expand_user(fp: str | Path) -> str:
    fp = str(fp) if isinstance(fp, Path) else fp
    if fp.startswith("~/"):
        fp = os.path.join(PosixPath(Path.home()), fp[2:])
    return fp


class ColorCode(IntEnum):
    red = 31
    green = 32
    orange = 33
    blue = 34
    purple = 35
    cyan = 36
    lightgrey = 37
    darkgrey = 90
    lighred = 91
    lightgreen = 92
    yellow = 93
    lightblue = 94
    pink = 95
    lightcyan = 96


def __color_str_template(color:ColorCode) -> str:
    return "\033[%dm{}\033[00m" % (color.value)


def lightcyan(*values: object) -> str:
    return __color_str_template(ColorCode.lightcyan).format(values[0])


def lightgreen(*values: object) -> str:
    return __color_str_template(ColorCode.lightgreen).format(values[0])

