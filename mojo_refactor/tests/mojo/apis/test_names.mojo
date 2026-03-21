"""
Test for names.mojo - API Names
Compares output with Python rqalpha/apis/names.py
"""

from std.collections import List
from rqmojo.apis.names import (
    VALID_HISTORY_FIELDS, VALID_TENORS, VALID_MARGIN_FIELDS,
    VALID_SHARE_FIELDS, VALID_TURNOVER_FIELDS, VALID_STOCK_CONNECT_FIELDS,
    VALID_CURRENT_PERFORMANCE_FIELDS, get_valid_instrument_types
)


def test_valid_history_fields():
    """测试 VALID_HISTORY_FIELDS"""
    print("=== Testing VALID_HISTORY_FIELDS ===")
    
    var count = len(VALID_HISTORY_FIELDS)
    print("VALID_HISTORY_FIELDS count: " + String(count))
    
    if count == 16:
        print("PASS: VALID_HISTORY_FIELDS count correct")
    else:
        print("FAIL: expected 16, got " + String(count))
    
    print("")


def test_valid_tenors():
    """测试 VALID_TENORS"""
    print("=== Testing VALID_TENORS ===")
    
    var count = len(VALID_TENORS)
    print("VALID_TENORS count: " + String(count))
    
    if count == 21:
        print("PASS: VALID_TENORS count correct")
    else:
        print("FAIL: expected 21, got " + String(count))
    
    print("")


def test_valid_margin_fields():
    """测试 VALID_MARGIN_FIELDS"""
    print("=== Testing VALID_MARGIN_FIELDS ===")
    
    var count = len(VALID_MARGIN_FIELDS)
    print("VALID_MARGIN_FIELDS count: " + String(count))
    
    if count == 8:
        print("PASS: VALID_MARGIN_FIELDS count correct")
    else:
        print("FAIL: expected 8, got " + String(count))
    
    print("")


def test_valid_share_fields():
    """测试 VALID_SHARE_FIELDS"""
    print("=== Testing VALID_SHARE_FIELDS ===")
    
    var count = len(VALID_SHARE_FIELDS)
    print("VALID_SHARE_FIELDS count: " + String(count))
    
    if count == 5:
        print("PASS: VALID_SHARE_FIELDS count correct")
    else:
        print("FAIL: expected 5, got " + String(count))
    
    print("")


def test_valid_instrument_types():
    """测试 VALID_INSTRUMENT_TYPES"""
    print("=== Testing VALID_INSTRUMENT_TYPES ===")
    
    var types = get_valid_instrument_types()
    var count = len(types)
    print("VALID_INSTRUMENT_TYPES count: " + String(count))
    
    if count == 9:
        print("PASS: VALID_INSTRUMENT_TYPES count correct")
    else:
        print("FAIL: expected 9, got " + String(count))
    
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo apis/names.mojo Test")
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
