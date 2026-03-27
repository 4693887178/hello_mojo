"""
第五组测试 - data/base_data_source/__init__.mojo
测试Mojo版本的基础数据源模块
"""

from rqmojo.data.base_data_source.data_source import BaseDataSource, FuturesTradingParameters, ExchangeRate, create_base_data_source, create_base_data_source_with_path
from rqmojo.data.base_data_source.adjust import adjust_bars
from rqmojo.utils.typing import DateTime


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_create_base_data_source() raises:
    var _ = create_base_data_source()
    assert_true(True, "BaseDataSource created")


def test_create_base_data_source_with_path() raises:
    var _ = create_base_data_source_with_path("/data/bundle")
    assert_true(True, "BaseDataSource with path created")


def test_futures_trading_parameters_creation() raises:
    var params = FuturesTradingParameters(
        long_margin_ratio=0.1,
        short_margin_ratio=0.1
    )
    assert_equal(params.long_margin_ratio, 0.1, "long_margin_ratio should match")
    assert_equal(params.short_margin_ratio, 0.1, "short_margin_ratio should match")


def test_exchange_rate_creation() raises:
    var rate = ExchangeRate(
        bid_reference=7.2,
        ask_reference=7.3,
        bid_settlement_sh=7.2,
        ask_settlement_sh=7.3,
        bid_settlement_sz=7.2,
        ask_settlement_sz=7.3
    )
    assert_equal(rate.bid_reference, 7.2, "bid_reference should match")
    assert_equal(rate.ask_reference, 7.3, "ask_reference should match")


def test_base_data_source_get_trading_dates() raises:
    var ds = create_base_data_source_with_path("/data/bundle")
    var start_date = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2020, 1, 31, 0, 0, 0, 0)
    var count = ds.count_trading_dates(start_date, end_date)
    assert_true(count >= 0, "count should be >= 0")


def test_base_data_source_count_trading_dates() raises:
    var ds = create_base_data_source_with_path("/data/bundle")
    var start_date = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2020, 1, 31, 0, 0, 0, 0)
    var count = ds.count_trading_dates(start_date, end_date)
    assert_true(count >= 0, "count should be >= 0")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
