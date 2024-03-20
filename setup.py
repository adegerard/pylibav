import os
import platform
import re
import shutil
import struct
import sys
from setuptools import (
    Extension,
    setup,
)
from Cython.Build import cythonize
from Cython.Compiler.AutoDocTransforms import EmbedSignature

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

# Copy FFmpeg AV libraries to package source
if os.path.exists(package_lib_dir):
    shutil.rmtree(package_lib_dir)
os.makedirs(package_lib_dir)

for f in os.listdir(ffmpeg_lib_dir):
    fp: str = os.path.join(ffmpeg_lib_dir, f)
    if (
        not os.path.islink(fp)
        and (match := re.match(re.compile(f"[^.]+.so.*"), f))
    ):
        shutil.copy2(fp, package_lib_dir)


FFMPEG_AV_LIBRARIES = [
    "avformat",
    "avcodec",
    "avdevice",
    "avutil",
    "avfilter",
    "swscale",
    "swresample",
]

print(ffmpeg_workdir)
print(ffmpeg_include_dir)
print(ffmpeg_lib_dir)

print(package_dir)
print(package_include_dir)
print(package_lib_dir)
print()



# Monkey-patch Cython to not overwrite embedded signatures.
old_embed_signature = EmbedSignature._embed_signature

def new_embed_signature(self, sig, doc):
    # Strip any `self` parameters from the front.
    sig = re.sub(r"\(self(,\s+)?", "(", sig)

    # If they both start with the same signature; skip it.
    if sig and doc:
        new_name = sig.split("(")[0].strip()
        old_name = doc.split("(")[0].strip()
        if new_name == old_name:
            return doc
        if new_name.endswith("." + old_name):
            return doc

    return old_embed_signature(self, sig, doc)

EmbedSignature._embed_signature = new_embed_signature



# Cythonize package
ext_modules = []
for dirname, dirnames, filenames in os.walk(package_dir):

    for filename in filenames:
        # We are looking for Cython sources.
        if filename.startswith(".") or os.path.splitext(filename)[1] != ".pyx":
            continue

        src = os.path.join(dirname, filename)
        pyx_filepath = os.path.join(os.path.split(dirname)[-1], filename)
        module_name = (
            os.path.splitext(pyx_filepath)[0]
        ).replace("/", ".").replace(os.sep, ".")

        # Cythonize the module.
        ext_modules.extend(
            cythonize(
                Extension(
                    module_name,
                    sources=[src],
                    include_dirs=[package_include_dir, ffmpeg_include_dir, "include"],
                    libraries=FFMPEG_AV_LIBRARIES,
                    library_dirs=[package_lib_dir],
                ),
                compiler_directives=dict(
                    c_string_type="str",
                    c_string_encoding="ascii",
                    embedsignature=True,
                    language_level=2,
                ),
                build_dir=os.path.join("build", "src"),
                include_path=["include", package_include_dir, ffmpeg_include_dir],
            )
        )




setup(
    ext_modules=ext_modules,
)