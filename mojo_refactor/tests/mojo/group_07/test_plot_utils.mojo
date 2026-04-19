"""
Test for mod/rqmojo_mod_sys_analyser/plot/utils.mojo
Group 07 - File 04 - Comprehensive Tests

Tests all functions in utils.mojo against Python original behavior:
- max_dd, max_ddd: Drawdown calculations
- weekly_returns: Weekly return computation
- trading_dates_index: Binary search index lookup
- IndexRange.new(): Factory method
- Helper functions: format_date, calculate_returns, etc.
"""

from std.math import sqrt, abs as fabs
from std.collections import List, Dict
from rqmojo.mod.rqmojo_mod_sys_analyser.plot.utils import (
    format_date, format_datetime,
    calculate_returns, calculate_max_drawdown, calculate_sharpe_ratio,
    max_dd, max_ddd, weekly_returns, trading_dates_index,
)
from rqmojo.mod.rqmojo_mod_sys_analyser.plot.consts import IndexRange
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


# ============== Pad Zero & Format Helpers ==============

def test_pad_zero_single_digit() raises:
    """_pad_zero should left-pad single digits to width 2."""
    var dt = DateTime(2024, 1, 5, 0, 0, 0, 0)
    var result = format_date(dt)
    assert_equal(result, "2024-01-05", "Single digit month/day should be zero-padded")


def test_pad_zero_double_digit() raises:
    """Double digit values should not be padded."""
    var dt = DateTime(2024, 12, 25, 0, 0, 0, 0)
    var result = format_date(dt)
    assert_equal(result, "2024-12-25", "Double digit month/day should not be padded")


def test_format_datetime_includes_time() raises:
    """Datetime formatter should include time component."""
    var dt = DateTime(2024, 3, 15, 9, 30, 45, 0)
    var result = format_datetime(dt)
    assert_true(len(result) > 10, "Datetime string should be longer than date-only")


# ============== Calculate Returns ==============

def test_calculate_returns_basic() raises:
    """Basic return calculation from NAV list."""
    var nav_list: List[Float64] = [1.0, 1.05, 1.10, 1.08]
    var returns = calculate_returns(nav_list)
    assert_equal(len(returns), 3, "Should have 3 return values")
    assert_true(fabs(returns[0] - 0.05) < 1e-10, "First return ~5%")
    assert_true(fabs(returns[1] - 0.047619) < 1e-6, "Second return ~4.76%")
    assert_true(fabs(returns[2] - (-0.018182)) < 1e-6, "Third return ~-1.82%")


def test_calculate_returns_empty() raises:
    """Empty NAV list should return empty list."""
    var nav_list: List[Float64] = []
    var returns = calculate_returns(nav_list)
    assert_equal(len(returns), 0)


def test_calculate_returns_single_element() raises:
    """Single element NAV list should return empty list."""
    var nav_list: List[Float64] = [1.0]
    var returns = calculate_returns(nav_list)
    assert_equal(len(returns), 0)


def test_calculate_returns_zero_nav() raises:
    """Zero previous NAV should produce 0.0 return (no division by zero)."""
    var nav_list: List[Float64] = [0.0, 1.05, 1.10]
    var returns = calculate_returns(nav_list)
    assert_equal(len(returns), 2)
    assert_equal(returns[0], 0.0, "Return after zero NAV should be 0")


# ============== Calculate Max Drawdown ==============

def test_calculate_max_drawdown_basic() raises:
    """Max drawdown for simple up-down-up pattern."""
    var nav_list: List[Float64] = [1.0, 1.1, 1.0, 0.9, 1.0]
    var dd = calculate_max_drawdown(nav_list)
    assert_true(dd > 0.18, "Drawdown should be >18%")
    assert_true(dd < 0.19, "Drawdown should be <19% (peak=1.1, trough=0.9)")


def test_calculate_max_drawdown_no_drawdown() raises:
    """Monotonically increasing NAV should have 0 drawdown."""
    var nav_list: List[Float64] = [1.0, 1.1, 1.2, 1.3, 1.4]
    var dd = calculate_max_drawdown(nav_list)
    assert_equal(dd, 0.0, "No drawdown for monotonically increasing NAV")


def test_calculate_max_drawdown_empty() raises:
    """Empty list should return 0 drawdown."""
    var nav_list: List[Float64] = []
    var dd = calculate_max_drawdown(nav_list)
    assert_equal(dd, 0.0)


def test_calculate_max_drawdown_monotone_decreasing() raises:
    """Monotonically decreasing NAV should have large drawdown."""
    var nav_list: List[Float64] = [1.0, 0.9, 0.8, 0.7]
    var dd = calculate_max_drawdown(nav_list)
    assert_true(dd > 0.29, "Drawdown should be >29%")


# ============== Calculate Sharpe Ratio ==============

def test_sharpe_ratio_basic() raises:
    """Sharpe ratio for typical return series."""
    var returns: List[Float64] = [0.01, -0.005, 0.02, 0.015, -0.01, 0.008]
    var sharpe = calculate_sharpe_ratio(returns)
    assert_true(sharpe > 0, "Positive average returns → positive Sharpe")


def test_sharpe_ratio_empty() raises:
    """Empty returns should return 0 Sharpe."""
    var returns: List[Float64] = []
    var sharpe = calculate_sharpe_ratio(returns)
    assert_equal(sharpe, 0.0)


def test_sharpe_ratio_constant() raises:
    """Constant returns (zero variance) should return 0."""
    var returns: List[Float64] = [0.01, 0.01, 0.01, 0.01]
    var sharpe = calculate_sharpe_ratio(returns)
    assert_equal(sharpe, 0.0, "Zero variance → 0 Sharpe")


# ============== Max DD (IndexRange version) ==============

def test_max_dd_basic() raises:
    """Max DD should find the maximum drawdown period.

    arr = [100, 110, 105, 95, 90, 100]
    Peak at idx=1 (110), trough at idx=4 (90), ratio=1.222
    Expected: start=1, end=4
    """
    var arr: List[Float64] = [100.0, 110.0, 105.0, 95.0, 90.0, 100.0]
    var index: List[String] = ["2020-01-01", "2020-01-02", "2020-01-03", "2020-01-04", "2020-01-05", "2020-01-06"]
    var result = max_dd(arr, index)
    assert_equal(result.start, 1, "Start should be at peak index 1")
    assert_equal(result.end, 4, "End should be at trough index 4")
    assert_equal(result.start_date, "2020-01-02", "Start date from index")
    assert_equal(result.end_date, "2020-01-05", "End date from index")


def test_max_dd_monotonic_increasing() raises:
    """Monotonically increasing: end should be n-1 per Python behavior.

    When all ratios are 1.0, numpy argmax returns 0,
    then Python sets end = len(arr)-1.
    """
    var arr: List[Float64] = [100.0, 110.0, 120.0, 130.0, 140.0]
    var index: List[String] = ["d0", "d1", "d2", "d3", "d4"]
    var result = max_dd(arr, index)
    assert_equal(result.end, 4, "End should be last index when no real drawdown")


def test_max_dd_strict_greater_first_occurrence() raises:
    """Verify strict > gives FIRST occurrence on ties (matching numpy argmax).

    arr = [100, 100, 100, 100]
    All ratios are 1.0. With strict >, end_idx stays at initial value 0.
    Then end becomes n-1=3. Start is argmax of arr[:3]=[100,100,100] = 0.
    """
    var arr: List[Float64] = [100.0, 100.0, 100.0, 100.0]
    var index: List[String] = ["a", "b", "c", "d"]
    var result = max_dd(arr, index)
    assert_equal(result.start, 0, "First occurrence tie → start=0")
    assert_equal(result.end, 3, "end=0 corrected to n-1=3")


def test_max_dd_empty() raises:
    """Empty array should return zeroed IndexRange."""
    var arr: List[Float64] = []
    var index: List[String] = []
    var result = max_dd(arr, index)
    assert_equal(result.start, 0)
    assert_equal(result.end, 0)
    assert_equal(result.start_date, "")
    assert_equal(result.end_date, "")


def test_max_dd_single_element() raises:
    """Single element array should work without error."""
    var arr: List[Float64] = [100.0]
    var index: List[String] = ["2020-01-01"]
    var result = max_dd(arr, index)
    assert_equal(result.end, 0, "Single element → end stays 0 or becomes 0")


def test_max_dd_decline_then_recover() raises:
    """Declining then recovering pattern.

    arr = [100, 90, 80, 70, 80, 90]
    Peak=100 at 0, worst trough=70 at 3, ratio=100/70=1.428
    """
    var arr: List[Float64] = [100.0, 90.0, 80.0, 70.0, 80.0, 90.0]
    var index: List[String] = ["d0", "d1", "d2", "d3", "d4", "d5"]
    var result = max_dd(arr, index)
    assert_equal(result.start, 0, "Peak at start")
    assert_equal(result.end, 3, "Trough at index 3")


# ============== Max DDD ==============

def test_max_ddd_basic() raises:
    """Basic max drawdown duration.

    arr = [100, 90, 80, 70, 80, 90, 110]
    Peak=100 at 0, below peak from idx 1-5.
    At idx 6: 110 > 100 → new peak! End drawdown: duration = 6-0 = 6.
    ddd_start=0, ddd_end=5.
    """
    var arr: List[Float64] = [100.0, 90.0, 80.0, 70.0, 80.0, 90.0, 110.0]
    var index: List[String] = ["d0", "d1", "d2", "d3", "d4", "d5", "d6"]
    var result = max_ddd(arr, index)
    assert_true(result.start < result.end, "Start should be before end")
    assert_true((result.end - result.start) > 0, "Duration should be positive")
    assert_equal(result.start, 0, "DDD starts at first peak index")
    assert_equal(result.end, 5, "DDD ends just before new peak")


def test_max_ddd_no_drawdown() raises:
    """Monotonically increasing: no drawdown duration."""
    var arr: List[Float64] = [100.0, 110.0, 120.0, 130.0]
    var index: List[String] = ["d0", "d1", "d2", "d3"]
    var result = max_ddd(arr, index)
    assert_equal(result.start, 0)
    assert_equal(result.end, 0)


def test_max_ddd_empty() raises:
    """Empty array → zeroed IndexRange."""
    var arr: List[Float64] = []
    var index: List[String] = []
    var result = max_ddd(arr, index)
    assert_equal(result.start, 0)
    assert_equal(result.end, 0)


def test_max_ddd_multiple_drawdowns() raises:
    """Multiple drawdown periods: should find the longest.

    arr = [100, 90, 95, 90, 85, 95, 100]
    Peak=100 at 0, below peak from idx 1 onwards until new peak above 100.
    At idx 6: 100 == 100, not > and not <, so nothing changes.
    After loop: last_i=6, arr[6]=100 not < max_seen=100 → fall through to ddd defaults.
    """
    var arr: List[Float64] = [100.0, 90.0, 95.0, 90.0, 85.0, 95.0, 100.0]
    var index: List[String] = ["d0", "d1", "d2", "d3", "d4", "d5", "d6"]
    var result = max_ddd(arr, index)
    assert_true(result.start <= result.end, "Valid range")


# ============== Weekly Returns ==============

def test_weekly_returns_basic() raises:
    """Weekly returns across week boundaries.

    Using dates from late Jan and early Feb to ensure multiple week keys.
    Week key = first 7 chars of date string (YYYY-MM).
    """
    var nav_list: List[Float64] = [1.0, 1.02, 1.03, 1.05, 1.04, 1.06, 1.08, 1.10, 1.12, 1.11, 1.13, 1.15, 1.14, 1.16]
    var dates: List[String] = [
        "2020-01-27", "2020-01-28", "2020-01-29", "2020-01-30", "2020-01-31",
        "2020-02-03", "2020-02-04", "2020-02-05", "2020-02-06", "2020-02-07",
        "2020-02-10", "2020-02-11", "2020-02-12", "2020-02-13"
    ]
    var result = weekly_returns(nav_list, dates)
    assert_true(len(result) >= 1, "Should have at least one weekly return")


def test_weekly_returns_empty() raises:
    """Empty inputs should return empty list."""
    var nav_list: List[Float64] = []
    var dates: List[String] = []
    var result = weekly_returns(nav_list, dates)
    assert_equal(len(result), 0)


def test_weekly_returns_same_week() raises:
    """All dates in same week should return empty (no complete week pair)."""
    var nav_list: List[Float64] = [1.0, 1.02, 1.03]
    var dates: List[String] = ["2020-01-01", "2020-01-02", "2020-01-03"]
    var result = weekly_returns(nav_list, dates)
    assert_equal(len(result), 0, "Single week → no returns")


# ============== Trading Dates Index ==============

def test_trading_dates_index_basic() raises:
    """Binary search right for trade dates in sorted index."""
    var trade_dates: List[String] = ["2020-01-05", "2020-01-15"]
    var index: List[String] = [
        "2020-01-01", "2020-01-02", "2020-01-03", "2020-01-06",
        "2020-01-07", "2020-01-10", "2020-01-14", "2020-01-16"
    ]
    var result = trading_dates_index(trade_dates, "OPEN", index)
    assert_equal(len(result), 2, "Should find indices for both dates")
    assert_true(result[0] >= 0, "First index should be valid")
    assert_true(result[1] >= 0, "Second index should be valid")


def test_trading_dates_index_empty_index() raises:
    """Empty index should return empty result."""
    var trade_dates: List[String] = ["2020-01-05"]
    var index: List[String] = []
    var result = trading_dates_index(trade_dates, "OPEN", index)
    assert_equal(len(result), 0)


def test_trading_dates_index_empty_trades() raises:
    """Empty trade dates should return empty result."""
    var trade_dates: List[String] = []
    var index: List[String] = ["2020-01-01", "2020-01-02"]
    var result = trading_dates_index(trade_dates, "OPEN", index)
    assert_equal(len(result), 0)


def test_trading_dates_index_exact_match() raises:
    """Date exactly in index: searchsorted right gives next position."""
    var trade_dates: List[String] = ["2020-01-03"]
    var index: List[String] = ["2020-01-01", "2020-01-03", "2020-01-05"]
    var result = trading_dates_index(trade_dates, "OPEN", index)
    assert_equal(len(result), 1)
    # searchsorted_right("2020-01-03") in ["01","03","05"] → 2 (insert after "03")
    # result = 2 - 1 = 1
    assert_equal(result[0], 1, "searchsorted right of exact match → 1")


def test_trading_dates_index_before_all() raises:
    """Date before all index entries: searchsorted right → 0, result skipped (< 0 check)."""
    var trade_dates: List[String] = ["2019-12-01"]
    var index: List[String] = ["2020-01-01", "2020-01-02"]
    var result = trading_dates_index(trade_dates, "OPEN", index)
    assert_equal(len(result), 0, "Before all → skipped")


def test_trading_dates_index_after_all() raises:
    """Date after all index entries: searchsorted right → len(index)."""
    var trade_dates: List[String] = ["2020-02-01"]
    var index: List[String] = ["2020-01-01", "2020-01-02"]
    var result = trading_dates_index(trade_dates, "OPEN", index)
    assert_equal(len(result), 1)
    assert_equal(result[0], 1, "searchsorted right → 2, minus 1 = 1")


# ============== IndexRange.new() Factory Method ==============

def test_index_range_new_basic() raises:
    """IndexRange.new() should extract dates from index."""
    var index: List[String] = ["2020-01-01", "2020-01-05", "2020-01-10"]
    var ir = IndexRange.new(1, 2, index)
    assert_equal(ir.start, 1)
    assert_equal(ir.end, 2)
    assert_equal(ir.start_date, "2020-01-05")
    assert_equal(ir.end_date, "2020-01-10")


def test_index_range_new_out_of_bounds() raises:
    """Out-of-bounds indices should give empty strings."""
    var index: List[String] = ["2020-01-01"]
    var ir = IndexRange.new(0, 5, index)
    assert_equal(ir.start_date, "2020-01-01", "Valid start index")
    assert_equal(ir.end_date, "", "Out-of-bounds end → empty string")


def test_index_range_new_negative_indices() raises:
    """Negative indices should give empty strings."""
    var index: List[String] = ["2020-01-01", "2020-01-02"]
    var ir = IndexRange.new(-1, 1, index)
    assert_equal(ir.start_date, "", "Negative start → empty string")
    assert_equal(ir.end_date, "2020-01-02", "Valid end index")


def test_index_range_new_empty_index() raises:
    """Empty index should give empty date strings."""
    var index: List[String] = []
    var ir = IndexRange.new(0, 0, index)
    assert_equal(ir.start_date, "")
    assert_equal(ir.end_date, "")


# ============== IndexRange _days property ==============

def test_index_range_days() raises:
    """_days should return end - start."""
    var ir = IndexRange(start=2, end=7, start_date="a", end_date="b")
    assert_equal(ir._days(), 5, "7 - 2 = 5 days")


def test_index_range_days_zero() raises:
    """Same start/end → 0 days."""
    var ir = IndexRange(start=3, end=3, start_date="a", end_date="b")
    assert_equal(ir._days(), 0)


# ============== Main Test Runner ==============

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
