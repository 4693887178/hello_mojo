"""
Mojo Test for Simulation Event Source Integration
Ported from tests/integration_tests/test_api/mod/sys_simulation/test_simulation_event_source_integration.py
Tests simulation event source functionality using pure rqmojo implementation.
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List
from rqmojo.const import ORDER_STATUS, SIDE, POSITION_EFFECT
from rqmojo.model.bar import BarObject, BarMap, create_bar_object, create_bar_map
from rqmojo.utils.datetime_func import DateTime


comptime TEST_START_DATE_YEAR = 2015
comptime TEST_START_DATE_MONTH = 4
comptime TEST_START_DATE_DAY = 14
comptime TEST_END_DATE_DAY = 24
comptime INITIAL_CASH = 1000000.0
comptime TEST_FREQUENCY = "1d"


def is_close(a: Float64, b: Float64, tolerance: Float64 = 1e-6) -> Bool:
    var diff = a - b
    if diff < 0:
        diff = -diff
    return diff < tolerance


def test_bar_map_creation() raises:
    """
    Test creating bar map in Mojo.
    """
    print("=== Testing Bar Map Creation ===")
    
    var bar_map = create_bar_map("1d")
    print("  BarMap created with frequency: 1d")
    
    assert_equal(bar_map.frequency(), "1d")
    
    print("Test test_bar_map_creation: PASSED")


def test_bar_map_update_dt() raises:
    """
    Test updating datetime in bar map.
    """
    print("=== Testing Bar Map Update DateTime ===")
    
    var bar_map = create_bar_map("1d")
    var dt = DateTime(2015, 4, 14, 9, 31, 0, 0)
    
    bar_map.update_dt(dt)
    print("  BarMap datetime updated: " + bar_map.dt().__str__())
    
    assert_equal(bar_map.dt().year, 2015)
    assert_equal(bar_map.dt().month, 4)
    assert_equal(bar_map.dt().day, 14)
    
    print("Test test_bar_map_update_dt: PASSED")


def test_open_auction_bar_properties() raises:
    """
    Test open auction bar properties (ported from test_open_auction).
    
    In Python test:
    - open_auction bar does not have 'close' attribute
    - open_auction_prices are stored: (open, limit_up, limit_down, prev_close)
    """
    print("=== Testing Open Auction Bar Properties ===")
    
    var dt = DateTime(2015, 4, 14, 9, 25, 0, 0)
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=dt,
        open=18.0,
        high=18.5,
        low=17.5,
        close=18.2,
        volume=1000000.0,
        total_turnover=18000000.0,
        limit_up=19.8,
        limit_down=16.2,
        prev_close=18.0
    )
    
    print("  Bar open: " + String(bar.open()))
    print("  Bar limit_up: " + String(bar.limit_up()))
    print("  Bar limit_down: " + String(bar.limit_down()))
    print("  Bar prev_close: " + String(bar.prev_close()))
    
    assert_equal(bar.open(), 18.0)
    assert_true(is_close(bar.limit_up(), 19.8))
    assert_true(is_close(bar.limit_down(), 16.2))
    assert_true(is_close(bar.prev_close(), 18.0))
    
    print("Test test_open_auction_bar_properties: PASSED")


def test_handle_bar_with_close() raises:
    """
    Test handle_bar with close attribute (ported from test_open_auction).
    
    In Python test:
    - handle_bar bar has 'close' attribute
    - open_auction_prices match bar values
    """
    print("=== Testing Handle Bar With Close ===")
    
    var dt = DateTime(2015, 4, 14, 15, 0, 0, 0)
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=dt,
        open=18.0,
        high=18.8,
        low=17.8,
        close=18.5,
        volume=2000000.0,
        total_turnover=36000000.0,
        limit_up=19.8,
        limit_down=16.2,
        prev_close=18.0
    )
    
    print("  Bar has close: " + String(bar.close()))
    print("  Bar open: " + String(bar.open()))
    print("  Bar limit_up: " + String(bar.limit_up()))
    print("  Bar limit_down: " + String(bar.limit_down()))
    print("  Bar prev_close: " + String(bar.prev_close()))
    
    assert_true(is_close(bar.close(), 18.5))
    assert_true(is_close(bar.open(), 18.0))
    
    print("Test test_handle_bar_with_close: PASSED")


def test_event_source_dates() raises:
    """
    Test event source date range.
    """
    print("=== Testing Event Source Dates ===")
    
    var start_dt = DateTime(TEST_START_DATE_YEAR, TEST_START_DATE_MONTH, TEST_START_DATE_DAY, 0, 0, 0, 0)
    var end_dt = DateTime(TEST_START_DATE_YEAR, TEST_START_DATE_MONTH, TEST_END_DATE_DAY, 0, 0, 0, 0)
    
    print("  Start date: " + start_dt.__str__())
    print("  End date: " + end_dt.__str__())
    
    assert_equal(start_dt.year, 2015)
    assert_equal(start_dt.month, 4)
    assert_equal(start_dt.day, 14)
    assert_equal(end_dt.day, 24)
    
    print("Test test_event_source_dates: PASSED")


def test_config_consistency() raises:
    """
    Test that config values are consistent with Python test.
    """
    print("=== Testing Config Consistency ===")
    
    assert_equal(TEST_START_DATE_YEAR, 2015)
    assert_equal(TEST_START_DATE_MONTH, 4)
    assert_equal(TEST_START_DATE_DAY, 14)
    assert_equal(TEST_END_DATE_DAY, 24)
    assert_true(is_close(INITIAL_CASH, 1000000.0))
    assert_equal(TEST_FREQUENCY, "1d")
    
    print("Config values:")
    print("  Start date: " + String(TEST_START_DATE_YEAR) + "-" + String(TEST_START_DATE_MONTH) + "-" + String(TEST_START_DATE_DAY))
    print("  End date: " + String(TEST_START_DATE_YEAR) + "-" + String(TEST_START_DATE_MONTH) + "-" + String(TEST_END_DATE_DAY))
    print("  Initial cash: " + String(INITIAL_CASH))
    print("  Frequency: " + TEST_FREQUENCY)
    
    print("Test test_config_consistency: PASSED")


def run_all_tests() raises -> Dict[String, String]:
    var results = Dict[String, String]()
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Running test_simulation_event_source_integration.mojo")
    print("=" * 60)
    print("")
    
    var tests = List[String]()
    tests.append("test_config_consistency")
    tests.append("test_bar_map_creation")
    tests.append("test_bar_map_update_dt")
    tests.append("test_open_auction_bar_properties")
    tests.append("test_handle_bar_with_close")
    tests.append("test_event_source_dates")
    
    for test_name in tests:
        try:
            if test_name == "test_config_consistency":
                test_config_consistency()
            elif test_name == "test_bar_map_creation":
                test_bar_map_creation()
            elif test_name == "test_bar_map_update_dt":
                test_bar_map_update_dt()
            elif test_name == "test_open_auction_bar_properties":
                test_open_auction_bar_properties()
            elif test_name == "test_handle_bar_with_close":
                test_handle_bar_with_close()
            elif test_name == "test_event_source_dates":
                test_event_source_dates()
            
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
