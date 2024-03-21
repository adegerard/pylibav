from libc.stdint cimport uint64_t
from fractions import Fraction
from .libav cimport (
    AVDictionary,
    AVDictionaryEntry,
    AVRational,
    av_dict_get,
    av_dict_set,
    av_dict_free,
    AV_DICT_IGNORE_SUFFIX,
)
from .error cimport err_check


# === DICTIONARIES ===
# ====================

cdef _decode(char *s, encoding, errors):
    return (<bytes>s).decode(encoding, errors)

cdef bytes _encode(s, encoding, errors):
    return s.encode(encoding, errors)

cdef dict avdict_to_dict(AVDictionary *input, str encoding, str errors):
    cdef AVDictionaryEntry *element = NULL
    cdef dict output = {}
    while True:
        element = av_dict_get(input, "", element, AV_DICT_IGNORE_SUFFIX)
        if element == NULL:
            break
        output[_decode(element.key, encoding, errors)] = _decode(element.value, encoding, errors)
    return output


cdef dict_to_avdict(AVDictionary **dst, dict src, str encoding, str errors):
    av_dict_free(dst)
    for key, value in src.items():
        err_check(
            av_dict_set(
                dst,
                _encode(key, encoding, errors),
                _encode(value, encoding, errors),
                0
            )
        )


# === FRACTIONS ===
# =================

cdef object avrational_to_fraction(const AVRational *input):
    if input.num and input.den:
        return Fraction(input.num, input.den)


cdef object to_avrational(object value, AVRational *input):
    if value is None:
        input.num = 0
        input.den = 1
        return

    if isinstance(value, Fraction):
        frac = value
    else:
        frac = Fraction(value)

    input.num = frac.numerator
    input.den = frac.denominator


# === OTHER ===
# =============


cdef check_ndarray(object array, object dtype, int ndim):
    """
    Check a numpy array has the expected data type and number of dimensions.
    """
    if array.dtype != dtype:
        raise ValueError(f"Expected numpy array with dtype `{dtype}` but got `{array.dtype}`")
    if array.ndim != ndim:
        raise ValueError(f"Expected numpy array with ndim `{ndim}` but got `{array.ndim}`")


cdef check_ndarray_shape(object array, bint ok):
    """
    Check a numpy array has the expected shape.
    """
    if not ok:
        raise ValueError(f"Unexpected numpy array shape `{array.shape}`")


cdef flag_in_bitfield(uint64_t bitfield, uint64_t flag):
    # Not every flag exists in every version of FFMpeg, so we define them to 0.
    if not flag:
        return None
    return bool(bitfield & flag)


# === BACKWARDS COMPAT ===

from .error import FFmpegError as AVError
from .error import err_check
