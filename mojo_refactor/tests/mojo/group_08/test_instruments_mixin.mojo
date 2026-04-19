"""
Test for data/instruments_mixin.mojo
Group 08 - File 3
Updated to match refactored InstrumentsMixin API
"""

from rqmojo.data.instruments_mixin import InstrumentsMixin, create_instruments_mixin_with_test_data
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def test_instruments_mixin_init() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var all_ins = mixin._get_all_instruments()
    assert_equal(len(all_ins), 5, "should have 5 test instruments")


def test_instruments_mixin_get_instrument() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var ins = mixin.instrument("000001.XSHE")
    assert_true(ins != None, "should find 000001.XSHE")
    assert_equal(ins.value().order_book_id(), "000001.XSHE", "order_book_id should match")


def test_instruments_mixin_get_instrument_not_found() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var ins = mixin.instrument("000002.XSHE")
    assert_true(ins == None, "should not find 000002.XSHE")


def test_instruments_mixin_get_active_instrument() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var dt = DateTime(2019, 6, 1, 0, 0, 0, 0)
    var ins = mixin.get_active_instrument("000001.XSHE", dt)
    assert_equal(ins.order_book_id(), "000001.XSHE", "should find active instrument")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
