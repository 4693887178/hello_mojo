"""
Test for adjust.mojo - Data Adjustment
Compares output with Python rqalpha/data/base_data_source/adjust.py
"""

from std.collections import Set, List, Dict
from rqmojo.data.base_data_source.adjust import (
    get_price_fields, get_fields_require_adjustment,
    _factor_for_date, adjust_bars
)


def test_price_fields():
    """测试 PRICE_FIELDS 常量"""
    print("=== Testing PRICE_FIELDS ===")
    
    var fields = get_price_fields()
    
    if fields.contains("open"):
        print("PASS: PRICE_FIELDS contains 'open'")
    else:
        print("FAIL: PRICE_FIELDS should contain 'open'")
    
    if fields.contains("close"):
        print("PASS: PRICE_FIELDS contains 'close'")
    else:
        print("FAIL: PRICE_FIELDS should contain 'close'")
    
    print("")


def test_fields_require_adjustment():
    """测试 FIELDS_REQUIRE_ADJUSTMENT 常量"""
    print("=== Testing FIELDS_REQUIRE_ADJUSTMENT ===")
    
    var fields = get_fields_require_adjustment()
    
    if fields.contains("volume"):
        print("PASS: FIELDS_REQUIRE_ADJUSTMENT contains 'volume'")
    else:
        print("FAIL: FIELDS_REQUIRE_ADJUSTMENT should contain 'volume'")
    
    print("")


def test_factor_for_date():
    """测试 _factor_for_date 函数"""
    print("=== Testing _factor_for_date ===")
    
    var dates = List[UInt64]()
    dates.append(20200101)
    dates.append(20200601)
    dates.append(20210101)
    
    var factors = List[Float64]()
    factors.append(1.0)
    factors.append(1.1)
    factors.append(1.2)
    
    var result = _factor_for_date(dates, factors, 20200301)
    print("_factor_for_date result: " + String(result))
    
    if result == 1.0:
        print("PASS: _factor_for_date returns 1.0")
    else:
        print("FAIL: expected 1.0, got " + String(result))
    
    print("")


def test_adjust_bars_empty():
    """测试 adjust_bars 空输入"""
    print("=== Testing adjust_bars empty ===")
    
    var bars = List[Dict[String, object]]()
    var result = adjust_bars(bars, None, "close", "post", None)
    
    if len(result) == 0:
        print("PASS: adjust_bars handles empty input")
    else:
        print("FAIL: expected empty result")
    
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo data/base_data_source/adjust.mojo Test")
    print("=" * 60)
    print("")
    
    test_price_fields()
    test_fields_require_adjustment()
    test_factor_for_date()
    test_adjust_bars_empty()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
