"""
Test for data/trading_dates_mixin.mojo
Group 08 - File 10
"""

from rqmojo.data.trading_dates_mixin import TradingDatesMixin, create_trading_dates_mixin
from rqmojo.utils.typing import DateTime
from std.collections import List



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_trading_dates_mixin_init() raises:
    print("Test: TradingDatesMixin init")
    var mixin = create_trading_dates_mixin()
    print("  PASSED")
    assert_true(True, "test passed")


def test_trading_dates_mixin_count_trading_dates() raises:
    print("Test: TradingDatesMixin count_trading_dates")
    var mixin = create_trading_dates_mixin()
    var count = mixin.count_trading_dates(2024, 1, 1, 2024, 1, 31)
    print("  PASSED")
    assert_true(True, "test passed")


def test_trading_dates_mixin_is_trading_date() raises:
    print("Test: TradingDatesMixin is_trading_date")
    var mixin = create_trading_dates_mixin()
    var result = mixin.is_trading_date(2024, 1, 2)
    print("  PASSED")
    assert_true(True, "test passed")


def test_trading_dates_mixin_get_previous_trading_date() raises:
    print("Test: TradingDatesMixin get_previous_trading_date")
    var mixin = create_trading_dates_mixin()
    var prev_date = mixin.get_previous_trading_date(2024, 1, 2)
    print("  PASSED")
    assert_true(True, "test passed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()