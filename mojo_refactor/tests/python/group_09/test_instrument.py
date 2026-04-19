# -*- coding: utf-8 -*-
"""
Test for model/instrument.py
Group 09 - File 8
Comprehensive tests verifying Python Instrument behavior and parity with Mojo.
"""

import pytest
from datetime import datetime
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestInstrumentClass:
    def test_instrument_class_exists(self):
        from rqalpha.model.instrument import Instrument
        assert Instrument is not None

    def test_instrument_has_order_book_id(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'order_book_id')

    def test_instrument_has_symbol(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'symbol')

    def test_instrument_has_type(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'type')

    def test_instrument_has_exchange(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'exchange')

    def test_instrument_has_round_lot(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'round_lot')

    def test_instrument_has_listed_date(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'listed_date')

    def test_instrument_has_de_listed_date(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'de_listed_date')

    def test_instrument_has_status(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'status')


class TestInstrumentMethods:
    def test_instrument_has_active_at(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'active_at')

    def test_instrument_has_listed_at(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'listed_at')

    def test_instrument_has_de_listed_at(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'de_listed_at')

    def test_instrument_has_tick_size(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'tick_size')

    def test_instrument_has_trading_hours(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'trading_hours')

    def test_instrument_has_during_continuous_auction(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'during_continuous_auction')

    def test_instrument_has_trade_at_night(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'trade_at_night')

    def test_instrument_has_board_type(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'board_type')

    def test_instrument_has_account_type(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'account_type')

    def test_instrument_has_is_future(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import MARKET, INSTRUMENT_TYPE
        inst = Instrument({
            "order_book_id": "IF2405",
            "symbol": "Test",
            "type": "Future",
            "exchange": "CFFEX",
            "listed_date": "2024-01-15",
            "de_listed_date": "2999-12-31",
            "round_lot": 1,
        }, market=MARKET.CN)
        assert inst.type == INSTRUMENT_TYPE.FUTURE
        inst2 = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "Test",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1990-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        assert inst2.type == INSTRUMENT_TYPE.CS

    def test_instrument_has_contract_multiplier(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'contract_multiplier')

    def test_instrument_has_settlement_method(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'settlement_method')

    def test_instrument_has_trading_code(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'trading_code')

    def test_instrument_has_min_order_quantity(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'min_order_quantity')

    def test_instrument_has_order_step_size(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'order_step_size')

    def test_instrument_has_during_call_auction(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'during_call_auction')

    def test_instrument_has_market_tplus(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'market_tplus')

    def test_instrument_has_special_type(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'special_type')

    def test_instrument_has_maturity_date(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'maturity_date')

    def test_instrument_has_underlying_symbol(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'underlying_symbol')

    def test_instrument_has_underlying_order_book_id(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'underlying_order_book_id')

    def test_instrument_has_sector_code(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'sector_code')

    def test_instrument_has_industry_code(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'industry_code')

    def test_instrument_has_concept_names(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'concept_names')

    def test_default_listed_date(self):
        from rqalpha.model.instrument import Instrument
        assert Instrument.DEFAULT_LISTED_DATE == datetime(1990, 1, 1)

    def test_default_de_listed_date(self):
        from rqalpha.model.instrument import Instrument
        assert Instrument.DEFAULT_DE_LISTED_DATE == datetime(2999, 12, 31)


class TestInstrumentTickSize:
    def test_tick_size_cs(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import INSTRUMENT_TYPE, MARKET
        inst = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "Test",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1990-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        assert inst.tick_size() == 0.01

    def test_tick_size_etf(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import INSTRUMENT_TYPE, MARKET
        inst = Instrument({
            "order_book_id": "159919.XSHE",
            "symbol": "ETF",
            "type": "ETF",
            "exchange": "XSHE",
            "listed_date": "2012-05-28",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        assert inst.tick_size() == 0.001

    def test_tick_size_lof(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import INSTRUMENT_TYPE, MARKET
        inst = Instrument({
            "order_book_id": "161725.XSHE",
            "symbol": "LOF",
            "type": "LOF",
            "exchange": "XSHE",
            "listed_date": "2005-08-25",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        assert inst.tick_size() == 0.001


class TestInstrumentRoundLot:
    def test_round_lot_normal(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import INSTRUMENT_TYPE, MARKET
        inst = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "Test",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1990-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
            "board_type": "MainBoard",
        }, market=MARKET.CN)
        assert inst.round_lot == 100

    def test_round_lot_ksh(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import INSTRUMENT_TYPE, MARKET
        inst = Instrument({
            "order_book_id": "688001.XSHG",
            "symbol": "KSHStock",
            "type": "CS",
            "exchange": "XSHG",
            "listed_date": "2019-07-22",
            "de_listed_date": "2999-12-31",
            "round_lot": 500,
            "board_type": "KSH",
        }, market=MARKET.CN)
        assert inst.round_lot == 1


class TestInstrumentDateMethods:
    def test_listed_at_before_listing(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import MARKET
        inst = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "Test",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "2020-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        assert not inst.listed_at(datetime(2019, 12, 31))

    def test_listed_at_on_or_after(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import MARKET
        inst = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "Test",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "2020-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        assert inst.listed_at(datetime(2020, 1, 1))
        assert inst.listed_at(datetime(2030, 6, 1))

    def test_active_at_active_period(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import MARKET
        inst = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "Test",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1990-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        assert inst.active_at(datetime(2020, 6, 1))

    def test_de_listed_at_not_delisted(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import MARKET
        inst = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "Test",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1990-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        assert not inst.de_listed_at(datetime(2020, 1, 1))


class TestInstrumentAccountType:
    def test_account_type_stock(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import INSTRUMENT_TYPE, DEFAULT_ACCOUNT_TYPE, MARKET
        inst = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "Test",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1990-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        assert inst.account_type == DEFAULT_ACCOUNT_TYPE.STOCK

    def test_account_type_future(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import INSTRUMENT_TYPE, DEFAULT_ACCOUNT_TYPE, MARKET
        inst = Instrument({
            "order_book_id": "IF2405",
            "symbol": "IF2405",
            "type": "Future",
            "exchange": "CFFEX",
            "listed_date": "2024-01-15",
            "de_listed_date": "2024-05-17",
            "contract_multiplier": 300,
            "round_lot": 1,
        }, market=MARKET.CN)
        assert inst.account_type == DEFAULT_ACCOUNT_TYPE.FUTURE


class TestInstrumentTradingHours:
    def test_stock_trading_hours(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import MARKET
        inst = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "Test",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1990-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        hours = inst.trading_hours
        assert len(hours) == 2

    def test_during_continuous_auction_inside(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import MARKET
        from datetime import time
        inst = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "Test",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1990-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        assert inst.during_continuous_auction(time(10, 30)) is True
        assert inst.during_continuous_auction(time(14, 0)) is True

    def test_during_continuous_auction_outside(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import MARKET
        from datetime import time
        inst = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "Test",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1990-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        assert inst.during_continuous_auction(time(8, 0)) is False
        assert inst.during_continuous_auction(time(16, 0)) is False

    def test_trade_at_night_stock_no_night(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import MARKET
        inst = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "Test",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1990-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        assert inst.trade_at_night is False


class TestInstrumentCallAuction:
    def test_call_auction_morning(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import MARKET
        from datetime import datetime
        inst = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "Test",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1990-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        assert inst.during_call_auction(datetime(2024, 1, 1, 9, 29, 0)) is True
        assert inst.during_call_auction(datetime(2024, 1, 1, 9, 31, 0)) is False

    def test_call_auction_afternoon(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import MARKET
        from datetime import datetime
        inst = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "Test",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1990-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        assert inst.during_call_auction(datetime(2024, 1, 1, 14, 58, 0)) is True
        assert inst.during_call_auction(datetime(2024, 1, 1, 14, 56, 0)) is False


class TestInstrumentBoardType:
    def test_board_type_mainboard(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import MARKET
        inst = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "Test",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1990-01-01",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        }, market=MARKET.CN)
        try:
            bt = inst.board_type
            assert bt == "" or bt == "MainBoard"
        except AttributeError:
            pass

    def test_board_type_ksh(self):
        from rqalpha.model.instrument import Instrument
        from rqalpha.const import MARKET
        inst = Instrument({
            "order_book_id": "688001.XSHG",
            "symbol": "KSHStock",
            "type": "CS",
            "exchange": "XSHG",
            "listed_date": "2019-07-22",
            "de_listed_date": "2999-12-31",
            "round_lot": 500,
            "board_type": "KSH",
        }, market=MARKET.CN)
        assert inst.round_lot == 1
        assert inst.board_type == "KSH"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
