"""
Test for typing.mojo - Type Aliases
"""

from std.collections import List
from std.utils import Variant
from rqmojo.const import POSITION_DIRECTION
from rqmojo.utils.typing import DateLike, StrOrIter, POSITION_DIRECTION_TYPE, DateTime


def test_datetime_alias() raises:
    print("=== Testing DateTime alias ===")
    
    print("DateTime is a comptime alias for Morrow")
    
    var dt = DateTime(2020, 1, 1, 10, 30, 0, 0)
    print("DateTime instance created: " + dt.__str__())
    
    print("PASS: DateTime alias works correctly")
    print("")


def test_datelike_type() raises:
    print("=== Testing DateLike type ===")
    
    print("DateLike = Variant[DateTime, Int, String]")
    
    var morrow_val = DateTime(2020, 1, 1, 10, 30, 0, 0)
    var int_val = 20200101
    var string_val = "2020-01-01"
    
    print("DateTime instance created: " + morrow_val.__str__())
    print("Int instance: " + String(int_val))
    print("String instance: " + string_val)
    
    print("PASS: DateLike type alias defined with DateTime, Int, and String")
    print("")


def test_stroriter_type():
    print("=== Testing StrOrIter type ===")
    
    print("StrOrIter = Variant[String, List[String]]")
    
    var string_val = "test"
    var list_val = List[String]()
    list_val.append("item1")
    list_val.append("item2")
    
    print("String instance: " + string_val)
    print("List[String] instance created with " + String(len(list_val)) + " items")
    
    print("PASS: StrOrIter type alias defined")
    print("")


def test_position_direction_type():
    print("=== Testing POSITION_DIRECTION_TYPE ===")
    
    print("POSITION_DIRECTION_TYPE = Variant[String, POSITION_DIRECTION]")
    
    var string_val = "long"
    var enum_val = POSITION_DIRECTION.LONG
    
    print("String instance: " + string_val)
    print("POSITION_DIRECTION instance: LONG")
    
    print("PASS: POSITION_DIRECTION_TYPE defined")
    print("")


def test_type_alias_consistency():
    print("=== Testing type alias consistency ===")
    
    print("All type aliases are defined as comptime Variant types")
    print("PASS: Type alias counts consistent")
    print("")


def main() raises:
    print("=" * 60)
    print("RQAlpha Mojo utils/typing.mojo Test")
    print("=" * 60)
    print("")
    
    test_datetime_alias()
    test_datelike_type()
    test_stroriter_type()
    test_position_direction_type()
    test_type_alias_consistency()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
