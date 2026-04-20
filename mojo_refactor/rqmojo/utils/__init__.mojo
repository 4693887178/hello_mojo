"""
RQMojo utils - RqAttrDict with chain assignment support

Python: config.base.start_date = "20150101"
Mojo:  config["base"]["start_date"] = "20150101"
"""

from std.collections import Dict, List as StdList
from std.utils import Variant
from std.memory import ArcPointer


struct NullValue(TrivialRegisterPassable, Writable):
    @always_inline
    def __init__(out self):
        pass

    @always_inline
    def __eq__(self, other: NullValue) -> Bool:
        return True

    @always_inline
    def write_to(self, mut writer: Some[Writer]):
        writer.write("None")


struct RqAttrDictIterator[origin: Origin](Iterator):
    comptime Element: Movable = String

    var _keys: StdList[String]
    var _idx: Int
    var _done: Bool

    def __init__(out self, ref dict_ref: RqAttrDict):
        self._keys = StdList[String]()
        for k in dict_ref._children: self._keys.append(k)
        for k in dict_ref._values:
            if k != "__value__": self._keys.append(k)
        self._idx = 0
        self._done = len(self._keys) == 0

    def __next__(mut self) raises StopIteration -> Self.Element:
        if self._done:
            raise StopIteration()
        var key = self._keys[self._idx]
        self._idx += 1
        if self._idx >= len(self._keys):
            self._done = True
        return key


struct RqAttrDict(ImplicitlyCopyable, Movable, Writable, Iterable):
    var _children: Dict[String, ArcPointer[RqAttrDict]]
    var _values: Dict[String, Variant[NullValue, Int, Float64, String, Bool]]

    def __init__(out self):
        self._children = Dict[String, ArcPointer[RqAttrDict]]()
        self._values = Dict[String, Variant[NullValue, Int, Float64, String, Bool]]()

    def __init__(out self, *, copy: RqAttrDict):
        self._children = Dict[String, ArcPointer[RqAttrDict]]()
        self._values = Dict[String, Variant[NullValue, Int, Float64, String, Bool]]()
        for entry in copy._children.items():
            var c = entry.value[].copy()
            self._children[entry.key] = ArcPointer[RqAttrDict](c^)
        for entry in copy._values.items():
            self._values[entry.key] = entry.value

    @implicit
    def __init__(out self, value: NoneType._mlir_type):
        self._children = Dict[String, ArcPointer[RqAttrDict]]()
        self._values = Dict[String, Variant[NullValue, Int, Float64, String, Bool]]()
        self._values["__value__"] = Variant[NullValue, Int, Float64, String, Bool](NullValue())

    @implicit
    def __init__(out self, value: Int):
        self._children = Dict[String, ArcPointer[RqAttrDict]]()
        self._values = Dict[String, Variant[NullValue, Int, Float64, String, Bool]]()
        self._values["__value__"] = Variant[NullValue, Int, Float64, String, Bool](value)

    @implicit
    def __init__(out self, value: Float64):
        self._children = Dict[String, ArcPointer[RqAttrDict]]()
        self._values = Dict[String, Variant[NullValue, Int, Float64, String, Bool]]()
        self._values["__value__"] = Variant[NullValue, Int, Float64, String, Bool](value)

    @implicit
    def __init__(out self, value: String):
        self._children = Dict[String, ArcPointer[RqAttrDict]]()
        self._values = Dict[String, Variant[NullValue, Int, Float64, String, Bool]]()
        self._values["__value__"] = Variant[NullValue, Int, Float64, String, Bool](value)

    @implicit
    def __init__(out self, value: Bool):
        self._children = Dict[String, ArcPointer[RqAttrDict]]()
        self._values = Dict[String, Variant[NullValue, Int, Float64, String, Bool]]()
        self._values["__value__"] = Variant[NullValue, Int, Float64, String, Bool](value)

    comptime IteratorType[
        iterable_mut: Bool,
        //, iterable_origin: Origin[mut=iterable_mut]
    ]: Iterator = RqAttrDictIterator[origin=iterable_origin]

    def __iter__(ref self) -> Self.IteratorType[origin_of(self)]:
        var iter = RqAttrDictIterator[origin_of(self)](self)
        return iter^

    def __getitem__(self, key: String) raises -> RqAttrDict:
        if key in self._children:
            return self._children[key][].copy()
        if key in self._values:
            var result = RqAttrDict()
            result._values["__value__"] = self._values[key]
            return result
        return RqAttrDict()

    def __setitem__(mut self, key: String, value: RqAttrDict) raises:
        if "__value__" in value._values:
            self._values[key] = value._values["__value__"]
        elif len(value._children) > 0 or len(value._values) > 0:
            var vcopy = value.copy()
            self._children[key] = ArcPointer[RqAttrDict](vcopy^)

    def to[ValueType: ImplicitlyCopyable](mut self, default: ValueType) raises -> ValueType:
        if "__value__" in self._values and self._values["__value__"].isa[ValueType]():
            return self._values["__value__"][ValueType]
        return default

    def contains(self, key: String) -> Bool:
        return key in self._children or key in self._values

    def size(self) -> Int:
        return len(self._children) + len(self._values)

    def is_empty(self) -> Bool:
        return self.size() == 0

    def __bool__(self) -> Bool:
        return self.size() > 0

    def keys(self) -> StdList[String]:
        var r = StdList[String]()
        for k in self._children: r.append(k)
        for k in self._values:
            if k != "__value__": r.append(k)
        return r^

    def child_keys(self) -> StdList[String]:
        var r = StdList[String]()
        for k in self._children: r.append(k)
        return r^

    def value_keys(self) -> StdList[String]:
        var r = StdList[String]()
        for k in self._values:
            if k != "__value__": r.append(k)
        return r^

    def has_children(self) -> Bool:
        return len(self._children) > 0

    def has_value(self) -> Bool:
        return "__value__" in self._values

    def update(mut self, other: RqAttrDict) raises:
        for ck in other.child_keys():
            var other_child = other._children[ck][].copy()
            if ck in self._values:
                _ = self._values.pop(ck)
            if ck in self._children:
                self._children[ck][].update(other_child)
            else:
                self._children[ck] = ArcPointer[RqAttrDict](other_child^)
        for vk in other.value_keys():
            if vk in self._children:
                _ = self._children.pop(vk)
            self._values[vk] = other._values[vk]

    def items(self) raises -> Dict[String, String]:
        var result = Dict[String, String]()
        for vk in self.value_keys():
            var v = self._values[vk]
            if v.isa[String]():
                result[vk] = v[String]
            elif v.isa[Int]():
                result[vk] = String(v[Int])
            elif v.isa[Float64]():
                result[vk] = String(v[Float64])
            elif v.isa[Bool]():
                result[vk] = "true" if v[Bool] else "false"
            elif v.isa[NullValue]():
                result[vk] = "None"
        for ck in self.child_keys():
            result[ck] = String.write(self._children[ck][])
            var child_items = self._children[ck][].items()
            var child_keys_list = StdList[String]()
            for chk in child_items.keys():
                child_keys_list.append(chk)
            for child_k in child_keys_list:
                result[ck + "." + child_k] = child_items[child_k]
        return result^

    def convert_to_dict(self) raises -> Dict[String, String]:
        return self.items()

    def write_to(self, mut writer: Some[Writer]) raises:
        writer.write("{")
        var first = True
        for vk in self.value_keys():
            if not first: writer.write(", ")
            first = False
            var v = self._values[vk]
            writer.write("'", vk, "': ")
            if v.isa[String]():
                writer.write("'", v[String], "'")
            elif v.isa[Int]():
                writer.write(v[Int])
            elif v.isa[Float64]():
                writer.write(v[Float64])
            elif v.isa[Bool]():
                writer.write("true" if v[Bool] else "false")
            elif v.isa[NullValue]():
                writer.write("None")
        for ck in self.child_keys():
            if not first: writer.write(", ")
            first = False
            writer.write("'", ck, "': ")
            self._children[ck][].write_to(writer)
        writer.write("}")
