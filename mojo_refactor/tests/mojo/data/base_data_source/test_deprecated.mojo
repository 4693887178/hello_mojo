"""
Comprehensive Test Suite for data/base_data_source/deprecated.mojo
Coverage: unit tests, integration tests, boundary conditions
Pattern: std.testing TestSuite (standard framework)
Matches Python: rqalpha/data/base_data_source/deprecated.py (AbstractInstrumentStore + InstrumentStore only)
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Dict, List, Set, Optional

from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, MARKET
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.utils.typing import DateTime
from rqmojo.data.base_data_source.deprecated import (
    AbstractInstrumentStore,
    InstrumentStore,
    create_instrument_store,
)


# ============================================================
# 1. Unit Tests: InstrumentStore - Construction
# ============================================================

def _make_stock(order_book_id: String, symbol: String) -> Instrument:
    return create_stock_instrument(
        order_book_id=order_book_id,
        symbol=symbol,
        listed_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        exchange=EXCHANGE.XSHE
    )


def _make_future(order_book_id: String, symbol: String) -> Instrument:
    return create_future_instrument(
        order_book_id=order_book_id,
        symbol=symbol,
        listed_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        maturity_date=DateTime(2025, 6, 1, 0, 0, 0, 0),
        de_listed_date=DateTime(2025, 6, 15, 0, 0, 0, 0),
        contract_multiplier=10.0,
        exchange=EXCHANGE.SHFE,
        underlying_symbol="RB"
    )


def test_instrument_store_empty_instruments() raises:
    """InstrumentStore with empty list produces empty store."""
    var instruments = List[Instrument]()
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)
    assert_equal(store.instrument_type(), INSTRUMENT_TYPE.CS)
    assert_equal(len(store.all_id_and_syms()), 0)
    assert_equal(len(store.get_instruments(None)), 0)


def test_instrument_store_filters_by_type() raises:
    """InstrumentStore only stores instruments matching instrument_type."""
    var instruments = List[Instrument]()
    instruments.append(_make_stock("000001.XSHE", "平安银行"))
    instruments.append(_make_future("RB2501", "螺纹钢2501"))
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)
    assert_equal(len(store.all_id_and_syms()), 2)
    assert_equal(len(store.get_instruments(None)), 1)


def test_instrument_store_type_property() raises:
    """Instrument type returns the type passed at construction."""
    var instruments = List[Instrument]()
    var store_cs = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)
    var store_fut = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.FUTURE)
    assert_equal(store_cs.instrument_type(), INSTRUMENT_TYPE.CS)
    assert_equal(store_fut.instrument_type(), INSTRUMENT_TYPE.FUTURE)


# ============================================================
# 2. Unit Tests: InstrumentStore - all_id_and_syms
# ============================================================

def test_all_id_and_syms_returns_both_keys() raises:
    """All id and syms returns union of order_book_ids and symbols."""
    var instruments = List[Instrument]()
    instruments.append(_make_stock("000001.XSHE", "平安银行"))
    instruments.append(_make_stock("600000.XSHG", "浦发银行"))
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)
    var ids = store.all_id_and_syms()
    assert_equal(len(ids), 4)


def test_all_id_and_syms_deduplication() raises:
    """If order_book_id == symbol, it appears twice (both maps have it)."""
    var instruments = List[Instrument]()
    instruments.append(_make_stock("TEST.ID", "TEST.ID"))
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)
    var ids = store.all_id_and_syms()
    assert_equal(len(ids), 2)


def test_all_id_and_syms_empty_store() raises:
    """Empty store returns empty list."""
    var instruments = List[Instrument]()
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)
    assert_equal(len(store.all_id_and_syms()), 0)


# ============================================================
# 3. Unit Tests: InstrumentStore - get_instruments(None)
# ============================================================

def test_get_instruments_none_returns_all() raises:
    """Get instruments None returns all stored instruments."""
    var instruments = List[Instrument]()
    instruments.append(_make_stock("000001.XSHE", "平安银行"))
    instruments.append(_make_stock("600000.XSHG", "浦发银行"))
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)
    var result = store.get_instruments(None)
    assert_equal(len(result), 2)


def test_get_instruments_none_empty_store() raises:
    """Get instruments None on empty store returns empty list."""
    var instruments = List[Instrument]()
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)
    var result = store.get_instruments(None)
    assert_equal(len(result), 0)


# ============================================================
# 4. Unit Tests: InstrumentStore - get_instruments with IDs
# ============================================================

def test_get_instruments_by_order_book_id() raises:
    """Lookup by order_book_id returns correct instrument."""
    var instruments = List[Instrument]()
    instruments.append(_make_stock("000001.XSHE", "平安银行"))
    instruments.append(_make_stock("600000.XSHG", "浦发银行"))
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)

    var ids = List[String]()
    ids.append("000001.XSHE")
    var result = store.get_instruments(ids.copy())
    assert_equal(len(result), 1)
    assert_equal(result[0].order_book_id(), "000001.XSHE")


def test_get_instruments_by_symbol() raises:
    """Lookup by symbol resolves via sym_id_map and returns correct instrument."""
    var instruments = List[Instrument]()
    instruments.append(_make_stock("000001.XSHE", "平安银行"))
    instruments.append(_make_stock("600000.XSHG", "浦发银行"))
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)

    var ids = List[String]()
    ids.append("平安银行")
    var result = store.get_instruments(ids.copy())
    assert_equal(len(result), 1)
    assert_equal(result[0].symbol(), "平安银行")


def test_get_instruments_mixed_lookup() raises:
    """Lookup with mix of order_book_id and symbol."""
    var instruments = List[Instrument]()
    instruments.append(_make_stock("000001.XSHE", "平安银行"))
    instruments.append(_make_stock("600000.XSHG", "浦发银行"))
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)

    var ids = List[String]()
    ids.append("000001.XSHE")
    ids.append("浦发银行")
    var result = store.get_instruments(ids.copy())
    assert_equal(len(result), 2)


def test_get_instruments_duplicate_ids() raises:
    """Duplicate lookup keys do not produce duplicate results (Set dedup)."""
    var instruments = List[Instrument]()
    instruments.append(_make_stock("000001.XSHE", "平安银行"))
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)

    var ids = List[String]()
    ids.append("000001.XSHE")
    ids.append("000001.XSHE")
    ids.append("平安银行")
    var result = store.get_instruments(ids.copy())
    assert_equal(len(result), 1)


def test_get_instruments_nonexistent_id() raises:
    """Looking up non-existent ID returns empty list."""
    var instruments = List[Instrument]()
    instruments.append(_make_stock("000001.XSHE", "平安银行"))
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)

    var ids = List[String]()
    ids.append("NONEXISTENT")
    var result = store.get_instruments(ids.copy())
    assert_equal(len(result), 0)


def test_get_instruments_empty_list() raises:
    """Passing empty list returns empty result."""
    var instruments = List[Instrument]()
    instruments.append(_make_stock("000001.XSHE", "平安银行"))
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)

    var ids = List[String]()
    var result = store.get_instruments(ids.copy())
    assert_equal(len(result), 0)


def test_get_instruments_partial_match() raises:
    """Only matching IDs are returned; non-matching are silently ignored."""
    var instruments = List[Instrument]()
    instruments.append(_make_stock("000001.XSHE", "平安银行"))
    instruments.append(_make_stock("600000.XSHG", "浦发银行"))
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)

    var ids = List[String]()
    ids.append("000001.XSHE")
    ids.append("NONEXISTENT")
    ids.append("浦发银行")
    var result = store.get_instruments(ids.copy())
    assert_equal(len(result), 2)


# ============================================================
# 5. Integration Tests: create_instrument_store factory
# ============================================================

def test_create_instrument_store_factory() raises:
    """Create instrument store correctly delegates to InstrumentStore."""
    var instruments = List[Instrument]()
    instruments.append(_make_stock("000001.XSHE", "平安银行"))
    var store = create_instrument_store(instruments, INSTRUMENT_TYPE.CS)
    assert_equal(store.instrument_type(), INSTRUMENT_TYPE.CS)
    assert_equal(len(store.get_instruments(None)), 1)


# ============================================================
# 6. Boundary / Edge Case Tests
# ============================================================

def test_single_instrument_store() raises:
    """Store with exactly one instrument."""
    var instruments = List[Instrument]()
    instruments.append(_make_stock("000001.XSHE", "AAPL"))
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)
    assert_equal(len(store.get_instruments(None)), 1)
    assert_equal(len(store.all_id_and_syms()), 2)


def test_all_instruments_filtered_out() raises:
    """All instruments filtered by type mismatch -> empty store."""
    var instruments = List[Instrument]()
    instruments.append(_make_stock("000001.XSHE", "平安银行"))
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.FUTURE)
    assert_equal(len(store.get_instruments(None)), 0)
    assert_equal(len(store.all_id_and_syms()), 0)


def test_many_instruments_stress() raises:
    """Store with many instruments (stress test for correctness)."""
    var instruments = List[Instrument]()
    for i in range(50):
        var obid = String(i) + ".XSHE"
        var sym = "STOCK_" + String(i)
        instruments.append(create_stock_instrument(
            order_book_id=obid,
            symbol=sym,
            listed_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
            exchange=EXCHANGE.XSHE
        ))
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)
    assert_equal(len(store.get_instruments(None)), 50)
    assert_equal(len(store.all_id_and_syms()), 100)

    var query = List[String]()
    query.append("0.XSHE")
    query.append("STOCK_49")
    var result = store.get_instruments(query.copy())
    assert_equal(len(result), 2)


def test_symbol_resolves_to_correct_order_book_id() raises:
    """Symbol lookup resolves to the correct instrument when multiple exist."""
    var instruments = List[Instrument]()
    instruments.append(_make_stock("000001.XSHE", "平安银行"))
    instruments.append(_make_stock("000002.XSHE", "万科A"))
    var store = InstrumentStore(instruments=instruments, instrument_type=INSTRUMENT_TYPE.CS)

    var ids = List[String]()
    ids.append("万科A")
    var result = store.get_instruments(ids.copy())
    assert_equal(len(result), 1)
    assert_equal(result[0].order_book_id(), "000002.XSHE")


# ============================================================
# Main entry point - standard testing framework
# ============================================================

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
