cimport pylibav.libav as libav
from .enum_type cimport define_enum
from .utils cimport flag_in_bitfield


cdef object _cinit_sentinel = object()

cdef Option wrap_option(tuple choices, const libav.AVOption *ptr):
    if ptr == NULL:
        return None
    cdef Option obj = Option(_cinit_sentinel)
    obj.ptr = ptr
    obj.choices = choices
    return obj


OptionType = define_enum("OptionType", __name__, (
    ("FLAGS", libav.AV_OPT_TYPE_FLAGS),
    ("INT", libav.AV_OPT_TYPE_INT),
    ("INT64", libav.AV_OPT_TYPE_INT64),
    ("DOUBLE", libav.AV_OPT_TYPE_DOUBLE),
    ("FLOAT", libav.AV_OPT_TYPE_FLOAT),
    ("STRING", libav.AV_OPT_TYPE_STRING),
    ("RATIONAL", libav.AV_OPT_TYPE_RATIONAL),
    ("BINARY", libav.AV_OPT_TYPE_BINARY),
    ("DICT", libav.AV_OPT_TYPE_DICT),
    # ("UINT64", libav.AV_OPT_TYPE_UINT64), # Added recently, and not yet used AFAICT.
    ("CONST", libav.AV_OPT_TYPE_CONST),
    ("IMAGE_SIZE", libav.AV_OPT_TYPE_IMAGE_SIZE),
    ("PIXEL_FMT", libav.AV_OPT_TYPE_PIXEL_FMT),
    ("SAMPLE_FMT", libav.AV_OPT_TYPE_SAMPLE_FMT),
    ("VIDEO_RATE", libav.AV_OPT_TYPE_VIDEO_RATE),
    ("DURATION", libav.AV_OPT_TYPE_DURATION),
    ("COLOR", libav.AV_OPT_TYPE_COLOR),
    ("CHANNEL_LAYOUT", libav.AV_OPT_TYPE_CHANNEL_LAYOUT),
    ("BOOL", libav.AV_OPT_TYPE_BOOL),
))

cdef tuple _INT_TYPES = (
    libav.AV_OPT_TYPE_FLAGS,
    libav.AV_OPT_TYPE_INT,
    libav.AV_OPT_TYPE_INT64,
    libav.AV_OPT_TYPE_PIXEL_FMT,
    libav.AV_OPT_TYPE_SAMPLE_FMT,
    libav.AV_OPT_TYPE_DURATION,
    libav.AV_OPT_TYPE_CHANNEL_LAYOUT,
    libav.AV_OPT_TYPE_BOOL,
)

OptionFlags = define_enum("OptionFlags", __name__, (
    ("ENCODING_PARAM", libav.AV_OPT_FLAG_ENCODING_PARAM),
    ("DECODING_PARAM", libav.AV_OPT_FLAG_DECODING_PARAM),
    ("AUDIO_PARAM", libav.AV_OPT_FLAG_AUDIO_PARAM),
    ("VIDEO_PARAM", libav.AV_OPT_FLAG_VIDEO_PARAM),
    ("SUBTITLE_PARAM", libav.AV_OPT_FLAG_SUBTITLE_PARAM),
    ("EXPORT", libav.AV_OPT_FLAG_EXPORT),
    ("READONLY", libav.AV_OPT_FLAG_READONLY),
    ("FILTERING_PARAM", libav.AV_OPT_FLAG_FILTERING_PARAM),
), is_flags=True)

cdef class BaseOption:
    def __cinit__(self, sentinel):
        if sentinel is not _cinit_sentinel:
            raise RuntimeError(f"Cannot construct pylibav.{self.__class__.__name__}")

    @property
    def name(self):
        return self.ptr.name

    @property
    def help(self):
        return self.ptr.help if self.ptr.help != NULL else ""

    @property
    def flags(self):
        return self.ptr.flags

    # Option flags
    @property
    def is_encoding_param(self):
        return flag_in_bitfield(self.ptr.flags, libav.AV_OPT_FLAG_ENCODING_PARAM)
    @property
    def is_decoding_param(self):
        return flag_in_bitfield(self.ptr.flags, libav.AV_OPT_FLAG_DECODING_PARAM)
    @property
    def is_audio_param(self):
        return flag_in_bitfield(self.ptr.flags, libav.AV_OPT_FLAG_AUDIO_PARAM)
    @property
    def is_video_param(self):
        return flag_in_bitfield(self.ptr.flags, libav.AV_OPT_FLAG_VIDEO_PARAM)
    @property
    def is_subtitle_param(self):
        return flag_in_bitfield(self.ptr.flags, libav.AV_OPT_FLAG_SUBTITLE_PARAM)
    @property
    def is_export(self):
        return flag_in_bitfield(self.ptr.flags, libav.AV_OPT_FLAG_EXPORT)
    @property
    def is_readonly(self):
        return flag_in_bitfield(self.ptr.flags, libav.AV_OPT_FLAG_READONLY)
    @property
    def is_filtering_param(self):
        return flag_in_bitfield(self.ptr.flags, libav.AV_OPT_FLAG_FILTERING_PARAM)


cdef class Option(BaseOption):
    @property
    def type(self):
        return OptionType._get(self.ptr.type, create=True)

    @property
    def offset(self):
        """
        This can be used to find aliases of an option.
        Options in a particular descriptor with the same offset are aliases.
        """
        return self.ptr.offset

    @property
    def default(self):
        if self.ptr.type in _INT_TYPES:
            return self.ptr.default_val.i64

        if self.ptr.type in (
            libav.AV_OPT_TYPE_DOUBLE,
            libav.AV_OPT_TYPE_FLOAT,
            libav.AV_OPT_TYPE_RATIONAL
        ):
            return self.ptr.default_val.dbl

        if self.ptr.type in (
            libav.AV_OPT_TYPE_STRING,
            libav.AV_OPT_TYPE_BINARY,
            libav.AV_OPT_TYPE_IMAGE_SIZE,
            libav.AV_OPT_TYPE_VIDEO_RATE,
            libav.AV_OPT_TYPE_COLOR
        ):
            return self.ptr.default_val.str if self.ptr.default_val.str != NULL else ""


    def _norm_range(self, value):
        if self.ptr.type in _INT_TYPES:
            return int(value)
        return value

    @property
    def min(self):
        return self._norm_range(self.ptr.min)

    @property
    def max(self):
        return self._norm_range(self.ptr.max)

    def __repr__(self):
        return (
            f"<pylibav.{self.__class__.__name__} {self.name}"
            f" ({self.type} at *0x{self.offset:x}) at 0x{id(self):x}>"
        )


cdef OptionChoice wrap_option_choice(const AVOption *ptr, bint is_default):
    if ptr == NULL:
        return None

    cdef OptionChoice obj = OptionChoice(_cinit_sentinel)
    obj.ptr = ptr
    obj.is_default = is_default
    return obj


cdef class OptionChoice(BaseOption):
    """
    Represents AV_OPT_TYPE_CONST options which are essentially
    choices of non-const option with same unit.
    """

    @property
    def value(self):
        return self.ptr.default_val.i64

    def __repr__(self):
        return f"<pylibav.{self.__class__.__name__} {self.name} at 0x{id(self):x}>"
