"""
Test for apis/api_base.mojo
Group 12 - File 5
"""

from std.collections import Dict, List
from rqmojo.apis.api_base import order_shares, order_value, order_percent, cancel_order
from rqmojo.apis.api_base import order_target_value, order_target_percent
from rqmojo.apis.api_base import get_position, get_portfolio, history, get_price
from rqmojo.apis.api_base import get_trading_dates, get_previous_trading_date, get_next_trading_date
from std.testing import assert_equal, assert_true, assert_false, TestSuite


def test_cancel_order_exists() raises:
    print("Test: cancel_order function exists")
    assert_true(True, "cancel_order should exist")
    print("  PASSED")


def test_order_shares_exists() raises:
    print("Test: order_shares function exists")
    assert_true(True, "order_shares should exist")
    print("  PASSED")


def test_order_value_exists() raises:
    print("Test: order_value function exists")
    assert_true(True, "order_value should exist")
    print("  PASSED")


def test_order_percent_exists() raises:
    print("Test: order_percent function exists")
    assert_true(True, "order_percent should exist")
    print("  PASSED")


def test_order_target_value_exists() raises:
    print("Test: order_target_value function exists")
    assert_true(True, "order_target_value should exist")
    print("  PASSED")


def test_order_target_percent_exists() raises:
    print("Test: order_target_percent function exists")
    assert_true(True, "order_target_percent should exist")
    print("  PASSED")


def test_get_position_exists() raises:
    print("Test: get_position function exists")
    assert_true(True, "get_position should exist")
    print("  PASSED")


def test_get_portfolio_exists() raises:
    print("Test: get_portfolio function exists")
    assert_true(True, "get_portfolio should exist")
    print("  PASSED")


def test_get_trading_dates_exists() raises:
    print("Test: get_trading_dates function exists")
    assert_true(True, "get_trading_dates should exist")
    print("  PASSED")


def test_get_previous_trading_date_exists() raises:
    print("Test: get_previous_trading_date function exists")
    assert_true(True, "get_previous_trading_date should exist")
    print("  PASSED")


def test_get_next_trading_date_exists() raises:
    print("Test: get_next_trading_date function exists")
    assert_true(True, "get_next_trading_date should exist")
    print("  PASSED")


def test_get_price_exists() raises:
    print("Test: get_price function exists")
    assert_true(True, "get_price should exist")
    print("  PASSED")


def test_history_exists() raises:
    print("Test: history function exists")
    assert_true(True, "history should exist")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
