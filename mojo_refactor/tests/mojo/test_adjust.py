#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Test script for adjust.mojo
"""

import numpy as np
from rqalpha.data.base_data_source.adjust import adjust_bars, get_price_fields, get_fields_require_adjustment, _factor_for_date


def test_basic_functions():
    """Test basic functions"""
    print("Testing basic functions...")
    
    # Test get_price_fields
    price_fields = get_price_fields()
    print(f"Price fields: {price_fields}")
    assert 'open' in price_fields
    assert 'close' in price_fields
    assert 'high' in price_fields
    assert 'low' in price_fields
    
    # Test get_fields_require_adjustment
    adjustment_fields = get_fields_require_adjustment()
    print(f"Adjustment fields: {adjustment_fields}")
    assert 'open' in adjustment_fields
    assert 'close' in adjustment_fields
    assert 'volume' in adjustment_fields
    
    print("Basic functions test passed!")


def test_adjust_bars():
    """Test adjust_bars function"""
    print("\nTesting adjust_bars function...")
    
    # Create sample bars
    dates = np.array([1609459200, 1609545600, 1609632000, 1609718400, 1609804800])  # 2021-01-01 to 2021-01-05
    open_prices = np.array([100.0, 101.0, 102.0, 103.0, 104.0])
    close_prices = np.array([101.0, 102.0, 103.0, 104.0, 105.0])
    volume = np.array([1000, 2000, 3000, 4000, 5000])
    
    dtype = [("datetime", "i8"), ("open", "f8"), ("close", "f8"), ("volume", "i4")]
    bars = np.array(list(zip(dates, open_prices, close_prices, volume)), dtype=dtype)
    
    # Create sample ex_factors
    ex_dates = np.array([1609372800, 1609459200, 1609804800])  # 2020-12-31, 2021-01-01, 2021-01-05
    ex_cum_factors = np.array([1.0, 1.01, 1.02])
    
    ex_dtype = [("start_date", "i8"), ("ex_cum_factor", "f8")]
    ex_factors = np.array(list(zip(ex_dates, ex_cum_factors)), dtype=ex_dtype)
    
    # Test adjust_bars with 'pre' adjust_type
    result = adjust_bars(bars, ex_factors, "", "pre", "2021-01-05")
    print(f"Result shape: {result.shape}")
    assert result.shape == bars.shape
    
    # Test adjust_bars with 'post' adjust_type
    result_post = adjust_bars(bars, ex_factors, "", "post", "2021-01-05")
    print(f"Result shape (post): {result_post.shape}")
    assert result_post.shape == bars.shape
    
    # Test adjust_bars with specific field
    result_open = adjust_bars(bars, ex_factors, "open", "pre", "2021-01-05")
    print(f"Result shape (open): {result_open.shape}")
    assert result_open.shape == bars.shape
    
    result_volume = adjust_bars(bars, ex_factors, "volume", "pre", "2021-01-05")
    print(f"Result shape (volume): {result_volume.shape}")
    assert result_volume.shape == bars.shape
    
    print("adjust_bars test passed!")


def test_edge_cases():
    """Test edge cases"""
    print("\nTesting edge cases...")
    
    # Test with None ex_factors
    dates = np.array([1609459200, 1609545600, 1609632000])
    open_prices = np.array([100.0, 101.0, 102.0])
    dtype = [("datetime", "i8"), ("open", "f8")]
    bars = np.array(list(zip(dates, open_prices)), dtype=dtype)
    
    result = adjust_bars(bars, None, "", "pre", "2021-01-05")
    print(f"Result shape (None ex_factors): {result.shape}")
    assert result.shape == bars.shape
    
    # Test with empty bars
    empty_bars = np.array([], dtype=dtype)
    ex_factors = np.array([(1609372800, 1.0)], dtype=[("start_date", "i8"), ("ex_cum_factor", "f8")])
    result_empty = adjust_bars(empty_bars, ex_factors, "", "pre", "2021-01-05")
    print(f"Result shape (empty bars): {result_empty.shape}")
    assert result_empty.shape == empty_bars.shape
    
    print("Edge cases test passed!")


if __name__ == "__main__":
    test_basic_functions()
    test_adjust_bars()
    test_edge_cases()
    print("\nAll tests passed!")
