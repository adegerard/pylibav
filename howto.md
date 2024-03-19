
This project is a fork of [PyAV](https://github.com/PyAV-Org/PyAV).

What differs from the original branch
- removed some video decoders/encoders
- removed some audio codecs


## Compilation

### Debian 12
```sh
sudo apt-get install \
    autoconf \
    automake \
    build-essential \
    libtool \
    pkg-config \
    wget \
    mercurial \
    texinfo \
    zlib1g-dev \
    cmake-doc ninja-build cmake-format
conda activate pyav
pip install --upgrade -r requirements
python scripts/fetch-vendor.py --config-file scripts/ffmpeg-6.1.json /tmp/pyav
./build_local.sh
```


And if you want to build from the absolute source (POSIX only):

```bash
git clone https://github.com/PyAV-Org/PyAV.git
cd PyAV
source scripts/activate.sh

# Either install the testing dependencies:
pip install --upgrade -r tests/requirements.txt
# or have it all, including FFmpeg, built/installed for you:
./scripts/build-deps

# Build PyAV.
make
pip install .
```


# pyav-ffmpeg-lite

This project is a fork of [pyav-ffmpeg](https://github.com/PyAV-Org/pyav-ffmpeg).
It provides binary builds of FFmpeg and its dependencies for [pyav-lite](https://github.com/adegerard/pyav-ffmpeg-lite).

Build for the following platforms:
- Debian 12 (x86_64)
- Windows 11 (AMD64)

What differs from the original branch
- removed some video decoders/encoders
- removed some audio codecs

## Build:
- Linux, python 3.11.8
    ```sh
    conda create -n pyav python==3.11.8
    conda activate pyav
    sudo apt-get install gcc curl nasm
    python scripts/build-ffmpeg.py /tmp/pyav_ffmpeg_lite
    ```

- Windows  11, python 3.11.8, MSYS2(mingw64)
    ```sh
    pacman -Suy
    pacman -S mingw-w64-x86_64-python mingw-w64-x86_64-python-pip
    pacman -S mingw-w64-x86_64-zlib-devel
    base-devel zlib-devel mingw-w64-x86_64-gcc mingw-w64-x86_64-cmake
    pacman -S mingw-w64-x86_64-gperf mingw-w64-x86_64-nasm
    python scripts/build-ffmpeg.py /a/tmp/pyav_ffmpeg_lite
    ```


`python -m build --wheel`
