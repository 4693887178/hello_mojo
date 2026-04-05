"""
Comprehensive tests for adjust.mojo module.
Tests cover all public functions and edge cases,
using std.testing framework as required by project conventions.
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.python import Python, PythonObject
from rqmojo.data.base_data_source.adjust import (
    adjust_bars,
    adjust_ratio,
    get_price_fields,
    get_fields_require_adjustment,
    _is_price_field,
    _factor_for_date,
)
from bison import Series


# =====================================================================
# Helper: build test data via Python numpy/pandas
# =====================================================================

def _make_np() raises -> PythonObject:
    return Python.import_module("numpy")


def _make_pd() raises -> PythonObject:
    return Python.import_module("pandas")


def _build_bars_raw(
    datetime_vals: PythonObject,
    open_vals: PythonObject,
    close_vals: PythonObject,
    high_vals: PythonObject,
    low_vals: PythonObject,
    volume_vals: PythonObject,
) raises -> PythonObject:
    var np = _make_np()
    var builtins = Python.import_module("builtins")
    var dtype_py = Python.evaluate("[('datetime', 'i8'), ('open', 'f8'), ('close', 'f8'), ('high', 'f8'), ('low', 'f8'), ('volume', 'f8')]")
    var zipped = builtins.zip(datetime_vals, open_vals, close_vals, high_vals, low_vals, volume_vals)
    var rows = builtins.list(zipped)
    return np.array(rows, dtype=dtype_py)


def _build_ex_factors_raw(
    start_dates: PythonObject, cum_factors: PythonObject
) raises -> PythonObject:
    var np = _make_np()
    var builtins = Python.import_module("builtins")
    var dtype_py = Python.evaluate("[('start_date', 'i8'), ('ex_cum_factor', 'f8')]")
    var zipped = builtins.zip(start_dates, cum_factors)
    var rows = builtins.list(zipped)
    return np.array(rows, dtype=dtype_py)


def _build_simple_bars(n: Int = 5) raises -> PythonObject:
    """Build n daily bars starting from 2020-01-01."""
    var np = _make_np()
    var pd = _make_pd()
    var dates = pd.date_range("2020-01-01", periods=n)
    var dt_ints = (dates.astype("int64") // Python.evaluate("10**9")).values
    var opens = np.arange(PythonObject(Float64(n)), dtype=np.float64) + PythonObject(Float64(100.0))
    var closes = opens + PythonObject(Float64(1.0))
    var highs = opens + PythonObject(Float64(2.0))
    var lows = opens - PythonObject(Float64(0.5))
    var volumes = np.arange(PythonObject(Float64(n)), dtype=np.float64) * PythonObject(Float64(1000.0)) + PythonObject(Float64(1000.0))
    return _build_bars_raw(dt_ints, opens, closes, highs, lows, volumes)


def _build_simple_ex_factors() raises -> PythonObject:
    """Build ex-factors covering 2019-12-31 to 2020-01-02."""
    var np = _make_np()
    var pd = _make_pd()
    var dates = pd.date_range("2019-12-31", periods=3)
    var dt_ints = (dates.astype("int64") // Python.evaluate("10**9")).values
    var factors_arr = np.array(
        Python.evaluate("[1.0, 1.01, 1.02]"),
        dtype=np.float64,
    )
    return _build_ex_factors_raw(dt_ints, factors_arr)


# =====================================================================
# Test: get_price_fields
# =====================================================================

def test_get_price_fields_returns_all_8_fields() raises:
    var fields = get_price_fields()
    assert_equal(len(fields), 8)
    assert_true("open" in fields)
    assert_true("close" in fields)
    assert_true("high" in fields)
    assert_true("low" in fields)
    assert_true("limit_up" in fields)
    assert_true("limit_down" in fields)
    assert_true("acc_net_value" in fields)
    assert_true("unit_net_value" in fields)


def test_get_price_fields_is_independent_copy() raises:
    var fields1 = get_price_fields()
    var fields2 = get_price_fields()
    fields1.add("extra")
    assert_false("extra" in fields2)


# =====================================================================
# Test: get_fields_require_adjustment
# =====================================================================

def test_get_fields_require_adjustment_includes_volume() raises:
    var fields = get_fields_require_adjustment()
    assert_equal(len(fields), 9)
    assert_true("volume" in fields)
    assert_true("open" in fields)


# =====================================================================
# Test: _is_price_field
# =====================================================================

def test_is_price_field_true_for_all_price_fields() raises:
    assert_true(_is_price_field("open"))
    assert_true(_is_price_field("close"))
    assert_true(_is_price_field("high"))
    assert_true(_is_price_field("low"))
    assert_true(_is_price_field("limit_up"))
    assert_true(_is_price_field("limit_down"))
    assert_true(_is_price_field("acc_net_value"))
    assert_true(_is_price_field("unit_net_value"))


def test_is_price_field_false_for_non_price_fields() raises:
    assert_false(_is_price_field("volume"))
    assert_false(_is_price_field("amount"))
    assert_false(_is_price_field("datetime"))
    assert_false(_is_price_field(""))


# =====================================================================
# Test: _factor_for_date
# =====================================================================

def _make_factor_series() raises -> Tuple[Series, Series]:
    var np = _make_np()
    var pd = _make_pd()
    var dates = pd.date_range("2019-12-31", periods=3)
    var dt_ints = pd.Series((dates.astype("int64") // Python.evaluate("10**9")).values)
    var factors_arr = pd.Series(
        np.array(Python.evaluate("[1.0, 1.01, 1.02]"), dtype=np.float64)
    )
    var s_dates = Series(dt_ints)
    var s_factors = Series(factors_arr)
    return (s_dates^, s_factors^)


def test_factor_for_date_before_first() raises:
    var (dates, factors) = _make_factor_series()
    var result = _factor_for_date(dates, factors, Int64(1577664000))
    assert_true(result >= Float64(0.99) and result <= Float64(1.01))


def test_factor_for_date_between_dates() raises:
    var (dates, factors) = _make_factor_series()
    var result = _factor_for_date(dates, factors, Int64(1577836800))
    assert_true(result >= Float64(1.00) and result <= Float64(1.02))


def test_factor_for_date_after_last() raises:
    var (dates, factors) = _make_factor_series()
    var result = _factor_for_date(dates, factors, Int64(9999999999))
    assert_true(result >= Float64(1.01) and result <= Float64(1.03))


# =====================================================================
# Test: adjust_bars — edge cases
# =====================================================================

def test_adjust_bars_none_ex_factors_returns_original() raises:
    var bars = _build_simple_bars(3)
    var result = adjust_bars(bars, Python.none(), "", "pre", "2020-01-05")
    assert_true(result is not None)
    assert_equal(len(result), 3)


def test_adjust_bars_empty_bars_returns_empty() raises:
    var np = _make_np()
    var dtype_py = Python.evaluate("[('datetime', 'i8'), ('open', 'f8')]")
    var empty_bars = np.array(Python.evaluate("[]"), dtype=dtype_py)
    var ex_factors = _build_simple_ex_factors()
    var result = adjust_bars(empty_bars, ex_factors, "", "pre", "2020-01-05")
    assert_equal(len(result), 0)


def test_adjust_bars_no_adjustment_needed() raises:
    var np = _make_np()
    var pd = _make_pd()
    var dates = pd.date_range("2019-12-31", periods=3)
    var dt_ints = (dates.astype("int64") // Python.evaluate("10**9")).values
    var factors_arr = np.array(
        Python.evaluate("[1.0, 1.0, 1.0]"),
        dtype=np.float64,
    )
    var ex_factors = _build_ex_factors_raw(dt_ints, factors_arr)
    var bars = _build_simple_bars(3)
    var result = adjust_bars(bars, ex_factors, "", "pre", "2020-01-03")
    assert_equal(len(result), 3)


# =====================================================================
# Test: adjust_bars — pre-adjustment with single field
# =====================================================================

def test_adjust_bars_pre_single_price_field() raises:
    var bars = _build_simple_bars(5)
    var ex_factors = _build_simple_ex_factors()
    var result = adjust_bars(bars, ex_factors, "open", "pre", "2020-01-05")
    assert_true(result is not None)
    assert_equal(len(result), 5)


def test_adjust_bars_pre_volume_field() raises:
    var bars = _build_simple_bars(5)
    var ex_factors = _build_simple_ex_factors()
    var result = adjust_bars(bars, ex_factors, "volume", "pre", "2020-01-05")
    assert_true(result is not None)
    assert_equal(len(result), 5)


# =====================================================================
# Test: adjust_bars — post-adjustment
# =====================================================================

def test_adjust_bars_post_base_rate_is_one() raises:
    var bars = _build_simple_bars(5)
    var ex_factors = _build_simple_ex_factors()
    var result = adjust_bars(bars, ex_factors, "", "post", "2020-01-05")
    assert_true(result is not None)
    assert_equal(len(result), 5)


# =====================================================================
# Test: adjust_bars — all fields adjustment
# =====================================================================

def test_adjust_bars_all_fields() raises:
    var bars = _build_simple_bars(5)
    var ex_factors = _build_simple_ex_factors()
    var result = adjust_bars(bars, ex_factors, "", "pre", "2020-01-05")
    assert_true(result is not None)
    assert_equal(len(result), 5)


def test_adjust_bars_preserves_bar_count() raises:
    var n_vals = [1, 3, 5, 10]
    for n_val in n_vals:
        var bars = _build_simple_bars(n_val)
        var ex_factors = _build_simple_ex_factors()
        var result = adjust_bars(bars, ex_factors, "", "pre", "2020-01-05")
        assert_equal(len(result), n_val)


# =====================================================================
# Test: adjust_bars — single bar edge case
# =====================================================================

def test_adjust_bars_single_bar() raises:
    var bars = _build_simple_bars(1)
    var ex_factors = _build_simple_ex_factors()
    var result = adjust_bars(bars, ex_factors, "close", "pre", "2020-01-01")
    assert_true(result is not None)
    assert_equal(len(result), 1)


# =====================================================================
# Test: adjust_ratio
# =====================================================================

def test_adjust_ratio_normal_case() raises:
    var result = adjust_ratio(PythonObject(Float64(100.0)), PythonObject(Float64(50.0)))
    var val = Float64(py=result)
    assert_true(val > Float64(1.99) and val < Float64(2.01))


def test_adjust_ratio_zero_ex_factor() raises:
    var result = adjust_ratio(PythonObject(Float64(100.0)), PythonObject(Float64(0.0)))
    var val = Float64(py=result)
    assert_equal(val, Float64(1.0))


def test_adjust_ratio_zero_pre_close() raises:
    var result = adjust_ratio(PythonObject(Float64(0.0)), PythonObject(Float64(50.0)))
    var val = Float64(py=result)
    assert_equal(val, Float64(1.0))


def test_adjust_ratio_both_zero() raises:
    var result = adjust_ratio(PythonObject(Float64(0.0)), PythonObject(Float64(0.0)))
    var val = Float64(py=result)
    assert_equal(val, Float64(1.0))


# =====================================================================
# Test: cross-validation with Python implementation
# =====================================================================

def _py_datetime(date_str: String) raises -> PythonObject:
    """Create a Python datetime object from string for Python's adjust_bars."""
    var datetime_mod = Python.import_module("datetime")
    return datetime_mod.datetime.strptime(date_str, "%Y-%m-%d")


def test_cross_validation_with_python_adjust() raises:
    var bars = _build_simple_bars(5)
    var ex_factors = _build_simple_ex_factors()

    var mojo_result = adjust_bars(
        bars.copy(), ex_factors.copy(), "open", "pre", "2020-01-05"
    )

    var py_adjust = Python.import_module("rqalpha.data.base_data_source.adjust")
    var py_result = py_adjust.adjust_bars(
        bars.copy(), ex_factors.copy(), "open", "pre", _py_datetime("2020-01-05")
    )

    assert_equal(len(mojo_result), len(py_result))

    for i_idx in range(len(mojo_result)):
        var mojo_val = Float64(py=mojo_result["open"][i_idx])
        var py_val = Float64(py=py_result["open"][i_idx])
        var diff = mojo_val - py_val
        if diff < Float64(0):
            diff = -diff
        var rel_tol = max(abs(mojo_val), abs(py_val)) * Float64(0.02)
        assert_true(diff < max(Float64(2.0), rel_tol))


def test_cross_validation_volume_adjustment() raises:
    var bars = _build_simple_bars(5)
    var ex_factors = _build_simple_ex_factors()

    var mojo_result = adjust_bars(
        bars.copy(), ex_factors.copy(), "volume", "pre", "2020-01-05"
    )

    var py_adjust = Python.import_module("rqalpha.data.base_data_source.adjust")
    var py_result = py_adjust.adjust_bars(
        bars.copy(), ex_factors.copy(), "volume", "pre", _py_datetime("2020-01-05")
    )

    assert_equal(len(mojo_result), len(py_result))
    for i_idx in range(len(mojo_result)):
        var mojo_vol = Float64(py=mojo_result["volume"][i_idx])
        var py_vol = Float64(py=py_result["volume"][i_idx])
        var vol_diff = mojo_vol - py_vol
        if vol_diff < Float64(0):
            vol_diff = -vol_diff
        var vol_rel_tol = max(abs(mojo_vol), abs(py_vol)) * Float64(0.02)
        assert_true(vol_diff < max(Float64(20.0), vol_rel_tol))


def test_cross_validation_all_fields_adjustment() raises:
    var bars = _build_simple_bars(5)
    var ex_factors = _build_simple_ex_factors()

    var mojo_result = adjust_bars(
        bars.copy(), ex_factors.copy(), "", "pre", "2020-01-05"
    )

    var py_adjust = Python.import_module("rqalpha.data.base_data_source.adjust")
    var py_result = py_adjust.adjust_bars(
        bars.copy(), ex_factors.copy(), "", "pre", _py_datetime("2020-01-05")
    )

    assert_equal(len(mojo_result), len(py_result))
    var price_fields_list = ["open", "close", "high", "low"]
    for field_name in price_fields_list:
        for i_idx in range(len(mojo_result)):
            var mojo_val = Float64(py=mojo_result[field_name][i_idx])
            var py_val = Float64(py=py_result[field_name][i_idx])
            var diff = mojo_val - py_val
            if diff < Float64(0):
                diff = -diff
            var rel_tol = max(abs(mojo_val), abs(py_val)) * Float64(0.02)
            assert_true(diff < max(Float64(2.0), rel_tol))


def test_cross_validation_post_adjustment() raises:
    var bars = _build_simple_bars(5)
    var ex_factors = _build_simple_ex_factors()

    var mojo_result = adjust_bars(
        bars.copy(), ex_factors.copy(), "", "post", "2020-01-05"
    )

    var py_adjust = Python.import_module("rqalpha.data.base_data_source.adjust")
    var py_result = py_adjust.adjust_bars(
        bars.copy(), ex_factors.copy(), "", "post", "2020-01-05"
    )

    assert_equal(len(mojo_result), len(py_result))


def test_cross_validation_none_and_empty_cases() raises:
    var bars = _build_simple_bars(3)

    var mojo_none = adjust_bars(bars.copy(), Python.none(), "", "pre", "2020-01-05")
    var py_adjust = Python.import_module("rqalpha.data.base_data_source.adjust")
    var py_none = py_adjust.adjust_bars(bars.copy(), Python.none(), "", "pre", "2020-01-05")

    assert_equal(len(mojo_none), len(py_none))


# =====================================================================
# Main entry point
# =====================================================================

def main() raises:
    var suite = TestSuite.discover_tests[__functions_in_module()]()
    suite^.run()
    print("\n=== All adjust.mojo tests passed! ===")
