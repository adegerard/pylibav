import os
import platform
from enum import IntEnum
from pprint import pprint
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



IS_PLATFORM_WINDOWS = bool(sys.platform == "win32")
IS_PLATFORM_LINUX = bool(sys.platform == "linux")

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



root_dir = os.path.dirname(os.path.realpath(__file__))
libav_build_dirname = os.path.join("build", f"ffmpeg-{get_platform_tag()}")

# ffmpeg_lib_dir = os.path.join(root_dir, relative_workdir, "lib")
# ffmpeg_include_dir = os.path.join(relative_workdir, "include")

source_dir = os.path.join("src", "pylibav")
source_lib_dir = os.path.join(source_dir, "lib")

if rebuild:
    # Copy FFmpeg AV libraries to package source
    if os.path.exists(source_lib_dir):
        shutil.rmtree(source_lib_dir)
    os.makedirs(source_lib_dir)

    lib_pattern = f"[^.]+.so.*" if IS_PLATFORM_LINUX else f"[^.]+.dll"
    for f in os.listdir(ffmpeg_lib_dir):
        fp: str = os.path.join(ffmpeg_lib_dir, f)
        if (
            not os.path.islink(fp)
            and (match := re.match(re.compile(lib_pattern), f))
        ):
            shutil.copy2(fp, relative_workdir)




# FFmpeg libav libraries
libav_include_dir = os.path.join(source_dir, "include")
libav_library_dirs = [
    # os.path.join(libav_build_dirname, "lib")
    # source_lib_dir
    os.path.join("src", "pylibav", "lib")

    # os.path.join(root_dir, libav_build_dirname, "lib")
    # os.path.join(root_dir, ffmpeg_dirname, "bin")
]


LIBAV_LIBRARY_NAMES = [
    "avformat",
    "avcodec",
    "avdevice",
    "avutil",
    "avfilter",
    "swscale",
    "swresample"
]
if IS_PLATFORM_WINDOWS:
    libav_libraries = LIBAV_LIBRARY_NAMES

elif IS_PLATFORM_LINUX:
    libav_libraries = [
        os.path.join(
            os.path.dirname(os.path.realpath(__file__)),
            source_lib_dir,
            f
        )
        for f in os.listdir(libav_build_dirname)
        if f.split('.')[0] in LIBAV_LIBRARY_NAMES
    ]



# Debug: to be removed
print(lightgreen("------------------------------------------------------------"))
# print(f"ffmpeg_build: {ffmpeg_workdir}")
print(f"package_include_dir: {libav_include_dir}")
print(f"package_lib_dir: {libav_library_dirs}")
print(lightgreen("------------------------------------------------------------"))
print("libraries")
pprint(libav_libraries)
print()


# Cythonize package
ext_modules = []
for dirpath, dirnames, filenames in os.walk(source_dir):
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
                    include_dirs=[libav_include_dir],
                    libraries=libav_libraries,
                    # library_dirs=[package_lib_dir], <- linux
                    # library dirs: must contains both dll and lib
                    # absolute path
                    library_dirs=libav_library_dirs,
                ),
                compiler_directives=dict(
                    c_string_type="str",
                    c_string_encoding="ascii",
                    embedsignature=False,
                    language_level=3,
                ),
                # build_dir=os.path.join("build"),

            )
        )




setup(
    ext_modules=ext_modules,
)