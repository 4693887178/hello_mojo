"""
RQAlpha Mojo - Class Helper
Ported from rqalpha/utils/class_helper.py
"""

from collections import List, Dict
from rqmojo.utils.logger import user_system_log


fn deprecated_property(property_name: String, instead_property_name: String) raises -> String:
    if property_name == instead_property_name:
        raise Error("property_name and instead_property_name must be different")
    user_system_log().warn("\"" + property_name + "\" is deprecated, please use \"" + instead_property_name + "\" instead, check the document for more information")
    return instead_property_name


@fieldwise_init
struct cached_property(Movable, Copyable):
    var name: String
    var cached: Bool
    var value: String
    var _computed: Bool

    fn __init__(name: String) -> Self:
        return Self(name, False, "", False)

    fn __init__(name: String, value: String) -> Self:
        return Self(name, True, value, True)

    fn is_cached(self) -> Bool:
        return self.cached

    fn get_name(self) -> String:
        return self.name

    fn get_value(self) -> String:
        return self.value

    fn set_value(mut self, value: String):
        self.value = value
        self.cached = True
        self._computed = True


comptime CachedProperty = cached_property


trait HasCachedProperties:
    fn get_cached_properties(self) -> List[cached_property]: ...
    fn set_cached_property(mut self, name: String, value: String): ...


@fieldwise_init
struct PropertyRepr(Movable):
    var properties: List[String]
    var cached_properties: List[cached_property]


fn property_repr(obj_name: String, properties: Dict[String, String]) raises -> String:
    var result = obj_name + "("
    var first = True
    for key in properties.keys():
        if not first:
            result = result + ", "
        var val = properties[key]
        result = result + key + "=" + val
        first = False
    result = result + ")"
    return result
