import os
from pathlib import Path, PosixPath
import platform
import struct
import sys


IS_PLATFORM_DARWIN = bool(sys.platform == "darwin")
IS_PLATFORM_DARWIN_ARM = IS_PLATFORM_DARWIN and bool(platform.machine() == "arm64")
IS_PLATFORM_WINDOWS = bool(sys.platform == "win32")
IS_PLATFORM_LINUX = bool(sys.platform == "linux")

ENV_SEP: str = ";" if IS_PLATFORM_WINDOWS else ":"

def get_platform_tag() -> str:
    """return platform tag"""
    machine = platform.machine()
    if IS_PLATFORM_LINUX:
        return f"manylinux_{machine}"

    elif IS_PLATFORM_DARWIN:
        # cibuildwheel sets ARCHFLAGS:
        # https://github.com/pypa/cibuildwheel/blob/5255155bc57eb6224354356df648dc42e31a0028/cibuildwheel/macos.py#L207-L220
        machine = os.environ["ARCHFLAGS"].split()[1]
        return f"macosx_{machine}"

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
