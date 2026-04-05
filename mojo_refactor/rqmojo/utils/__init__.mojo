"""
RQMojo utils - RqValue and helper functions
"""

from std.collections import Dict, List


comptime KIND_NONE: Int = 0
comptime KIND_INT: Int = 1
comptime KIND_FLOAT: Int = 2
comptime KIND_BOOL: Int = 3
comptime KIND_STRING: Int = 4
comptime KIND_DICT: Int = 5
comptime KIND_LIST: Int = 6


struct KeyValuePair(Copyable, Movable):
    var key: String
    var value: RqValue

    def __init__(out self, key: String, value: RqValue):
        self.key = key
        self.value = value.copy()


struct RqValue(Copyable, Movable):
    var kind: Int
    var int_val: Int64
    var float_val: Float64
    var bool_val: Bool
    var string_val: String
    var dict_val: Dict[String, RqValue]
    var list_val: List[RqValue]

    def __init__(out self):
        self.kind = KIND_NONE
        self.int_val = 0
        self.float_val = 0.0
        self.bool_val = False
        self.string_val = ""
        self.dict_val = Dict[String, RqValue]()
        self.list_val = List[RqValue]()

    def is_dict(self) -> Bool:
        return self.kind == KIND_DICT

    def is_list(self) -> Bool:
        return self.kind == KIND_LIST

    def is_string(self) -> Bool:
        return self.kind == KIND_STRING

    def is_int(self) -> Bool:
        return self.kind == KIND_INT

    def is_float(self) -> Bool:
        return self.kind == KIND_FLOAT

    def is_bool(self) -> Bool:
        return self.kind == KIND_BOOL

    def is_none(self) -> Bool:
        return self.kind == KIND_NONE


def make_int_value(val: Int64) -> RqValue:
    var result = RqValue()
    result.kind = KIND_INT
    result.int_val = val
    return result^


def make_float_value(val: Float64) -> RqValue:
    var result = RqValue()
    result.kind = KIND_FLOAT
    result.float_val = val
    return result^


def make_bool_value(val: Bool) -> RqValue:
    var result = RqValue()
    result.kind = KIND_BOOL
    result.bool_val = val
    return result^


def make_string_value(val: String) -> RqValue:
    var result = RqValue()
    result.kind = KIND_STRING
    result.string_val = val
    return result^


def make_dict_value(d: Dict[String, RqValue]) -> RqValue:
    var result = RqValue()
    result.kind = KIND_DICT
    result.dict_val = d.copy()
    return result^


def make_list_value(l: List[RqValue]) -> RqValue:
    var result = RqValue()
    result.kind = KIND_LIST
    result.list_val = l.copy()
    return result^


struct RqAttrDict(Copyable, Movable):
    var data: Dict[String, RqValue]

    def __init__(out self):
        self.data = Dict[String, RqValue]()


    def __init__(out self, d: Dict[String, RqValue]) raises:
        self.data = Dict[String, RqValue]()
        _init_from_dict(self.data, d)

    def __str__(self) raises -> String:
        return _dict_to_string(self.data)


    def __repr__(self) raises -> String:
        return _dict_to_string(self.data)


    def __bool__(self) -> Bool:
        return len(self.data) > 0

    def __getitem__(self, key: String) raises -> RqValue:
        return self.data[key].copy()

    def __setitem__(mut self, key: String, value: RqValue):
        self.data[key] = value.copy()

    def keys(self) -> List[String]:
        var result = List[String]()
        for k in self.data.keys():
            result.append(k)
        return result^

    def values(self) raises -> List[RqValue]:
        var result = List[RqValue]()
        for k in self.data.keys():
            result.append(self.data[k].copy())
        return result^

    def items(self) raises -> List[KeyValuePair]:
        var result = List[KeyValuePair]()
        for k in self.data.keys():
            result.append(KeyValuePair(k, self.data[k].copy()))
        return result^

    def iteritems(self) raises -> List[KeyValuePair]:
        return self.items()

    def __iter__(self) -> List[String]:
        return self.keys()

    def update(mut self, other: RqAttrDict) raises:
        _merge_dicts(self.data, other.data)

    def convert_to_dict(self) raises -> Dict[String, RqValue]:
        var result = Dict[String, RqValue]()
        _copy_dict_recursive(result, self.data)
        return result^


def _dict_to_string(d: Dict[String, RqValue]) raises -> String:
    var parts = List[String]()
    for k in d.keys():
        parts.append("'" + k + "': " + _value_to_string(d[k]))
    return "{" + ", ".join(parts) + "}"


def _value_to_string(v: RqValue) raises -> String:
    if v.kind == KIND_NONE:
        return "None"
    if v.kind == KIND_INT:
        return String(v.int_val)
    if v.kind == KIND_FLOAT:
        return String(v.float_val)
    if v.kind == KIND_BOOL:
        return "True" if v.bool_val else "False"
    if v.kind == KIND_STRING:
        return v.string_val
    if v.kind == KIND_DICT:
        return _dict_to_string(v.dict_val)
    if v.kind == KIND_LIST:
        return _list_to_string(v.list_val)
    return "Unknown"


def _list_to_string(l: List[RqValue]) raises -> String:
    var parts = List[String]()
    for item in l:
        parts.append(_value_to_string(item))
    return "[" + ", ".join(parts) + "]"


def _copy_dict_recursive(mut target: Dict[String, RqValue], source: Dict[String, RqValue]) raises:
    for k in source.keys():
        var v = source[k].copy()
        if v.kind == KIND_DICT:
            var nested = Dict[String, RqValue]()
            _copy_dict_recursive(nested, v.dict_val)
            target[k] = RqValue()
            target[k].kind = KIND_DICT
            target[k].dict_val = nested^
        elif v.kind == KIND_LIST:
            target[k] = RqValue()
            target[k].kind = KIND_LIST
            target[k].list_val = _copy_list_recursive(v.list_val)
        else:
            target[k] = v.copy()


def _copy_list_recursive(source: List[RqValue]) raises -> List[RqValue]:
    var result = List[RqValue]()
    for item in source:
        var v = item.copy()
        if v.kind == KIND_DICT:
            var nested = Dict[String, RqValue]()
            _copy_dict_recursive(nested, v.dict_val)
            var new_val = RqValue()
            new_val.kind = KIND_DICT
            new_val.dict_val = nested^
            result.append(new_val^)
        else:
            result.append(v.copy())
    return result^


def _init_from_dict(mut target: Dict[String, RqValue], source: Dict[String, RqValue]) raises:
    for k in source.keys():
        var v = source[k].copy()
        if v.kind == KIND_DICT:
            var nested = Dict[String, RqValue]()
            _init_from_dict(nested, v.dict_val)
            target[k] = RqValue()
            target[k].kind = KIND_DICT
            target[k].dict_val = nested^
        elif v.kind == KIND_LIST:
            target[k] = RqValue()
            target[k].kind = KIND_LIST
            target[k].list_val = _copy_list_recursive(v.list_val)
        else:
            target[k] = v.copy()


def _merge_dicts(mut target: Dict[String, RqValue], other: Dict[String, RqValue]) raises:
    for k in other.keys():
        var v = other[k].copy()
        if v.kind == KIND_DICT:
            if target.__contains__(k):
                var existing = target[k].copy()
                if existing.kind == KIND_DICT:
                    _merge_dicts(existing.dict_val, v.dict_val)
                    target[k] = existing.copy()
                else:
                    target[k] = v.copy()
            else:
                target[k] = v.copy()
