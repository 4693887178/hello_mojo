"""
Unit Tests Part 1: AnalyserMod creation, _parse_benchmark, _safe_convert, _is_null_oid
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import List
from std.math import abs

from rqmojo.mod.rqmojo_mod_sys_analyser.mod import AnalyserMod, create_analyser_mod, create_analyser_mod_with_params
from rqmojo.utils.typing import DateTime
from rqmojo.data.data_proxy import create_data_proxy


def assert_close(actual: Float64, expected: Float64, tolerance: Float64, msg: String = "") raises:
    if abs(actual - expected) > tolerance:
        raise msg + ": expected " + String(expected) + " got " + String(actual)


def test_create_defaults() raises:
    var mod = create_analyser_mod()
    assert_equal(mod.name, "analyser")
    assert_false(mod.enabled)
    assert_equal(len(mod._benchmark_daily_returns), 0)
    assert_equal(len(mod._orders), 0)
    assert_equal(len(mod._trades), 0)
    assert_equal(len(mod._total_portfolios), 0)
    assert_close(mod._initial_cash, 100000.0, 0.01)
    assert_equal(mod._trading_days_a_year, 252)


def test_create_with_params() raises:
    var dp = create_data_proxy()
    var start = DateTime(2023, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2023, 12, 31, 0, 0, 0, 0)
    var mod = create_analyser_mod_with_params(dp^, start, end, 50000.0, "000001.XSHE")
    assert_equal(mod.name, "analyser")
    assert_close(mod._initial_cash, 50000.0, 0.01)


def test_create_with_params_no_benchmark() raises:
    var dp = create_data_proxy()
    var start = DateTime(2023, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2023, 12, 31, 0, 0, 0, 0)
    var mod = create_analyser_mod_with_params(dp^, start, end, 100000.0)
    assert_true(mod._benchmark is None)


def test_parse_benchmark_single() raises:
    var mod = create_analyser_mod()
    var result = mod._parse_benchmark("000001.XSHE")
    assert_equal(len(result), 1)
    assert_equal(result[0][0], "000001.XSHE")
    assert_close(result[0][1], 1.0, 0.001)


def test_parse_benchmark_with_weight() raises:
    var mod = create_analyser_mod()
    var result = mod._parse_benchmark("000001.XSHE:0.5")
    assert_equal(len(result), 1)
    assert_close(result[0][1], 0.5, 0.001)


def test_parse_benchmark_multiple() raises:
    var mod = create_analyser_mod()
    var result = mod._parse_benchmark("000001.XSHE:0.5,000905.XSHG:0.5")
    assert_equal(len(result), 2)
    assert_close(result[0][1], 0.5, 0.001)
    assert_close(result[1][1], 0.5, 0.001)


def test_parse_benchmark_null() raises:
    var mod = create_analyser_mod()
    var result = mod._parse_benchmark("null")
    assert_equal(len(result), 1)
    assert_equal(result[0][0], "null")


def test_parse_benchmark_empty() raises:
    var mod = create_analyser_mod()
    var result = mod._parse_benchmark("")
    assert_equal(len(result), 0)


def test_parse_benchmark_unequal_weights() raises:
    var mod = create_analyser_mod()
    var result = mod._parse_benchmark("000001.XSHE:0.3,000905.XSHG:0.7")
    assert_equal(len(result), 2)
    assert_close(result[0][1], 0.3, 0.001)
    assert_close(result[1][1], 0.7, 0.001)


def test_safe_convert_default() raises:
    assert_close(AnalyserMod._safe_convert(3.14159265), 3.1416, 0.0001)


def test_safe_convert_two_digits() raises:
    assert_close(AnalyserMod._safe_convert(3.14159265, 2), 3.14, 0.01)


def test_safe_convert_zero() raises:
    assert_close(AnalyserMod._safe_convert(0.0), 0.0, 0.0001)


def test_safe_convert_negative() raises:
    assert_close(AnalyserMod._safe_convert(-1.56789), -1.5679, 0.0001)


def test_is_null_oid() raises:
    var mod = create_analyser_mod()
    assert_true(mod._is_null_oid("null"))
    assert_true(mod._is_null_oid("NULL"))
    assert_false(mod._is_null_oid("000001.XSHE"))


fn main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
