"""
Test for model/instrument.mojo
Group 09 - File 8
"""

from std.collections import Dict, List
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_instrument_struct() raises:
    print("Test: Instrument struct exists")
    var inst = create_stock_instrument(
        order_book_id="000001.XSHE",
        symbol="平安银行",
        listed_date=DateTime(1991, 4, 3, 0, 0, 0, 0),
        exchange=EXCHANGE.XSHE
    )
    assert_equal(inst.order_book_id(), "000001.XSHE", "Order book ID should match")
    print("  PASSED")


def test_instrument_properties() raises:
    print("Test: Instrument properties")
    var inst = create_stock_instrument(
        order_book_id="000001.XSHE",
        symbol="平安银行",
        listed_date=DateTime(1991, 4, 3, 0, 0, 0, 0),
        exchange=EXCHANGE.XSHE
    )
    
    assert_equal(inst.symbol(), "平安银行", "Symbol should match")
    assert_equal(inst.type(), INSTRUMENT_TYPE.CS, "Type should be CS")
    print("  PASSED")


def test_instrument_exchange() raises:
    print("Test: Instrument exchange")
    var inst = create_stock_instrument(
        order_book_id="000001.XSHE",
        symbol="平安银行",
        listed_date=DateTime(1991, 4, 3, 0, 0, 0, 0),
        exchange=EXCHANGE.XSHE
    )
    
    assert_equal(inst.exchange(), EXCHANGE.XSHE, "Exchange should match")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
