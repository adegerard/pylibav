import argparse
import os
from pprint import pprint
from utils import *
import shutil
import signal
import subprocess


# https://github.com/FFmpeg/FFmpeg/blob/master/configure
ffmpeg_options = [
    # Licensing options
    "--enable-gpl",
    "--enable-version3",

    # Configuration options
    "--disable-static",
    "--enable-shared",

    # Program options
    # "--disable-programs",
    # "--disable-ffmpeg",
    "--disable-ffplay",
    "--disable-ffprobe",

    # Documentation options
    "--disable-doc",
    # "--disable-htmlpages",
    # "--disable-manpages",
    # "--disable-podpages",
    # "--disable-txtpages",

    # Component options
    # "--disable-avdevice",
    # "--disable-avcodec",
    # "--disable-avformat",
    # "--disable-swresample",
    # "--disable-swscale",
    # "--disable-postproc",
    # "--disable-avfilter",
    "--disable-network",
    # "--disable-pixelutils",


    # Individual component options
    # ...

    # External library support:
    "--disable-alsa",
    "--disable-gnutls",
    "--disable-mediafoundation",
    "--disable-sndio",

    # TODO: enable this?
    # "--enable-libopencv",

    # "--disable-w32threads",

]
OS_SEP = ';' if IS_PLATFORM_WINDOWS else ':'

def get_environment(workdir: str) -> dict[str, str]:
    os_env = os.environ.copy()
    def prepend_env_entry(env, entry, value):
        new_value = OS_SEP.join([value, env.get(entry, '')])
        env[entry] = new_value

    include_dir = os.path.join(workdir, "include")
    lib_dir = os.path.join(workdir, "lib")
    prepend_env_entry(os_env, "CPPFLAGS", f"-I{include_dir}")
    prepend_env_entry(os_env, "LDFLAGS", f"-L{lib_dir}")
    # prepend_env_entry(os_env, "CPPFLAGS", f"{include_dir}")
    # prepend_env_entry(os_env, "LDFLAGS", f"{lib_dir}")
    print("----------------------------------------------")
    pprint(os_env)
    print("----------------------------------------------")

    return os_env



def main() -> None:
    parser = argparse.ArgumentParser("build-ffmpeg")
    parser.add_argument(
        "--build-dir",
        default="build"
    )
    parser.add_argument(
        "--rebuild",
        action="store_true",
        default=False
    )
    parser.add_argument(
        "--build_only",
        action="store_true",
        default=False
    )
    args = parser.parse_args()
    rebuild: bool = args.rebuild
    configure: bool = not args.build_only

    # Global
    build_dir = os.path.join(os.getcwd(), "build")
    download_dir = os.path.abspath(os.path.join(build_dir, "downloads"))


    # FFmpeg
    pkg_name = "ffmpeg"
    pkg_source_dir = os.path.abspath(os.path.join(
        os.getcwd(), os.pardir, pkg_name
    ))

    pkg_build_dirname = f"{pkg_name}-{get_platform_tag()}"
    workdir = os.path.abspath(os.path.join(build_dir, pkg_build_dirname))

    if rebuild and os.path.exists(workdir):
        shutil.rmtree(workdir)
    for d in (workdir, download_dir):
        os.makedirs(d, exist_ok=True)
    print(f"- source directory: {pkg_source_dir}")
    print(f"- work directory: {workdir}")

    # Package environment
    package_env = get_environment(workdir)

    if configure:
        # Configure
        lib_dir = os.path.join(workdir, "lib")
        # Configure command
        command = [
            "sh",
            f"{pkg_source_dir}/configure",
            f"--prefix={workdir}",
            # f"--libdir={lib_dir}",
            # f"--prefix={workdir}",
            # f"--incdir={workdir}",
            *ffmpeg_options,
        ]
        pprint(command)
        print(lightgreen(f"\n- [{pkg_name}] Configure"))
        subprocess.run(
            command,
            check=True,
            env=package_env,
            cwd=pkg_source_dir,
            stdout=None,
            stderr=None,
        )

    # Make
    command = [
        "make",
        "-j",
        "V=1"
    ]
    print(lightgreen(f"\n- [{pkg_name}] Make"))
    subprocess.run(
        command,
        check=True,
        env=package_env,
        cwd=pkg_source_dir,
        stdout=None,
        stderr=None,
    )

    # Make install
    command = ["make", "install"]
    print(lightgreen(f"\n- [{pkg_name}] Make install"))
    subprocess.run(
        command,
        check=True,
        env=package_env,
        cwd=pkg_source_dir,
        stdout=None,
        stderr=None,
    )


    # if IS_PLATFORM_WINDOWS:
    #     deploy_dir = builder.deploy_dir()
    #     # fix .lib files being installed in the wrong directory
    #     for name in [
    #         "avcodec",
    #         "avdevice",
    #         "avfilter",
    #         "avformat",
    #         "avutil",
    #         "postproc",
    #         "swresample",
    #         "swscale",
    #     ]:
    #         try:
    #             shutil.move(
    #                 os.path.join(deploy_dir, "bin", name + ".lib"),
    #                 os.path.join(deploy_dir, "lib"),
    #             )
    #         except Exception as e:
    #             print(e)

    #     # copy some libraries provided by mingw
    #     mingw_bindir = os.path.dirname(
    #         subprocess.run(["where", "gcc"], check=True, stdout=subprocess.PIPE)
    #         .stdout.decode()
    #         .splitlines()[0]
    #         .strip()
    #     )
    #     for name in [
    #         "libgcc_s_seh-1.dll",
    #         "libiconv-2.dll",
    #         "libstdc++-6.dll",
    #         "libwinpthread-1.dll",
    #         "zlib1.dll",
    #     ]:
    #         shutil.copy(os.path.join(mingw_bindir, name), os.path.join(deploy_dir, "bin"))

    # # find libraries
    # deploy_dir = builder.deploy_dir()
    # if IS_PLATFORM_LINUX:
    #     libraries = glob.glob(os.path.join(deploy_dir, "lib", "*.so"))
    # elif IS_PLATFORM_WINDOWS:
    #     libraries = glob.glob(os.path.join(deploy_dir, "bin", "*.dll"))

    # run(["strip", "-s"] + libraries)


if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    main()