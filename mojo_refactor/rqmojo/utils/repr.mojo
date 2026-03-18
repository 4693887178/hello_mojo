"""
RQAlpha Mojo - Repr Utilities
Ported from rqalpha/utils/repr.py

Provides property-based repr functionality similar to Python's PropertyReprMeta.
"""

from collections import Dict, List
from rqmojo.utils.class_helper import cached_property


@fieldwise_init
struct ReprPropertyItem(Copyable, Movable):
    var name: String
    var value: String

    fn get_name(self) -> String:
        return self.name

    fn get_value(self) -> String:
        return self.value


trait Reprable:
    fn __repr_properties__(self) -> List[ReprPropertyItem]: ...
    fn __repr_cached_properties__(self) -> List[cached_property]: ...
    fn __class_name__(self) -> String: ...
    fn __abandon_properties__(self) -> List[String]:
        return List[String]()


trait SlotsReprable:
    fn __slots__(self) -> List[String]: ...
    fn __get_slot_value(self, name: String) -> String: ...
    fn __class_name__(self) -> String: ...


trait SimpleObject:
    fn __simple_object__(self) -> String: ...


struct ReprBuilder:
    var cls_name: String
    var properties: List[String]
    
    fn __init__(out self, cls_name: String, var properties: List[String]):
        self.cls_name = cls_name
        self.properties = properties^
    
    fn build(self) -> String:
        return _repr(self.cls_name, self.properties)
    
    fn format[T: Reprable](self, inst: T) -> String:
        var props = properties(inst)
        var result = self.cls_name + "("
        var first = True
        for name in self.properties:
            if name[:1] == "_":
                continue
            if not props.__contains__(name):
                continue
            if not first:
                result = result + ", "
            var val = props.get(name, "")
            result = result + name + "=" + val
            first = False
        result = result + ")"
        return result


fn _repr(cls_name: String, properties: List[String]) -> String:
    var fmt_str = cls_name + "("
    var first = True
    for p in properties:
        if not first:
            fmt_str = fmt_str + ", "
        fmt_str = fmt_str + p + "={}"
        first = False
    fmt_str = fmt_str + ")"
    return fmt_str


fn property_repr[T: Reprable](inst: T) -> String:
    var cls_name = inst.__class_name__()
    var props = properties(inst)
    return dict_repr_from_dict(cls_name, props)


fn slots_repr[T: SlotsReprable](inst: T) -> String:
    var cls_name = inst.__class_name__()
    var slots_dict = slots(inst)
    return dict_repr_from_dict(cls_name, slots_dict)


fn dict_repr[T: Reprable](inst: T) -> String:
    var cls_name = inst.__class_name__()
    var props = properties(inst)
    return dict_repr_from_dict(cls_name, props)


fn dict_repr_from_dict(cls_name: String, d: Dict[String, String]) -> String:
    var result = cls_name + "("
    var first = True
    for key in d.keys():
        if key[:1] == "_":
            continue
        if not first:
            result = result + ", "
        var val = d.get(key, "")
        result = result + key + "=" + val
        first = False
    result = result + ")"
    return result


fn properties[T: Reprable](inst: T) -> Dict[String, String]:
    var result = Dict[String, String]()
    var abandon = inst.__abandon_properties__()
    
    var props = inst.__repr_properties__()
    for prop in props:
        var name = prop.get_name()
        
        if name[:1] == "_":
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
        
        if name[:1] == "_":
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


fn slots[T: SlotsReprable](inst: T) -> Dict[String, String]:
    var result = Dict[String, String]()
    var slot_names = inst.__slots__()
    for name in slot_names:
        result[name] = inst.__get_slot_value(name)
    return result^


fn iter_properties_of_class[T: Reprable](inst: T) -> List[String]:
    var result = List[String]()
    var props = inst.__repr_properties__()
    for prop in props:
        result.append(prop.get_name())
    var cached_props = inst.__repr_cached_properties__()
    for cached in cached_props:
        result.append(cached.get_name())
    return result^


fn truncate_string(s: String, max_length: Int = 100) -> String:
    if len(s) <= max_length:
        return s
    return String(s[:max_length-3]) + "..."


fn format_float(value: Float64, precision: Int = 4) -> String:
    var s = String(value)
    if len(s) > precision + 2:
        return String(s[:precision + 2])
    return s


fn make_repr_builder(cls_name: String, var prop_names: List[String]) -> ReprBuilder:
    return ReprBuilder(cls_name, prop_names^)
