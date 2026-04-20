"""
Test for rqmojo/utils/repr.mojo
"""

from std.collections import Dict, List
from rqmojo.utils.repr import (
    property_repr, slots_repr, dict_repr, properties, slots,
    Reprable, SlotsReprable, ReprPropertyItem, CachedProperty,
    _repr, truncate_string, format_float, ReprBuilder, make_repr_builder
)


struct TestReprClass(Reprable, Copyable, Movable):
    var _name: String
    var _value: Int
    
    def __init__(out self, name: String, value: Int):
        self._name = name
        self._value = value
    
    def __repr_properties__(self) -> List[ReprPropertyItem]:
        var props = List[ReprPropertyItem]()
        props.append(ReprPropertyItem("name", self._name))
        props.append(ReprPropertyItem("value", String(self._value)))
        return props^
    
    def __repr_cached_properties__(self) -> List[CachedProperty]:
        return List[CachedProperty]()
    
    def __class_name__(self) -> String:
        return "TestReprClass"


struct TestSlotsClass(SlotsReprable, Copyable, Movable):
    var _name: String
    var _value: Int
    
    def __init__(out self, name: String, value: Int):
        self._name = name
        self._value = value
    
    def __slots__(self) -> List[String]:
        var slots_list = List[String]()
        slots_list.append("name")
        slots_list.append("value")
        return slots_list^
    
    def __get_slot_value(self, name: String) -> String:
        if name == "name":
            return self._name
        if name == "value":
            return String(self._value)
        return ""
    
    def __class_name__(self) -> String:
        return "TestSlotsClass"


struct TestAbandonClass(Reprable, Copyable, Movable):
    var _name: String
    var _hidden: String
    
    def __init__(out self, name: String, hidden: String):
        self._name = name
        self._hidden = hidden
    
    def __repr_properties__(self) -> List[ReprPropertyItem]:
        var props = List[ReprPropertyItem]()
        props.append(ReprPropertyItem("name", self._name))
        props.append(ReprPropertyItem("hidden", self._hidden))
        return props^
    
    def __repr_cached_properties__(self) -> List[CachedProperty]:
        return List[CachedProperty]()
    
    def __class_name__(self) -> String:
        return "TestAbandonClass"
    
    def __abandon_properties__(self) -> List[String]:
        var abandon = List[String]()
        abandon.append("hidden")
        return abandon^


def dict_contains(d: Dict[String, String], key: String) -> Bool:
    """Check if dict contains key."""
    for k in d.keys():
        if k == key:
            return True
    return False



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_property_repr() raises:
    """Test property_repr function."""
    var obj = TestReprClass("test", 42)
    var result = property_repr(obj)
    assert_true(result.count("TestReprClass") > 0, "Should contain TestReprClass")


def test_dict_repr() raises:
    """Test dict_repr function."""
    var obj = TestReprClass("test", 42)
    var result = dict_repr(obj)
    assert_true(result.count("TestReprClass") > 0, "Should contain TestReprClass")


def test_slots_repr() raises:
    """Test slots_repr function."""
    var obj = TestSlotsClass("test", 42)
    var result = slots_repr(obj)
    assert_true(result.count("TestSlotsClass") > 0, "Should contain TestSlotsClass")


def test_properties() raises:
    """Test properties function."""
    var obj = TestReprClass("test", 42)
    var result = properties(obj)
    assert_equal(len(result), 2, "Should have 2 properties")
    assert_true(dict_contains(result, "name"), "Should have name property")
    assert_true(dict_contains(result, "value"), "Should have value property")


def test_slots() raises:
    """Test slots function."""
    var obj = TestSlotsClass("test", 42)
    var result = slots(obj)
    assert_equal(len(result), 2, "Should have 2 slots")
    assert_true(dict_contains(result, "name"), "Should have name slot")
    assert_true(dict_contains(result, "value"), "Should have value slot")


def test_repr_function() raises:
    """Test _repr function."""
    var prop_names = List[String]()
    prop_names.append("name")
    prop_names.append("value")
    var result = _repr("TestClass", prop_names)
    assert_true(result.count("TestClass") > 0, "Should contain TestClass")


def test_truncate_string() raises:
    """Test truncate_string function."""
    var long_str = "a" * 150
    var result = truncate_string(long_str, 100)
    assert_equal(len(result), 100, "Should truncate to 100 chars")
    assert_true(result.count("...") > 0, "Should end with ...")


def test_format_float() raises:
    """Test format_float function."""
    var result = format_float(3.14159265, 4)
    assert_true(len(result) > 0, "Should return a string")


def test_abandon_properties() raises:
    """Test __abandon_properties__ filtering."""
    var obj = TestAbandonClass("test", "hidden_value")
    var result = properties(obj)
    assert_equal(len(result), 1, "Should have 1 property after abandon")
    assert_true(dict_contains(result, "name"), "Should have name property")
    assert_false(dict_contains(result, "hidden"), "Should not have hidden property")


def test_repr_builder() raises:
    """Test ReprBuilder."""
    var prop_names = List[String]()
    prop_names.append("name")
    prop_names.append("value")
    var builder = make_repr_builder("TestClass", prop_names^)
    var result = builder.build()
    assert_true(result.count("TestClass") > 0, "Should contain TestClass")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
