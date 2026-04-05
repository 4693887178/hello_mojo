"""
Comprehensive Python Test Suite for rqalpha/data/base_data_source/deprecated.py
Mirrors the Mojo test suite for cross-validation
"""

import pytest
from rqalpha.const import INSTRUMENT_TYPE, EXCHANGE, MARKET
from rqalpha.model.instrument import Instrument
from rqalpha.data.base_data_source.deprecated import (
    AbstractInstrumentStore,
    InstrumentStore,
)


def _make_stock(order_book_id, symbol):
    return Instrument({
        "order_book_id": order_book_id,
        "symbol": symbol,
        "type": "CS",
        "listed_date": "2020-01-01",
        "de_listed_date": "2999-12-31",
        "exchange": "XSHE",
        "round_lot": 100,
        "status": "Active",
        "special_type": "Normal",
    })


def _make_future(order_book_id, symbol):
    return Instrument({
        "order_book_id": order_book_id,
        "symbol": symbol,
        "type": "Future",
        "listed_date": "2020-01-01",
        "de_listed_date": "2025-06-15",
        "maturity_date": "2025-06-01",
        "exchange": "SHFE",
        "round_lot": 1,
        "contract_multiplier": 10.0,
        "status": "Active",
        "special_type": "Normal",
    })


# ============================================================
# InstrumentStore - Construction Tests
# ============================================================

class TestInstrumentStoreConstruction:
    def test_empty_instruments(self):
        store = InstrumentStore([], INSTRUMENT_TYPE.CS)
        assert store.instrument_type == INSTRUMENT_TYPE.CS
        assert list(store.all_id_and_syms) == []
        assert list(store.get_instruments(None)) == []

    def test_filters_by_type(self):
        instruments = [_make_stock("000001.XSHE", "平安银行"), _make_future("RB2501", "螺纹钢2501")]
        store = InstrumentStore(instruments, INSTRUMENT_TYPE.CS)
        assert len(list(store.all_id_and_syms)) == 2
        assert len(list(store.get_instruments(None))) == 1

    def test_type_property(self):
        store_cs = InstrumentStore([], INSTRUMENT_TYPE.CS)
        store_fut = InstrumentStore([], INSTRUMENT_TYPE.FUTURE)
        assert store_cs.instrument_type == INSTRUMENT_TYPE.CS
        assert store_fut.instrument_type == INSTRUMENT_TYPE.FUTURE


# ============================================================
# all_id_and_syms Tests
# ============================================================

class TestAllIdAndSyms:
    def test_returns_both_keys(self):
        instruments = [
            _make_stock("000001.XSHE", "平安银行"),
            _make_stock("600000.XSHG", "浦发银行"),
        ]
        store = InstrumentStore(instruments, INSTRUMENT_TYPE.CS)
        ids = list(store.all_id_and_syms)
        assert len(ids) == 4

    def test_empty_store(self):
        store = InstrumentStore([], INSTRUMENT_TYPE.CS)
        assert list(store.all_id_and_syms) == []


# ============================================================
# get_instruments(None) Tests
# ============================================================

class TestGetInstrumentsNone:
    def test_returns_all(self):
        instruments = [
            _make_stock("000001.XSHE", "平安银行"),
            _make_stock("600000.XSHG", "浦发银行"),
        ]
        store = InstrumentStore(instruments, INSTRUMENT_TYPE.CS)
        result = list(store.get_instruments(None))
        assert len(result) == 2

    def test_empty_store(self):
        store = InstrumentStore([], INSTRUMENT_TYPE.CS)
        assert list(store.get_instruments(None)) == []


# ============================================================
# get_instruments with IDs Tests
# ============================================================

class TestGetInstrumentsWithIds:
    def test_by_order_book_id(self):
        instruments = [
            _make_stock("000001.XSHE", "平安银行"),
            _make_stock("600000.XSHG", "浦发银行"),
        ]
        store = InstrumentStore(instruments, INSTRUMENT_TYPE.CS)
        result = list(store.get_instruments(["000001.XSHE"]))
        assert len(result) == 1
        assert result[0].order_book_id == "000001.XSHE"

    def test_by_symbol(self):
        instruments = [
            _make_stock("000001.XSHE", "平安银行"),
            _make_stock("600000.XSHG", "浦发银行"),
        ]
        store = InstrumentStore(instruments, INSTRUMENT_TYPE.CS)
        result = list(store.get_instruments(["平安银行"]))
        assert len(result) == 1
        assert result[0].symbol == "平安银行"

    def test_mixed_lookup(self):
        instruments = [
            _make_stock("000001.XSHE", "平安银行"),
            _make_stock("600000.XSHG", "浦发银行"),
        ]
        store = InstrumentStore(instruments, INSTRUMENT_TYPE.CS)
        result = list(store.get_instruments(["000001.XSHE", "浦发银行"]))
        assert len(result) == 2

    def test_nonexistent_id(self):
        instruments = [_make_stock("000001.XSHE", "平安银行")]
        store = InstrumentStore(instruments, INSTRUMENT_TYPE.CS)
        result = list(store.get_instruments(["NONEXISTENT"]))
        assert result == []

    def test_partial_match(self):
        instruments = [
            _make_stock("000001.XSHE", "平安银行"),
            _make_stock("600000.XSHG", "浦发银行"),
        ]
        store = InstrumentStore(instruments, INSTRUMENT_TYPE.CS)
        result = list(store.get_instruments(["000001.XSHE", "NONEXISTENT", "浦发银行"]))
        assert len(result) == 2

    def test_empty_list(self):
        instruments = [_make_stock("000001.XSHE", "平安银行")]
        store = InstrumentStore(instruments, INSTRUMENT_TYPE.CS)
        result = list(store.get_instruments([]))
        assert result == []


# ============================================================
# Boundary / Edge Case Tests
# ============================================================

class TestBoundaryConditions:
    def test_single_instrument(self):
        instruments = [_make_stock("000001.XSHE", "AAPL")]
        store = InstrumentStore(instruments, INSTRUMENT_TYPE.CS)
        assert len(list(store.get_instruments(None))) == 1
        assert len(list(store.all_id_and_syms)) == 2

    def test_all_filtered_out(self):
        instruments = [_make_stock("000001.XSHE", "平安银行")]
        store = InstrumentStore(instruments, INSTRUMENT_TYPE.FUTURE)
        assert list(store.get_instruments(None)) == []
        assert list(store.all_id_and_syms) == []

    def test_many_instruments_stress(self):
        instruments = [
            Instrument({
                "order_book_id": f"{i}.XSHE",
                "symbol": f"STOCK_{i}",
                "type": "CS",
                "listed_date": "2020-01-01",
                "de_listed_date": "2999-12-31",
                "exchange": "XSHE",
                "round_lot": 100,
                "status": "Active",
                "special_type": "Normal",
            })
            for i in range(50)
        ]
        store = InstrumentStore(instruments, INSTRUMENT_TYPE.CS)
        assert len(list(store.get_instruments(None))) == 50
        assert len(list(store.all_id_and_syms)) == 100
        result = list(store.get_instruments(["0.XSHE", "STOCK_49"]))
        assert len(result) == 2

    def test_symbol_resolves_to_correct_obid(self):
        instruments = [
            _make_stock("000001.XSHE", "平安银行"),
            _make_stock("000002.XSHE", "万科A"),
        ]
        store = InstrumentStore(instruments, INSTRUMENT_TYPE.CS)
        result = list(store.get_instruments(["万科A"]))
        assert len(result) == 1
        assert result[0].order_book_id == "000002.XSHE"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
