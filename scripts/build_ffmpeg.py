import argparse
import glob
import os
from pathlib import Path, PosixPath
import shutil
import signal
import subprocess
import sys
from utils import (
    IS_PLATFORM_DARWIN,
    IS_PLATFORM_LINUX,
    IS_PLATFORM_WINDOWS,
    get_platform_tag,
)
from build_package import(
    Builder,
    log_group,
    Package,
    run
)



ffmpeg_build_args = [
    "--disable-alsa",
    "--disable-doc",
    "--disable-libtheora",
    "--disable-mediafoundation",
    "--disable-videotoolbox",
    "--disable-audiotoolbox",
    "--enable-fontconfig",
    # "--enable-gmp",
    # FFmpeg has native TLS backends for macOS and Windows
    "--disable-gnutls",
    "--disable-libaom",
    "--disable-libass",
    "--disable-libbluray",
    "--disable-libdav1d",
    "--disable-libfreetype",
    "--disable-libmp3lame",
    "--disable-libopencore-amrnb",
    "--disable-libopencore-amrwb",
    "--disable-libopus",
    "--disable-libspeex",
    "--disable-libtwolame",
    "--disable-libvorbis",
    "--disable-libvpx",
    "--enable-libxcb" if IS_PLATFORM_LINUX else "--disable-libxcb",
    "--disable-libxml2",
    "--enable-lzma",
    "--enable-zlib",
    "--enable-version3",

    # GPL
    "--disable-libx264",
    "--disable-libopenh264",
    "--disable-libx265",
    "--disable-libxvid",
    "--enable-gpl",

    # TODO: enable this?
    # "--enable-libopencv",

]





def main() -> None:
    parser = argparse.ArgumentParser("build-ffmpeg")
    parser.add_argument(
        "--build-dir",
        default="build"
    )
    parser.add_argument(
        "--stage",
        default=None,
        help="AArch64 build requires stage and possible values can be 1, 2 or 3",
    )
    parser.add_argument(
        "--rebuild",
        action="store_true",
        default=False
    )
    args = parser.parse_args()

    build_dir = os.path.abspath(args.build_dir)
    build_stage = None if args.stage is None else int(args.stage) - 1
    rebuild: bool = args.rebuild

    # Output FFmpeg build
    deploy_dir = os.path.abspath(
        os.path.abspath(os.path.join("build", "tmp", "deploy"))
    )
    output_package = os.path.join(deploy_dir, f"ffmpeg-{get_platform_tag()}.tar.gz")


    if not os.path.exists(output_package) or rebuild:
        builder = Builder(build_dir=build_dir, package_name="ffmpeg")
        builder.create_directories()

        # get and install tools
        available_tools = set()
        if IS_PLATFORM_LINUX and os.environ.get("CIBUILDWHEEL") == "1":
            with log_group("install packages"):
                run(
                    [
                        "yum",
                        "-y",
                        "install",
                        "gperf",
                        "libuuid-devel",
                        "libxcb-devel",
                        "zlib-devel",
                    ]
                )
            available_tools.update(["gperf", "nasm"])

        elif IS_PLATFORM_WINDOWS:
            available_tools.update(["gperf", "nasm"])
            for tool in ["gcc", "g++", "curl", "gperf", "ld", "nasm", "pkg-config"]:
                run(["where", tool])

        with log_group("install python packages"):
            run(["pip", "install", "cmake", "meson", "ninja"])


        # build tools
        if "gperf" not in available_tools:
            builder.build(
                Package(
                    name="gperf",
                    source_url="http://ftp.gnu.org/pub/gnu/gperf/gperf-3.1.tar.gz",
                ),
                for_builder=True,
            )

        # if "nasm" not in available_tools:
        #     builder.build(
        #         Package(
        #             name="nasm",
        #             source_url="https://www.nasm.us/pub/nasm/releasebuilds/2.16.01/nasm-2.16.01.tar.gz",
        #         ),
        #         for_builder=True,
        #     )
        library_group = []
        # if not IS_PLATFORM_WINDOWS:
        if True:
            library_group = [
                Package(
                    name="xz",
                    source_url="https://github.com/tukaani-project/xz/releases/download/v5.6.1/xz-5.6.1.tar.xz",
                    build_arguments=[
                        "--disable-doc",
                        "--disable-lzma-links",
                        "--disable-lzmadec",
                        "--disable-lzmainfo",
                        "--disable-nls",
                        "--disable-scripts",
                        "--disable-xz",
                        "--disable-xzdec",
                    ],
                ),
                # Package(
                #     name="gmp",
                #     source_url="https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz",
                #     # out-of-tree builds fail on Windows
                #     # build_dir=".",
                # ),
                # Package(
                #     name="png",
                #     source_url="http://deb.debian.org/debian/pool/main/libp/libpng1.6/libpng1.6_1.6.43.orig.tar.gz",
                #     # avoid an assembler error on Windows
                #     build_arguments=["PNG_COPTS=-fno-asynchronous-unwind-tables"],
                # ),
                # Package(
                #     name="xml2",
                #     requires=["xz"],
                #     source_url="https://download.gnome.org/sources/libxml2/2.12/libxml2-2.12.6.tar.xz",
                #     build_arguments=["--without-python"],
                # ),
                # Package(
                #     name="freetype",
                #     requires=["png"],
                #     source_url="https://download.savannah.gnu.org/releases/freetype/freetype-2.13.2.tar.xz",
                #     # At this point we have not built our own harfbuzz and we do NOT want to
                #     # pick up the system's harfbuzz.
                #     build_arguments=["--with-harfbuzz=no"],
                # ),
                # Package(
                #     name="fontconfig",
                #     requires=["freetype", "xml2"],
                #     source_url="https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.15.0.tar.xz",
                #     build_arguments=["--disable-nls", "--enable-libxml2"],
                # ),
                # Package(
                #     name="fribidi",
                #     source_url="https://github.com/fribidi/fribidi/releases/download/v1.0.13/fribidi-1.0.13.tar.xz",
                # ),
                # Package(
                #     name="harfbuzz",
                #     requires=["freetype"],
                #     source_url="https://github.com/harfbuzz/harfbuzz/releases/download/8.3.1/harfbuzz-8.3.1.tar.xz",
                #     build_arguments=[
                #         "--with-cairo=no",
                #         "--with-chafa=no",
                #         "--with-freetype=yes",
                #         "--with-glib=no",
                #     ],
                #     # parallel build fails on Windows
                #     build_parallel=False if IS_PLATFORM_WINDOWS else True,
                # ),
            ]

        # GNU tls
        # if IS_PLATFORM_LINUX:
        #     library_group += [
        #         Package(
        #             name="unistring",
        #             source_url="https://ftp.gnu.org/gnu/libunistring/libunistring-1.2.tar.gz",
        #         ),
        #         Package(
        #             name="nettle",
        #             requires=["gmp"],
        #             source_url="https://ftp.gnu.org/gnu/nettle/nettle-3.9.1.tar.gz",
        #             build_arguments=["--disable-documentation"],
        #             # build randomly fails with "*** missing separator.  Stop."
        #             build_parallel=False,
        #         ),
        #         Package(
        #             name="gnutls",
        #             requires=["nettle", "unistring"],
        #             source_url="https://www.gnupg.org/ftp/gcrypt/gnutls/v3.8/gnutls-3.8.3.tar.xz",
        #             build_arguments=[
        #                 "--disable-cxx",
        #                 "--disable-doc",
        #                 "--disable-guile",
        #                 "--disable-libdane",
        #                 "--disable-nls",
        #                 "--disable-tests",
        #                 "--disable-tools",
        #                 "--with-included-libtasn1",
        #                 "--without-p11-kit",
        #             ],
        #         ),
        #     ]

        # codecs
        codec_group = []
        # codec_group = [
        #     Package(
        #         name="openjpeg",
        #         requires=["cmake"],
        #         source_filename="openjpeg-2.5.2.tar.gz",
        #         source_url="https://github.com/uclouvain/openjpeg/archive/v2.5.2.tar.gz",
        #         build_system="cmake",
        #     ),
        # ]

        # FFmpeg
        ffmpeg_package = Package(
            name="ffmpeg",
            source_url="https://ffmpeg.org/releases/ffmpeg-6.1.1.tar.xz",
            build_arguments=ffmpeg_build_args,
        )

        # packages
        package_groups = [library_group, codec_group, [ffmpeg_package]]
        if build_stage is not None:
            packages = package_groups[build_stage]
        else:
            packages = [p for p_list in package_groups for p in p_list]

        # Build packages
        for package in packages:
            builder.build(package)


    if IS_PLATFORM_WINDOWS and (build_stage is None or build_stage == 2):
        deploy_dir = builder.deploy_dir()
        # fix .lib files being installed in the wrong directory
        for name in [
            "avcodec",
            "avdevice",
            "avfilter",
            "avformat",
            "avutil",
            "postproc",
            "swresample",
            "swscale",
        ]:
            try:
                shutil.move(
                    os.path.join(deploy_dir, "bin", name + ".lib"),
                    os.path.join(deploy_dir, "lib"),
                )
            except Exception as e:
                print(e)

        # copy some libraries provided by mingw
        mingw_bindir = os.path.dirname(
            subprocess.run(["where", "gcc"], check=True, stdout=subprocess.PIPE)
            .stdout.decode()
            .splitlines()[0]
            .strip()
        )
        for name in [
            "libgcc_s_seh-1.dll",
            "libiconv-2.dll",
            "libstdc++-6.dll",
            "libwinpthread-1.dll",
            "zlib1.dll",
        ]:
            shutil.copy(os.path.join(mingw_bindir, name), os.path.join(deploy_dir, "bin"))

    # find libraries
    deploy_dir = builder.deploy_dir()
    if IS_PLATFORM_LINUX:
        libraries = glob.glob(os.path.join(deploy_dir, "lib", "*.so"))
    elif IS_PLATFORM_WINDOWS:
        libraries = glob.glob(os.path.join(deploy_dir, "bin", "*.dll"))
    elif IS_PLATFORM_DARWIN:
        libraries = glob.glob(os.path.join(deploy_dir, "lib", "*.dylib"))

    # strip libraries
    # if IS_PLATFORM_DARWIN:
    #     run(["strip", "-S"] + libraries)
    #     run(["otool", "-L"] + libraries)
    # else:
    #     run(["strip", "-s"] + libraries)

    # build output tarball
    if build_stage is None or build_stage == 2:
        os.makedirs(deploy_dir, exist_ok=True)
        run(["tar", "czvf", output_package, "-C", deploy_dir, "bin", "include", "lib"])


if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    main()