"""
Test for names.mojo - API Names
"""

from std.collections import List
from rqmojo.apis.names import (
    get_valid_history_fields, get_valid_tenors, get_valid_margin_fields,
    get_valid_share_fields, get_valid_instrument_types
)


def test_valid_history_fields():
    print("=== Testing VALID_HISTORY_FIELDS ===")
    
    var fields = get_valid_history_fields()
    var count = len(fields)
    print("VALID_HISTORY_FIELDS count: " + String(count))
    
    if count == 16:
        print("PASS: VALID_HISTORY_FIELDS count correct")
    else:
        print("FAIL: expected 16, got " + String(count))
    
    print("")


def test_valid_tenors():
    print("=== Testing VALID_TENORS ===")
    
    var tenors = get_valid_tenors()
    var count = len(tenors)
    print("VALID_TENORS count: " + String(count))
    
    if count == 21:
        print("PASS: VALID_TENORS count correct")
    else:
        print("FAIL: expected 21, got " + String(count))
    
    print("")


def test_valid_margin_fields():
    print("=== Testing VALID_MARGIN_FIELDS ===")
    
    var fields = get_valid_margin_fields()
    var count = len(fields)
    print("VALID_MARGIN_FIELDS count: " + String(count))
    
    if count == 8:
        print("PASS: VALID_MARGIN_FIELDS count correct")
    else:
        print("FAIL: expected 8, got " + String(count))
    
    print("")


def test_valid_share_fields():
    print("=== Testing VALID_SHARE_FIELDS ===")
    
    var fields = get_valid_share_fields()
    var count = len(fields)
    print("VALID_SHARE_FIELDS count: " + String(count))
    
    if count == 5:
        print("PASS: VALID_SHARE_FIELDS count correct")
    else:
        print("FAIL: expected 5, got " + String(count))
    
    print("")


def test_valid_instrument_types():
    print("=== Testing VALID_INSTRUMENT_TYPES ===")
    
    var types = get_valid_instrument_types()
    var count = len(types)
    print("VALID_INSTRUMENT_TYPES count: " + String(count))
    
    if count == 16:
        print("PASS: VALID_INSTRUMENT_TYPES count correct")
    else:
        print("FAIL: expected 16, got " + String(count))
    
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
