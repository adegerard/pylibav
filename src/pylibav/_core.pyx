from pylibav.libav cimport libav

# Initialise libraries.
libav.avformat_network_init()
libav.avdevice_register_all()

# Exports.
time_base = libav.AV_TIME_BASE


cdef decode_version(v):
    if v < 0:
        return (-1, -1, -1)

    cdef int major = (v >> 16) & 0xff
    cdef int minor = (v >> 8) & 0xff
    cdef int micro = (v) & 0xff

    return (major, minor, micro)

library_meta = {
    "libavutil": dict(
        version=decode_version(libav.avutil_version()),
        configuration=libav.avutil_configuration(),
        license=libav.avutil_license()
    ),
    "libavcodec": dict(
        version=decode_version(libav.avcodec_version()),
        configuration=libav.avcodec_configuration(),
        license=libav.avcodec_license()
    ),
    "libavformat": dict(
        version=decode_version(libav.avformat_version()),
        configuration=libav.avformat_configuration(),
        license=libav.avformat_license()
    ),
    "libavdevice": dict(
        version=decode_version(libav.avdevice_version()),
        configuration=libav.avdevice_configuration(),
        license=libav.avdevice_license()
    ),
    "libavfilter": dict(
        version=decode_version(libav.avfilter_version()),
        configuration=libav.avfilter_configuration(),
        license=libav.avfilter_license()
    ),
    "libswscale": dict(
        version=decode_version(libav.swscale_version()),
        configuration=libav.swscale_configuration(),
        license=libav.swscale_license()
    ),
    "libswresample": dict(
        version=decode_version(libav.swresample_version()),
        configuration=libav.swresample_configuration(),
        license=libav.swresample_license()
    ),
}

library_versions = {name: meta["version"] for name, meta in library_meta.items()}
