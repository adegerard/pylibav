from collections.abc import Mapping
from pylibav.enum cimport define_enum
cimport pylibav.libav as libav
from ..libav cimport (
    AVFrameSideDataType,
)
from ..dictionary cimport wrap_dictionary
from .motionvectors cimport MotionVectors


cdef object _cinit_bypass_sentinel = object()


Type = define_enum("Type", __name__, (
    ("PANSCAN", AVFrameSideDataType.AV_FRAME_DATA_PANSCAN),
    ("A53_CC", libav.AV_FRAME_DATA_A53_CC),
    ("STEREO3D", libav.AV_FRAME_DATA_STEREO3D),
    ("MATRIXENCODING", libav.AV_FRAME_DATA_MATRIXENCODING),
    ("DOWNMIX_INFO", libav.AV_FRAME_DATA_DOWNMIX_INFO),
    ("REPLAYGAIN", libav.AV_FRAME_DATA_REPLAYGAIN),
    ("DISPLAYMATRIX", libav.AV_FRAME_DATA_DISPLAYMATRIX),
    ("AFD", libav.AV_FRAME_DATA_AFD),
    ("MOTION_VECTORS", libav.AV_FRAME_DATA_MOTION_VECTORS),
    ("SKIP_SAMPLES", libav.AV_FRAME_DATA_SKIP_SAMPLES),
    ("AUDIO_SERVICE_TYPE", libav.AV_FRAME_DATA_AUDIO_SERVICE_TYPE),
    ("MASTERING_DISPLAY_METADATA", libav.AV_FRAME_DATA_MASTERING_DISPLAY_METADATA),
    ("GOP_TIMECODE", libav.AV_FRAME_DATA_GOP_TIMECODE),
    ("SPHERICAL", libav.AV_FRAME_DATA_SPHERICAL),
    ("CONTENT_LIGHT_LEVEL", libav.AV_FRAME_DATA_CONTENT_LIGHT_LEVEL),
    ("ICC_PROFILE", libav.AV_FRAME_DATA_ICC_PROFILE),
    ("SEI_UNREGISTERED", libav.AV_FRAME_DATA_SEI_UNREGISTERED) if libav.AV_FRAME_DATA_SEI_UNREGISTERED != -1 else None,
))


cdef SideData wrap_side_data(Frame frame, int index):
    cdef AVFrameSideDataType type_ = frame.ptr.side_data[index].type
    if type_ == libav.AV_FRAME_DATA_MOTION_VECTORS:
        return MotionVectors(_cinit_bypass_sentinel, frame, index)
    else:
        return SideData(_cinit_bypass_sentinel, frame, index)


cdef class SideData(Buffer):
    def __init__(self, sentinel, Frame frame, int index):
        if sentinel is not _cinit_bypass_sentinel:
            raise RuntimeError("cannot manually instatiate SideData")
        self.frame = frame
        self.ptr = frame.ptr.side_data[index]
        self.metadata = wrap_dictionary(self.ptr.metadata)

    cdef size_t _buffer_size(self):
        return self.ptr.size

    cdef void* _buffer_ptr(self):
        return self.ptr.data

    cdef bint _buffer_writable(self):
        return False

    def __repr__(self):
        return f"<pylibav.sidedata.{self.__class__.__name__} {self.ptr.size} bytes of {self.type} at 0x{<unsigned int>self.ptr.data:0x}>"

    @property
    def type(self):
        return Type.get(self.ptr.type) or self.ptr.type


cdef class _SideDataContainer:
    def __init__(self, Frame frame):
        self.frame = frame
        self._by_index = []
        self._by_type = {}

        cdef int i
        cdef SideData data
        for i in range(self.frame.ptr.nb_side_data):
            data = wrap_side_data(frame, i)
            self._by_index.append(data)
            self._by_type[data.type] = data

    def __len__(self):
        return len(self._by_index)

    def __iter__(self):
        return iter(self._by_index)

    def __getitem__(self, key):
        if isinstance(key, int):
            return self._by_index[key]

        type_ = Type.get(key)
        return self._by_type[type_]


class SideDataContainer(_SideDataContainer, Mapping):
    pass
