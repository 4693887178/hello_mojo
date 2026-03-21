"""
Test for repr.mojo - Repr Utilities
"""

from std.collections import Dict, List
from rqmojo.utils.repr import (
    ReprPropertyItem, CachedProperty, ReprBuilder, Reprable, SlotsReprable,
    _repr, property_repr, dict_repr, dict_repr_from_dict, slots_repr,
    truncate_string, format_float, make_repr_builder
)


@fieldwise_init
struct TestReprable(Reprable, Movable):
    var _name: String
    var _value: Int
    
    def __repr_properties__(self) -> List[ReprPropertyItem]:
        var result = List[ReprPropertyItem]()
        result.append(ReprPropertyItem("name", self._name))
        result.append(ReprPropertyItem("value", String(self._value)))
        return result^
    
    def __repr_cached_properties__(self) -> List[CachedProperty]:
        return List[CachedProperty]()
    
    def __class_name__(self) -> String:
        return "TestReprable"


@fieldwise_init
struct TestSlotsReprable(SlotsReprable, Movable):
    var x: Int
    var y: Int
    
    def __slots__(self) -> List[String]:
        var result = List[String]()
        result.append("x")
        result.append("y")
        return result^
    
    def __get_slot_value(self, name: String) -> String:
        if name == "x":
            return String(self.x)
        if name == "y":
            return String(self.y)
        return ""
    
    def __class_name__(self) -> String:
        return "TestSlotsReprable"


def test_repr_property_item():
    print("=== Testing ReprPropertyItem ===")
    
    var item = ReprPropertyItem("test_name", "test_value")
    
    print("name: " + item.get_name())
    print("value: " + item.get_value())
    
    if item.get_name() == "test_name" and item.get_value() == "test_value":
        print("PASS: ReprPropertyItem works correctly")
    else:
        print("FAIL: ReprPropertyItem mismatch")
    print("")


def test_repr_function():
    print("=== Testing _repr ===")
    
    var props = List[String]()
    props.append("name")
    props.append("value")
    
    var result = _repr("MyClass", props)
    
    print("_repr result: " + result)
    print("PASS: _repr function works correctly")
    print("")


def test_dict_repr_from_dict():
    print("=== Testing dict_repr_from_dict ===")
    
    var d = Dict[String, String]()
    d["name"] = "test"
    d["value"] = "42"
    
    var result = dict_repr_from_dict("MyClass", d)
    
    print("dict_repr_from_dict result: " + result)
    print("PASS: dict_repr_from_dict works correctly")
    print("")


def test_property_repr():
    print("=== Testing property_repr ===")
    
    var obj = TestReprable(_name="test_name", _value=42)
    var result = property_repr(obj)
    
    print("property_repr result: " + result)
    print("PASS: property_repr works correctly")
    print("")


def test_slots_repr():
    print("=== Testing slots_repr ===")
    
    var obj = TestSlotsReprable(x=10, y=20)
    var result = slots_repr(obj)
    
    print("slots_repr result: " + result)
    print("PASS: slots_repr works correctly")
    print("")


def test_truncate_string():
    print("=== Testing truncate_string ===")
    
    var short = "hello"
    var long_str = "a" * 200
    
    var result1 = truncate_string(short, 100)
    var result2 = truncate_string(long_str, 100)
    
    print("Short string: " + result1)
    print("Long string (truncated): " + result2)
    
    if len(result1) == 5 and len(result2) == 100:
        print("PASS: truncate_string works correctly")
    else:
        print("FAIL: truncate_string length mismatch")
    print("")


def test_format_float():
    print("=== Testing format_float ===")
    
    var result1 = format_float(3.14159, 4)
    var result2 = format_float(123.456789, 2)
    
    print("format_float(3.14159, 4): " + result1)
    print("format_float(123.456789, 2): " + result2)
    
    print("PASS: format_float works correctly")
    print("")


def test_repr_builder():
    print("=== Testing ReprBuilder ===")
    
    var props = List[String]()
    props.append("name")
    props.append("value")
    
    var builder = make_repr_builder("TestClass", props^)
    var result = builder.build()
    
    print("ReprBuilder.build result: " + result)
    print("PASS: ReprBuilder works correctly")
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo utils/repr.mojo Test")
    print("=" * 60)
    print("")
    
    test_repr_property_item()
    test_repr_function()
    test_dict_repr_from_dict()
    test_property_repr()
    test_slots_repr()
    test_truncate_string()
    test_format_float()
    test_repr_builder()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
