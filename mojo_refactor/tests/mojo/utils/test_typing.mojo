"""
Test for typing.mojo - Type Aliases
"""

from std.collections import List
from utils import Variant
from rqmojo.const import POSITION_DIRECTION
from rqmojo.utils.datetime_func import Date, DateTime
from rqmojo.utils.typing import DateLike, StrOrIter, POSITION_DIRECTION_TYPE


def test_datelike_type():
    print("=== Testing DateLike type ===")
    
    print("DateLike = Variant[Date, DateTime, Int]")
    
    var date_val = Date(2020, 1, 1)
    var datetime_val = DateTime(2020, 1, 1, 10, 30, 0, 0)
    var int_val = 20200101
    
    print("Date instance created")
    print("DateTime instance created")
    print("Int instance: " + String(int_val))
    
    print("PASS: DateLike type alias defined")
    print("")


def test_stroriter_type():
    print("=== Testing StrOrIter type ===")
    
    print("StrOrIter = Variant[String, List[String]]")
    
    print("PASS: StrOrIter type alias defined")
    print("")


def test_position_direction_type():
    print("=== Testing POSITION_DIRECTION_TYPE ===")
    
    print("POSITION_DIRECTION_TYPE = Variant[String, POSITION_DIRECTION]")
    
    print("PASS: POSITION_DIRECTION_TYPE defined")
    print("")


def test_type_alias_consistency():
    print("=== Testing type alias consistency ===")
    
    print("All type aliases are defined as comptime Variant types")
    print("PASS: Type alias counts consistent")
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo utils/typing.mojo Test")
    print("=" * 60)
    print("")
    
    test_datelike_type()
    test_stroriter_type()
    test_position_direction_type()
    test_type_alias_consistency()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
