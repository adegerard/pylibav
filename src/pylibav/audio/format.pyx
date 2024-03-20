import sys
import pylibav.libav as libav
from ..libav cimport (
    AVSampleFormat,
    av_get_sample_fmt,
    av_get_sample_fmt_name,
    av_get_bytes_per_sample,
    av_sample_fmt_is_planar,
    av_get_packed_sample_fmt,
    av_get_planar_sample_fmt,
)

cdef str container_format_postfix = "le" if sys.byteorder == "little" else "be"


cdef object _cinit_bypass_sentinel

cdef AudioFormat get_audio_format(AVSampleFormat c_format):
    """Get an AudioFormat without going through a string."""

    if c_format < 0:
        return None

    cdef AudioFormat format = AudioFormat.__new__(AudioFormat, _cinit_bypass_sentinel)
    format._init(c_format)
    return format


cdef class AudioFormat:
    """Descriptor of audio formats."""

    def __cinit__(self, name):
        if name is _cinit_bypass_sentinel:
            return

        cdef AVSampleFormat sample_fmt
        if isinstance(name, AudioFormat):
            sample_fmt = (<AudioFormat>name).sample_fmt
        else:
            sample_fmt = av_get_sample_fmt(name)

        if sample_fmt < 0:
            raise ValueError(f"Not a sample format: {name!r}")

        self._init(sample_fmt)

    cdef _init(self, AVSampleFormat sample_fmt):
        self.sample_fmt = sample_fmt

    def __repr__(self):
        return f"<pylibav.AudioFormat {self.name}>"

    @property
    def name(self):
        """Canonical name of the sample format.

        >>> SampleFormat('s16p').name
        's16p'

        """
        return <str>av_get_sample_fmt_name(self.sample_fmt)

    @property
    def bytes(self):
        """Number of bytes per sample.

        >>> SampleFormat('s16p').bytes
        2

        """
        return av_get_bytes_per_sample(self.sample_fmt)

    @property
    def bits(self):
        """Number of bits per sample.

        >>> SampleFormat('s16p').bits
        16

        """
        return av_get_bytes_per_sample(self.sample_fmt) << 3

    @property
    def is_planar(self):
        """Is this a planar format?

        Strictly opposite of :attr:`is_packed`.

        """
        return bool(av_sample_fmt_is_planar(self.sample_fmt))

    @property
    def is_packed(self):
        """Is this a planar format?

        Strictly opposite of :attr:`is_planar`.

        """
        return not av_sample_fmt_is_planar(self.sample_fmt)

    @property
    def planar(self):
        """The planar variant of this format.

        Is itself when planar:

        >>> from pylibav import AudioFormat as Format
        >>> fmt = Format('s16p')
        >>> fmt.planar is fmt
        True

        """
        if self.is_planar:
            return self
        return get_audio_format(av_get_planar_sample_fmt(self.sample_fmt))

    @property
    def packed(self):
        """The packed variant of this format.

        Is itself when packed:

        >>> fmt = Format('s16')
        >>> fmt.packed is fmt
        True

        """
        if self.is_packed:
            return self
        return get_audio_format(av_get_packed_sample_fmt(self.sample_fmt))

    @property
    def container_name(self):
        """The name of a :class:`ContainerFormat` which directly accepts this data.

        :raises ValueError: when planar, since there are no such containers.

        """
        if self.is_planar:
            raise ValueError("no planar container formats")

        if self.sample_fmt == libav.AV_SAMPLE_FMT_U8:
            return "u8"
        elif self.sample_fmt == libav.AV_SAMPLE_FMT_S16:
            return "s16" + container_format_postfix
        elif self.sample_fmt == libav.AV_SAMPLE_FMT_S32:
            return "s32" + container_format_postfix
        elif self.sample_fmt == libav.AV_SAMPLE_FMT_FLT:
            return "f32" + container_format_postfix
        elif self.sample_fmt == libav.AV_SAMPLE_FMT_DBL:
            return "f64" + container_format_postfix

        raise ValueError("unknown layout")
