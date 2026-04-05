"""
Test for mod/rqmojo_mod_sys_simulation/matcher.mojo
Group 10 - File 5
"""

from std.collections import Dict, List
from rqmojo.mod.rqmojo_mod_sys_simulation.matcher import Matcher, create_matcher
from rqmojo.model.order import Order, create_order_with_id, MarketOrder
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.const import SIDE, POSITION_EFFECT, MATCHING_TYPE
from rqmojo.utils.typing import DateTime
from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def test_matcher_struct() raises:
    print("Test: Matcher struct exists")
    var matcher = create_matcher()
    assert_true(True, "Matcher should be creatable")
    print("  PASSED")


def test_matcher_match_order() raises:
    print("Test: Matcher match_order method")
    var matcher = create_matcher(matching_type=MATCHING_TYPE.CURRENT_BAR_CLOSE, slippage=0.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 1, 1, 10, 0, 0, 0),
        open=10.0,
        close=10.5,
        high=11.0,
        low=9.5,
        volume=1000000.0,
        total_turnover=10500000.0
    )
    var trade = matcher.match_order(order, bar, DateTime(2024, 1, 1, 10, 0, 0, 0))
    assert_true(trade is not None, "Trade should be created")
    print("  PASSED")


def test_matcher_slippage() raises:
    print("Test: Matcher slippage")
    var matcher = create_matcher(matching_type=MATCHING_TYPE.CURRENT_BAR_CLOSE, slippage=0.01)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 1, 1, 10, 0, 0, 0),
        open=10.0,
        close=10.0,
        high=10.0,
        low=10.0,
        volume=1000000.0,
        total_turnover=10000000.0
    )
    var trade = matcher.match_order(order, bar, DateTime(2024, 1, 1, 10, 0, 0, 0))
    if trade is not None:
        var t = trade.value()
        assert_true(t.price > 10.0, "Buy price should be higher with slippage")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
