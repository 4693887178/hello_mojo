# -*- coding: utf-8 -*-
"""
Test for rqalpha/apis/names.py - API Names
Compares output with Mojo rqmojo/apis/names.mojo
"""

from rqalpha.apis.names import (
    VALID_HISTORY_FIELDS, VALID_TENORS, VALID_MARGIN_FIELDS,
    VALID_SHARE_FIELDS, VALID_TURNOVER_FIELDS, VALID_STOCK_CONNECT_FIELDS,
    VALID_CURRENT_PERFORMANCE_FIELDS, VALID_INSTRUMENT_TYPES
)


def test_valid_history_fields():
    """测试 VALID_HISTORY_FIELDS"""
    print("=== Testing VALID_HISTORY_FIELDS ===")
    
    expected_fields = ["datetime", "open", "close", "high", "low"]
    for field in expected_fields:
        assert field in VALID_HISTORY_FIELDS, f"Expected '{field}' in VALID_HISTORY_FIELDS"
    
    print(f"VALID_HISTORY_FIELDS count: {len(VALID_HISTORY_FIELDS)}")
    print("PASS: VALID_HISTORY_FIELDS correct")
    print("")


def test_valid_tenors():
    """测试 VALID_TENORS"""
    print("=== Testing VALID_TENORS ===")
    
    expected_tenors = ["0S", "1M", "3M", "6M", "1Y", "10Y"]
    for tenor in expected_tenors:
        assert tenor in VALID_TENORS, f"Expected '{tenor}' in VALID_TENORS"
    
    print(f"VALID_TENORS count: {len(VALID_TENORS)}")
    print("PASS: VALID_TENORS correct")
    print("")


def test_valid_margin_fields():
    """测试 VALID_MARGIN_FIELDS"""
    print("=== Testing VALID_MARGIN_FIELDS ===")
    
    expected_fields = ["margin_balance", "short_balance"]
    for field in expected_fields:
        assert field in VALID_MARGIN_FIELDS, f"Expected '{field}' in VALID_MARGIN_FIELDS"
    
    print(f"VALID_MARGIN_FIELDS count: {len(VALID_MARGIN_FIELDS)}")
    print("PASS: VALID_MARGIN_FIELDS correct")
    print("")


def test_valid_share_fields():
    """测试 VALID_SHARE_FIELDS"""
    print("=== Testing VALID_SHARE_FIELDS ===")
    
    expected_fields = ["total", "circulation_a"]
    for field in expected_fields:
        assert field in VALID_SHARE_FIELDS, f"Expected '{field}' in VALID_SHARE_FIELDS"
    
    print(f"VALID_SHARE_FIELDS count: {len(VALID_SHARE_FIELDS)}")
    print("PASS: VALID_SHARE_FIELDS correct")
    print("")


def test_valid_instrument_types():
    """测试 VALID_INSTRUMENT_TYPES"""
    print("=== Testing VALID_INSTRUMENT_TYPES ===")
    
    expected_types = ["CS", "ETF", "Future"]
    for t in expected_types:
        assert t in VALID_INSTRUMENT_TYPES, f"Expected '{t}' in VALID_INSTRUMENT_TYPES"
    
    print(f"VALID_INSTRUMENT_TYPES count: {len(VALID_INSTRUMENT_TYPES)}")
    print("PASS: VALID_INSTRUMENT_TYPES correct")
    print("")


if __name__ == "__main__":
    print("=" * 60)
    print("RQAlpha Python apis/names.py Test")
    print("=" * 60)
    print("")
    
    test_valid_history_fields()
    test_valid_tenors()
    test_valid_margin_fields()
    test_valid_share_fields()
    test_valid_instrument_types()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
