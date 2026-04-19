"""
Comprehensive Unit Tests for mod/rqmojo_mod_sys_analyser/mod.mojo

Tests cover all public and private functionality matching Python original:
1. AnalyserMod creation and initialization
2. _parse_benchmark (string format, single/multiple, weights, edge cases)
3. _safe_convert (rounding, precision, edge cases)
4. _is_null_oid
5. collect_daily and calculate_summary
6. collect_account_daily
7. get_state / set_state serialization
8. Data structs (BenchmarkPortfolio, PortfolioRecord, AccountRecord, PositionRecord, TradeRecord, PressureTestPeriod)
9. Helper functions (_format_date, _format_datetime, _is_long_only_instrument, _parse_float_list_from_json)
10. Module-level functions (get_pressure_test_periods, get_null_oids, get_account_fields_map)
11. PerformanceMetrics and TradeSummary structs
12. Factory functions (create_analyser_mod, create_analyser_mod_with_params)
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Dict, List, Optional
from std.math import abs

from rqmojo.mod.rqmojo_mod_sys_analyser.mod import (
    AnalyserMod, BenchmarkPortfolio, PerformanceMetrics, TradeSummary,
    PortfolioRecord, AccountRecord, PositionRecord, TradeRecord,
    PressureTestPeriod,
    create_analyser_mod, create_analyser_mod_with_params,
    create_performance_metrics, create_trade_summary,
    get_pressure_test_periods, get_null_oids, get_account_fields_map,
    _format_date, _format_datetime, _is_long_only_instrument,
    _parse_float_list_from_json,
)
from rqmojo.const import EXIT_CODE, INSTRUMENT_TYPE, DEFAULT_ACCOUNT_TYPE
from rqmojo.utils.typing import DateTime
from rqmojo.data.data_proxy import create_data_proxy


def assert_close(actual: Float64, expected: Float64, tolerance: Float64, msg: String = "") raises:
    if abs(actual - expected) > tolerance:
        var full_msg = msg + ": expected " + String(expected) + " but got " + String(actual) + " (tolerance=" + String(tolerance) + ")"
        raise full_msg


# ============================================================
# Test Group 1: AnalyserMod Creation and Initialization
# ============================================================

def test_create_analyser_mod_defaults() raises:
    var mod = create_analyser_mod()
    assert_equal(mod.name, "analyser")
    assert_false(mod.enabled)
    assert_equal(len(mod._benchmark_daily_returns), 0)
    assert_equal(len(mod._total_benchmark_portfolios), 0)
    assert_equal(len(mod._orders), 0)
    assert_equal(len(mod._trades), 0)
    assert_equal(len(mod._total_portfolios), 0)
    assert_equal(len(mod._daily_pnl), 0)
    assert_equal(len(mod._portfolio_daily_returns), 0)
    assert_close(mod._initial_cash, 100000.0, 0.01)
    assert_equal(mod._trading_days_a_year, 252)


def test_create_analyser_mod_with_params() raises:
    var dp = create_data_proxy()
    var start = DateTime(2023, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2023, 12, 31, 0, 0, 0, 0)
    var mod = create_analyser_mod_with_params(dp^, start, end, 50000.0, "000001.XSHE")
    assert_equal(mod.name, "analyser")
    assert_close(mod._initial_cash, 50000.0, 0.01)
    assert_equal(mod._start_date.year, 2023)
    assert_equal(mod._end_date.year, 2023)


def test_create_analyser_mod_with_params_no_benchmark() raises:
    var dp = create_data_proxy()
    var start = DateTime(2023, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2023, 12, 31, 0, 0, 0, 0)
    var mod = create_analyser_mod_with_params(dp^, start, end, 100000.0)
    assert_equal(mod._benchmark_config, "")
    assert_true(mod._benchmark is None)


# ============================================================
# Test Group 2: _parse_benchmark
# ============================================================

def test_parse_benchmark_single_no_weight() raises:
    var mod = create_analyser_mod()
    var result = mod._parse_benchmark("000001.XSHE")
    assert_equal(len(result), 1)
    assert_equal(result[0][0], "000001.XSHE")
    assert_close(result[0][1], 1.0, 0.001)


def test_parse_benchmark_single_with_weight() raises:
    var mod = create_analyser_mod()
    var result = mod._parse_benchmark("000001.XSHE:0.5")
    assert_equal(len(result), 1)
    assert_equal(result[0][0], "000001.XSHE")
    assert_close(result[0][1], 0.5, 0.001)


def test_parse_benchmark_multiple() raises:
    var mod = create_analyser_mod()
    var result = mod._parse_benchmark("000001.XSHE:0.5,000905.XSHG:0.5")
    assert_equal(len(result), 2)
    assert_equal(result[0][0], "000001.XSHE")
    assert_close(result[0][1], 0.5, 0.001)
    assert_equal(result[1][0], "000905.XSHG")
    assert_close(result[1][1], 0.5, 0.001)


def test_parse_benchmark_null() raises:
    var mod = create_analyser_mod()
    var result = mod._parse_benchmark("null")
    assert_equal(len(result), 1)
    assert_equal(result[0][0], "null")
    assert_close(result[0][1], 1.0, 0.001)


def test_parse_benchmark_empty_string() raises:
    var mod = create_analyser_mod()
    var result = mod._parse_benchmark("")
    assert_equal(len(result), 0)


def test_parse_benchmark_unequal_weights() raises:
    var mod = create_analyser_mod()
    var result = mod._parse_benchmark("000001.XSHE:0.3,000905.XSHG:0.7")
    assert_equal(len(result), 2)
    assert_close(result[0][1], 0.3, 0.001)
    assert_close(result[1][1], 0.7, 0.001)


def test_parse_benchmark_multiple_no_weight() raises:
    var mod = create_analyser_mod()
    var result = mod._parse_benchmark("000001.XSHE,000905.XSHG")
    assert_equal(len(result), 2)
    assert_close(result[0][1], 1.0, 0.001)
    assert_close(result[1][1], 1.0, 0.001)


# ============================================================
# Test Group 3: _safe_convert
# ============================================================

def test_safe_convert_default_precision() raises:
    var result = AnalyserMod._safe_convert(3.14159265)
    assert_close(result, 3.1416, 0.0001)


def test_safe_convert_custom_precision() raises:
    var result = AnalyserMod._safe_convert(3.14159265, 2)
    assert_close(result, 3.14, 0.01)


def test_safe_convert_six_digits() raises:
    var result = AnalyserMod._safe_convert(3.14159265, 6)
    assert_close(result, 3.141593, 0.000001)


def test_safe_convert_zero() raises:
    var result = AnalyserMod._safe_convert(0.0)
    assert_close(result, 0.0, 0.0001)


def test_safe_convert_negative() raises:
    var result = AnalyserMod._safe_convert(-1.56789)
    assert_close(result, -1.5679, 0.0001)


def test_safe_convert_large_value() raises:
    var result = AnalyserMod._safe_convert(100000.123456)
    assert_close(result, 100000.1235, 0.001)


# ============================================================
# Test Group 4: _is_null_oid
# ============================================================

def test_is_null_oid_lowercase() raises:
    var mod = create_analyser_mod()
    assert_true(mod._is_null_oid("null"))


def test_is_null_oid_uppercase() raises:
    var mod = create_analyser_mod()
    assert_true(mod._is_null_oid("NULL"))


def test_is_null_oid_valid_oid() raises:
    var mod = create_analyser_mod()
    assert_false(mod._is_null_oid("000001.XSHE"))


# ============================================================
# Test Group 5: Format Functions
# ============================================================

def test_format_date_normal() raises:
    var dt = DateTime(2024, 3, 5, 14, 30, 0, 0)
    assert_equal(_format_date(dt), "2024-03-05")


def test_format_date_single_digit() raises:
    var dt = DateTime(2024, 1, 9, 0, 0, 0, 0)
    assert_equal(_format_date(dt), "2024-01-09")


def test_format_datetime_normal() raises:
    var dt = DateTime(2024, 3, 5, 14, 30, 45, 0)
    assert_equal(_format_datetime(dt), "2024-03-05 14:30:45")


def test_format_datetime_midnight() raises:
    var dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    assert_equal(_format_datetime(dt), "2024-01-01 00:00:00")


# ============================================================
# Test Group 6: _is_long_only_instrument
# ============================================================

def test_is_long_only_cs() raises:
    assert_true(_is_long_only_instrument(INSTRUMENT_TYPE.CS))


def test_is_long_only_etf() raises:
    assert_true(_is_long_only_instrument(INSTRUMENT_TYPE.ETF))


def test_is_long_only_bond() raises:
    assert_true(_is_long_only_instrument(INSTRUMENT_TYPE.BOND))


def test_is_long_only_convertible() raises:
    assert_true(_is_long_only_instrument(INSTRUMENT_TYPE.CONVERTIBLE))


def test_is_long_only_future_false() raises:
    assert_false(_is_long_only_instrument(INSTRUMENT_TYPE.FUTURE))


def test_is_long_only_option_false() raises:
    assert_false(_is_long_only_instrument(INSTRUMENT_TYPE.OPTION))


# ============================================================
# Test Group 7: _parse_float_list_from_json
# ============================================================

def test_parse_float_list_normal() raises:
    var json = "{\"test\":[1.0,2.5,3.14]}"
    var result = _parse_float_list_from_json(json, "test")
    assert_equal(len(result), 3)
    assert_close(result[0], 1.0, 0.001)
    assert_close(result[1], 2.5, 0.001)
    assert_close(result[2], 3.14, 0.01)


def test_parse_float_list_empty_array() raises:
    var json = "{\"test\":[]}"
    var result = _parse_float_list_from_json(json, "test")
    assert_equal(len(result), 0)


def test_parse_float_list_missing_key() raises:
    var json = "{\"other\":[1.0]}"
    var result = _parse_float_list_from_json(json, "test")
    assert_equal(len(result), 0)


def test_parse_float_list_negative_values() raises:
    var json = "{\"data\":[0.01,-0.005,0.008]}"
    var result = _parse_float_list_from_json(json, "data")
    assert_equal(len(result), 3)
    assert_close(result[1], -0.005, 0.0001)


# ============================================================
# Test Group 8: Module-Level Constants
# ============================================================

def test_pressure_test_periods() raises:
    var periods = get_pressure_test_periods()
    assert_equal(len(periods), 4)
    assert_equal(periods[0].title, "打击壳价值")
    assert_equal(periods[0].start_date, "2016-11-01")
    assert_equal(periods[0].end_date, "2018-02-01")
    assert_equal(periods[3].title, "小盘踩踏危机")


def test_null_oids() raises:
    var null_oids = get_null_oids()
    assert_equal(len(null_oids), 2)


def test_account_fields_map() raises:
    var fields_map = get_account_fields_map()
    assert_equal(len(fields_map), 3)
    assert_true(DEFAULT_ACCOUNT_TYPE.STOCK.value in fields_map)
    assert_true(DEFAULT_ACCOUNT_TYPE.FUTURE.value in fields_map)
    assert_true(DEFAULT_ACCOUNT_TYPE.BOND.value in fields_map)
    var future_fields = fields_map[DEFAULT_ACCOUNT_TYPE.FUTURE.value].copy()
    assert_equal(len(future_fields), 4)


# ============================================================
# Test Group 9: Data Structs
# ============================================================

def test_benchmark_portfolio() raises:
    var dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var bp = BenchmarkPortfolio(date=dt, unit_net_value=1.05, total_value=105000.0)
    assert_close(bp.unit_net_value, 1.05, 0.001)
    assert_close(bp.total_value, 105000.0, 1.0)


def test_portfolio_record() raises:
    var pr = PortfolioRecord(
        date="2024-01-01", cash=50000.0, total_value=100000.0,
        market_value=50000.0, unit_net_value=1.0, units=100000.0,
        static_unit_net_value=1.0
    )
    assert_equal(pr.date, "2024-01-01")
    assert_close(pr.cash, 50000.0, 0.1)


def test_account_record() raises:
    var ar = AccountRecord(
        date="2024-01-01", cash=50000.0, transaction_cost=100.0,
        market_value=50000.0, total_value=100000.0,
        position_pnl=0.0, trading_pnl=0.0, daily_pnl=0.0, margin=0.0
    )
    assert_equal(ar.date, "2024-01-01")
    assert_close(ar.transaction_cost, 100.0, 0.1)


def test_trade_record() raises:
    var tr = TradeRecord(
        datetime="2024-01-01 10:00:00", trading_datetime="2024-01-01 10:00:00",
        order_book_id="000001.XSHE", symbol="平安银行",
        side="BUY", position_effect="OPEN", exec_id="1",
        tax=5.0, commission=10.0, last_quantity=100, last_price=10.5,
        order_id=1, transaction_cost=15.0
    )
    assert_equal(tr.order_book_id, "000001.XSHE")
    assert_equal(tr.side, "BUY")
    assert_equal(tr.last_quantity, 100)


def test_performance_metrics() raises:
    var pm = create_performance_metrics()
    assert_close(pm.total_returns, 0.0, 0.001)
    assert_close(pm.sharpe_ratio, 0.0, 0.001)


def test_trade_summary() raises:
    var ts = create_trade_summary()
    assert_equal(ts.total_trades, 0)
    assert_equal(ts.winning_trades, 0)
    assert_equal(ts.losing_trades, 0)
    assert_close(ts.total_pnl, 0.0, 0.001)


def test_pressure_test_period_struct() raises:
    var ptp = PressureTestPeriod(title="test", start_date="2020-01-01", end_date="2020-12-31")
    assert_equal(ptp.title, "test")
    assert_equal(ptp.start_date, "2020-01-01")
    assert_equal(ptp.end_date, "2020-12-31")


# ============================================================
# Test Group 10: start_up and tear_down
# ============================================================

def test_start_up_enables_mod() raises:
    var mod = create_analyser_mod()
    assert_false(mod.enabled)
    mod.start_up("env", "config")
    assert_true(mod.enabled)


def test_tear_down_no_portfolios() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, None)
    assert_equal(len(mod._total_portfolios), 0)


def test_tear_down_non_success_exit() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")
    mod.tear_down(EXIT_CODE.EXIT_USER_ERROR, None)


# ============================================================
# Test Group 11: set_benchmark
# ============================================================

def test_set_benchmark_valid() raises:
    var mod = create_analyser_mod()
    mod.set_benchmark("000001.XSHE")
    assert_equal(mod._benchmark_config, "000001.XSHE")
    assert_true(mod._benchmark is not None)


def test_set_benchmark_empty() raises:
    var mod = create_analyser_mod()
    mod.set_benchmark("")
    assert_true(mod._benchmark is None)


# ============================================================
# Test Group 12: collect_daily and calculate_summary
# ============================================================

def test_collect_daily_and_summary() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")

    var dt1 = DateTime(2024, 1, 2, 15, 0, 0, 0)
    mod.collect_daily(dt1, dt1, 99000.0, 100000.0, 50000.0, 1.0, 100000.0, 1.0, 0.01, 1000.0)

    var dt2 = DateTime(2024, 1, 3, 15, 0, 0, 0)
    mod.collect_daily(dt2, dt2, 98500.0, 99500.0, 49500.0, 0.995, 100000.0, 0.995, -0.005, -500.0)

    assert_equal(len(mod._total_portfolios), 2)
    assert_equal(len(mod._portfolio_daily_returns), 2)
    assert_equal(len(mod._daily_pnl), 2)

    assert_close(mod._portfolio_daily_returns[0], 0.01, 0.001)
    assert_close(mod._portfolio_daily_returns[1], -0.005, 0.001)

    var summary = mod.calculate_summary()
    assert_true("total_returns" in summary)
    assert_true("annualized_returns" in summary)
    assert_true("max_drawdown" in summary)
    assert_true("sharpe" in summary)
    assert_true("win_rate" in summary)
    assert_true("profit_loss_rate" in summary)


def test_calculate_summary_empty() raises:
    var mod = create_analyser_mod()
    var summary = mod.calculate_summary()
    assert_equal(len(summary), 0)


def test_calculate_summary_all_positive() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")
    for i in range(10):
        var dt = DateTime(2024, 1, i + 1, 15, 0, 0, 0)
        mod.collect_daily(dt, dt, 100000.0, 100000.0, 50000.0, 1.0, 100000.0, 1.0, 0.01, 100.0)

    var summary = mod.calculate_summary()
    assert_true(summary["total_returns"] > 0)
    assert_true(summary["win_rate"] > 0)


def test_calculate_summary_with_benchmark() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")
    mod._benchmark_daily_returns.append(0.008)
    mod._benchmark_daily_returns.append(-0.003)
    mod._portfolio_daily_returns.append(0.01)
    mod._portfolio_daily_returns.append(-0.005)

    var summary = mod.calculate_summary()
    assert_true("benchmark_total_returns" in summary)


# ============================================================
# Test Group 13: collect_account_daily
# ============================================================

def test_collect_account_daily() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")

    mod.collect_account_daily("stock", "2024-01-01", 50000.0, 100.0, 50000.0, 100000.0)

    assert_true("stock" in mod._sub_accounts)
    var accounts = mod._sub_accounts["stock"].copy()
    assert_equal(len(accounts), 1)
    assert_equal(accounts[0].date, "2024-01-01")
    assert_close(accounts[0].cash, 50000.0, 0.1)


def test_collect_account_daily_multiple() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")

    mod.collect_account_daily("stock", "2024-01-01", 50000.0, 100.0, 50000.0, 100000.0)
    mod.collect_account_daily("stock", "2024-01-02", 49500.0, 50.0, 50000.0, 99500.0)

    var accounts = mod._sub_accounts["stock"].copy()
    assert_equal(len(accounts), 2)


def test_collect_account_daily_future_with_extra_fields() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")

    mod.collect_account_daily(
        "future", "2024-01-01", 200000.0, 200.0, 100000.0, 300000.0,
        position_pnl=500.0, trading_pnl=300.0, daily_pnl=800.0, margin=50000.0
    )

    var accounts = mod._sub_accounts["future"].copy()
    assert_equal(len(accounts), 1)
    assert_close(accounts[0].position_pnl, 500.0, 0.1)
    assert_close(accounts[0].margin, 50000.0, 0.1)


# ============================================================
# Test Group 14: get_state / set_state
# ============================================================

def test_get_set_state_roundtrip() raises:
    var mod = create_analyser_mod()
    mod._portfolio_daily_returns.append(0.01)
    mod._portfolio_daily_returns.append(-0.005)
    mod._benchmark_daily_returns.append(0.008)
    mod._daily_pnl.append(100.0)
    mod._daily_pnl.append(-50.0)

    var state = mod.get_state()
    assert_true(len(state) > 0)

    var mod2 = create_analyser_mod()
    mod2.set_state(state)

    assert_equal(len(mod2._portfolio_daily_returns), 2)
    assert_close(mod2._portfolio_daily_returns[0], 0.01, 0.001)
    assert_close(mod2._portfolio_daily_returns[1], -0.005, 0.001)
    assert_equal(len(mod2._benchmark_daily_returns), 1)
    assert_close(mod2._benchmark_daily_returns[0], 0.008, 0.001)
    assert_equal(len(mod2._daily_pnl), 2)
    assert_close(mod2._daily_pnl[0], 100.0, 0.1)


def test_get_state_empty() raises:
    var mod = create_analyser_mod()
    var state = mod.get_state()
    assert_true(len(state) > 0)
    assert_true(state.find("benchmark_daily_returns") != -1)
    assert_true(state.find("portfolio_daily_returns") != -1)


def test_set_state_invalid_json() raises:
    var mod = create_analyser_mod()
    mod.set_state("invalid json")
    assert_equal(len(mod._portfolio_daily_returns), 0)


# ============================================================
# Test Group 15: Getter Methods
# ============================================================

def test_get_benchmark_portfolios() raises:
    var mod = create_analyser_mod()
    var bp = mod.get_benchmark_portfolios()
    assert_equal(len(bp), 0)


def test_get_benchmark_daily_returns() raises:
    var mod = create_analyser_mod()
    var returns = mod.get_benchmark_daily_returns()
    assert_equal(len(returns), 0)


def test_get_portfolio_daily_returns() raises:
    var mod = create_analyser_mod()
    var returns = mod.get_portfolio_daily_returns()
    assert_equal(len(returns), 0)


def test_get_orders() raises:
    var mod = create_analyser_mod()
    var orders = mod.get_orders()
    assert_equal(len(orders), 0)


def test_get_trades() raises:
    var mod = create_analyser_mod()
    var trades = mod.get_trades()
    assert_equal(len(trades), 0)


def test_get_total_portfolios() raises:
    var mod = create_analyser_mod()
    var portfolios = mod.get_total_portfolios()
    assert_equal(len(portfolios), 0)


def test_get_daily_pnl() raises:
    var mod = create_analyser_mod()
    var pnl = mod.get_daily_pnl()
    assert_equal(len(pnl), 0)


def test_get_sub_accounts() raises:
    var mod = create_analyser_mod()
    var accounts = mod.get_sub_accounts()
    assert_equal(len(accounts), 0)


def test_get_positions() raises:
    var mod = create_analyser_mod()
    var positions = mod.get_positions()
    assert_equal(len(positions), 0)


# ============================================================
# Test Group 16: Writable trait
# ============================================================

def test_analyser_mod_writable() raises:
    var mod = create_analyser_mod()
    var s = String.write(mod)
    assert_true(len(s) > 0)
    assert_true(s.find("AnalyserMod") != -1)


def test_benchmark_portfolio_writable() raises:
    var dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var bp = BenchmarkPortfolio(date=dt, unit_net_value=1.05, total_value=105000.0)
    var s = String.write(bp)
    assert_true(len(s) > 0)
    assert_true(s.find("BenchmarkPortfolio") != -1)


def test_portfolio_record_writable() raises:
    var pr = PortfolioRecord(
        date="2024-01-01", cash=50000.0, total_value=100000.0,
        market_value=50000.0, unit_net_value=1.0, units=100000.0,
        static_unit_net_value=1.0
    )
    var s = String.write(pr)
    assert_true(s.find("PortfolioRecord") != -1)


def test_trade_record_writable() raises:
    var tr = TradeRecord(
        datetime="2024-01-01 10:00:00", trading_datetime="2024-01-01 10:00:00",
        order_book_id="000001.XSHE", symbol="平安银行",
        side="BUY", position_effect="OPEN", exec_id="1",
        tax=5.0, commission=10.0, last_quantity=100, last_price=10.5,
        order_id=1, transaction_cost=15.0
    )
    var s = String.write(tr)
    assert_true(s.find("TradeRecord") != -1)


def test_performance_metrics_writable() raises:
    var pm = PerformanceMetrics(total_returns=0.1, annualized_returns=0.2, max_drawdown=0.05, sharpe_ratio=1.5, win_rate=0.6)
    var s = String.write(pm)
    assert_true(s.find("PerformanceMetrics") != -1)


def test_trade_summary_writable() raises:
    var ts = TradeSummary(total_trades=10, winning_trades=6, losing_trades=4, total_pnl=1000.0)
    var s = String.write(ts)
    assert_true(s.find("TradeSummary") != -1)


# ============================================================
# Test Group 17: Edge Cases
# ============================================================

def test_multiple_collect_daily() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")

    for i in range(5):
        var dt = DateTime(2024, 1, i + 1, 15, 0, 0, 0)
        mod.collect_daily(dt, dt, 100000.0, 100000.0, 50000.0, 1.0, 100000.0, 1.0, 0.01, 100.0)

    assert_equal(len(mod._total_portfolios), 5)
    assert_equal(len(mod._portfolio_daily_returns), 5)
    assert_equal(len(mod._daily_pnl), 5)


def test_safe_convert_rounding() raises:
    var result = AnalyserMod._safe_convert(2.5555, 2)
    assert_close(result, 2.56, 0.01)


def test_parse_benchmark_with_spaces() raises:
    var mod = create_analyser_mod()
    var result = mod._parse_benchmark(" 000001.XSHE : 0.5 , 000905.XSHG : 0.5 ")
    assert_equal(len(result), 2)


def test_collect_account_daily_different_types() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")

    mod.collect_account_daily("stock", "2024-01-01", 50000.0, 100.0, 50000.0, 100000.0)
    mod.collect_account_daily("future", "2024-01-01", 200000.0, 200.0, 100000.0, 300000.0)

    assert_true("stock" in mod._sub_accounts)
    assert_true("future" in mod._sub_accounts)


# ============================================================
# Main Test Runner
# ============================================================

fn main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
