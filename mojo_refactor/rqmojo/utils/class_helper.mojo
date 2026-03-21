"""
RQAlpha Mojo - Class Helper
Ported from rqalpha/utils/class_helper.py
"""

from collections import List, Dict
from rqmojo.utils.logger import user_system_log
from rqmojo.utils.i18n import gettext


comptime __all__: List[String] = [
    "deprecated_property",
    "cached_property",
    "CachedProperty",
    "property_repr",
    "make_cached_property",
]


def deprecated_property(property_name: String, instead_property_name: String) raises -> String:
    if property_name == instead_property_name:
        raise Error(gettext("property_name and instead_property_name must be different"))
    user_system_log().warn(gettext("\"") + property_name + gettext("\" is deprecated, please use \"") + instead_property_name + gettext("\" instead, check the document for more information"))
    return instead_property_name


@fieldwise_init
struct cached_property(Movable, Copyable):
    var name: String
    var cached: Bool
    var value: String
    var _computed: Bool

    def __init__(name: String) -> Self:
        return Self(name, False, "", False)

    def __init__(name: String, value: String) -> Self:
        return Self(name, True, value, True)

    def is_cached(self) -> Bool:
        return self.cached

    def get_name(self) -> String:
        return self.name

    def get_value(self) -> String:
        return self.value

    def set_value(mut self, value: String):
        self.value = value
        self.cached = True
        self._computed = True


comptime CachedProperty = cached_property


def make_cached_property(name: String, value: String) -> cached_property:
    return cached_property(name, value)


trait HasCachedProperties:
    def get_cached_properties(self) -> List[cached_property]: ...
    def set_cached_property(mut self, name: String, value: String): ...


@fieldwise_init
struct PropertyRepr(Movable):
    var properties: List[String]
    var cached_properties: List[cached_property]


def property_repr(obj_name: String, properties: Dict[String, String]) -> String:
    var result = obj_name + "("
    var first = True
    for key in properties.keys():
        if not first:
            result = result + ", "
        var val = properties.get(key, "")
        result = result + key + "=" + val
        first = False
    result = result + ")"
    return result
