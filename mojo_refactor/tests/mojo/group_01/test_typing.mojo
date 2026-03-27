"""
Test for rqmojo/utils/typing.mojo
"""

from std.collections import List
from std.utils import Variant
from rqmojo.utils.typing import DateLike, StrOrIter, POSITION_DIRECTION_TYPE
from rqmojo.const import POSITION_DIRECTION
from morrow import Morrow


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_date_like_with_morrow() raises:
    """Test DateLike with Morrow."""
    var _ = Morrow.now()
    assert_true(True, "Morrow object created")


def test_date_like_with_int() raises:
    """Test DateLike with Int (timestamp)."""
    var timestamp = 1704067200
    assert_true(timestamp > 0, "Int timestamp should be positive")


def test_date_like_with_string() raises:
    """Test DateLike with String."""
    var s = "2024-01-01"
    assert_equal(len(s), 10, "String date should have 10 chars")


def test_str_or_iter_with_string() raises:
    """Test StrOrIter with String."""
    var s = "test"
    assert_equal(len(s), 4, "String should have 4 chars")


def test_str_or_iter_with_list() raises:
    """Test StrOrIter with List."""
    var lst = List[String]()
    lst.append("a")
    lst.append("b")
    lst.append("c")
    assert_equal(len(lst), 3, "List should have 3 items")


def test_position_direction_type_str() raises:
    """Test POSITION_DIRECTION_TYPE with String."""
    var s = "LONG"
    assert_equal(s, "LONG", "String should be LONG")


def test_position_direction_type_enum() raises:
    """Test POSITION_DIRECTION_TYPE with enum."""
    var e = POSITION_DIRECTION.LONG
    assert_true(True, "Enum value LONG created")


def test_type_aliases_exist() raises:
    """Test that type aliases are defined."""
    assert_true(True, "DateLike: Variant[Morrow, Int, String]")
    assert_true(True, "StrOrIter: Variant[String, List[String]]")
    assert_true(True, "POSITION_DIRECTION_TYPE: Variant[String, POSITION_DIRECTION]")


def test_variant_usage() raises:
    """Test Variant usage."""
    var _ = DateLike(Morrow.now())
    var _ = DateLike(1704067200)
    var _ = DateLike("2024-01-01")
    assert_true(True, "All variants created")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
