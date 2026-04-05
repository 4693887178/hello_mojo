"""
Test for model/bar.mojo
Group 11 - File 1
"""

from std.collections import Dict, List
from rqmojo.model.bar import BarObject, BarData, BarMap, create_bar_object, create_simple_bar, create_nan_bar_object, create_nan_bar_data
from rqmojo.const import INSTRUMENT_TYPE
from rqmojo.utils.typing import DateTime
from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def test_bar_data_struct() raises:
    print("Test: BarData struct exists")
    var data = create_nan_bar_data()
    assert_true(data.open != data.open, "NaN bar open should be NaN")
    print("  PASSED")


def test_bar_object_struct() raises:
    print("Test: BarObject struct exists")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 1, 1, 10, 0, 0, 0),
        open=10.0,
        high=11.0,
        low=9.5,
        close=10.5,
        volume=1000000.0,
        total_turnover=10500000.0
    )
    assert_equal(bar.order_book_id(), "000001.XSHE", "Order book ID should match")
    assert_equal(bar.open(), 10.0, "Open should match")
    assert_equal(bar.high(), 11.0, "High should match")
    assert_equal(bar.low(), 9.5, "Low should match")
    assert_equal(bar.close(), 10.5, "Close should match")
    print("  PASSED")


def test_bar_is_trading() raises:
    print("Test: BarObject is_trading")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 1, 1, 10, 0, 0, 0),
        open=10.0,
        high=11.0,
        low=9.5,
        close=10.5,
        volume=1000000.0,
        total_turnover=10500000.0
    )
    assert_true(bar.is_trading(), "Bar with volume should be trading")
    
    var bar_no_volume = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 1, 1, 10, 0, 0, 0),
        open=10.0,
        high=11.0,
        low=9.5,
        close=10.5,
        volume=0.0,
        total_turnover=0.0
    )
    assert_false(bar_no_volume.is_trading(), "Bar with no volume should not be trading")
    print("  PASSED")


def test_bar_vwap() raises:
    print("Test: BarObject vwap")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 1, 1, 10, 0, 0, 0),
        open=10.0,
        high=11.0,
        low=9.5,
        close=10.5,
        volume=1000000.0,
        total_turnover=10500000.0
    )
    var vwap = bar.vwap()
    assert_equal(vwap, 10.5, "VWAP should be total_turnover / volume")
    print("  PASSED")


def test_bar_limit_up_down() raises:
    print("Test: BarObject limit_up and limit_down")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 1, 1, 10, 0, 0, 0),
        open=10.0,
        high=11.0,
        low=9.5,
        close=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
        limit_up=11.5,
        limit_down=9.0
    )
    assert_equal(bar.limit_up(), 11.5, "Limit up should match")
    assert_equal(bar.limit_down(), 9.0, "Limit down should match")
    print("  PASSED")


def test_bar_map() raises:
    print("Test: BarMap struct")
    var bar_map = BarMap("1d")
    assert_equal(bar_map.frequency(), "1d", "Frequency should match")
    print("  PASSED")


def test_create_simple_bar() raises:
    print("Test: create_simple_bar function")
    var bar = create_simple_bar(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 1, 1, 10, 0, 0, 0),
        open=10.0,
        high=11.0,
        low=9.5,
        close=10.5,
        volume=1000000.0
    )
    assert_equal(bar.order_book_id(), "000001.XSHE", "Order book ID should match")
    assert_equal(bar.total_turnover(), 1000000.0 * 10.5, "Total turnover should be volume * close")
    print("  PASSED")


def test_create_nan_bar_object() raises:
    print("Test: create_nan_bar_object function")
    var bar = create_nan_bar_object("000001.XSHE")
    assert_equal(bar.order_book_id(), "000001.XSHE", "Order book ID should match")
    assert_true(bar.isnan(), "NaN bar should return True for isnan")
    assert_true(bar.suspended(), "NaN bar should be suspended")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
