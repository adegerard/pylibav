import os
import platform
from enum import IntEnum
import re
import shutil
import struct
import sys
from setuptools import (
    Extension,
    setup,
)
from Cython.Build import cythonize



rebuild: bool = False


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



IS_PLATFORM_DARWIN = bool(sys.platform == "darwin")
IS_PLATFORM_DARWIN_ARM = IS_PLATFORM_DARWIN and bool(platform.machine() == "arm64")
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

ffmpeg_workdir = f"build/tmp/deploy/ffmpeg-{get_platform_tag()}"
ffmpeg_lib_dir = os.path.join(ffmpeg_workdir, "lib")
ffmpeg_include_dir = os.path.join(ffmpeg_workdir, "include")

package_dir = "src/pylibav"
package_lib_dir = os.path.join(package_dir, "lib")
package_include_dir = os.path.join(package_dir, "include")


if rebuild:
    # Copy FFmpeg AV libraries to package source
    if os.path.exists(package_lib_dir):
        shutil.rmtree(package_lib_dir)
    os.makedirs(package_lib_dir)

    lib_pattern = f"[^.]+.so.*" if IS_PLATFORM_LINUX else f"[^.]+.dll"
    for f in os.listdir(ffmpeg_lib_dir):
        fp: str = os.path.join(ffmpeg_lib_dir, f)
        if (
            not os.path.islink(fp)
            and (match := re.match(re.compile(lib_pattern), f))
        ):
            shutil.copy2(fp, package_lib_dir)


LIBAV_LIBRARIES = (
    "libavformat",
    "libavcodec",
    "libavdevice",
    "libavutil",
    "libavfilter",
    "libswscale",
    "libswresample",
)

LIBAV_LIBRARIES = [
    os.path.join(
        os.path.dirname(os.path.realpath(__file__)),
        package_dir,
        f
    )
    for f in os.listdir(package_lib_dir)
    if f.split('.')[0] in LIBAV_LIBRARIES
]


# Debug: to be removed
print(ffmpeg_workdir)
print(ffmpeg_include_dir)
print(ffmpeg_lib_dir)
print(package_dir)
print(package_include_dir)
print(package_lib_dir)
print()


# Cythonize package
ext_modules = []
for dirpath, dirnames, filenames in os.walk(package_dir):
    if "__pycache__" in dirpath:
        continue

    for filename in sorted(filenames):
        if filename.startswith(".") or os.path.splitext(filename)[1] != ".pyx":
            continue

        module_name = f"{'.'.join(dirpath.split(os.sep)[1:])}.{os.path.splitext(filename)[0]}"
        src_filepath = os.path.join(dirpath, filename)
        print(
            lightgreen(f"- Cythonize module"),
            lightcyan(f"{module_name}"),
            lightgreen("from"),
            lightcyan(f"{src_filepath}")
        )

        # Cythonize the module
        ext_modules.extend(
            cythonize(
                Extension(
                    module_name,
                    sources=[src_filepath],
                    include_dirs=[ffmpeg_include_dir],
                    libraries=LIBAV_LIBRARIES,
                    library_dirs=[package_lib_dir],
                ),
                compiler_directives=dict(
                    c_string_type="str",
                    c_string_encoding="ascii",
                    embedsignature=False,
                    language_level=3,
                ),
                build_dir=os.path.join("build", "tmp", "work", "pylibav"),
            )
        )




setup(
    ext_modules=ext_modules,
)