from libc.stdint cimport uint8_t
from pylibav.libav cimport (
    libav,
    AVColorRange,
    sws_getCachedContext,
    sws_getCoefficients,
    sws_getColorspaceDetails,
    sws_setColorspaceDetails,
    sws_scale,
)
from pylibav.enum_type cimport define_enum
from pylibav.error cimport err_check
from .format cimport VideoFormat
from .frame cimport alloc_video_frame


Interpolation = define_enum("Interpolation", __name__, (
    ("FAST_BILINEAR", libav.SWS_FAST_BILINEAR, "Fast bilinear"),
    ("BILINEAR", libav.SWS_BILINEAR, "Bilinear"),
    ("BICUBIC", libav.SWS_BICUBIC, "Bicubic"),
    ("X", libav.SWS_X, "Experimental"),
    ("POINT", libav.SWS_POINT, "Nearest neighbor / point"),
    ("AREA", libav.SWS_AREA, "Area averaging"),
    ("BICUBLIN", libav.SWS_BICUBLIN, "Luma bicubic / chroma bilinear"),
    ("GAUSS", libav.SWS_GAUSS, "Gaussian"),
    ("SINC", libav.SWS_SINC, "Sinc"),
    ("LANCZOS", libav.SWS_LANCZOS, "Lanczos"),
    ("SPLINE", libav.SWS_SPLINE, "Bicubic spline"),
))


Colorspace = define_enum("Colorspace", __name__, (
    ("ITU709", libav.SWS_CS_ITU709),
    ("FCC", libav.SWS_CS_FCC),
    ("ITU601", libav.SWS_CS_ITU601),
    ("ITU624", libav.SWS_CS_ITU624),
    ("SMPTE170M", libav.SWS_CS_SMPTE170M),
    ("SMPTE240M", libav.SWS_CS_SMPTE240M),
    ("DEFAULT", libav.SWS_CS_DEFAULT),

    # Lowercase for b/c.
    ("itu709", libav.SWS_CS_ITU709),
    ("fcc", libav.SWS_CS_FCC),
    ("itu601", libav.SWS_CS_ITU601),
    ("itu624", libav.SWS_CS_SMPTE170M),
    ("smpte240", libav.SWS_CS_SMPTE240M),
    ("default", libav.SWS_CS_DEFAULT),

))


ColorRange = define_enum("ColorRange", __name__, (
    ("UNSPECIFIED", AVColorRange.AVCOL_RANGE_UNSPECIFIED, "Unspecified"),
    ("MPEG", AVColorRange.AVCOL_RANGE_MPEG, "MPEG (limited) YUV range, 219*2^(n-8)"),
    ("JPEG", AVColorRange.AVCOL_RANGE_JPEG, "JPEG (full) YUV range, 2^n-1"),
    ("NB", AVColorRange.AVCOL_RANGE_NB, "Not part of ABI"),
))

cdef class VideoReformatter:
    """An object for reformatting size and pixel format of :class:`.VideoFrame`.

    It is most efficient to have a reformatter object for each set of parameters
    you will use as calling :meth:`reformat` will reconfigure the internal object.

    """

    def __dealloc__(self):
        with nogil:
            libav.sws_freeContext(self.ptr)

    def reformat(
        self,
        VideoFrame frame not None,
        width=None,
        height=None,
        format=None,
        src_colorspace=None,
        dst_colorspace=None,
        interpolation=None,
        src_color_range=None,
        dst_color_range=None
        ):
        """Create a new :class:`VideoFrame` with the given width/height/format/colorspace.

        Returns the same frame untouched if nothing needs to be done to it.

        :param int width: New width, or ``None`` for the same width.
        :param int height: New height, or ``None`` for the same height.
        :param format: New format, or ``None`` for the same format.
        :type  format: :class:`.VideoFormat` or ``str``
        :param src_colorspace: Current colorspace, or ``None`` for the frame colorspace.
        :type  src_colorspace: :class:`Colorspace` or ``str``
        :param dst_colorspace: Desired colorspace, or ``None`` for the frame colorspace.
        :type  dst_colorspace: :class:`Colorspace` or ``str``
        :param interpolation: The interpolation method to use, or ``None`` for ``BILINEAR``.
        :type  interpolation: :class:`Interpolation` or ``str``
        :param src_color_range: Current color range, or ``None`` for the frame color range.
        :type  src_color_range: :class:`color range` or ``str``
        :param dst_color_range: Desired color range, or ``None`` for the frame color range.
        :type  dst_color_range: :class:`color range` or ``str``

        """

        cdef VideoFormat video_format = VideoFormat(format if format is not None else frame.format)
        cdef int c_src_colorspace = (Colorspace[src_colorspace].value if src_colorspace is not None else frame.colorspace)
        cdef int c_dst_colorspace = (Colorspace[dst_colorspace].value if dst_colorspace is not None else frame.colorspace)
        cdef int c_interpolation = (Interpolation[interpolation] if interpolation is not None else Interpolation.BILINEAR).value
        cdef int c_src_color_range = (ColorRange[src_color_range].value if src_color_range is not None else frame.color_range)
        cdef int c_dst_color_range = (ColorRange[dst_color_range].value if dst_color_range is not None else frame.color_range)

        return self._reformat(
            frame,
            width or frame.ptr.width,
            height or frame.ptr.height,
            video_format.pix_fmt,
            c_src_colorspace,
            c_dst_colorspace,
            c_interpolation,
            c_src_color_range,
            c_dst_color_range,
        )

    cdef _reformat(
        self,
        VideoFrame frame,
        int width,
        int height,
        AVPixelFormat dst_format,
        int src_colorspace,
        int dst_colorspace,
        int interpolation,
        int src_color_range,
        int dst_color_range
    ):

        if frame.ptr.format < 0:
            raise ValueError("Frame does not have format set.")

        cdef AVPixelFormat src_format = <AVPixelFormat> frame.ptr.format

        # Shortcut!
        if (
            dst_format == src_format
            and width == frame.ptr.width
            and height == frame.ptr.height
            and dst_colorspace == src_colorspace
            and src_color_range == dst_color_range
        ):
            return frame

        # Try and reuse existing SwsContextProxy
        # VideoStream.decode will copy its SwsContextProxy to VideoFrame
        # So all Video frames from the same VideoStream should have the same one
        with nogil:
            self.ptr = sws_getCachedContext(
                self.ptr,
                frame.ptr.width,
                frame.ptr.height,
                src_format,
                width,
                height,
                dst_format,
                interpolation,
                NULL,
                NULL,
                NULL
            )

        # We want to change the colorspace/color_range transforms.
        # We do that by grabbing all of the current settings, changing a
        # couple, and setting them all. We need a lot of state here.
        cdef const int *inv_tbl
        cdef const int *tbl
        cdef int src_colorspace_range, dst_colorspace_range
        cdef int brightness, contrast, saturation
        cdef int ret

        if (
            src_colorspace != dst_colorspace
            or src_color_range != dst_color_range
        ):
            with nogil:
                # Casts for const-ness, because Cython isn't expressive enough.
                ret = sws_getColorspaceDetails(
                    self.ptr,
                    <int**>&inv_tbl,
                    &src_colorspace_range,
                    <int**>&tbl,
                    &dst_colorspace_range,
                    &brightness,
                    &contrast,
                    &saturation
                )

            err_check(ret)

            with nogil:
                # Grab the coefficients for the requested transforms.
                # The inv_table brings us to linear, and `tbl` to the new space.
                if src_colorspace != libav.SWS_CS_DEFAULT:
                    inv_tbl = sws_getCoefficients(src_colorspace)
                if dst_colorspace != libav.SWS_CS_DEFAULT:
                    tbl = sws_getCoefficients(dst_colorspace)

                # Apply!
                ret = sws_setColorspaceDetails(
                    self.ptr,
                    inv_tbl,
                    src_color_range,
                    tbl,
                    dst_color_range,
                    brightness,
                    contrast,
                    saturation
                )

            err_check(ret)

        # Create a new VideoFrame.
        cdef VideoFrame new_frame = alloc_video_frame()
        new_frame._copy_internal_attributes(frame)
        new_frame._init(dst_format, width, height)

        # Finally, scale the image.
        with nogil:
            sws_scale(
                self.ptr,
                # Cast for const-ness, because Cython isn't expressive enough.
                <const uint8_t**>frame.ptr.data,
                frame.ptr.linesize,
                0,  # slice Y
                frame.ptr.height,
                <unsigned char **>new_frame.ptr.data,
                new_frame.ptr.linesize,
            )

        return new_frame
