from typing import TypedDict
print("importing _core.pyi")

class _Meta(TypedDict):
    version: tuple[int, int, int]
    configuration: str
    license: str

library_meta: dict[str, _Meta]
library_versions: dict[str, tuple[int, int, int]]

time_base: int
