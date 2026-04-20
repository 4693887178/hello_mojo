"""
RQAlpha Mojo - API Names Module Test
Tests for apis/names.mojo
"""

from std.collections import List
from rqmojo.apis.names import (
    get_valid_history_fields,
    get_valid_tenors,
    get_valid_instrument_types,
    get_valid_margin_fields,
    get_valid_share_fields,
)
from rqmojo.const import INSTRUMENT_TYPE


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_valid_history_fields() raises:
    """Test that VALID_HISTORY_FIELDS has correct items."""
    var fields = get_valid_history_fields()
    
    assert_equal(len(fields), 16, "VALID_HISTORY_FIELDS should have 16 items")
    assert_true(fields[0] == "datetime", "First field should be 'datetime'")
    assert_equal(fields[1], "open", "Second field should be 'open'")
    assert_true(fields[2] == "close", "Third field should be 'close'")
    assert_equal(fields[3], "high", "Fourth field should be 'high'")
    assert_true(fields[4] == "low", "Fifth field should be 'low'")
    assert_equal(fields[5], "total_turnover", "Sixth field should be 'total_turnover'")
    assert_true(fields[6] == "volume", "Seventh field should be 'volume'")
    
    print("  get_valid_history_fields tests passed!")


def test_valid_tenors() raises:
    """Test that VALID_TENORS has correct items."""
    var tenors = get_valid_tenors()
    
    assert_equal(len(tenors), 21, "VALID_TENORS should have 21 items")
    assert_true(tenors[0] == "0S", "First tenor should be '0S'")
    assert_equal(tenors[1], "1M", "Second tenor should be '1M'")
    assert_true(tenors[6] == "1Y", "Seventh tenor should be '1Y'")
    assert_equal(tenors[15], "10Y", "16th tenor should be '10Y'")
    assert_true(tenors[20] == "50Y", "Last tenor should be '50Y'")
    
    print("  get_valid_tenors tests passed!")


def test_valid_instrument_types() raises:
    """Test that VALID_INSTRUMENT_TYPES has correct items."""
    var types = get_valid_instrument_types()
    
    assert_equal(len(types), 16, "VALID_INSTRUMENT_TYPES should have 16 items")
    
    var has_fund = False
    var has_stock = False
    for i in range(len(types)):
        if types[i] == "Fund":
            has_fund = True
        if types[i] == "Stock":
            has_stock = True
    
    assert_true(has_fund, "VALID_INSTRUMENT_TYPES should contain 'Fund'")
    assert_true(has_stock, "VALID_INSTRUMENT_TYPES should contain 'Stock'")
    
    print("  get_valid_instrument_types tests passed!")


def test_valid_margin_fields() raises:
    """Test that VALID_MARGIN_FIELDS has correct items."""
    var fields = get_valid_margin_fields()
    
    assert_equal(len(fields), 8, "VALID_MARGIN_FIELDS should have 8 items")
    assert_true(fields[0] == "margin_balance", "First field should be 'margin_balance'")
    assert_equal(fields[7], "total_balance", "Last field should be 'total_balance'")
    print("  get_valid_margin_fields tests passed!")


def test_valid_share_fields() raises:
    """Test that VALID_SHARE_FIELDS has correct items."""
    var fields = get_valid_share_fields()
    
    assert_equal(len(fields), 5, "VALID_SHARE_FIELDS should have 5 items")
    assert_true(fields[0] == "total", "First field should be 'total'")
    assert_equal(fields[4], "total_a", "Last field should be 'total_a'")
    print("  get_valid_share_fields tests passed!")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
