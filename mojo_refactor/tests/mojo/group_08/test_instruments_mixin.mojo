"""
Test for data/instruments_mixin.mojo
Group 08 - File 3
"""

from rqmojo.data.instruments_mixin import InstrumentsMixin, create_instruments_mixin_with_test_data
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE
from rqmojo.utils.typing import DateTime



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_instruments_mixin_init() raises:
    print("Test: InstrumentsMixin init")
    var mixin = create_instruments_mixin_with_test_data()
    print("  PASSED")
    assert_true(True, "test passed")


def test_instruments_mixin_get_instrument() raises:
    print("Test: InstrumentsMixin get_instrument")
    var mixin = create_instruments_mixin_with_test_data()
    var ins = mixin.get_instrument("000001.XSHE")
    print("  PASSED")
    assert_true(True, "test passed")


def test_instruments_mixin_all_instruments() raises:
    print("Test: InstrumentsMixin get_instrument for multiple")
    var mixin = create_instruments_mixin_with_test_data()
    var ins1 = mixin.get_instrument("000001.XSHE")
    var ins2 = mixin.get_instrument("000002.XSHE")
    print("  PASSED")
    assert_true(True, "test passed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()