"""
Test for adjust.mojo - Data Adjustment
Uses Python interop for numpy operations
"""

from std.collections import Set, List, Dict
from std.python import Python, PythonObject
from rqmojo.data.base_data_source.adjust import (
    get_price_fields, get_fields_require_adjustment
)


def _set_contains(s: Set[String], key: String) -> Bool:
    for item in s:
        if item == key:
            return True
    return False


def test_price_fields():
    print("=== Testing PRICE_FIELDS ===")
    
    var fields = get_price_fields()
    
    if _set_contains(fields, "open"):
        print("PASS: PRICE_FIELDS contains 'open'")
    else:
        print("FAIL: PRICE_FIELDS should contain 'open'")
    
    if _set_contains(fields, "close"):
        print("PASS: PRICE_FIELDS contains 'close'")
    else:
        print("FAIL: PRICE_FIELDS should contain 'close'")
    
    print("")


def test_fields_require_adjustment():
    print("=== Testing FIELDS_REQUIRE_ADJUSTMENT ===")
    
    var fields = get_fields_require_adjustment()
    
    if _set_contains(fields, "volume"):
        print("PASS: FIELDS_REQUIRE_ADJUSTMENT contains 'volume'")
    else:
        print("FAIL: FIELDS_REQUIRE_ADJUSTMENT should contain 'volume'")
    
    print("")


def test_price_fields_count():
    print("=== Testing PRICE_FIELDS count ===")
    
    var fields = get_price_fields()
    var count = 0
    for _ in fields:
        count += 1
    
    print("PRICE_FIELDS count: " + String(count))
    
    if count == 8:
        print("PASS: PRICE_FIELDS has 8 fields")
    else:
        print("FAIL: expected 8 fields, got " + String(count))
    
    print("")


def test_fields_require_adjustment_count():
    print("=== Testing FIELDS_REQUIRE_ADJUSTMENT count ===")
    
    var fields = get_fields_require_adjustment()
    var count = 0
    for _ in fields:
        count += 1
    
    print("FIELDS_REQUIRE_ADJUSTMENT count: " + String(count))
    
    if count == 9:
        print("PASS: FIELDS_REQUIRE_ADJUSTMENT has 9 fields")
    else:
        print("FAIL: expected 9 fields, got " + String(count))
    
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo data/base_data_source/adjust.mojo Test")
    print("=" * 60)
    print("")
    
    test_price_fields()
    test_fields_require_adjustment()
    test_price_fields_count()
    test_fields_require_adjustment_count()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
