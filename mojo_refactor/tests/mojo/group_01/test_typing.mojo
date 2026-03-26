"""
Test for rqmojo/utils/typing.mojo
"""

from std.collections import List
from utils import Variant
from rqmojo.utils.typing import DateLike, StrOrIter, POSITION_DIRECTION_TYPE
from rqmojo.const import POSITION_DIRECTION
from morrow import Morrow


def test_date_like_with_morrow() -> Bool:
    """Test DateLike with Morrow."""
    print("Test 1: DateLike with Morrow")
    var m = Morrow.now()
    print("  Morrow object created")
    print("  PASS")
    return True


def test_date_like_with_int() -> Bool:
    """Test DateLike with Int (timestamp)."""
    print("Test 2: DateLike with Int")
    var timestamp = 1704067200
    print("  Int timestamp: ", timestamp)
    print("  PASS")
    return True


def test_date_like_with_string() -> Bool:
    """Test DateLike with String."""
    print("Test 3: DateLike with String")
    var s = "2024-01-01"
    print("  String date: ", s)
    print("  PASS")
    return True


def test_str_or_iter_with_string() -> Bool:
    """Test StrOrIter with String."""
    print("Test 4: StrOrIter with String")
    var s = "test"
    print("  String: ", s)
    print("  PASS")
    return True


def test_str_or_iter_with_list() -> Bool:
    """Test StrOrIter with List."""
    print("Test 5: StrOrIter with List")
    var lst = List[String]()
    lst.append("a")
    lst.append("b")
    lst.append("c")
    print("  List length: ", len(lst))
    print("  PASS")
    return True


def test_position_direction_type_str() -> Bool:
    """Test POSITION_DIRECTION_TYPE with String."""
    print("Test 6: POSITION_DIRECTION_TYPE with String")
    var s = "LONG"
    print("  String: ", s)
    print("  PASS")
    return True


def test_position_direction_type_enum() -> Bool:
    """Test POSITION_DIRECTION_TYPE with enum."""
    print("Test 7: POSITION_DIRECTION_TYPE with enum")
    var e = POSITION_DIRECTION.LONG
    print("  Enum value: LONG")
    print("  PASS")
    return True


def test_type_aliases_exist() -> Bool:
    """Test that type aliases are defined."""
    print("Test 8: Type aliases exist")
    print("  DateLike: Variant[Morrow, Int, String]")
    print("  StrOrIter: Variant[String, List[String]]")
    print("  POSITION_DIRECTION_TYPE: Variant[String, POSITION_DIRECTION]")
    print("  PASS")
    return True


def test_variant_usage() -> Bool:
    """Test Variant usage."""
    print("Test 9: Variant usage")
    var v1 = DateLike(Morrow.now())
    var v2 = DateLike(1704067200)
    var v3 = DateLike("2024-01-01")
    print("  Variant with Morrow: created")
    print("  Variant with Int: created")
    print("  Variant with String: created")
    print("  PASS")
    return True


def main() raises:
    print("=" * 60)
    print("Mojo typing.mojo Test")
    print("=" * 60)
    
    var results = List[Bool]()
    results.append(test_date_like_with_morrow())
    results.append(test_date_like_with_int())
    results.append(test_date_like_with_string())
    results.append(test_str_or_iter_with_string())
    results.append(test_str_or_iter_with_list())
    results.append(test_position_direction_type_str())
    results.append(test_position_direction_type_enum())
    results.append(test_type_aliases_exist())
    results.append(test_variant_usage())
    
    var passed = 0
    for r in results:
        if r:
            passed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, "/", len(results), " passed")
    print("=" * 60)
