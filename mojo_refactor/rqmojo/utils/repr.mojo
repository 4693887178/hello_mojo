"""
RQAlpha Mojo - Repr Utilities
Ported from rqalpha/utils/repr.py

Provides property-based repr functionality similar to Python's PropertyReprMeta.
Optimized for Mojo best practices: unified types, efficient string building,
Writable conformance, and clean trait-based architecture.
"""

from std.collections import Dict, List


@fieldwise_init
struct PropertyItem(Copyable, Movable, Writable):
    var name: String
    var value: String

    def get_name(self) -> String:
        return self.name

    def get_value(self) -> String:
        return self.value

    def write_to(self, mut writer: Some[Writer]):
        writer.write("PropertyItem(", self.name, "=", self.value, ")")


comptime ReprPropertyItem = PropertyItem
comptime CachedProperty = PropertyItem


trait Reprable:
    def __repr_properties__(self) -> List[PropertyItem]: ...
    def __repr_cached_properties__(self) -> List[PropertyItem]: ...
    def __class_name__(self) -> String: ...
    def __abandon_properties__(self) -> List[String]:
        return List[String]()


trait SlotsReprable:
    def __slots__(self) -> List[String]: ...
    def __get_slot_value(self, name: String) -> String: ...
    def __class_name__(self) -> String: ...


struct ReprBuilder(Copyable):
    var cls_name: String
    var properties: List[String]

    def __init__(out self, cls_name: String, var properties: List[String]):
        self.cls_name = cls_name
        self.properties = properties^

    def build(self) -> String:
        return _build_repr_string(self.cls_name, self.properties)


def _is_private(name: String) -> Bool:
    if len(name) == 0:
        return False
    return name[byte=0] == "_"


def _is_abandoned(name: String, abandon_list: List[String]) -> Bool:
    for item in abandon_list:
        if item == name:
            return True
    return False


def _build_repr_string(cls_name: String, properties: List[String]) -> String:
    var parts = List[String]()
    for p in properties:
        if _is_private(p):
            continue
        parts.append(p + "={}")
    return cls_name + "(" + ", ".join(parts) + ")"


def _build_kv_string(cls_name: String, d: Dict[String, String]) -> String:
    var parts = List[String]()
    for key in d.keys():
        if _is_private(key):
            continue
        var val = d.get(key, "")
        parts.append(key + "=" + val)
    return cls_name + "(" + ", ".join(parts) + ")"


def _collect_properties[T: Reprable](
    inst: T, abandon: List[String]
) -> Dict[String, String]:
    var result = Dict[String, String]()

    var props = inst.__repr_properties__()
    for prop in props:
        var name = prop.get_name()
        if _is_private(name) or _is_abandoned(name, abandon):
            continue
        result[name] = prop.get_value()

    var cached_props = inst.__repr_cached_properties__()
    for cached in cached_props:
        var name = cached.get_name()
        if _is_private(name) or _is_abandoned(name, abandon):
            continue
        result[name] = cached.get_value()

    return result^


def property_repr[T: Reprable](inst: T) -> String:
    var cls_name = inst.__class_name__()
    var props = properties(inst)
    return _build_kv_string(cls_name, props)


def slots_repr[T: SlotsReprable](inst: T) -> String:
    var cls_name = inst.__class_name__()
    var slots_dict = slots(inst)
    return _build_kv_string(cls_name, slots_dict)


def dict_repr[T: Reprable](inst: T) -> String:
    var cls_name = inst.__class_name__()
    var props = properties(inst)
    return _build_kv_string(cls_name, props)


def dict_repr_from_dict(cls_name: String, d: Dict[String, String]) -> String:
    return _build_kv_string(cls_name, d)


def properties[T: Reprable](inst: T) -> Dict[String, String]:
    var abandon = inst.__abandon_properties__()
    return _collect_properties(inst, abandon)


def slots[T: SlotsReprable](inst: T) -> Dict[String, String]:
    var result = Dict[String, String]()
    var slot_names = inst.__slots__()
    for name in slot_names:
        result[name] = inst.__get_slot_value(name)
    return result^


def truncate_string(s: String, max_length: Int = 100) -> String:
    if len(s) <= max_length:
        return s
    return s[byte=0:max_length - 3] + "..."


def format_float(value: Float64, precision: Int = 4) -> String:
    var s = String(value)
    if len(s) > precision + 2:
        return String(s[byte=0:precision + 2])
    return s


def make_repr_builder(
    cls_name: String, var prop_names: List[String]
) -> ReprBuilder:
    return ReprBuilder(cls_name, prop_names^)
