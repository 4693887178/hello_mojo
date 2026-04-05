"""
Test for names.mojo - API Names
"""

from std.testing import assert_equal, assert_true, TestSuite
from std.collections import List
from rqmojo.apis.names import (
    get_valid_history_fields, get_valid_tenors, get_valid_margin_fields,
    get_valid_share_fields, get_valid_instrument_types, get_valid_turnover_fields,
    get_valid_stock_connect_fields, get_valid_current_performance_fields
)


def list_contains(list: List[String], item: String) -> Bool:
    for i in range(len(list)):
        if list[i] == item:
            return True
    return False


def test_valid_history_fields() raises:
    var fields = get_valid_history_fields()
    assert_equal(len(fields), 16, "VALID_HISTORY_FIELDS count should be 16")
    assert_true(list_contains(fields, "datetime"), "VALID_HISTORY_FIELDS should contain 'datetime'")
    assert_true(list_contains(fields, "close"), "VALID_HISTORY_FIELDS should contain 'close'")


def test_valid_tenors() raises:
    var tenors = get_valid_tenors()
    assert_equal(len(tenors), 21, "VALID_TENORS count should be 21")
    assert_true(list_contains(tenors, "0S"), "VALID_TENORS should contain '0S'")
    assert_true(list_contains(tenors, "1Y"), "VALID_TENORS should contain '1Y'")


def test_valid_margin_fields() raises:
    var fields = get_valid_margin_fields()
    assert_equal(len(fields), 8, "VALID_MARGIN_FIELDS count should be 8")
    assert_true(list_contains(fields, "margin_balance"), "VALID_MARGIN_FIELDS should contain 'margin_balance'")


def test_valid_share_fields() raises:
    var fields = get_valid_share_fields()
    assert_equal(len(fields), 5, "VALID_SHARE_FIELDS count should be 5")
    assert_true(list_contains(fields, "total"), "VALID_SHARE_FIELDS should contain 'total'")


def test_valid_instrument_types() raises:
    var types = get_valid_instrument_types()
    assert_equal(len(types), 16, "VALID_INSTRUMENT_TYPES count should be 16")
    assert_true(list_contains(types, "CS"), "VALID_INSTRUMENT_TYPES should contain 'CS'")
    assert_true(list_contains(types, "Future"), "VALID_INSTRUMENT_TYPES should contain 'Future'")


def test_valid_turnover_fields() raises:
    var fields = get_valid_turnover_fields()
    assert_equal(len(fields), 8, "VALID_TURNOVER_FIELDS count should be 8")
    assert_true(list_contains(fields, "today"), "VALID_TURNOVER_FIELDS should contain 'today'")


def test_valid_stock_connect_fields() raises:
    var fields = get_valid_stock_connect_fields()
    assert_equal(len(fields), 2, "VALID_STOCK_CONNECT_FIELDS count should be 2")
    assert_true(list_contains(fields, "shares_holding"), "VALID_STOCK_CONNECT_FIELDS should contain 'shares_holding'")


def test_valid_current_performance_fields() raises:
    var fields = get_valid_current_performance_fields()
    assert_equal(len(fields), 39, "VALID_CURRENT_PERFORMANCE_FIELDS count should be 39")
    assert_true(list_contains(fields, "operating_revenue"), "VALID_CURRENT_PERFORMANCE_FIELDS should contain 'operating_revenue'")
    assert_true(list_contains(fields, "net_asset_psto_opening"), "VALID_CURRENT_PERFORMANCE_FIELDS should contain 'net_asset_psto_opening'")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
