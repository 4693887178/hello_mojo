"""
Mojo Test for data/base_data_source/__init__.mojo
Tests the base data source module exports
TDD: Write tests first, then verify implementation
"""

from rqmojo.data.base_data_source import BaseDataSource, FuturesTradingParameters, ExchangeRate, create_base_data_source
from rqmojo.utils.datetime_func import DateTime, Date
from rqmojo.const import MARKET


def test_base_data_source_creation():
    var ds = create_base_data_source()
    print("BaseDataSource created successfully")
    assert ds._initialized == False


def test_base_data_source_load_bundle():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    print("Bundle loaded")
    assert ds._initialized == True


def test_base_data_source_get_instrument():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    
    var ins = ds.get_instrument("000001.XSHE")
    print("Instrument: " + ins.order_book_id)
    assert ins.order_book_id == "000001.XSHE"


def test_base_data_source_get_all_instruments():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    
    var instruments = ds.get_all_instruments()
    print("Instruments count: " + String(len(instruments)))
    assert len(instruments) > 0


def test_base_data_source_get_bar():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    
    var dt = DateTime(2024, 1, 15, 10, 0, 0, 0)
    var bar = ds.get_bar("000001.XSHE", dt)
    print("Bar close: " + String(bar.close))
    assert bar.close > 0


def test_base_data_source_history_bars():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    
    var dt = DateTime(2024, 1, 15, 10, 0, 0, 0)
    var bars = ds.history_bars("000001.XSHE", 5, dt)
    print("History bars count: " + String(len(bars)))
    assert len(bars) == 5


def test_base_data_source_get_tick():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    
    var dt = DateTime(2024, 1, 15, 10, 0, 0, 0)
    var tick = ds.get_tick("000001.XSHE", dt)
    print("Tick last: " + String(tick.last))
    assert tick.last > 0


def test_base_data_source_get_trading_dates():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    
    var start = Date(2019, 11, 1)
    var end = Date(2019, 11, 30)
    var dates = ds.get_trading_dates(start, end)
    print("Trading dates count: " + String(len(dates)))
    assert len(dates) > 0


def test_base_data_source_is_trading_date():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    
    var is_trading = ds.is_trading_date(2019, 11, 15)
    print("Is trading date 2019-11-15: " + String(is_trading))
    assert True


def test_base_data_source_get_previous_trading_date():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    
    var prev = ds.get_previous_trading_date(2019, 11, 20)
    print("Previous trading date: " + prev.__str__())
    assert True


def test_base_data_source_get_next_trading_date():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    
    var next = ds.get_next_trading_date(2019, 11, 20)
    print("Next trading date: " + next.__str__())
    assert True


def test_base_data_source_is_suspended():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    
    var dt = DateTime(2024, 1, 15, 0, 0, 0, 0)
    var suspended = ds.is_suspended("000001.XSHE", dt)
    print("Is suspended: " + String(suspended))
    assert suspended == False


def test_base_data_source_get_dividend():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    
    var dividend = ds.get_dividend("000001.XSHE")
    print("Dividend: " + String(dividend))
    assert dividend == 0.0


def test_base_data_source_get_split():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    
    var split = ds.get_split("000001.XSHE")
    print("Split: " + String(split))
    assert split == 1.0


def test_base_data_source_get_ex_cum_factor():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    
    var factor = ds.get_ex_cum_factor("000001.XSHE")
    print("Ex cum factor: " + String(factor))
    assert factor == 1.0


def test_futures_trading_parameters():
    var params = FuturesTradingParameters(long_margin_ratio=0.1, short_margin_ratio=0.1)
    print("FuturesTradingParameters: " + params.__str__())
    assert params.long_margin_ratio == 0.1
    assert params.short_margin_ratio == 0.1


def test_exchange_rate():
    var rate = ExchangeRate(
        bid_reference=1.0,
        ask_reference=1.0,
        bid_settlement_sh=1.0,
        ask_settlement_sh=1.0,
        bid_settlement_sz=1.0,
        ask_settlement_sz=1.0
    )
    print("ExchangeRate: " + rate.__str__())
    assert rate.bid_reference == 1.0


def test_base_data_source_get_futures_trading_parameters():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    
    var dt = DateTime(2024, 1, 15, 0, 0, 0, 0)
    var params = ds.get_futures_trading_parameters("IF2312", dt)
    print("Futures params: " + params.__str__())
    assert params.long_margin_ratio >= 0


def test_base_data_source_get_exchange_rate():
    var ds = create_base_data_source()
    ds.load_bundle("/path/to/bundle")
    
    var dt = Date(2024, 1, 15)
    var rate = ds.get_exchange_rate(dt, MARKET.CN, MARKET.CN)
    print("Exchange rate: " + rate.__str__())
    assert rate.bid_reference > 0


def main():
    print("=== Testing data/base_data_source/__init__ ===")
    test_base_data_source_creation()
    test_base_data_source_load_bundle()
    test_base_data_source_get_instrument()
    test_base_data_source_get_all_instruments()
    test_base_data_source_get_bar()
    test_base_data_source_history_bars()
    test_base_data_source_get_tick()
    test_base_data_source_get_trading_dates()
    test_base_data_source_is_trading_date()
    test_base_data_source_get_previous_trading_date()
    test_base_data_source_get_next_trading_date()
    test_base_data_source_is_suspended()
    test_base_data_source_get_dividend()
    test_base_data_source_get_split()
    test_base_data_source_get_ex_cum_factor()
    test_futures_trading_parameters()
    test_exchange_rate()
    test_base_data_source_get_futures_trading_parameters()
    print("All base_data_source tests passed!")
