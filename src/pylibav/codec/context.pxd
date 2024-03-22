from libc.stdint cimport int64_t
from pylibav.libav cimport (
    AVCodec,
    AVCodecContext,
    AVCodecParserContext,
)
from pylibav.codec.codec cimport Codec
from pylibav.frame cimport Frame
from pylibav.packet cimport Packet


cdef class CodecContext:

    cdef AVCodecContext *ptr

    # Whether AVCodecContext.extradata should be de-allocated upon destruction.
    cdef bint extradata_set

    # Used as a signal that this is within a stream, and also for us to access
    # that stream. This is set "manually" by the stream after constructing
    # this object.
    cdef int stream_index

    cdef AVCodecParserContext *parser

    cdef _init(self, AVCodecContext *ptr, const AVCodec *codec)

    cdef readonly Codec codec

    cdef public dict options

    # Public API.
    cpdef open(self, bint strict=?)
    cpdef close(self, bint strict=?)

    cdef _set_default_time_base(self)

    # Wraps both versions of the transcode API, returning lists.
    cpdef encode(self, Frame frame=?)
    cpdef decode(self, Packet packet=?)

    # Used by both transcode APIs to setup user-land objects.
    # TODO: Remove the `Packet` from `_setup_decoded_frame` (because flushing
    # packets are bogus). It should take all info it needs from the context and/or stream.
    cdef _prepare_and_time_rebase_frames_for_encode(self, Frame frame)
    cdef _prepare_frames_for_encode(self, Frame frame)
    cdef _setup_encoded_packet(self, Packet)
    cdef _setup_decoded_frame(self, Frame, Packet)

    # Implemented by base for the generic send/recv API.
    # Note that the user cannot send without recieving. This is because
    # _prepare_frames_for_encode may expand a frame into multiple (e.g. when
    # resampling audio to a higher rate but with fixed size frames), and the
    # send/recv buffer may be limited to a single frame. Ergo, we need to flush
    # the buffer as often as possible.
    cdef _recv_packet(self)
    cdef _send_packet_and_recv(self, Packet packet)
    cdef _recv_frame(self)

    # Implemented by children for the generic send/recv API, so we have the
    # correct subclass of Frame.
    cdef Frame _next_frame
    cdef Frame _alloc_next_frame(self)


cdef CodecContext wrap_codec_context(AVCodecContext*, const AVCodec*)