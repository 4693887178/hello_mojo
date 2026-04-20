"""
RQMojo Test for data/base_data_source/adjust.mojo
Group 02 - File 10
Tests for data adjustment functions
"""

from python import Python
from rqmojo.data.base_data_source.adjust import get_price_fields, get_fields_require_adjustment



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_get_price_fields() raises:
    print("Testing get_price_fields...")
    
    var fields = get_price_fields()
    var found_open = False
    var found_close = False
    var found_high = False
    var found_low = False
    
    for f in fields:
        if f == "open":
            found_open = True
        elif f == "close":
            found_close = True
        elif f == "high":
            found_high = True
        elif f == "low":
            found_low = True
    
    assert_true(found_open)
    assert_true(found_close)
    assert_true(found_high)
    assert_true(found_low)
    
    print("  get_price_fields tests passed!")


def test_get_fields_require_adjustment() raises:
    print("Testing get_fields_require_adjustment...")
    
    var fields = get_fields_require_adjustment()
    var found_open = False
    var found_volume = False
    
    for f in fields:
        if f == "open":
            found_open = True
        elif f == "volume":
            found_volume = True
    
    assert_true(found_open)
    assert_true(found_volume)
    
    print("  get_fields_require_adjustment tests passed!")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()