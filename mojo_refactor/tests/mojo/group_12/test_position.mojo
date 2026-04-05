"""
Test for portfolio/position.mojo
Group 12 - File 6
"""

from std.collections import Dict, List
from rqmojo.portfolio.position import Position, create_position
from rqmojo.const import POSITION_DIRECTION
from rqmojo.utils.typing import DateTime
from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def test_position_struct() raises:
    print("Test: Position struct exists")
    var position = create_position("000001.XSHE", POSITION_DIRECTION.LONG)
    assert_equal(position.order_book_id, "000001.XSHE", "Order book ID should match")
    assert_equal(position.direction, POSITION_DIRECTION.LONG, "Direction should be LONG")
    print("  PASSED")


def test_position_quantity() raises:
    print("Test: Position quantity")
    var position = create_position("000001.XSHE", POSITION_DIRECTION.LONG)
    assert_equal(position.quantity, 0, "Initial quantity should be 0")
    print("  PASSED")


def test_position_market_value() raises:
    print("Test: Position market_value")
    var position = create_position("000001.XSHE", POSITION_DIRECTION.LONG)
    assert_equal(position.market_value, 0.0, "Initial market value should be 0")
    print("  PASSED")


def test_position_closable() raises:
    print("Test: Position closable")
    var position = create_position("000001.XSHE", POSITION_DIRECTION.LONG)
    var closable = position.closable()
    assert_equal(closable, 0, "Initial closable should be 0")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
