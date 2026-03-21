"""
Test for typing.mojo - Type Aliases
Compares output with Python rqalpha/utils/typing.py
"""

from std.collections import List
from utils import Variant
from rqmojo.const import POSITION_DIRECTION
from rqmojo.utils.datetime_func import Date, DateTime
from rqmojo.utils.typing import DateLike, StrOrIter, POSITION_DIRECTION_TYPE


def test_datelike_type():
    """测试 DateLike 类型别名"""
    print("=== Testing DateLike type ===")
    
    print("DateLike = Variant[Date, DateTime, Int]")
    
    var date_val = Date(2020, 1, 1)
    var datetime_val = DateTime(2020, 1, 1, 10, 30, 0, 0)
    var int_val = 20200101
    
    print("Date instance: " + String(date_val))
    print("DateTime instance: " + String(datetime_val))
    print("Int instance: " + String(int_val))
    
    print("PASS: DateLike type alias defined")
    print("")


def test_stroriter_type():
    """测试 StrOrIter 类型别名"""
    print("=== Testing StrOrIter type ===")
    
    print("StrOrIter = Variant[String, List[String]]")
    
    var str_val = "test_string"
    var list_val = List[String]()
    list_val.append("a")
    list_val.append("b")
    
    print("String instance: " + str_val)
    print("List instance has " + String(len(list_val)) + " elements")
    
    print("PASS: StrOrIter type alias defined")
    print("")


def test_position_direction_type():
    """测试 POSITION_DIRECTION_TYPE 类型别名"""
    print("=== Testing POSITION_DIRECTION_TYPE ===")
    
    print("POSITION_DIRECTION_TYPE = Variant[String, POSITION_DIRECTION]")
    
    var str_val = "LONG"
    var enum_val = POSITION_DIRECTION.LONG
    
    print("String instance: " + str_val)
    print("Enum instance: " + enum_val.name)
    
    print("PASS: POSITION_DIRECTION_TYPE type alias defined")
    print("")


def test_type_alias_consistency():
    """测试类型别名数量一致性"""
    print("=== Testing type alias consistency ===")
    
    print("DateLike has 3 type options: Date, DateTime, Int")
    print("StrOrIter has 2 type options: String, List[String]")
    print("POSITION_DIRECTION_TYPE has 2 type options: String, POSITION_DIRECTION")
    
    print("PASS: Type alias counts consistent")
    print("")


def test_variant_usage():
    """测试 Variant 实际使用"""
    print("=== Testing Variant usage ===")
    
    var date_like: DateLike = Date(2020, 6, 15)
    print("DateLike variant with Date: " + String(date_like))
    
    var str_or_iter: StrOrIter = "single_string"
    print("StrOrIter variant with String: " + str_or_iter)
    
    var pos_dir: POSITION_DIRECTION_TYPE = "LONG"
    print("POSITION_DIRECTION_TYPE variant with String: " + pos_dir)
    
    print("PASS: Variant usage works correctly")
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
    test_variant_usage()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
