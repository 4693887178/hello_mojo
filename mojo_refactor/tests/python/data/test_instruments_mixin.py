"""
Python integration test for instruments_mixin.mojo
Compares Python rqalpha behavior with the Mojo refactored version.

This test verifies that the Mojo implementation matches the Python original
by testing the same scenarios in both languages and comparing results.
"""

import pytest
from datetime import datetime

from rqalpha.data.instruments_mixin import InstrumentsMixin
from rqalpha.interface import AbstractDataSource
from rqalpha.model.instrument import Instrument
from rqalpha.const import INSTRUMENT_TYPE


class MockDataSource(AbstractDataSource):
    """Mock data source for testing, mimicking the Mojo test data."""

    def __init__(self):
        self._instruments = []
        self._id_map = {}
        self._sym_map = {}

        # Stock instruments
        ins1 = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        ins2 = Instrument({
            "order_book_id": "600000.XSHG",
            "symbol": "浦发银行",
            "type": "CS",
            "exchange": "XSHG",
            "listed_date": "1999-11-10",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        # Future instruments
        ins3 = Instrument({
            "order_book_id": "RB1912",
            "symbol": "螺纹钢1912",
            "type": "Future",
            "exchange": "SHFE",
            "listed_date": "2019-01-01",
            "de_listed_date": "2019-12-15",
            "maturity_date": "2019-12-15",
            "contract_multiplier": 10.0,
            "underlying_symbol": "RB",
        })
        ins4 = Instrument({
            "order_book_id": "AG1912",
            "symbol": "白银1912",
            "type": "Future",
            "exchange": "SHFE",
            "listed_date": "2019-01-01",
            "de_listed_date": "2019-12-15",
            "maturity_date": "2019-12-15",
            "contract_multiplier": 15.0,
            "underlying_symbol": "AG",
        })
        ins5 = Instrument({
            "order_book_id": "TF1912",
            "symbol": "五年期国债1912",
            "type": "Future",
            "exchange": "CFFEX",
            "listed_date": "2019-01-01",
            "de_listed_date": "2019-12-15",
            "maturity_date": "2019-12-15",
            "contract_multiplier": 10000.0,
            "underlying_symbol": "TF",
        })

        self._instruments = [ins1, ins2, ins3, ins4, ins5]
        for ins in self._instruments:
            self._id_map[ins.order_book_id] = ins
            self._sym_map[ins.symbol] = ins

    def get_instruments(self, id_or_syms=None, types=None):
        if id_or_syms is not None:
            result = []
            for i in id_or_syms:
                if i in self._id_map:
                    result.append(self._id_map[i])
                if i in self._sym_map and self._sym_map[i] not in result:
                    result.append(self._sym_map[i])
            return result
        if types is not None:
            return [ins for ins in self._instruments if ins.type in types]
        return self._instruments

    # Required abstract methods (stubs)
    def get_trading_calendars(self):
        return {}

    def get_yield_curve(self, start_date, end_date, tenor=None):
        return None

    def get_dividend(self, instrument):
        return None

    def get_split(self, instrument):
        return None

    def get_bar(self, instrument, dt, frequency):
        return None

    def get_open_auction_bar(self, instrument, dt):
        return None

    def get_open_auction_volume(self, instrument, dt):
        return None

    def get_settle_price(self, instrument, date):
        return None

    def history_bars(self, instrument, bar_count, frequency, fields, dt, skip_suspended, include_now, adjust_type, adjust_orig):
        return None

    def history_ticks(self, instrument, count, dt):
        return []

    def current_snapshot(self, instrument, frequency, dt):
        return None

    def get_trading_minutes_for(self, instrument, trading_dt):
        return []

    def available_data_range(self, frequency):
        return datetime(2000, 1, 1), datetime(2020, 12, 31)

    def get_futures_trading_parameters(self, instrument, dt):
        return None

    def get_merge_ticks(self, order_book_id_list, trading_date, last_dt):
        return []

    def get_share_transformation(self, order_book_id):
        return None

    def is_suspended(self, order_book_id, dates):
        return [False] * len(dates)

    def is_st_stock(self, order_book_id, dates):
        return [False] * len(dates)

    def get_algo_bar(self, id_or_ins, start_min, end_min, dt):
        return None

    def get_exchange_rate(self, trading_date, local, settlement):
        return 1.0


@pytest.fixture
def mixin():
    return InstrumentsMixin(MockDataSource())


class TestInstrumentsMixinPython:
    """Python tests that mirror the Mojo test suite."""

    def test_get_active_instrument_found(self, mixin):
        dt = datetime(2019, 6, 1)
        ins = mixin.get_active_instrument("000001.XSHE", dt)
        assert ins.order_book_id == "000001.XSHE"

    def test_get_active_instrument_future_active(self, mixin):
        dt = datetime(2019, 6, 1)
        ins = mixin.get_active_instrument("RB1912", dt)
        assert ins.order_book_id == "RB1912"

    def test_get_active_instrument_not_found(self, mixin):
        from rqalpha.utils.exception import InstrumentNotFound
        dt = datetime(2019, 6, 1)
        with pytest.raises(InstrumentNotFound):
            mixin.get_active_instrument("NONEXIST", dt)

    def test_get_active_instrument_future_delisted(self, mixin):
        from rqalpha.utils.exception import InstrumentNotFound
        dt = datetime(2020, 1, 1)
        with pytest.raises(InstrumentNotFound):
            mixin.get_active_instrument("RB1912", dt)

    def test_get_active_instrument_before_listing(self, mixin):
        from rqalpha.utils.exception import InstrumentNotFound
        dt = datetime(2018, 1, 1)
        with pytest.raises(InstrumentNotFound):
            mixin.get_active_instrument("RB1912", dt)

    def test_get_instrument_history_basic(self, mixin):
        result = mixin.get_instrument_history("000001.XSHE")
        assert len(result) == 1
        assert result[0].order_book_id == "000001.XSHE"

    def test_get_instrument_history_with_listed_at_filter(self, mixin):
        dt_before = datetime(1990, 1, 1)
        result = mixin.get_instrument_history("000001.XSHE", listed_at=dt_before)
        assert len(result) == 0

        dt_after = datetime(2000, 1, 1)
        result2 = mixin.get_instrument_history("000001.XSHE", listed_at=dt_after)
        assert len(result2) == 1

    def test_get_active_instruments(self, mixin):
        dt = datetime(2019, 6, 1)
        result = mixin.get_active_instruments(["000001.XSHE", "RB1912"], dt)
        assert len(result) == 2
        assert "000001.XSHE" in result
        assert "RB1912" in result

    def test_get_active_instruments_partial_active(self, mixin):
        dt = datetime(2020, 6, 1)
        result = mixin.get_active_instruments(["000001.XSHE", "RB1912"], dt)
        assert len(result) == 1
        assert "000001.XSHE" in result
        assert "RB1912" not in result

    def test_get_all_instruments_by_type(self, mixin):
        result = mixin.get_all_instruments([INSTRUMENT_TYPE.CS])
        assert len(result) == 2

    def test_get_all_instruments_future_type(self, mixin):
        result = mixin.get_all_instruments([INSTRUMENT_TYPE.FUTURE])
        assert len(result) == 3

    def test_get_all_instruments_with_dt_filter(self, mixin):
        dt = datetime(2019, 6, 1)
        result = mixin.get_all_instruments([INSTRUMENT_TYPE.FUTURE], dt=dt)
        assert len(result) == 3

    def test_get_all_instruments_with_dt_filter_delisted(self, mixin):
        dt = datetime(2020, 6, 1)
        result = mixin.get_all_instruments([INSTRUMENT_TYPE.FUTURE], dt=dt)
        assert len(result) == 0

    def test_get_all_instruments_stock_always_active(self, mixin):
        dt = datetime(2020, 6, 1)
        result = mixin.get_all_instruments([INSTRUMENT_TYPE.CS], dt=dt)
        assert len(result) == 2

    def test_assure_order_book_id_found(self, mixin):
        obid = mixin.assure_order_book_id("000001.XSHE")
        assert obid == "000001.XSHE"

    def test_assure_order_book_id_with_expected_type(self, mixin):
        obid = mixin.assure_order_book_id("000001.XSHE", expected_type=INSTRUMENT_TYPE.CS)
        assert obid == "000001.XSHE"

    def test_assure_order_book_id_wrong_type(self, mixin):
        from rqalpha.utils.exception import InstrumentNotFound
        with pytest.raises(InstrumentNotFound):
            mixin.assure_order_book_id("000001.XSHE", expected_type=INSTRUMENT_TYPE.FUTURE)

    def test_assure_order_book_id_not_found(self, mixin):
        from rqalpha.utils.exception import InstrumentNotFound
        with pytest.raises(InstrumentNotFound):
            mixin.assure_order_book_id("NONEXIST")

    def test_instrument_not_none_found(self, mixin):
        ins = mixin.instrument_not_none("000001.XSHE")
        assert ins.order_book_id == "000001.XSHE"

    def test_instrument_not_none_not_found(self, mixin):
        from rqalpha.utils.exception import InstrumentNotFound
        with pytest.raises(InstrumentNotFound):
            mixin.instrument_not_none("NONEXIST")

    def test_instrument_found(self, mixin):
        ins = mixin.instrument("000001.XSHE")
        assert ins is not None
        assert ins.order_book_id == "000001.XSHE"

    def test_instrument_not_found(self, mixin):
        ins = mixin.instrument("NONEXIST")
        assert ins is None

    def test_lookup_by_symbol(self, mixin):
        result = mixin.get_instrument_history("平安银行")
        assert len(result) == 1
        assert result[0].order_book_id == "000001.XSHE"
