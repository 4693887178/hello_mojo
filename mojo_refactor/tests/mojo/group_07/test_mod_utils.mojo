"""
Test for mod/utils.mojo
Group 07 - File 09

Tests cover:
  - mod_config_value_parse: Parse config string values to typed RqAttrDict values
  - register_mod / unregister_mod / get_mod_config: Stub functions
  - parse_instrument_types: Parse instrument type strings to INSTRUMENT_TYPE list
  - parse_markets: Parse market strings to MARKET list
"""

from std.collections import List
from rqmojo.mod.utils import (
    mod_config_value_parse,
    inject_mod_commands,
    register_mod,
    unregister_mod,
    get_mod_config,
    parse_instrument_types,
    parse_markets,
)
from rqmojo.utils import RqAttrDict
from rqmojo.const import INSTRUMENT_TYPE, MARKET

from std.testing import assert_equal, assert_true, TestSuite


def test_parse_true_string() raises:
    print("Test: mod_config_value_parse('True') -> Bool True")
    var result = mod_config_value_parse("True")
    assert_true(result.has_value(), "Should have a value")
    assert_equal(result.to[Bool](False), True, "True string should parse to True")
    print("  PASSED")


def test_parse_true_lowercase() raises:
    print("Test: mod_config_value_parse('true') -> Bool True")
    var result = mod_config_value_parse("true")
    assert_true(result.has_value(), "Should have a value")
    assert_equal(result.to[Bool](False), True, "'true' should parse to True")
    print("  PASSED")


def test_parse_false_string() raises:
    print("Test: mod_config_value_parse('False') -> Bool False")
    var result = mod_config_value_parse("False")
    assert_true(result.has_value(), "Should have a value")
    assert_equal(result.to[Bool](True), False, "False string should parse to False")
    print("  PASSED")


def test_parse_false_lowercase() raises:
    print("Test: mod_config_value_parse('false') -> Bool False")
    var result = mod_config_value_parse("false")
    assert_true(result.has_value(), "Should have a value")
    assert_equal(result.to[Bool](True), False, "'false' should parse to False")
    print("  PASSED")


def test_parse_integer() raises:
    print("Test: mod_config_value_parse('123') -> Int 123")
    var result = mod_config_value_parse("123")
    assert_true(result.has_value(), "Should have a value")
    assert_equal(result.to[Int](0), 123, "Integer string should parse to Int")
    print("  PASSED")


def test_parse_zero() raises:
    print("Test: mod_config_value_parse('0') -> Int 0")
    var result = mod_config_value_parse("0")
    assert_true(result.has_value(), "Should have a value")
    assert_equal(result.to[Int](999), 0, "Zero should parse to Int 0")
    print("  PASSED")


def test_parse_large_integer() raises:
    print("Test: mod_config_value_parse('999999') -> Int 999999")
    var result = mod_config_value_parse("999999")
    assert_true(result.has_value(), "Should have a value")
    assert_equal(result.to[Int](0), 999999, "Large integer should parse correctly")
    print("  PASSED")


def test_parse_float() raises:
    print("Test: mod_config_value_parse('3.14') -> Float64 ~3.14")
    var result = mod_config_value_parse("3.14")
    assert_true(result.has_value(), "Should have a value")
    var fval = result.to[Float64](0.0)
    assert_true(fval > 3.13 and fval < 3.15, "Float string should parse to Float64")
    print("  PASSED")


def test_parse_float_half() raises:
    print("Test: mod_config_value_parse('0.5') -> Float64 ~0.5")
    var result = mod_config_value_parse("0.5")
    assert_true(result.has_value(), "Should have a value")
    var fval = result.to[Float64](0.0)
    assert_true(fval > 0.49 and fval < 0.51, "0.5 should parse correctly")
    print("  PASSED")


def test_parse_negative_float() raises:
    print("Test: mod_config_value_parse('-1.5') -> Float64 ~-1.5")
    var result = mod_config_value_parse("-1.5")
    assert_true(result.has_value(), "Should have a value")
    var fval = result.to[Float64](0.0)
    assert_true(fval > -1.51 and fval < -1.49, "-1.5 should parse correctly")
    print("  PASSED")


def test_parse_plain_string() raises:
    print("Test: mod_config_value_parse('hello') -> String 'hello'")
    var result = mod_config_value_parse("hello")
    assert_true(result.has_value(), "Should have a value")
    assert_equal(result.to[String](""), "hello", "Plain string should return as-is")
    print("  PASSED")


def test_parse_alphanumeric_string() raises:
    print("Test: mod_config_value_parse('test_value') -> String 'test_value'")
    var result = mod_config_value_parse("test_value")
    assert_true(result.has_value(), "Should have a value")
    assert_equal(result.to[String](""), "test_value", "Alphanumeric string should return as-is")
    print("  PASSED")


def test_register_mod_exists() raises:
    print("Test: register_mod function exists and is callable")
    var config = RqAttrDict()
    config["enabled"] = "true"
    register_mod("test_mod", config)
    print("  PASSED")


def test_unregister_mod_exists() raises:
    print("Test: unregister_mod function exists and is callable")
    unregister_mod("test_mod")
    print("  PASSED")


def test_get_mod_config_returns_dict() raises:
    print("Test: get_mod_config returns RqAttrDict")
    var config = get_mod_config("test_mod")
    assert_true(config.is_empty(), "Default config should be empty")
    print("  PASSED")


def test_parse_cs() raises:
    print("Test: parse_instrument_types('CS') -> [CS]")
    var types = parse_instrument_types("CS")
    assert_equal(len(types), 1, "Should have 1 type")
    assert_equal(types[0], INSTRUMENT_TYPE.CS, "Should be CS")
    print("  PASSED")


def test_parse_etf() raises:
    print("Test: parse_instrument_types('ETF') -> [ETF]")
    var types = parse_instrument_types("ETF")
    assert_equal(len(types), 1, "Should have 1 type")
    assert_equal(types[0], INSTRUMENT_TYPE.ETF, "Should be ETF")
    print("  PASSED")


def test_parse_future() raises:
    print("Test: parse_instrument_types('FUTURE') -> [FUTURE]")
    var types = parse_instrument_types("FUTURE")
    assert_equal(len(types), 1, "Should have 1 type")
    assert_equal(types[0], INSTRUMENT_TYPE.FUTURE, "Should be FUTURE")
    print("  PASSED")


def test_parse_multiple_with_spaces() raises:
    print("Test: parse_instrument_types('CS, ETF, FUTURE') -> 3 types")
    var types = parse_instrument_types("CS, ETF, FUTURE")
    assert_equal(len(types), 3, "Should have 3 types")
    assert_equal(types[0], INSTRUMENT_TYPE.CS, "First should be CS")
    assert_equal(types[1], INSTRUMENT_TYPE.ETF, "Second should be ETF")
    assert_equal(types[2], INSTRUMENT_TYPE.FUTURE, "Third should be FUTURE")
    print("  PASSED")


def test_parse_all_supported() raises:
    print("Test: parse_instrument_types with all supported types")
    var types = parse_instrument_types("CS,ETF,FUTURE,INDX,LOF,FUND,BOND")
    assert_equal(len(types), 7, "Should have 7 types")
    print("  PASSED")


def test_parse_unknown_type_ignored() raises:
    print("Test: parse_instrument_types ignores unknown types")
    var types = parse_instrument_types("UNKNOWN,CS")
    assert_equal(len(types), 1, "Only known types should be parsed")
    assert_equal(types[0], INSTRUMENT_TYPE.CS, "Should be CS")
    print("  PASSED")


def test_parse_empty_string_instruments() raises:
    print("Test: parse_instrument_types('') -> empty list")
    var types = parse_instrument_types("")
    assert_equal(len(types), 0, "Empty string should return empty list")
    print("  PASSED")


def test_parse_cn() raises:
    print("Test: parse_markets('CN') -> [CN]")
    var markets = parse_markets("CN")
    assert_equal(len(markets), 1, "Should have 1 market")
    assert_equal(markets[0], MARKET.CN, "Should be CN")
    print("  PASSED")


def test_parse_hk() raises:
    print("Test: parse_markets('HK') -> [HK]")
    var markets = parse_markets("HK")
    assert_equal(len(markets), 1, "Should have 1 market")
    assert_equal(markets[0], MARKET.HK, "Should be HK")
    print("  PASSED")


def test_parse_multiple_markets() raises:
    print("Test: parse_markets('CN,HK') -> [CN, HK]")
    var markets = parse_markets("CN,HK")
    assert_equal(len(markets), 2, "Should have 2 markets")
    assert_equal(markets[0], MARKET.CN, "First should be CN")
    assert_equal(markets[1], MARKET.HK, "Second should be HK")
    print("  PASSED")


def test_parse_markets_with_spaces() raises:
    print("Test: parse_markets(' CN , HK ') -> [CN, HK]")
    var markets = parse_markets(" CN , HK ")
    assert_equal(len(markets), 2, "Should handle whitespace")
    print("  PASSED")


def test_parse_empty_markets() raises:
    print("Test: parse_markets('') -> empty list")
    var markets = parse_markets("")
    assert_equal(len(markets), 0, "Empty string returns empty list")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
