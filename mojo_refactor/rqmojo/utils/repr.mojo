"""
RQAlpha Mojo - Repr Utilities
Ported from rqalpha/utils/repr.py

Provides property-based repr functionality similar to Python's PropertyReprMeta.
"""

from std.collections import Dict, List


@fieldwise_init
struct ReprPropertyItem(Copyable, Movable):
    var name: String
    var value: String

    def get_name(self) -> String:
        return self.name

    def get_value(self) -> String:
        return self.value


@fieldwise_init
struct CachedProperty(Copyable, Movable):
    var name: String
    var value: String

    def get_name(self) -> String:
        return self.name

    def get_value(self) -> String:
        return self.value


trait Reprable:
    def __repr_properties__(self) -> List[ReprPropertyItem]: ...
    def __repr_cached_properties__(self) -> List[CachedProperty]: ...
    def __class_name__(self) -> String: ...
    def __abandon_properties__(self) -> List[String]:
        return List[String]()


trait SlotsReprable:
    def __slots__(self) -> List[String]: ...
    def __get_slot_value(self, name: String) -> String: ...
    def __class_name__(self) -> String: ...


struct ReprBuilder:
    var cls_name: String
    var properties: List[String]
    
    def __init__(out self, cls_name: String, var properties: List[String]):
        self.cls_name = cls_name
        self.properties = properties^
    
    def build(self) -> String:
        return _repr(self.cls_name, self.properties)


def _starts_with(s: String, prefix: String) -> Bool:
    if len(s) < len(prefix):
        return False
    var bytes_s = s.as_bytes()
    var bytes_prefix = prefix.as_bytes()
    for i in range(len(bytes_prefix)):
        if bytes_s[i] != bytes_prefix[i]:
            return False
    return True


def _slice_string(s: String, start: Int, end: Int) -> String:
    var actual_end = min(end, len(s))
    if start >= actual_end:
        return ""
    if start == 0 and actual_end == len(s):
        return s
    return String(s[byte=start:actual_end])


def _repr(cls_name: String, properties: List[String]) -> String:
    var fmt_str = cls_name + "("
    var first = True
    for p in properties:
        if not first:
            fmt_str = fmt_str + ", "
        fmt_str = fmt_str + p + "={}"
        first = False
    fmt_str = fmt_str + ")"
    return fmt_str


def property_repr[T: Reprable](inst: T) -> String:
    var cls_name = inst.__class_name__()
    var props = properties(inst)
    return dict_repr_from_dict(cls_name, props)


def slots_repr[T: SlotsReprable](inst: T) -> String:
    var cls_name = inst.__class_name__()
    var slots_dict = slots(inst)
    return dict_repr_from_dict(cls_name, slots_dict)


def dict_repr[T: Reprable](inst: T) -> String:
    var cls_name = inst.__class_name__()
    var props = properties(inst)
    return dict_repr_from_dict(cls_name, props)


def dict_repr_from_dict(cls_name: String, d: Dict[String, String]) -> String:
    var result = cls_name + "("
    var first = True
    for key in d.keys():
        if _starts_with(key, "_"):
            continue
        if not first:
            result = result + ", "
        var val = d.get(key, "")
        result = result + key + "=" + val
        first = False
    result = result + ")"
    return result


def properties[T: Reprable](inst: T) -> Dict[String, String]:
    var result = Dict[String, String]()
    var abandon = inst.__abandon_properties__()
    
    var props = inst.__repr_properties__()
    for prop in props:
        var name = prop.get_name()
        
        if _starts_with(name, "_"):
            continue
        
        var is_abandoned = False
        for abandoned in abandon:
            if abandoned == name:
                is_abandoned = True
                break
        
        if is_abandoned:
            continue
        
        result[name] = prop.get_value()
    
    var cached_props = inst.__repr_cached_properties__()
    for cached in cached_props:
        var name = cached.get_name()
        
        if _starts_with(name, "_"):
            continue
        
        var is_abandoned = False
        for abandoned in abandon:
            if abandoned == name:
                is_abandoned = True
                break
        
        if is_abandoned:
            continue
        
        result[name] = cached.get_value()
    
    return result^


def slots[T: SlotsReprable](inst: T) -> Dict[String, String]:
    var result = Dict[String, String]()
    var slot_names = inst.__slots__()
    for name in slot_names:
        result[name] = inst.__get_slot_value(name)
    return result^


def truncate_string(s: String, max_length: Int = 100) -> String:
    if len(s) <= max_length:
        return s
    return _slice_string(s, 0, max_length - 3) + "..."


def format_float(value: Float64, precision: Int = 4) -> String:
    var s = String(value)
    if len(s) > precision + 2:
        return _slice_string(s, 0, precision + 2)
    return s


def make_repr_builder(cls_name: String, var prop_names: List[String]) -> ReprBuilder:
    return ReprBuilder(cls_name, prop_names^)
