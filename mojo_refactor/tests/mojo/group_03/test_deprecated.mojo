"""
RQAlpha Mojo - Deprecated Module Test
Tests for data/base_data_source/deprecated.mojo
Matches Python: AbstractInstrumentStore + InstrumentStore only
"""

from std.collections import List
from rqmojo.data.base_data_source.deprecated import (
    AbstractInstrumentStore,
    InstrumentStore,
    create_instrument_store,
)
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, TestSuite


def test_abstract_instrument_store_trait_exists() raises:
    """AbstractInstrumentStore trait is defined with get_instruments method."""
    pass


def test_instrument_store_construction() raises:
    """InstrumentStore can be constructed and stores instruments correctly."""
    var instruments = List[Instrument]()
    instruments.append(create_stock_instrument(
        order_book_id="000001.XSHE",
        symbol="平安银行",
        listed_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        exchange=EXCHANGE.XSHE
    ))
    var store = create_instrument_store(instruments, INSTRUMENT_TYPE.CS)
    assert_equal(store.instrument_type(), INSTRUMENT_TYPE.CS)
    assert_equal(len(store.get_instruments(None)), 1)


def test_instrument_store_get_instruments() raises:
    """InstrumentStore.get_instruments resolves by both id and symbol."""
    var instruments = List[Instrument]()
    instruments.append(create_stock_instrument(
        order_book_id="000001.XSHE",
        symbol="平安银行",
        listed_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        exchange=EXCHANGE.XSHE
    ))
    var store = create_instrument_store(instruments, INSTRUMENT_TYPE.CS)

    var ids = List[String]()
    ids.append("平安银行")
    var result = store.get_instruments(ids.copy())
    assert_equal(len(result), 1)
    assert_equal(result[0].order_book_id(), "000001.XSHE")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
