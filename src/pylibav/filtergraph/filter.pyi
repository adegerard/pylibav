from pylibav.descriptor import Descriptor
from pylibav.option import Option
from pylibav.filtergraph.pad import FilterPad


class Filter:
    name: str
    description: str

    descriptor: Descriptor
    options: tuple[Option, ...] | None
    flags: int
    dynamic_inputs: bool
    dynamic_outputs: bool
    timeline_support: bool
    slice_threads: bool
    command_support: bool
    inputs: tuple[FilterPad, ...]
    outputs: tuple[FilterPad, ...]

filters_available: set[str]
