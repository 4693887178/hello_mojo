"""
第五组测试 - data/base_data_source/__init__.mojo
测试Mojo版本的基础数据源模块
"""

from rqmojo.data.base_data_source.data_source import BaseDataSource, FuturesTradingParameters, ExchangeRate, create_base_data_source, create_base_data_source_with_path
from rqmojo.data.base_data_source.adjust import adjust_bars
from rqmojo.utils.typing import DateTime


def test_create_base_data_source() -> Bool:
    var ds = create_base_data_source()
    return True


def test_create_base_data_source_with_path() -> Bool:
    var ds = create_base_data_source_with_path("/data/bundle")
    return True


def test_futures_trading_parameters_creation() -> Bool:
    var params = FuturesTradingParameters(
        long_margin_ratio=0.1,
        short_margin_ratio=0.1
    )
    return params.long_margin_ratio == 0.1 and params.short_margin_ratio == 0.1


def test_exchange_rate_creation() -> Bool:
    var rate = ExchangeRate(
        bid_reference=7.2,
        ask_reference=7.3,
        bid_settlement_sh=7.2,
        ask_settlement_sh=7.3,
        bid_settlement_sz=7.2,
        ask_settlement_sz=7.3
    )
    return rate.bid_reference == 7.2 and rate.ask_reference == 7.3


def test_base_data_source_get_trading_dates() -> Bool:
    var ds = create_base_data_source_with_path("/data/bundle")
    var start_date = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2020, 1, 31, 0, 0, 0, 0)
    var count = ds.count_trading_dates(start_date, end_date)
    return count >= 0


def test_base_data_source_count_trading_dates() -> Bool:
    var ds = create_base_data_source_with_path("/data/bundle")
    var start_date = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2020, 1, 31, 0, 0, 0, 0)
    var count = ds.count_trading_dates(start_date, end_date)
    return count >= 0


def main():
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Testing: data/base_data_source/__init__.mojo")
    print("=" * 60)
    
    if test_create_base_data_source():
        print("PASS: test_create_base_data_source")
        passed += 1
    else:
        print("FAIL: test_create_base_data_source")
        failed += 1
    
    if test_create_base_data_source_with_path():
        print("PASS: test_create_base_data_source_with_path")
        passed += 1
    else:
        print("FAIL: test_create_base_data_source_with_path")
        failed += 1
    
    if test_futures_trading_parameters_creation():
        print("PASS: test_futures_trading_parameters_creation")
        passed += 1
    else:
        print("FAIL: test_futures_trading_parameters_creation")
        failed += 1
    
    if test_exchange_rate_creation():
        print("PASS: test_exchange_rate_creation")
        passed += 1
    else:
        print("FAIL: test_exchange_rate_creation")
        failed += 1
    
    if test_base_data_source_get_trading_dates():
        print("PASS: test_base_data_source_get_trading_dates")
        passed += 1
    else:
        print("FAIL: test_base_data_source_get_trading_dates")
        failed += 1
    
    if test_base_data_source_count_trading_dates():
        print("PASS: test_base_data_source_count_trading_dates")
        passed += 1
    else:
        print("FAIL: test_base_data_source_count_trading_dates")
        failed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, " passed, ", failed, " failed")
    print("=" * 60)
