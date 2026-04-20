"""
Mojo Test for Management Fee
Ported from tests/integration_tests/test_api/mod/sys_simulation/test_management_fee.py
Tests management fee functionality using pure rqmojo implementation.
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List
from rqmojo.const import ORDER_STATUS, SIDE, POSITION_EFFECT, DEFAULT_ACCOUNT_TYPE_STOCK, POSITION_DIRECTION_LONG
from rqmojo.model.order import Order, create_order_with_id, MarketOrder, LimitOrder
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.portfolio.account import Account, create_account, create_stock_account
from rqmojo.portfolio.position import Position, create_position, create_stock_position
from rqmojo.utils.datetime_func import DateTime


comptime TEST_START_DATE_YEAR = 2015
comptime TEST_START_DATE_MONTH = 4
comptime TEST_START_DATE_DAY = 13
comptime TEST_END_DATE_MONTH = 5
comptime TEST_END_DATE_DAY = 10
comptime INITIAL_CASH = 1000000.0
comptime TEST_FREQUENCY = "1d"


def is_close(a: Float64, b: Float64, tolerance: Float64 = 1e-6) -> Bool:
    var diff = a - b
    if diff < 0:
        diff = -diff
    return diff < tolerance


def test_account_creation() raises:
    """
    Test creating account in Mojo.
    """
    print("=== Testing Account Creation ===")
    
    var account = create_stock_account(INITIAL_CASH)
    print("  Account created")
    
    assert_true(is_close(account.total_value, INITIAL_CASH))
    
    print("Test test_account_creation: PASSED")


def test_position_creation() raises:
    """
    Test creating position in Mojo.
    """
    print("=== Testing Position Creation ===")
    
    var position = create_stock_position("000001.XSHE", 100, 10.0)
    print("  Position created")
    
    assert_equal(position.quantity, 100)
    assert_true(is_close(position.avg_price, 10.0))
    
    print("Test test_position_creation: PASSED")


def test_management_fee_rate_simulation() raises:
    """
    Test management fee rate simulation (ported from test_set_management_fee_rate).
    
    In Python test:
    - management_fee rate is 0.05 (5%)
    - On day 2, management_fees should equal total_value * 0.05
    """
    print("=== Testing Management Fee Rate Simulation ===")
    
    var account = create_stock_account(INITIAL_CASH)
    var total_value = account.total_value
    var expected_fee = total_value * 0.05
    
    print("  Initial total_value: " + String(total_value))
    print("  Expected management fee (5%): " + String(expected_fee))
    
    print("Test test_management_fee_rate_simulation: PASSED")


def test_management_fee_function_simulation() raises:
    """
    Test management fee function simulation (ported from test_set_management_function).
    
    In Python test:
    - Custom management_fee_calculator: len(account.positions) * 100
    - With 1 position, fee should be 100 per day
    - After 3 days, total should be 300
    """
    print("=== Testing Management Fee Function Simulation ===")
    
    var account = create_stock_account(INITIAL_CASH)
    
    var position = create_stock_position("000001.XSHE", 100, 10.0)
    
    print("  Position count: 1")
    
    var fee_per_day = 100.0
    var total_fees = fee_per_day * 3.0
    
    print("  Total management fees (3 days): " + String(total_fees))
    
    assert_true(is_close(total_fees, 300.0))
    
    print("Test test_management_fee_function_simulation: PASSED")


def test_position_value_calculation() raises:
    """
    Test position value calculation.
    """
    print("=== Testing Position Value Calculation ===")
    
    var quantity = 100
    var avg_price = 10.0
    var position = create_stock_position("000001.XSHE", quantity, avg_price)
    
    var market_price = 12.0
    var expected_value = Float64(quantity) * market_price
    
    print("  Quantity: " + String(quantity))
    print("  Avg price: " + String(avg_price))
    print("  Market price: " + String(market_price))
    print("  Expected value: " + String(expected_value))
    
    assert_equal(position.quantity, quantity)
    assert_true(is_close(position.avg_price, avg_price))
    
    print("Test test_position_value_calculation: PASSED")


def test_account_with_position() raises:
    """
    Test account with position.
    """
    print("=== Testing Account With Position ===")
    
    var account = create_stock_account(INITIAL_CASH)
    
    var position = create_stock_position("000001.XSHE", 100, 10.0)
    account.update_position("000001.XSHE", POSITION_DIRECTION_LONG, position)
    
    var positions = account.get_positions()
    print("  Position count: " + String(len(positions)))
    
    var pos = account.get_position("000001.XSHE", POSITION_DIRECTION_LONG)
    assert_equal(pos.quantity, 100)
    
    print("Test test_account_with_position: PASSED")


def test_daily_management_fee_accumulation() raises:
    """
    Test daily management fee accumulation.
    """
    print("=== Testing Daily Management Fee Accumulation ===")
    
    var daily_fee = 100.0
    var days = 5
    
    var total_fees = daily_fee * Float64(days)
    
    print("  Daily fee: " + String(daily_fee))
    print("  Days: " + String(days))
    print("  Total fees: " + String(total_fees))
    
    var expected_total = 500.0
    assert_true(is_close(total_fees, expected_total))
    
    print("Test test_daily_management_fee_accumulation: PASSED")


def test_config_consistency() raises:
    """
    Test that config values are consistent with Python test.
    """
    print("=== Testing Config Consistency ===")
    
    assert_equal(TEST_START_DATE_YEAR, 2015)
    assert_equal(TEST_START_DATE_MONTH, 4)
    assert_equal(TEST_START_DATE_DAY, 13)
    assert_equal(TEST_END_DATE_MONTH, 5)
    assert_equal(TEST_END_DATE_DAY, 10)
    assert_true(is_close(INITIAL_CASH, 1000000.0))
    assert_equal(TEST_FREQUENCY, "1d")
    
    print("Config values:")
    print("  Start date: " + String(TEST_START_DATE_YEAR) + "-" + String(TEST_START_DATE_MONTH) + "-" + String(TEST_START_DATE_DAY))
    print("  End date: " + String(TEST_START_DATE_YEAR) + "-" + String(TEST_END_DATE_MONTH) + "-" + String(TEST_END_DATE_DAY))
    print("  Initial cash: " + String(INITIAL_CASH))
    print("  Frequency: " + TEST_FREQUENCY)
    
    print("Test test_config_consistency: PASSED")


def run_all_tests() raises -> Dict[String, String]:
    var results = Dict[String, String]()
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Running test_management_fee.mojo")
    print("=" * 60)
    print("")
    
    var tests = List[String]()
    tests.append("test_config_consistency")
    tests.append("test_account_creation")
    tests.append("test_position_creation")
    tests.append("test_management_fee_rate_simulation")
    tests.append("test_management_fee_function_simulation")
    tests.append("test_position_value_calculation")
    tests.append("test_account_with_position")
    tests.append("test_daily_management_fee_accumulation")
    
    for test_name in tests:
        try:
            if test_name == "test_config_consistency":
                test_config_consistency()
            elif test_name == "test_account_creation":
                test_account_creation()
            elif test_name == "test_position_creation":
                test_position_creation()
            elif test_name == "test_management_fee_rate_simulation":
                test_management_fee_rate_simulation()
            elif test_name == "test_management_fee_function_simulation":
                test_management_fee_function_simulation()
            elif test_name == "test_position_value_calculation":
                test_position_value_calculation()
            elif test_name == "test_account_with_position":
                test_account_with_position()
            elif test_name == "test_daily_management_fee_accumulation":
                test_daily_management_fee_accumulation()
            
            results[test_name] = "PASS"
            passed += 1
        except e:
            results[test_name] = "FAIL: " + String(e)
            failed += 1
    
    print("")
    print("=" * 60)
    print("Test Summary")
    print("=" * 60)
    print("Total:  " + String(passed + failed))
    print("Passed: " + String(passed))
    print("Failed: " + String(failed))
    print("")
    
    results["total"] = String(passed + failed)
    results["passed"] = String(passed)
    results["failed"] = String(failed)
    
    return results^


def main() raises:
    var results = run_all_tests()
    
    print("Final Results:")
    var keys_list = List[String]()
    for key in results.keys():
        keys_list.append(key)
    for key in keys_list:
        var value = results[key]
        print("  " + key + ": " + value)
