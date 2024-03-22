from collections.abc import MutableMapping
from .libav cimport (
    AVDictionaryEntry,
    AV_DICT_IGNORE_SUFFIX,
    av_dict_copy,
    av_dict_count,
    av_dict_free,
    av_dict_get,
    av_dict_set,
)
from .error cimport err_check


cdef class _Dictionary:
    def __cinit__(self, *args, **kwargs):
        for arg in args:
            self.update(arg)
        if kwargs:
            self.update(kwargs)

    def __dealloc__(self):
        if self.ptr != NULL:
            av_dict_free(&self.ptr)

    def __getitem__(self, str key):
        cdef AVDictionaryEntry *element = av_dict_get(
            self.ptr, <char *>key, <AVDictionaryEntry *>NULL, 0)
        if element != NULL:
            return element.value
        else:
            raise KeyError(key)

    def __setitem__(self, str key, str value):
        err_check(av_dict_set(&self.ptr, key, value, 0))

    def __delitem__(self, str key):
        err_check(av_dict_set(&self.ptr, key, NULL, 0))

    def __len__(self):
        return err_check(av_dict_count(self.ptr))

    def __iter__(self):
        cdef AVDictionaryEntry *element = NULL
        while True:
            element = av_dict_get(
                self.ptr, "", element, AV_DICT_IGNORE_SUFFIX)
            if element == NULL:
                break
            yield element.key

    def __repr__(self):
        return f"pylibav.Dictionary({dict(self)!r})"

    cpdef _Dictionary copy(self):
        cdef _Dictionary other = Dictionary()
        av_dict_copy(&other.ptr, self.ptr, 0)
        return other


class Dictionary(_Dictionary, MutableMapping):
    pass


cdef _Dictionary wrap_dictionary(AVDictionary *input_):
    cdef _Dictionary output = Dictionary()
    output.ptr = input_
    return output
