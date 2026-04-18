"""
Test for mod/utils.mojo
Group 07 - File 09
"""

from std.collections import Dict, List
from rqmojo.mod.utils import register_mod, unregister_mod, get_mod_config, parse_instrument_types, parse_markets
from rqmojo.utils import RqAttrDict
from rqmojo.const import INSTRUMENT_TYPE, MARKET

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_register_mod() raises:
    print("Test: register_mod function")
    var config = RqAttrDict()
    config["enabled"] = "true"
    register_mod("test_mod", config)
    print("  PASSED")


def test_unregister_mod() raises:
    print("Test: unregister_mod function")
    unregister_mod("test_mod")
    print("  PASSED")


def test_get_mod_config() raises:
    print("Test: get_mod_config function")
    var config = get_mod_config("test_mod")
    print("  PASSED")


def test_parse_instrument_types() raises:
    print("Test: parse_instrument_types function")
    var types = parse_instrument_types("CS,IND")
    print("  PASSED")


def test_parse_markets() raises:
    print("Test: parse_markets function")
    var markets = parse_markets("CN,HK")
    assert_equal(len(markets), 2, "Should have 2 markets")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
