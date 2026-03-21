"""
RQAlpha Mojo - Function Tools
Ported from rqalpha/utils/functools.py
"""

from collections import Dict
from rqmojo.utils.i18n import gettext
from rqmojo.const import RUN_TYPE


comptime __all__: List[String] = [
    "CachedFunc",
    "memoize",
    "LazyProperty",
    "lazy_property",
]


@fieldwise_init
struct CachedFunc(Movable, Copyable):
    var cache: Dict[String, String]
    var max_size: Int

    def __init__(max_size: Int = 128) -> Self:
        return Self(Dict[String, String](), max_size)

    def get(mut self, key: String) -> Optional[String]:
        if self.cache.contains(key):
            return Optional[String](self.cache[key])
        return Optional[String](None)

    def set(mut self, key: String, value: String):
        self.cache[key] = value

    def contains(self, key: String) -> Bool:
        return self.cache.contains(key)

    def clear(mut self):
        self.cache.clear()


def memoize(func_name: String, max_size: Int = 128) -> CachedFunc:
    return CachedFunc(max_size)


@fieldwise_init
struct LazyProperty(Movable, Copyable):
    var name: String
    var cached: Bool
    var _value: String

    def __init__(name: String) -> Self:
        return Self(name, False, "")

    def is_cached(self) -> Bool:
        return self.cached

    def get_value(self) -> String:
        return self._value

    def set_value(mut self, value: String):
        self._value = value
        self.cached = True


def lazy_property(name: String) -> LazyProperty:
    return LazyProperty(name)
