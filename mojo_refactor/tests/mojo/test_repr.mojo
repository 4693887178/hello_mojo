"""
Comprehensive tests for repr.mojo

Tests cover all public APIs:
- PropertyItem / ReprPropertyItem / CachedProperty structs
- Reprable / SlotsReprable traits
- ReprBuilder
- Core functions: property_repr, slots_repr, dict_repr, dict_repr_from_dict
- Helper functions: properties, slots, truncate_string, format_float, make_repr_builder
- Internal helpers: _is_private, _is_abandoned, _build_repr_string, _build_kv_string
"""

from std.testing import assert_equal, assert_true, TestSuite
from std.collections import Dict, List
from rqmojo.utils.repr import (
    PropertyItem,
    ReprPropertyItem,
    CachedProperty,
    ReprBuilder,
    Reprable,
    SlotsReprable,
    property_repr,
    slots_repr,
    dict_repr,
    dict_repr_from_dict,
    properties,
    slots,
    truncate_string,
    format_float,
    make_repr_builder,
    _is_private,
    _is_abandoned,
)


@fieldwise_init
struct MockReprable(Reprable):
    var prop_items: List[PropertyItem]
    var cached_items: List[PropertyItem]
    var abandon_list: List[String]
    var class_name: String

    def __repr_properties__(self) -> List[PropertyItem]:
        return self.prop_items.copy()

    def __repr_cached_properties__(self) -> List[PropertyItem]:
        return self.cached_items.copy()

    def __class_name__(self) -> String:
        return self.class_name

    def __abandon_properties__(self) -> List[String]:
        return self.abandon_list.copy()


@fieldwise_init
struct MockSlotsReprable(SlotsReprable):
    var slot_data: Dict[String, String]
    var class_name: String

    def __slots__(self) -> List[String]:
        var names = List[String]()
        for k in self.slot_data.keys():
            names.append(k)
        return names^

    def __get_slot_value(self, name: String) -> String:
        return self.slot_data.get(name, "")

    def __class_name__(self) -> String:
        return self.class_name


def test_property_item_basic() raises:
    var item = PropertyItem(name="test_name", value="test_value")
    assert_equal(item.get_name(), "test_name")
    assert_equal(item.get_value(), "test_value")


def test_property_item_type_aliases() raises:
    var rpi = ReprPropertyItem(name="rpi", value="v1")
    assert_equal(rpi.get_name(), "rpi")
    assert_equal(rpi.get_value(), "v1")

    var cp = CachedProperty(name="cp", value="v2")
    assert_equal(cp.get_name(), "cp")
    assert_equal(cp.get_value(), "v2")


def test_repr_builder_basic() raises:
    var builder = make_repr_builder("TestClass", ["prop1", "prop2"])
    var result = builder.build()
    assert_equal(result, "TestClass(prop1={}, prop2={})")


def test_repr_builder_filters_private() raises:
    var builder = make_repr_builder("TestClass", ["public", "_private", "also_public"])
    var result = builder.build()
    assert_equal(result, "TestClass(public={}, also_public={})")


def test_repr_builder_empty() raises:
    var builder = make_repr_builder("EmptyClass", List[String]())
    var result = builder.build()
    assert_equal(result, "EmptyClass()")


def test_dict_repr_from_dict_basic() raises:
    var d = Dict[String, String]()
    d["prop1"] = "value1"
    d["prop2"] = "value2"
    var result = dict_repr_from_dict("TestClass", d)
    assert_equal(result, "TestClass(prop1=value1, prop2=value2)")


def test_dict_repr_from_dict_skips_private() raises:
    var d = Dict[String, String]()
    d["public"] = "val1"
    d["_private"] = "val2"
    d["also_public"] = "val3"
    var result = dict_repr_from_dict("TestClass", d)
    assert_equal(result, "TestClass(public=val1, also_public=val3)")


def test_dict_repr_from_dict_empty() raises:
    var d = Dict[String, String]()
    var result = dict_repr_from_dict("EmptyClass", d)
    assert_equal(result, "EmptyClass()")


def test_dict_repr_from_dict_single() raises:
    var d = Dict[String, String]()
    d["only"] = "one"
    var result = dict_repr_from_dict("Single", d)
    assert_equal(result, "Single(only=one)")


def test_truncate_string_no_truncate() raises:
    var s = "short string"
    var result = truncate_string(s, 20)
    assert_equal(result, s)


def test_truncate_string_exact_length() raises:
    var s = "exactly_12!"
    var result = truncate_string(s, 12)
    assert_equal(result, s)


def test_truncate_string_truncates() raises:
    var long_str = "a" * 105
    var result = truncate_string(long_str, 100)
    assert_equal(len(result), 100)
    assert_true(result[byte=97:] == "...")


def test_truncate_string_short_limit() raises:
    var s = "hello world"
    var result = truncate_string(s, 5)
    assert_equal(result, "he...")


def test_format_float_short() raises:
    var result = format_float(1.234)
    assert_equal(result, "1.234")


def test_format_float_integer() raises:
    var result = format_float(42.0)
    assert_true("42" in result)


def test_format_float_long() raises:
    var result = format_float(1.23456789)
    assert_equal(len(result), 6)


def test_format_float_zero() raises:
    var result = format_float(0.0)
    assert_true("0" in result)


def test_is_private() raises:
    assert_true(_is_private("_private"))
    assert_true(_is_private("__dunder__"))
    assert_true(not _is_private("public"))
    assert_true(not _is_private(""))


def test_is_abandoned_found() raises:
    var abandon = List[String](["skip1", "skip2"])
    assert_true(_is_abandoned("skip1", abandon))
    assert_true(_is_abandoned("skip2", abandon))
    assert_true(not _is_abandoned("keep", abandon))


def test_is_abandoned_empty() raises:
    var empty = List[String]()
    assert_true(not _is_abandoned("anything", empty))


def test_properties_basic() raises:
    var props = List[PropertyItem]()
    props.append(PropertyItem(name="name", value="Alice"))
    props.append(PropertyItem(name="age", value="30"))

    var cached = List[PropertyItem]()
    cached.append(PropertyItem(name="score", value="99"))

    var inst = MockReprable(
        prop_items=props^,
        cached_items=cached^,
        abandon_list=List[String](),
        class_name="Person",
    )
    var result = properties(inst)
    assert_equal(result.get("name", ""), "Alice")
    assert_equal(result.get("age", ""), "30")
    assert_equal(result.get("score", ""), "99")


def test_properties_filters_private() raises:
    var props = List[PropertyItem]()
    props.append(PropertyItem(name="public", value="ok"))
    props.append(PropertyItem(name="_secret", value="hidden"))

    var inst = MockReprable(
        prop_items=props^,
        cached_items=List[PropertyItem](),
        abandon_list=List[String](),
        class_name="Test",
    )
    var result = properties(inst)
    assert_true("public" in result)
    assert_true(not ("_secret" in result))


def test_properties_filters_abandoned() raises:
    var props = List[PropertyItem]()
    props.append(PropertyItem(name="keep", value="yes"))
    props.append(PropertyItem(name="drop", value="no"))

    var cached = List[PropertyItem]()
    cached.append(PropertyItem(name="cached_drop", value="hidden"))

    var inst = MockReprable(
        prop_items=props^,
        cached_items=cached^,
        abandon_list=List[String](["drop", "cached_drop"]),
        class_name="Test",
    )
    var result = properties(inst)
    assert_true("keep" in result)
    assert_true(not ("drop" in result))
    assert_true(not ("cached_drop" in result))


def test_properties_empty() raises:
    var inst = MockReprable(
        prop_items=List[PropertyItem](),
        cached_items=List[PropertyItem](),
        abandon_list=List[String](),
        class_name="Empty",
    )
    var result = properties(inst)
    assert_equal(len(result), 0)


def test_slots_basic() raises:
    var slot_data = Dict[String, String]()
    slot_data["slot_a"] = "value_a"
    slot_data["slot_b"] = "value_b"

    var inst = MockSlotsReprable(
        slot_data=slot_data^,
        class_name="SlotClass",
    )
    var result = slots(inst)
    assert_equal(result.get("slot_a", ""), "value_a")
    assert_equal(result.get("slot_b", ""), "value_b")


def test_slots_empty() raises:
    var inst = MockSlotsReprable(
        slot_data=Dict[String, String](),
        class_name="Empty",
    )
    var result = slots(inst)
    assert_equal(len(result), 0)


def test_property_repr_basic() raises:
    var props = List[PropertyItem]()
    props.append(PropertyItem(name="x", value="1"))
    props.append(PropertyItem(name="y", value="2"))

    var inst = MockReprable(
        prop_items=props^,
        cached_items=List[PropertyItem](),
        abandon_list=List[String](),
        class_name="Point",
    )
    var result = property_repr(inst)
    assert_equal(result, "Point(x=1, y=2)")


def test_property_repr_with_cached() raises:
    var props = List[PropertyItem]()
    props.append(PropertyItem(name="p", value="pv"))

    var cached = List[PropertyItem]()
    cached.append(PropertyItem(name="c", value="cv"))

    var inst = MockReprable(
        prop_items=props^,
        cached_items=cached^,
        abandon_list=List[String](),
        class_name="Mixed",
    )
    var result = property_repr(inst)
    assert_equal(result, "Mixed(p=pv, c=cv)")


def test_slots_repr_basic() raises:
    var slot_data = Dict[String, String]()
    slot_data["a"] = "1"
    slot_data["b"] = "2"

    var inst = MockSlotsReprable(
        slot_data=slot_data^,
        class_name="SlotObj",
    )
    var result = slots_repr(inst)
    assert_equal(result, "SlotObj(a=1, b=2)")


def test_dict_repr_basic() raises:
    var props = List[PropertyItem]()
    props.append(PropertyItem(name="k", value="v"))

    var inst = MockReprable(
        prop_items=props^,
        cached_items=List[PropertyItem](),
        abandon_list=List[String](),
        class_name="DictStyle",
    )
    var result = dict_repr(inst)
    assert_equal(result, "DictStyle(k=v)")


def test_dict_repr_matches_property_repr() raises:
    var props = List[PropertyItem]()
    props.append(PropertyItem(name="a", value="1"))

    var inst = MockReprable(
        prop_items=props^,
        cached_items=List[PropertyItem](),
        abandon_list=List[String](),
        class_name="Same",
    )
    assert_equal(dict_repr(inst), property_repr(inst))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
