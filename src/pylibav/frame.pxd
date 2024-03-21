from .libav cimport (
    AVFrame,
    AVRational,
)
# from .sidedata.sidedata cimport _SideDataContainer


cdef class Frame:

    cdef AVFrame *ptr

    # We define our own time.
    cdef AVRational _time_base
    cdef _rebase_time(self, AVRational)

    # cdef _SideDataContainer _side_data

    cdef readonly int index

    cdef _copy_internal_attributes(self, Frame source, bint data_layout=?)

    cdef _init_user_attributes(self)
