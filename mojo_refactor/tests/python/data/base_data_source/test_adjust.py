# -*- coding: utf-8 -*-
"""
Test for rqalpha/data/base_data_source/adjust.py - Data Adjustment
Compares output with Mojo rqmojo/data/base_data_source/adjust.mojo
"""

import numpy as np
from rqalpha.data.base_data_source.adjust import (
    PRICE_FIELDS, FIELDS_REQUIRE_ADJUSTMENT,
    _factor_for_date, adjust_bars
)


def test_price_fields():
    """测试 PRICE_FIELDS 常量"""
    print("=== Testing PRICE_FIELDS ===")
    
    expected = {'open', 'close', 'high', 'low', 'limit_up', 'limit_down', 'acc_net_value', 'unit_net_value'}
    assert PRICE_FIELDS == expected, f"Expected {expected}, got {PRICE_FIELDS}"
    
    print(f"PRICE_FIELDS: {PRICE_FIELDS}")
    print("PASS: PRICE_FIELDS correct")
    print("")


def test_fields_require_adjustment():
    """测试 FIELDS_REQUIRE_ADJUSTMENT 常量"""
    print("=== Testing FIELDS_REQUIRE_ADJUSTMENT ===")
    
    expected = PRICE_FIELDS | {'volume'}
    assert FIELDS_REQUIRE_ADJUSTMENT == expected, f"Expected {expected}, got {FIELDS_REQUIRE_ADJUSTMENT}"
    
    print(f"FIELDS_REQUIRE_ADJUSTMENT: {FIELDS_REQUIRE_ADJUSTMENT}")
    print("PASS: FIELDS_REQUIRE_ADJUSTMENT correct")
    print("")


def test_factor_for_date():
    """测试 _factor_for_date 函数"""
    print("=== Testing _factor_for_date ===")
    
    dates = np.array([20200101, 20200601, 20210101], dtype=np.uint64)
    factors = np.array([1.0, 1.1, 1.2], dtype=np.float64)
    
    result = _factor_for_date(dates, factors, 20200301)
    print(f"_factor_for_date([20200101, 20200601, 20210101], [1.0, 1.1, 1.2], 20200301) = {result}")
    
    assert result == 1.0, f"Expected 1.0, got {result}"
    
    result2 = _factor_for_date(dates, factors, 20200701)
    print(f"_factor_for_date([20200101, 20200601, 20210101], [1.0, 1.1, 1.2], 20200701) = {result2}")
    
    assert result2 == 1.1, f"Expected 1.1, got {result2}"
    
    print("PASS: _factor_for_date works correctly")
    print("")


def test_adjust_bars_empty():
    """测试 adjust_bars 空输入"""
    print("=== Testing adjust_bars empty ===")
    
    bars = np.array([], dtype=[('datetime', 'uint64'), ('close', 'float64')])
    result = adjust_bars(bars, None, 'close', 'post', None)
    
    assert len(result) == 0, "Expected empty result"
    
    print("PASS: adjust_bars handles empty input")
    print("")


def test_adjust_bars_no_factors():
    """测试 adjust_bars 无复权因子"""
    print("=== Testing adjust_bars no factors ===")
    
    bars = np.array([(20200101, 10.0), (20200102, 11.0)], dtype=[('datetime', 'uint64'), ('close', 'float64')])
    result = adjust_bars(bars, None, 'close', 'post', None)
    
    assert len(result) == 2, "Expected 2 bars"
    
    print("PASS: adjust_bars handles no factors")
    print("")


if __name__ == "__main__":
    print("=" * 60)
    print("RQAlpha Python data/base_data_source/adjust.py Test")
    print("=" * 60)
    print("")
    
    test_price_fields()
    test_fields_require_adjustment()
    test_factor_for_date()
    test_adjust_bars_empty()
    test_adjust_bars_no_factors()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
