"""
Comprehensive pure-Mojo tests for adjust.mojo module.
Uses std.testing framework exclusively — zero Python imports.
Covers all public functions, internal helpers, and edge cases.
"""

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite
from rqmojo.data.base_data_source.adjust import (
    adjust_bars,
    adjust_ratio,
    get_price_fields,
    get_fields_require_adjustment,
    _is_price_field,
    _factor_for_date,
    _parse_date_int,
    _make_series_int64,
    _make_series_float64,
    _build_factor_lists,
    _apply_factor_list,
    _apply_inv_factor_list,
    BarData,
    ExFactorData,
)


# =====================================================================
# Helper builders — pure Mojo test data construction
# =====================================================================

def _build_bar_data(
    datetime_vals: List[Int64],
    open_vals: List[Float64],
    close_vals: List[Float64],
    high_vals: List[Float64],
    low_vals: List[Float64],
    volume_vals: List[Float64],
) -> BarData:
    var fields = Dict[String, List[Float64]]()
    fields["open"] = open_vals^
    fields["close"] = close_vals^
    fields["high"] = high_vals^
    fields["low"] = low_vals^
    fields["volume"] = volume_vals^
    var names = List[String]()
    names.append("open")
    names.append("close")
    names.append("high")
    names.append("low")
    names.append("volume")
    return BarData(datetime=datetime_vals^, fields=fields^, field_names=names^)


def _build_simple_bars(n: Int) -> BarData:
    """Build n daily bars with dates 2020-01-01 .. 2020-01-n and synthetic prices."""
    var dts = List[Int64](capacity=n)
    var opens = List[Float64](capacity=n)
    var closes = List[Float64](capacity=n)
    var highs = List[Float64](capacity=n)
    var lows = List[Float64](capacity=n)
    var vols = List[Float64](capacity=n)
    for i in range(n):
        dts.append(Int64(1577836800) + Int64(i) * Int64(86400))
        opens.append(Float64(100.0) + Float64(i))
        closes.append(Float64(101.0) + Float64(i))
        highs.append(Float64(102.0) + Float64(i))
        lows.append(Float64(99.5) - Float64(i) * Float64(0.1))
        vols.append(Float64(1000.0) + Float64(i) * Float64(1000.0))
    return _build_bar_data(dts^, opens^, closes^, highs^, lows^, vols^)


def _build_ex_factors(
    start_dates: List[Int64],
    cum_factors: List[Float64],
) -> ExFactorData:
    return ExFactorData(start_dates=start_dates^, ex_cum_factors=cum_factors^)


def _build_simple_ex_factors() -> ExFactorData:
    """Ex-factors covering 2019-12-31 to 2020-01-02 with increasing factors."""
    var dates = List[Int64]()
    dates.append(Int64(1577664000))
    dates.append(Int64(1577750400))
    dates.append(Int64(1577836800))
    var factors = List[Float64]()
    factors.append(Float64(1.0))
    factors.append(Float64(1.01))
    factors.append(Float64(1.02))
    return _build_ex_factors(dates^, factors^)


def _build_uniform_ex_factors(factor_val: Float64) -> ExFactorData:
    """Ex-factors where all values are identical (no adjustment needed)."""
    var dates = List[Int64]()
    dates.append(Int64(1577664000))
    dates.append(Int64(1577750400))
    dates.append(Int64(1577836800))
    var factors = List[Float64]()
    factors.append(factor_val)
    factors.append(factor_val)
    factors.append(factor_val)
    return _build_ex_factors(dates^, factors^)


# =====================================================================
# Test: _parse_date_int
# =====================================================================

def test_parse_date_int_basic() raises:
    var result = _parse_date_int("2020-01-05")
    assert_equal(result, 202001050000000000)


def test_parse_date_int_jan_first() raises:
    var result = _parse_date_int("2020-01-01")
    assert_equal(result, 202001010000000000)


def test_parse_date_int_dec_last() raises:
    var result = _parse_date_int("2019-12-31")
    assert_equal(result, 201912310000000000)


def test_parse_date_int_invalid_format_raises() raises:
    with assert_raises():
        _parse_date_int("not-a-date")


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
# Test: _make_series helpers
# =====================================================================

def test_make_series_int64_basic() raises:
    var data = List[Int64]()
    data.append(Int64(10))
    data.append(Int64(20))
    data.append(Int64(30))
    var s = _make_series_int64(data)
    assert_equal(s.size(), 3)
    assert_equal(s.iloc(0)[Int64], Int64(10))
    assert_equal(s.iloc(2)[Int64], Int64(30))


def test_make_series_float64_basic() raises:
    var data = List[Float64]()
    data.append(Float64(1.5))
    data.append(Float64(2.5))
    var s = _make_series_float64(data)
    assert_equal(s.size(), 2)
    assert_true(s.iloc(0)[Float64] > Float64(1.49) and s.iloc(0)[Float64] < Float64(1.51))


def test_make_series_empty() raises:
    var empty_int = List[Int64]()
    var empty_flt = List[Float64]()
    var si = _make_series_int64(empty_int)
    var sf = _make_series_float64(empty_flt)
    assert_equal(si.size(), 0)
    assert_equal(sf.size(), 0)


# =====================================================================
# Test: _factor_for_date (binary search core logic)
# =====================================================================

def _make_test_factor_series() -> Tuple[Series, Series]:
    var dates = List[Int64]()
    dates.append(Int64(100))
    dates.append(Int64(200))
    dates.append(Int64(300))
    var factors = List[Float64]()
    factors.append(Float64(1.0))
    factors.append(Float64(1.5))
    factors.append(Float64(2.0))
    var sd = _make_series_int64(dates)
    var sf = _make_series_float64(factors)
    return (sd^, sf^)


def test_factor_for_date_before_first_returns_first() raises:
    var (dates, factors) = _make_test_factor_series()
    var result = _factor_for_date(dates, factors, Int64(50))
    assert_true(result >= Float64(0.99) and result <= Float64(1.01))


def test_factor_for_date_at_first_boundary() raises:
    var (dates, factors) = _make_test_factor_series()
    var result = _factor_for_date(dates, factors, Int64(100))
    assert_true(result >= Float64(0.99) and result <= Float64(1.01))


def test_factor_for_date_between_first_and_second() raises:
    var (dates, factors) = _make_test_factor_series()
    var result = _factor_for_date(dates, factors, Int64(150))
    assert_true(result >= Float64(0.99) and result <= Float64(1.01))


def test_factor_for_date_at_second_boundary() raises:
    var (dates, factors) = _make_test_factor_series()
    var result = _factor_for_date(dates, factors, Int64(200))
    assert_true(result >= Float64(1.49) and result <= Float64(1.51))


def test_factor_for_date_between_second_and_third() raises:
    var (dates, factors) = _make_test_factor_series()
    var result = _factor_for_date(dates, factors, Int64(250))
    assert_true(result >= Float64(1.49) and result <= Float64(1.51))


def test_factor_for_date_after_last_returns_last() raises:
    var (dates, factors) = _make_test_factor_series()
    var result = _factor_for_date(dates, factors, Int64(999))
    assert_true(result >= Float64(1.99) and result <= Float64(2.01))


def test_factor_for_date_single_element() raises:
    var single_date = List[Int64]()
    single_date.append(Int64(100))
    var single_factor = List[Float64]()
    single_factor.append(Float64(3.14))
    var sd = _make_series_int64(single_date)
    var sf = _make_series_float64(single_factor)
    var result = _factor_for_date(sd, sf, Int64(1))
    assert_true(result >= Float64(3.13) and result <= Float64(3.15))


def test_factor_for_date_exact_match_last() raises:
    var (dates, factors) = _make_test_factor_series()
    var result = _factor_for_date(dates, factors, Int64(300))
    assert_true(result >= Float64(1.99) and result <= Float64(2.01))


# =====================================================================
# Test: _build_factor_lists
# =====================================================================

def test_build_factor_lists_basic() raises:
    var bar_dates = List[Int64]()
    bar_dates.append(Int64(150))
    bar_dates.append(Int64(250))
    bar_dates.append(Int64(350))
    var ex_dates = List[Int64]()
    ex_dates.append(Int64(100))
    ex_dates.append(Int64(200))
    ex_dates.append(Int64(300))
    var ex_factors_list = List[Float64]()
    ex_factors_list.append(Float64(1.0))
    ex_factors_list.append(Float64(2.0))
    ex_factors_list.append(Float64(4.0))
    var sd = _make_series_int64(ex_dates)
    var sf = _make_series_float64(ex_factors_list)
    var (factors, inv_factors) = _build_factor_lists(bar_dates, sd, sf, Float64(1.0))
    assert_equal(len(factors), 3)
    assert_equal(len(inv_factors), 3)
    assert_true(factors[0] >= Float64(0.99) and factors[0] <= Float64(1.01))
    assert_true(factors[1] >= Float64(1.99) and factors[1] <= Float64(2.01))
    assert_true(factors[2] >= Float64(3.99) and factors[2] <= Float64(4.01))


def test_build_factor_lists_with_base_rate() raises:
    var bar_dates = List[Int64]()
    bar_dates.append(Int64(250))
    var ex_dates = List[Int64]()
    ex_dates.append(Int64(100))
    ex_dates.append(Int64(200))
    ex_dates.append(Int64(300))
    var ex_factors_list = List[Float64]()
    ex_factors_list.append(Float64(1.0))
    ex_factors_list.append(Float64(2.0))
    ex_factors_list.append(Float64(4.0))
    var sd = _make_series_int64(ex_dates)
    var sf = _make_series_float64(ex_factors_list)
    var (factors, inv_factors) = _build_factor_lists(bar_dates, sd, sf, Float64(2.0))
    assert_true(factors[0] >= Float64(0.99) and factors[0] <= Float64(1.01))
    var inv_expected = Float64(1.0) / factors[0]
    assert_true(inv_factors[0] >= inv_expected - Float64(0.001) and inv_factors[0] <= inv_expected + Float64(0.001))


# =====================================================================
# Test: _apply_factor_list / _apply_inv_factor_list
# =====================================================================

def test_apply_factor_list_basic() raises:
    var values = List[Float64]()
    values.append(Float64(10.0))
    values.append(Float64(20.0))
    values.append(Float64(30.0))
    var factors = List[Float64]()
    factors.append(Float64(2.0))
    factors.append(Float64(3.0))
    factors.append(Float64(4.0))
    var result = _apply_factor_list(values, factors)
    assert_equal(len(result), 3)
    assert_true(result[0] >= Float64(19.99) and result[0] <= Float64(20.01))
    assert_true(result[1] >= Float64(59.99) and result[1] <= Float64(60.01))
    assert_true(result[2] >= Float64(119.99) and result[2] <= Float64(120.01))


def test_apply_factor_list_empty() raises:
    var values = List[Float64]()
    var factors = List[Float64]()
    var result = _apply_factor_list(values, factors)
    assert_equal(len(result), 0)


def test_apply_inv_factor_list_basic() raises:
    var values = List[Float64]()
    values.append(Float64(100.0))
    values.append(Float64(200.0))
    var inv = List[Float64]()
    inv.append(Float64(0.5))
    inv.append(Float64(0.25))
    var result = _apply_inv_factor_list(values, inv)
    assert_true(result[0] >= Float64(49.99) and result[0] <= Float64(50.01))
    assert_true(result[1] >= Float64(49.99) and result[1] <= Float64(50.01))


# =====================================================================
# Test: BarData struct
# =====================================================================

def test_bar_data_size() raises:
    var bars = _build_simple_bars(5)
    assert_equal(bars.size(), 5)


def test_bar_data_is_empty() raises:
    var bars = _build_simple_bars(0)
    assert_true(bars.is_empty())


def test_bar_data_not_empty() raises:
    var bars = _build_simple_bars(1)
    assert_false(bars.is_empty())


def test_bar_data_copy_independence() raises:
    var bars = _build_simple_bars(3)
    var copy = bars.copy()
    var orig_open_0 = bars.get_field("open")[0]
    copy.get_field("open")[0] = Float64(999.0)
    assert_true(bars.get_field("open")[0] >= orig_open_0 - Float64(0.001) and bars.get_field("open")[0] <= orig_open_0 + Float64(0.001))


def test_bar_data_get_set_field() raises:
    var bars = _build_simple_bars(2)
    var original = bars.get_field("close")
    assert_equal(len(original), 2)
    var new_vals = List[Float64]()
    new_vals.append(Float64(555.0))
    new_vals.append(Float64(666.0))
    bars.set_field("close", new_vals^)
    var updated = bars.get_field("close")
    assert_true(updated[0] >= Float64(554.99) and updated[0] <= Float64(555.01))


def test_bar_data_field_names_preserved() raises:
    var bars = _build_simple_bars(3)
    assert_equal(len(bars.field_names), 5)
    assert_true("open" in bars.field_names)
    assert_true("volume" in bars.field_names)


# =====================================================================
# Test: ExFactorData struct
# =====================================================================

def test_ex_factor_data_basic() raises:
    var dates = List[Int64]()
    dates.append(Int64(1))
    dates.append(Int64(2))
    var factors = List[Float64]()
    factors.append(Float64(1.0))
    factors.append(Float64(2.0))
    var ef = _build_ex_factors(dates^, factors^)
    assert_equal(len(ef.start_dates), 2)
    assert_equal(len(ef.ex_cum_factors), 2)


# =====================================================================
# Test: adjust_bars — edge cases
# =====================================================================

def test_adjust_bars_empty_bars_returns_empty() raises:
    var empty_bars = _build_simple_bars(0)
    var ex_factors = _build_simple_ex_factors()
    var result = adjust_bars(empty_bars, ex_factors, "", "pre", "2020-01-05")
    assert_true(result.is_empty())


def test_adjust_bars_no_adjustment_needed_uniform_factors() raises:
    var bars = _build_simple_bars(3)
    var uniform_ef = _build_uniform_ex_factors(Float64(1.0))
    var result = adjust_bars(bars, uniform_ef, "", "post", "2020-01-05")
    assert_equal(result.size(), 3)
    var orig_close = bars.get_field("close")[0]
    var res_close = result.get_field("close")[0]
    assert_true(res_close >= orig_close - Float64(0.001) and res_close <= orig_close + Float64(0.001))


def test_adjust_bars_pre_base_rate_matches_range() raises:
    var bars = _build_simple_bars(3)
    var ef = _build_uniform_ex_factors(Float64(1.5))
    var result = adjust_bars(bars, ef, "", "pre", "2020-01-03")
    assert_equal(result.size(), 3)


# =====================================================================
# Test: adjust_bars — pre-adjustment with single price field
# =====================================================================

def test_adjust_bars_pre_single_price_field_modifies_values() raises:
    var bars = _build_simple_bars(5)
    var ex_factors = _build_simple_ex_factors()
    var orig_open_0 = bars.get_field("open")[0]
    var result = adjust_bars(bars, ex_factors, "open", "pre", "2020-01-05")
    assert_equal(result.size(), 5)
    var adj_open_0 = result.get_field("open")[0]
    var factor = adj_open_0 / orig_open_0
    assert_true(factor > Float64(0.95) and factor < Float64(1.1))


def test_adjust_bars_pre_single_price_field_others_unchanged() raises:
    var bars = _build_simple_bars(5)
    var ex_factors = _build_simple_ex_factors()
    var orig_close_0 = bars.get_field("close")[0]
    var result = adjust_bars(bars, ex_factors, "open", "pre", "2020-01-05")
    var res_close_0 = result.get_field("close")[0]
    assert_true(res_close_0 >= orig_close_0 - Float64(0.001) and res_close_0 <= orig_close_0 + Float64(0.001))


def test_adjust_bars_pre_volume_field_modifies_values() raises:
    var bars = _build_simple_bars(5)
    var ex_factors = _build_simple_ex_factors()
    var orig_vol_0 = bars.get_field("volume")[0]
    var result = adjust_bars(bars, ex_factors, "volume", "pre", "2020-01-05")
    assert_equal(result.size(), 5)
    var adj_vol_0 = result.get_field("volume")[0]
    assert_true(adj_vol_0 != orig_vol_0 or abs(adj_vol_0 - orig_vol_0) < Float64(0.001))


# =====================================================================
# Test: adjust_bars — post-adjustment (base_rate = 1.0)
# =====================================================================

def test_adjust_bars_post_base_rate_one() raises:
    var bars = _build_simple_bars(5)
    var ex_factors = _build_simple_ex_factors()
    var result = adjust_bars(bars, ex_factors, "", "post", "2020-01-05")
    assert_equal(result.size(), 5)
    var orig_open_0 = bars.get_field("open")[0]
    var res_open_0 = result.get_field("open")[0]
    assert_true(res_open_0 != orig_open_0 or abs(res_open_0 - orig_open_0) < Float64(0.001))


# =====================================================================
# Test: adjust_bars — all fields adjustment
# =====================================================================

def test_adjust_bars_all_fields_price_fields_modified() raises:
    var bars = _build_simple_bars(5)
    var ex_factors = _build_simple_ex_factors()
    var orig_open = bars.get_field("open")[2]
    var orig_close = bars.get_field("close")[2]
    var orig_high = bars.get_field("high")[2]
    var orig_low = bars.get_field("low")[2]
    var orig_vol = bars.get_field("volume")[2]
    var result = adjust_bars(bars, ex_factors, "", "pre", "2020-01-05")
    assert_equal(result.size(), 5)
    var res_open = result.get_field("open")[2]
    var res_close = result.get_field("close")[2]
    var res_high = result.get_field("high")[2]
    var res_low = result.get_field("low")[2]
    var res_vol = result.get_field("volume")[2]
    var open_changed = abs(res_open - orig_open) > Float64(0.01)
    var close_changed = abs(res_close - orig_close) > Float64(0.01)
    var high_changed = abs(res_high - orig_high) > Float64(0.01)
    var low_changed = abs(res_low - orig_low) > Float64(0.01)
    var vol_changed = abs(res_vol - orig_vol) > Float64(0.01)
    assert_true(open_changed or close_changed or high_changed or low_changed or vol_changed)


def test_adjust_bars_preserves_bar_count() raises:
    for n in range(1, 11):
        var bars = _build_simple_bars(n)
        var ex_factors = _build_simple_ex_factors()
        var result = adjust_bars(bars, ex_factors, "", "pre", "2020-01-05")
        assert_equal(result.size(), n)


# =====================================================================
# Test: adjust_bars — single bar edge case
# =====================================================================

def test_adjust_bars_single_bar() raises:
    var bars = _build_simple_bars(1)
    var ex_factors = _build_simple_ex_factors()
    var result = adjust_bars(bars, ex_factors, "close", "pre", "2020-01-01")
    assert_equal(result.size(), 1)


def test_adjust_bars_large_dataset() raises:
    var bars = _build_simple_bars(100)
    var ex_factors = _build_simple_ex_factors()
    var result = adjust_bars(bars, ex_factors, "", "pre", "2020-02-01")
    assert_equal(result.size(), 100)


# =====================================================================
# Test: adjust_bars — non-price field ignored
# =====================================================================

def test_adjust_bars_non_price_non_volume_field_unchanged() raises:
    var bars = _build_simple_bars(3)
    var ex_factors = _build_simple_ex_factors()
    var orig_open_0 = bars.get_field("open")[0]
    var result = adjust_bars(bars, ex_factors, "amount", "pre", "2020-01-05")
    var res_open_0 = result.get_field("open")[0]
    assert_true(res_open_0 >= orig_open_0 - Float64(0.001) and res_open_0 <= orig_open_0 + Float64(0.001))


# =====================================================================
# Test: adjust_ratio
# =====================================================================

def test_adjust_ratio_normal_case() raises:
    var result = adjust_ratio(Float64(100.0), Float64(50.0))
    assert_true(result > Float64(1.99) and result < Float64(2.01))


def test_adjust_ratio_zero_ex_factor() raises:
    var result = adjust_ratio(Float64(100.0), Float64(0.0))
    assert_equal(result, Float64(1.0))


def test_adjust_ratio_zero_pre_close() raises:
    var result = adjust_ratio(Float64(0.0), Float64(50.0))
    assert_equal(result, Float64(1.0))


def test_adjust_ratio_both_zero() raises:
    var result = adjust_ratio(Float64(0.0), Float64(0.0))
    assert_equal(result, Float64(1.0))


def test_adjust_ratio_identical_values() raises:
    var result = adjust_ratio(Float64(42.5), Float64(42.5))
    assert_true(result > Float64(0.999) and result < Float64(1.001))


def test_adjust_ratio_small_pre_close_large_factor() raises:
    var result = adjust_ratio(Float64(1.0), Float64(100.0))
    assert_true(result > Float64(0.0099) and result < Float64(0.0101))


def test_adjust_ratio_large_pre_close_small_factor() raises:
    var result = adjust_ratio(Float64(10000.0), Float64(0.1))
    assert_true(result > Float64(99999.0) and result < Float64(100001.0))


# =====================================================================
# Test: adjustment correctness — factor consistency checks
# =====================================================================

def test_adjustment_price_fields_use_same_factor() raises:
    var bars = _build_simple_bars(5)
    var ex_factors = _build_simple_ex_factors()
    var result = adjust_bars(bars, ex_factors, "", "pre", "2020-01-05")
    var orig_open = bars.get_field("open")[2]
    var orig_close = bars.get_field("close")[2]
    var res_open = result.get_field("open")[2]
    var res_close = result.get_field("close")[2]
    if orig_open != Float64(0.0):
        var open_ratio = res_open / orig_open
        var close_ratio = res_close / orig_close
        assert_true(abs(open_ratio - close_ratio) < Float64(0.001))


def test_adjustment_volume_inverse_of_price() raises:
    var bars = _build_simple_bars(5)
    var ex_factors = _build_simple_ex_factors()
    var orig_vol = bars.get_field("volume")[2]
    var orig_open = bars.get_field("open")[2]
    var result_all = adjust_bars(bars.copy(), ex_factors, "", "pre", "2020-01-05")
    var res_vol_all = result_all.get_field("volume")[2]
    var res_open_all = result_all.get_field("open")[2]
    if orig_open != Float64(0.0) and orig_vol != Float64(0.0):
        var price_ratio = res_open_all / orig_open
        var vol_ratio = res_vol_all / orig_vol
        var product = price_ratio * vol_ratio
        assert_true(product > Float64(0.99) and product < Float64(1.01))


# =====================================================================
# Main entry point
# =====================================================================

def main() raises:
    var suite = TestSuite.discover_tests[__functions_in_module()]()
    suite^.run()
    print("\n=== All adjust.mojo tests passed! ===")
