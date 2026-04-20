"""
RqAttrDict Mojo Implementation
Port from: rqalpha/utils/__init__.py  class RqAttrDict

Python: config.base.start_date = "20150101"
Mojo:  config["base"]["start_date"] = "20150101"
"""

from std.utils import Variant
from std.collections import Dict as StdDict
from std.memory import ArcPointer
from std.testing import assert_equal, assert_true, assert_false


struct NullValue(TrivialRegisterPassable, Writable):
    """Lightweight null placeholder for Variant (like EmberJson::Null)."""
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
    """Iterator for RqAttrDict - yields String keys (like Python __iter__)."""
    comptime Element: Movable = String

    var _keys: List[String]
    var _idx: Int
    var _done: Bool

    def __init__(out self, ref dict_ref: RqAttrDict):
        self._keys = List[String]()
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
    var _children: StdDict[String, ArcPointer[RqAttrDict]]
    var _values: StdDict[String, Variant[NullValue, Int, Float64, String, Bool]]

    def __init__(out self):
        self._children = StdDict[String, ArcPointer[RqAttrDict]]()
        self._values = StdDict[String, Variant[NullValue, Int, Float64, String, Bool]]()

    def __init__(out self, *, copy: RqAttrDict):
        self._children = StdDict[String, ArcPointer[RqAttrDict]]()
        self._values = StdDict[String, Variant[NullValue, Int, Float64, String, Bool]]()
        for entry in copy._children.items():
            var c = entry.value[].copy()
            self._children[entry.key] = ArcPointer[RqAttrDict](c^)
        for entry in copy._values.items():
            self._values[entry.key] = entry.value

    @implicit
    def __init__(out self, value: NoneType._mlir_type):
        self._children = StdDict[String, ArcPointer[RqAttrDict]]()
        self._values = StdDict[String, Variant[NullValue, Int, Float64, String, Bool]]()
        self._values["__value__"] = Variant[NullValue, Int, Float64, String, Bool](NullValue())

    @implicit
    def __init__(out self, value: Int):
        self._children = StdDict[String, ArcPointer[RqAttrDict]]()
        self._values = StdDict[String, Variant[NullValue, Int, Float64, String, Bool]]()
        self._values["__value__"] = Variant[NullValue, Int, Float64, String, Bool](value)

    @implicit
    def __init__(out self, value: Float64):
        self._children = StdDict[String, ArcPointer[RqAttrDict]]()
        self._values = StdDict[String, Variant[NullValue, Int, Float64, String, Bool]]()
        self._values["__value__"] = Variant[NullValue, Int, Float64, String, Bool](value)

    @implicit
    def __init__(out self, value: String):
        self._children = StdDict[String, ArcPointer[RqAttrDict]]()
        self._values = StdDict[String, Variant[NullValue, Int, Float64, String, Bool]]()
        self._values["__value__"] = Variant[NullValue, Int, Float64, String, Bool](value)

    @implicit
    def __init__(out self, value: Bool):
        self._children = StdDict[String, ArcPointer[RqAttrDict]]()
        self._values = StdDict[String, Variant[NullValue, Int, Float64, String, Bool]]()
        self._values["__value__"] = Variant[NullValue, Int, Float64, String, Bool](value)

    # ---- Iterable: enables 'for key in rqattrdict' ----
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

    def keys(self) -> List[String]:
        var r = List[String]()
        for k in self._children: r.append(k)
        for k in self._values:
            if k != "__value__": r.append(k)
        return r^

    def child_keys(self) -> List[String]:
        var r = List[String]()
        for k in self._children: r.append(k)
        return r^

    def value_keys(self) -> List[String]:
        var r = List[String]()
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
            if ck in self._children:
                self._children[ck][].update(other_child)
            else:
                self._children[ck] = ArcPointer[RqAttrDict](other_child^)
        for vk in other.value_keys():
            self._values[vk] = other._values[vk]

    # ---- items(): flat key-value dict (Python: items() + convert_to_dict) ----
    def items(self) raises -> Dict[String, String]:
        """Return all entries as flat key-value dict (values as strings)."""
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
            var child_items = self._children[ck][].items()
            var child_keys_list = List[String]()
            for chk in child_items.keys():
                child_keys_list.append(chk)
            for child_k in child_keys_list:
                result[ck + "." + child_k] = child_items[child_k]
        return result^

    # ---- convert_to_dict(): delegates to items() (Python: convert_to_dict) ----
    def convert_to_dict(self) raises -> Dict[String, String]:
        """Convert AttrDict to plain flat Dict."""
        return self.items()

    # ---- write_to: Mojo __repr__ / __str__ equivalent ----
    def write_to(self, mut writer: Some[Writer]) raises:
        """Pretty print like Python pprint.pformat(__dict__)."""
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


def test_basic_construction() raises:
    print("=== test_basic_construction ===")
    var d = RqAttrDict()
    assert_true(d.is_empty(), "new is empty")
    assert_false(d.__bool__(), "bool false when empty")
    assert_equal(d.size(), 0, "size 0")
    print("PASS")


def test_set_and_get_primitives() raises:
    print("=== test_set_and_get_primitives ===")
    var d = RqAttrDict()
    d["name"] = "Alice"
    d["age"] = 30
    d["score"] = 98.5
    d["active"] = True

    assert_equal(d["name"].to[String](""), "Alice", "string")
    assert_equal(d["age"].to[Int](0), 30, "int")
    assert_true(d["score"].to[Float64](0.0) > 98.0, "float")
    assert_true(d["active"].to[Bool](False), "bool")
    print("PASS")


def test_chain_assignment() raises:
    print("=== test_chain_assignment ===")
    var d = RqAttrDict()
    d["base"]["start_date"] = "20150101"
    d["base"]["end_date"] = "20151201"

    assert_true(d.contains("base"), "has base")
    assert_true(d["base"].contains("start_date"), "base has start_date")
    assert_equal(d["base"]["start_date"].to[String](""), "20150101", "chain read")
    assert_equal(d["base"]["end_date"].to[String](""), "20151201", "chain end_date")
    print("PASS")


def test_3level_nesting() raises:
    print("=== test_3level_nesting ===")
    var d = RqAttrDict()
    d["level1"]["level2"]["deep"] = "found"
    assert_equal(d["level1"]["level2"]["deep"].to[String](""), "found", "3-level")
    print("PASS")


def test_keys_and_contains() raises:
    print("=== test_keys_and_contains ===")
    var d = RqAttrDict()
    d["x"] = 1
    d["y"] = 2
    d["sub"]["z"] = 3

    var ks = d.keys()
    assert_equal(len(ks), 3, "3 top-level keys (x, y, sub)")
    assert_true(d.contains("x"), "has x")
    assert_true(d.contains("y"), "has y")
    assert_true(d.contains("sub"), "has sub")
    assert_false(d.contains("missing"), "no missing")
    assert_equal(d.size(), 3, "size=3 (x,y values + sub child)")
    print("PASS")


def test_bool_semantics() raises:
    print("=== test_bool_semantics ===")
    var empty = RqAttrDict()
    assert_false(empty.__bool__(), "empty is falsy")
    var nonempty = RqAttrDict()
    nonempty["key"] = "val"
    assert_true(nonempty.__bool__(), "non-empty is truthy")
    print("PASS")


def test_update_merge() raises:
    print("=== test_update_merge ===")
    var base = RqAttrDict()
    base["base"]["start_date"] = "20150101"

    var extra = RqAttrDict()
    extra["base"]["end_date"] = "20151201"
    extra["extra_flag"] = True

    base.update(extra)
    assert_equal(base["base"]["start_date"].to[String](""), "20150101", "original kept")
    assert_equal(base["base"]["end_date"].to[String](""), "20151201", "merged")
    assert_true(base["extra_flag"].to[Bool](False), "new top-level key")
    print("PASS")


def test_update_nested_overwrite() raises:
    print("=== test_update_nested_overwrite ===")
    var d = RqAttrDict()
    d["section"]["key1"] = "old"
    d["section"]["key2"] = "keep"

    var override = RqAttrDict()
    override["section"]["key1"] = "new"
    override["section"]["key3"] = "added"

    d.update(override)
    assert_equal(d["section"]["key1"].to[String](""), "new", "overwritten")
    assert_equal(d["section"]["key2"].to[String](""), "keep", "preserved")
    assert_equal(d["section"]["key3"].to[String](""), "added", "new key")
    print("PASS")


def test_items() raises:
    print("=== test_items (Python dict.items() equivalent) ===")
    var d = RqAttrDict()
    d["name"] = "Alice"
    d["age"] = 30
    d["active"] = True
    d["server"]["host"] = "localhost"

    var items_dict = d.items()
    assert_equal(len(items_dict), 4, "4 items (3 values + 1 child as flat)")

    assert_true("name" in items_dict, "has name key")
    assert_equal(items_dict["name"], "Alice", "name=Alice")
    assert_true("server.host" in items_dict, "has nested key")
    assert_equal(items_dict["server.host"], "localhost", "server.host=localhost")
    print("PASS")


def test_copy_independence() raises:
    print("=== test_copy_independence ===")
    var d = RqAttrDict()
    d["a"]["b"] = "original"
    var d2 = d.copy()

    assert_equal(d2["a"]["b"].to[String](""), "original", "copy has value")
    d2["a"]["b"] = "modified"
    assert_equal(d["a"]["b"].to[String](""), "original", "unchanged")
    print("PASS")


def test_empty_attrdict() raises:
    print("=== test_empty_attrdict ===")
    var d = RqAttrDict()
    var missing = d["nonexistent"]
    assert_true(missing.is_empty(), "missing key returns empty")
    assert_equal(missing.to[String]("fallback"), "fallback", "default on empty")
    print("PASS")


def test_mixed_types_deep() raises:
    print("=== test_mixed_types_deep ===")
    var config = RqAttrDict()
    config["server"]["host"] = "localhost"
    config["server"]["port"] = 8080
    config["server"]["ssl"] = True
    config["app"]["version"] = "2.0"
    config["app"]["debug"] = False
    config["timeout"] = 30.5

    assert_equal(config["server"]["host"].to[String](""), "localhost")
    assert_equal(config["server"]["port"].to[Int](0), 8080)
    assert_true(config["server"]["ssl"].to[Bool](False))
    assert_equal(config["app"]["version"].to[String](""), "2.0")
    assert_false(config["app"]["debug"].to[Bool](True))
    assert_true(config["timeout"].to[Float64](0.0) > 30.0)
    assert_equal(len(config.keys()), 3, "3 top-level keys")
    print("PASS")


def test_iteration() raises:
    print("=== test_iteration (Python __iter__ equivalent) ===")
    var d = RqAttrDict()
    d["name"] = "Alice"
    d["age"] = 30
    d["active"] = True

    var collected = List[String]()
    for key in d:
        collected.append(key)

    assert_equal(len(collected), 3, "3 keys from iteration")
    print("  Iterated keys:", collected)
    assert_true("name" in collected or "age" in collected, "has expected keys")
    print("PASS")


def test_iterate_empty() raises:
    print("=== test_iterate_empty ===")
    var empty = RqAttrDict()
    var count = 0
    for key in empty:
        count += 1
    assert_equal(count, 0, "empty dict yields nothing")
    print("PASS")


def test_iterate_nested() raises:
    print("=== test_iterate_nested ===")
    var d = RqAttrDict()
    d["server"]["host"] = "localhost"
    d["server"]["port"] = 8080
    d["app"]["name"] = "myapp"

    var top_keys = List[String]()
    for key in d:
        top_keys.append(key)

    assert_equal(len(top_keys), 2, "2 top-level: server, app")

    var server_keys = List[String]()
    for key in d["server"]:
        server_keys.append(key)
    assert_equal(len(server_keys), 2, "server has 2 children")
    print("PASS")


def test_convert_to_dict() raises:
    print("=== test_convert_to_dict (recursive to plain Dict) ===")
    var d = RqAttrDict()
    d["name"] = "test"
    d["count"] = 42
    d["base"]["start"] = "2020"

    var plain = d.convert_to_dict()

    assert_true("name" in plain, "has name")
    assert_equal(plain["name"], "test", "name value preserved (String)")
    assert_equal(plain["count"], "42", "count value preserved (Int as string)")
    assert_true("base.start" in plain, "nested base.start")
    assert_equal(plain["base.start"], "2020", "nested value correct")
    print("PASS")


def test_repr_write_to() raises:
    print("=== test_repr_write_to (Mojo __repr__ via write_to) ===")
    var d = RqAttrDict()
    d["name"] = "Alice"
    d["age"] = 25

    var s = String.write(d)
    print("  repr:", s)
    assert_true(s.find("name") >= 0, "repr contains name")
    assert_true(s.find("Alice") >= 0, "repr contains value Alice")
    assert_true(s.find("age") >= 0, "repr contains age")
    assert_true(s.find("25") >= 0, "repr contains 25")
    print("PASS")


def test_repr_nested() raises:
    print("=== test_repr_nested ===")
    var d = RqAttrDict()
    d["server"]["host"] = "localhost"
    d["server"]["port"] = 8080

    var s = String.write(d)
    print("  nested repr:", s)
    assert_true(s.find("server") >= 0, "has server key")
    assert_true(s.find("host") >= 0, "has nested host")
    assert_true(s.find("localhost") >= 0, "has localhost value")
    assert_true(s.find("8080") >= 0, "has port value")
    print("PASS")


def test_none_value() raises:
    print("=== test_none_value (NoneType support) ===")
    var d = RqAttrDict()
    d["name"] = "Alice"
    d["optional_field"] = None
    d["active"] = True

    assert_equal(d["name"].to[String](""), "Alice", "string value works")
    assert_true(d.contains("optional_field"), "has optional_field key")

    var items_dict = d.items()
    assert_true("optional_field" in items_dict, "items has None key")
    assert_equal(items_dict["optional_field"], "None", "None serializes as 'None'")

    var s = String.write(d)
    print("  repr with None:", s)
    assert_true(s.find("None") >= 0, "repr contains None")
    print("PASS")


def main() raises:
    print("\n" + "=" * 60)
    print("  RqAttrDict Mojo Port Test Suite")
    print("  Python: config.base.start_date = '20150101'")
    print("  Mojo:   config['base']['start_date'] = '20150101'")
    print("=" * 60 + "\n")

    test_basic_construction()
    test_set_and_get_primitives()
    test_chain_assignment()
    test_3level_nesting()
    test_keys_and_contains()
    test_bool_semantics()
    test_update_merge()
    test_update_nested_overwrite()
    test_copy_independence()
    test_empty_attrdict()
    test_mixed_types_deep()
    test_iteration()
    test_iterate_empty()
    test_iterate_nested()
    test_items()
    test_convert_to_dict()
    test_repr_write_to()
    test_repr_nested()
    test_none_value()

    print("\n" + "=" * 60)
    print("  ALL 19 TESTS PASSED!")
    print("=" * 60 + "\n")
