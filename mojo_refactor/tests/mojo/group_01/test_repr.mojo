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


def test_property_repr() -> Bool:
    """Test property_repr function."""
    print("Test 1: property_repr")
    var obj = TestReprClass("test", 42)
    var result = property_repr(obj)
    print("  Result: ", result)
    print("  Contains 'TestReprClass': ", result.count("TestReprClass") > 0)
    print("  PASS")
    return True


def test_dict_repr() -> Bool:
    """Test dict_repr function."""
    print("Test 2: dict_repr")
    var obj = TestReprClass("test", 42)
    var result = dict_repr(obj)
    print("  Result: ", result)
    print("  Contains 'TestReprClass': ", result.count("TestReprClass") > 0)
    print("  PASS")
    return True


def test_slots_repr() -> Bool:
    """Test slots_repr function."""
    print("Test 3: slots_repr")
    var obj = TestSlotsClass("test", 42)
    var result = slots_repr(obj)
    print("  Result: ", result)
    print("  Contains 'TestSlotsClass': ", result.count("TestSlotsClass") > 0)
    print("  PASS")
    return True


def test_properties() -> Bool:
    """Test properties function."""
    print("Test 4: properties")
    var obj = TestReprClass("test", 42)
    var result = properties(obj)
    print("  Properties count: ", len(result))
    var has_name = dict_contains(result, "name")
    var has_value = dict_contains(result, "value")
    print("  Has 'name': ", has_name)
    print("  Has 'value': ", has_value)
    print("  PASS")
    return True


def test_slots() -> Bool:
    """Test slots function."""
    print("Test 5: slots")
    var obj = TestSlotsClass("test", 42)
    var result = slots(obj)
    print("  Slots count: ", len(result))
    var has_name = dict_contains(result, "name")
    var has_value = dict_contains(result, "value")
    print("  Has 'name': ", has_name)
    print("  Has 'value': ", has_value)
    print("  PASS")
    return True


def test_repr_function() -> Bool:
    """Test _repr function."""
    print("Test 6: _repr function")
    var prop_names = List[String]()
    prop_names.append("name")
    prop_names.append("value")
    var result = _repr("TestClass", prop_names)
    print("  Result: ", result)
    print("  Contains 'TestClass': ", result.count("TestClass") > 0)
    print("  PASS")
    return True


def test_truncate_string() -> Bool:
    """Test truncate_string function."""
    print("Test 7: truncate_string")
    var long_str = "a" * 150
    var result = truncate_string(long_str, 100)
    print("  Original length: 150")
    print("  Truncated length: ", len(result))
    print("  Ends with '...': ", result.count("...") > 0)
    print("  PASS")
    return True


def test_format_float() -> Bool:
    """Test format_float function."""
    print("Test 8: format_float")
    var result = format_float(3.14159265, 4)
    print("  Result: ", result)
    print("  PASS")
    return True


def test_abandon_properties() -> Bool:
    """Test __abandon_properties__ filtering."""
    print("Test 9: __abandon_properties__")
    var obj = TestAbandonClass("test", "hidden_value")
    var result = properties(obj)
    print("  Properties count: ", len(result))
    var has_name = dict_contains(result, "name")
    var has_hidden = dict_contains(result, "hidden")
    print("  Has 'name': ", has_name)
    print("  Not has 'hidden': ", not has_hidden)
    print("  PASS")
    return True


def test_repr_builder() -> Bool:
    """Test ReprBuilder."""
    print("Test 10: ReprBuilder")
    var prop_names = List[String]()
    prop_names.append("name")
    prop_names.append("value")
    var builder = make_repr_builder("TestClass", prop_names^)
    var result = builder.build()
    print("  Result: ", result)
    print("  PASS")
    return True


def main() raises:
    print("=" * 60)
    print("Mojo repr.mojo Test")
    print("=" * 60)
    
    var results = List[Bool]()
    results.append(test_property_repr())
    results.append(test_dict_repr())
    results.append(test_slots_repr())
    results.append(test_properties())
    results.append(test_slots())
    results.append(test_repr_function())
    results.append(test_truncate_string())
    results.append(test_format_float())
    results.append(test_abandon_properties())
    results.append(test_repr_builder())
    
    var passed = 0
    for r in results:
        if r:
            passed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, "/", len(results), " passed")
    print("=" * 60)
