"""
Test for data/bundle.mojo
Group 09 - File 7
"""

from rqmojo.data.bundle import Bundle, create_bundle

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_bundle_init() raises:
    print("Test: Bundle init")
    var _ = create_bundle("./bundle")
    print("  PASSED")


def test_bundle_get_instruments_path() raises:
    print("Test: Bundle get_instruments_path")
    var bundle = create_bundle("./bundle")
    var _ = bundle.get_instruments_path()
    print("  PASSED")


def test_bundle_get_trading_dates_path() raises:
    print("Test: Bundle get_trading_dates_path")
    var bundle = create_bundle("./bundle")
    var _ = bundle.get_trading_dates_path()
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
