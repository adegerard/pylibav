from libc.stdint cimport int32_t
import warnings
from .enum_type cimport define_enum
from .error cimport err_check
from .utils cimport (
    avdict_to_dict,
    avrational_to_fraction,
    dict_to_avdict,
    to_avrational,
)
from pylibav.libav cimport (
    AVStream,
    AVMediaType,
    avcodec_parameters_from_context,
    av_get_media_type_string,
    av_display_rotation_get,
    AVPacketSideDataType,
    AV_NOPTS_VALUE,
)
from .video.stream import VideoStream
# from .audio.stream import AudioStream
# from .subtitles.stream import SubtitleStream
from .data.stream import DataStream
from .deprecation import AVDeprecationWarning


cdef object _cinit_bypass_sentinel = object()


# If necessary more can be added from
# https://ffmpeg.org/doxygen/trunk/group__lavc__packet.html#ga9a80bfcacc586b483a973272800edb97
SideData = define_enum("SideData", __name__, (
    ("DISPLAYMATRIX", AVPacketSideDataType.AV_PKT_DATA_DISPLAYMATRIX, "Display Matrix"),
))

cdef Stream wrap_stream(Container container, AVStream *c_stream, CodecContext codec_context):
    """Build an pylibav.Stream for an existing AVStream.

    The AVStream MUST be fully constructed and ready for use before this is
    called.

    """

    # This better be the right one...
    assert container.ptr.streams[c_stream.index] == c_stream

    cdef Stream py_stream
    cdef AVMediaType av_type = c_stream.codecpar.codec_type
    if av_type == AVMediaType.AVMEDIA_TYPE_VIDEO:
        py_stream = VideoStream.__new__(VideoStream, _cinit_bypass_sentinel)

    # elif av_type == AVMediaType.AVMEDIA_TYPE_AUDIO:
    #     py_stream = AudioStream.__new__(AudioStream, _cinit_bypass_sentinel)

    # elif av_type == AVMediaType.AVMEDIA_TYPE_SUBTITLE:
    #     py_stream = SubtitleStream.__new__(SubtitleStream, _cinit_bypass_sentinel)

    elif av_type == AVMediaType.AVMEDIA_TYPE_DATA:
        py_stream = DataStream.__new__(DataStream, _cinit_bypass_sentinel)

    else:
        py_stream = Stream.__new__(Stream, _cinit_bypass_sentinel)

    py_stream._init(container, c_stream, codec_context)
    return py_stream


cdef class Stream:
    """
    A single stream of audio, video or subtitles within a :class:`.Container`.

    ::

        >>> fh = pylibav.open(video_path)
        >>> stream = fh.streams.video[0]
        >>> stream
        <pylibav.VideoStream #0 h264, yuv420p 1280x720 at 0x...>

    This encapsulates a :class:`.CodecContext`, located at :attr:`Stream.codec_context`.
    Attribute access is passed through to that context when attributes are missing
    on the stream itself. E.g. ``stream.options`` will be the options on the
    context.
    """

    def __cinit__(self, name):
        if name is _cinit_bypass_sentinel:
            return
        raise RuntimeError("cannot manually instantiate Stream")

    cdef _init(self, Container container, AVStream *stream, CodecContext codec_context):
        self.container = container
        self.ptr = stream

        self.codec_context = codec_context
        if self.codec_context:
            self.codec_context.stream_index = stream.index

        self.nb_side_data, self.side_data = self._get_side_data(stream)

        self.metadata = avdict_to_dict(
            stream.metadata,
            encoding=self.container.metadata_encoding,
            errors=self.container.metadata_errors,
        )

    def __repr__(self):
        return (
            f"<pylibav.{self.__class__.__name__} #{self.index} {self.type or '<notype>'}/"
            f"{self.name or '<nocodec>'} at 0x{id(self):x}>"
        )

    def __getattr__(self, name):
        # Deprecate framerate pass-through as it is not always set.
        # See: https://github.com/PyAV-Org/PyAV/issues/1005
        if (
            <AVMediaType>self.ptr.codecpar.codec_type == AVMediaType.AVMEDIA_TYPE_VIDEO
            and name in ("framerate", "rate")
        ):
            warnings.warn(
                f"VideoStream.{name} is deprecated as it is not always set; please use VideoStream.average_rate.",
                AVDeprecationWarning
            )

        if name == "side_data":
            return self.side_data
        elif name == "nb_side_data":
            return self.nb_side_data

        # Convenience getter for codec context properties.
        if self.codec_context is not None:
            return getattr(self.codec_context, name)

    def __setattr__(self, name, value):
        if name == "id":
            self._set_id(value)
            return

        # Convenience setter for codec context properties.
        if self.codec_context is not None:
            setattr(self.codec_context, name, value)

        if name == "time_base":
            self._set_time_base(value)

    cdef _finalize_for_output(self):

        dict_to_avdict(
            &self.ptr.metadata, self.metadata,
            encoding=self.container.metadata_encoding,
            errors=self.container.metadata_errors,
        )

        if not self.ptr.time_base.num:
            self.ptr.time_base = self.codec_context.ptr.time_base

        # It prefers if we pass it parameters via this other object.
        # Lets just copy what we want.
        err_check(avcodec_parameters_from_context(self.ptr.codecpar, self.codec_context.ptr))

    cdef _get_side_data(self, AVStream *stream):
        # Get DISPLAYMATRIX SideData from a libav.AVStream object.
        # Returns: tuple[int, dict[str, Any]]

        nb_side_data = stream.codecpar.nb_coded_side_data
        side_data = {}

        for i in range(nb_side_data):
            # Based on: https://www.ffmpeg.org/doxygen/trunk/dump_8c_source.html#l00430
            if (
                <AVPacketSideDataType>stream.codecpar.coded_side_data[i].type
                == AVPacketSideDataType.AV_PKT_DATA_DISPLAYMATRIX
            ):
                side_data["DISPLAYMATRIX"] = av_display_rotation_get(
                    <const int32_t *>stream.codecpar.coded_side_data[i].data
                )

        return nb_side_data, side_data

    @property
    def id(self):
        """
        The format-specific ID of this stream.

        :type: int

        """
        return self.ptr.id

    cdef _set_id(self, value):
        """
        Setter used by __setattr__ for the id property.
        """
        if value is None:
            self.ptr.id = 0
        else:
            self.ptr.id = value

    @property
    def profile(self):
        """
        The profile of this stream.

        :type: str
        """
        if self.codec_context:
            return self.codec_context.profile
        else:
            return None

    @property
    def index(self):
        """
        The index of this stream in its :class:`.Container`.

        :type: int
        """
        return self.ptr.index


    @property
    def time_base(self):
        """
        The unit of time (in fractional seconds) in which timestamps are expressed.

        :type: :class:`~fractions.Fraction` or ``None``

        """
        return avrational_to_fraction(&self.ptr.time_base)

    cdef _set_time_base(self, value):
        """
        Setter used by __setattr__ for the time_base property.
        """
        to_avrational(value, &self.ptr.time_base)

    @property
    def start_time(self):
        """
        The presentation timestamp in :attr:`time_base` units of the first
        frame in this stream.

        :type: :class:`int` or ``None``
        """
        if self.ptr.start_time != AV_NOPTS_VALUE:
            return self.ptr.start_time

    @property
    def duration(self):
        """
        The duration of this stream in :attr:`time_base` units.

        :type: :class:`int` or ``None``

        """
        if self.ptr.duration != AV_NOPTS_VALUE:
            return self.ptr.duration

    @property
    def frames(self):
        """
        The number of frames this stream contains.

        Returns ``0`` if it is not known.

        :type: :class:`int`
        """
        return self.ptr.nb_frames

    @property
    def language(self):
        """
        The language of the stream.

        :type: :class:`str` or ``None``
        """
        return self.metadata.get('language')

    @property
    def type(self):
        """
        The type of the stream.

        Examples: ``'audio'``, ``'video'``, ``'subtitle'``.

        :type: str
        """
        return av_get_media_type_string(self.ptr.codecpar.codec_type)
