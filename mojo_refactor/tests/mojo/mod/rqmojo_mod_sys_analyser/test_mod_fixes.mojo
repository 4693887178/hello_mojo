"""
Comprehensive tests for mod.mojo - AnalyserMod
Tests all functionality matching Python original.
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List, Optional
from std.math import abs

from rqmojo.mod.rqmojo_mod_sys_analyser.mod import (
    AnalyserMod, BenchmarkPortfolio, PerformanceMetrics, TradeSummary,
    PortfolioRecord, AccountRecord, PositionRecord, TradeRecord,
    PressureTestPeriod,
    create_analyser_mod,
    create_performance_metrics, create_trade_summary,
    get_pressure_test_periods, get_null_oids, get_account_fields_map,
    _format_date, _format_datetime, _is_long_only_instrument,
    _parse_float_list_from_json,
)
from rqmojo.const import EXIT_CODE, INSTRUMENT_TYPE, DEFAULT_ACCOUNT_TYPE, SIDE, POSITION_EFFECT, POSITION_DIRECTION
from rqmojo.utils.typing import DateTime
from rqmojo.data.data_proxy import create_data_proxy
from rqmojo.model.trade import Trade, create_trade_full
from rqmojo.portfolio.position import Position, create_stock_position, create_future_position


def assert_close(actual: Float64, expected: Float64, tolerance: Float64, msg: String = "") raises:
    if abs(actual - expected) > tolerance:
        var full_msg = msg + ": expected " + String(expected) + " but got " + String(actual)
        raise full_msg


def test_parse_benchmark() raises:
    var r1 = AnalyserMod._parse_benchmark("000001.XSHE")
    assert_equal(len(r1), 1)
    assert_equal(r1[0][0], "000001.XSHE")
    assert_close(r1[0][1], 1.0, 0.001)

    var r2 = AnalyserMod._parse_benchmark("000001.XSHE:0.5")
    assert_equal(len(r2), 1)
    assert_close(r2[0][1], 0.5, 0.001)

    var r3 = AnalyserMod._parse_benchmark("000001.XSHE:0.5,000905.XSHG:0.5")
    assert_equal(len(r3), 2)

    var r4 = AnalyserMod._parse_benchmark("null")
    assert_equal(len(r4), 1)
    assert_equal(r4[0][0], "null")

    var r5 = AnalyserMod._parse_benchmark("")
    assert_equal(len(r5), 0)

    var r6 = AnalyserMod._parse_benchmark("000001.XSHE:0.3,000905.XSHG:0.7")
    assert_close(r6[0][1], 0.3, 0.001)
    assert_close(r6[1][1], 0.7, 0.001)

    var r7 = AnalyserMod._parse_benchmark("000001.XSHE,000905.XSHG")
    assert_close(r7[0][1], 1.0, 0.001)
    assert_close(r7[1][1], 1.0, 0.001)
    print("PASS: test_parse_benchmark")


def test_safe_convert() raises:
    assert_close(AnalyserMod._safe_convert(3.14159265), 3.1416, 0.0001)
    assert_close(AnalyserMod._safe_convert(3.14159265, 2), 3.14, 0.01)
    assert_close(AnalyserMod._safe_convert(3.14159265, 6), 3.141593, 0.000001)
    assert_close(AnalyserMod._safe_convert(0.0), 0.0, 0.0001)
    assert_close(AnalyserMod._safe_convert(-1.56789), -1.5679, 0.0001)
    assert_close(AnalyserMod._safe_convert(2.5555, 2), 2.56, 0.01)
    print("PASS: test_safe_convert")


def test_is_null_oid() raises:
    var mod = create_analyser_mod()
    assert_true(mod._is_null_oid("null"))
    assert_true(mod._is_null_oid("NULL"))
    assert_false(mod._is_null_oid("000001.XSHE"))
    print("PASS: test_is_null_oid")


def test_format_functions() raises:
    var dt1 = DateTime(2024, 3, 5, 14, 30, 45, 0)
    assert_equal(_format_date(dt1), "2024-03-05")
    assert_equal(_format_datetime(dt1), "2024-03-05 14:30:45")
    var dt2 = DateTime(2024, 1, 9, 0, 0, 0, 0)
    assert_equal(_format_date(dt2), "2024-01-09")
    assert_equal(_format_datetime(dt2), "2024-01-09 00:00:00")
    print("PASS: test_format_functions")


def test_is_long_only_instrument() raises:
    assert_true(_is_long_only_instrument(INSTRUMENT_TYPE.CS))
    assert_true(_is_long_only_instrument(INSTRUMENT_TYPE.ETF))
    assert_true(_is_long_only_instrument(INSTRUMENT_TYPE.BOND))
    assert_true(_is_long_only_instrument(INSTRUMENT_TYPE.CONVERTIBLE))
    assert_false(_is_long_only_instrument(INSTRUMENT_TYPE.FUTURE))
    assert_false(_is_long_only_instrument(INSTRUMENT_TYPE.OPTION))
    print("PASS: test_is_long_only_instrument")


def test_parse_float_list_from_json() raises:
    var r1 = _parse_float_list_from_json("{\"test\":[1.0,2.5,3.14]}", "test")
    assert_equal(len(r1), 3)
    assert_close(r1[0], 1.0, 0.001)
    assert_close(r1[2], 3.14, 0.01)

    var r2 = _parse_float_list_from_json("{\"test\":[]}", "test")
    assert_equal(len(r2), 0)

    var r3 = _parse_float_list_from_json("{\"other\":[1.0]}", "test")
    assert_equal(len(r3), 0)
    print("PASS: test_parse_float_list_from_json")


def test_module_constants() raises:
    var periods = get_pressure_test_periods()
    assert_equal(len(periods), 4)
    assert_equal(periods[0].title, "打击壳价值")
    assert_equal(periods[3].title, "小盘踩踏危机")

    var null_oids = get_null_oids()
    assert_equal(len(null_oids), 2)

    var fields_map = get_account_fields_map()
    assert_equal(len(fields_map), 3)
    assert_true(DEFAULT_ACCOUNT_TYPE.STOCK.value in fields_map)
    assert_true(DEFAULT_ACCOUNT_TYPE.FUTURE.value in fields_map)
    var future_fields = fields_map[DEFAULT_ACCOUNT_TYPE.FUTURE.value].copy()
    assert_equal(len(future_fields), 4)
    print("PASS: test_module_constants")


def test_create_and_start_up() raises:
    var mod = create_analyser_mod()
    assert_equal(mod.name, "analyser")
    assert_false(mod.enabled)
    assert_equal(len(mod._benchmark_daily_returns), 0)
    assert_equal(len(mod._orders), 0)
    assert_equal(len(mod._trades), 0)
    assert_equal(len(mod._total_portfolios), 0)
    assert_close(mod._initial_cash, 100000.0, 0.01)
    assert_equal(mod._trading_days_a_year, 252)

    mod.start_up("env", "config")
    assert_true(mod.enabled)
    print("PASS: test_create_and_start_up")


def test_collect_daily_and_summary() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")
    var dt1 = DateTime(2024, 1, 2, 15, 0, 0, 0)
    mod.collect_daily(dt1, dt1, 99000.0, 100000.0, 50000.0, 1.0, 100000.0, 1.0, 0.01, 1000.0)
    var dt2 = DateTime(2024, 1, 3, 15, 0, 0, 0)
    mod.collect_daily(dt2, dt2, 98500.0, 99500.0, 49500.0, 0.995, 100000.0, 0.995, -0.005, -500.0)
    assert_equal(len(mod._total_portfolios), 2)
    assert_equal(len(mod._portfolio_daily_returns), 2)
    assert_close(mod._portfolio_daily_returns[0], 0.01, 0.001)
    assert_close(mod._portfolio_daily_returns[1], -0.005, 0.001)

    var summary = mod.calculate_summary()
    assert_true("total_returns" in summary)
    assert_true("annualized_returns" in summary)
    assert_true("max_drawdown" in summary)
    assert_true("sharpe" in summary)
    assert_true("win_rate" in summary)
    assert_true("profit_loss_rate" in summary)

    var empty_summary = create_analyser_mod().calculate_summary()
    assert_equal(len(empty_summary), 0)
    print("PASS: test_collect_daily_and_summary")


def test_collect_account_daily() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")
    mod.collect_account_daily("stock", "2024-01-01", 50000.0, 100.0, 50000.0, 100000.0)
    mod.collect_account_daily("stock", "2024-01-02", 49500.0, 50.0, 50000.0, 99500.0)
    mod.collect_account_daily(
        "future", "2024-01-01", 200000.0, 200.0, 100000.0, 300000.0,
        position_pnl=500.0, trading_pnl=300.0, daily_pnl=800.0, margin=50000.0
    )
    assert_true("stock" in mod._sub_accounts)
    assert_true("future" in mod._sub_accounts)
    var stock_accounts = mod._sub_accounts["stock"].copy()
    assert_equal(len(stock_accounts), 2)
    assert_close(stock_accounts[0].cash, 50000.0, 0.1)
    var future_accounts = mod._sub_accounts["future"].copy()
    assert_close(future_accounts[0].position_pnl, 500.0, 0.1)
    assert_close(future_accounts[0].margin, 50000.0, 0.1)
    print("PASS: test_collect_account_daily")


def test_collect_position_daily() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")
    var stock_pos = create_stock_position("000001.XSHE", 100, 10.5)
    mod.collect_position_daily(
        "stock", "000001.XSHE", "平安银行", "2024-01-01",
        Optional[Position](stock_pos^), Optional[Position](None),
        INSTRUMENT_TYPE.CS
    )
    var positions = mod._positions["stock"].copy()
    assert_equal(len(positions), 1)
    assert_equal(positions[0].order_book_id, "000001.XSHE")
    assert_close(positions[0].quantity, 100.0, 0.1)

    var long_pos = create_future_position("IF2401", POSITION_DIRECTION.LONG, 10, 3500.0, 300.0, 0.1)
    mod.collect_position_daily(
        "future", "IF2401", "沪深300", "2024-01-01",
        Optional[Position](long_pos^), Optional[Position](None),
        INSTRUMENT_TYPE.FUTURE
    )
    var future_positions = mod._positions["future"].copy()
    assert_equal(len(future_positions), 1)
    assert_true(future_positions[0].LONG_quantity > 0)
    print("PASS: test_collect_position_daily")


def test_to_trade_record_trading_datetime() raises:
    var mod = create_analyser_mod()
    var cal_dt = DateTime(2024, 1, 2, 10, 30, 0, 0)
    var trade_dt = DateTime(2024, 1, 2, 9, 30, 0, 0)
    var trade = create_trade_full(
        trade_id=1, exec_id="1", order_id=100,
        order_book_id="000001.XSHE",
        side=SIDE.BUY, position_effect=POSITION_EFFECT.OPEN,
        position_direction=POSITION_DIRECTION.LONG,
        quantity=100, price=10.5,
        datetime=cal_dt, trading_datetime=trade_dt,
        commission=5.0, tax=1.0
    )
    var record = mod._to_trade_record(trade^)
    assert_equal(record.order_book_id, "000001.XSHE")
    assert_equal(record.side, "BUY")
    assert_equal(record.position_effect, "OPEN")
    assert_equal(record.last_quantity, 100)
    assert_close(record.last_price, 10.5, 0.01)
    assert_close(record.transaction_cost, 6.0, 0.01)
    assert_equal(record.datetime, "2024-01-02 10:30:00")
    assert_equal(record.trading_datetime, "2024-01-02 09:30:00")

    mod.collect_trade(trade^)
    var trades = mod.get_trades()
    assert_equal(len(trades), 1)
    print("PASS: test_to_trade_record_trading_datetime")


def test_get_set_state() raises:
    var mod = create_analyser_mod()
    mod._portfolio_daily_returns.append(0.01)
    mod._portfolio_daily_returns.append(-0.005)
    mod._benchmark_daily_returns.append(0.008)
    mod._daily_pnl.append(100.0)
    mod._daily_pnl.append(-50.0)
    var state = mod.get_state()
    assert_true(len(state) > 0)
    assert_true(state.find("benchmark_daily_returns") != -1)
    assert_true(state.find("portfolio_daily_returns") != -1)

    var mod2 = create_analyser_mod()
    mod2.set_state(state)
    assert_equal(len(mod2._portfolio_daily_returns), 2)
    assert_close(mod2._portfolio_daily_returns[0], 0.01, 0.001)
    assert_close(mod2._benchmark_daily_returns[0], 0.008, 0.001)
    assert_close(mod2._daily_pnl[0], 100.0, 0.1)

    var empty_state = create_analyser_mod().get_state()
    assert_true(len(empty_state) > 0)

    var mod3 = create_analyser_mod()
    mod3.set_state("invalid json")
    assert_equal(len(mod3._portfolio_daily_returns), 0)

    var mod4 = create_analyser_mod()
    var dt = DateTime(2024, 1, 2, 15, 0, 0, 0)
    mod4.collect_daily(dt, dt, 99000.0, 100000.0, 50000.0, 1.0, 100000.0, 1.0, 0.01, 1000.0)
    var state_with_portfolio = mod4.get_state()
    assert_true(state_with_portfolio.find("total_portfolios") != -1)
    assert_true(state_with_portfolio.find("orders_count") != -1)
    print("PASS: test_get_set_state")


def test_tear_down() raises:
    var mod1 = create_analyser_mod()
    mod1.start_up("env", "config")
    mod1.tear_down(EXIT_CODE.EXIT_SUCCESS, None)
    assert_equal(len(mod1.get_result()), 0)

    var mod2 = create_analyser_mod()
    mod2.start_up("env", "config")
    mod2.tear_down(EXIT_CODE.EXIT_USER_ERROR, None)
    assert_equal(len(mod2.get_result()), 0)
    print("PASS: test_tear_down")


def test_tear_down_with_data() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")
    var dt = DateTime(2024, 1, 2, 15, 0, 0, 0)
    mod.collect_daily(dt, dt, 99000.0, 100000.0, 50000.0, 1.0, 100000.0, 1.0, 0.01, 1000.0)
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, None)
    var result = mod.get_result()
    assert_true("strategy_name" in result)
    assert_true("start_date" in result)
    assert_true("end_date" in result)
    assert_true("total_returns" in result)
    assert_true("total_trades" in result)
    assert_equal(result["strategy_name"], "strategy")
    assert_equal(result["run_type"], "backtest")
    print("PASS: test_tear_down_with_data")


def test_tear_down_with_benchmark() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")
    var parsed = AnalyserMod._parse_benchmark("000001.XSHE")
    mod._benchmark = Optional[List[Tuple[String, Float64]]](parsed^)
    var dt = DateTime(2024, 1, 2, 15, 0, 0, 0)
    mod.collect_daily(dt, dt, 99000.0, 100000.0, 50000.0, 1.0, 100000.0, 1.0, 0.01, 1000.0)
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, None)
    assert_true("benchmark" in mod.get_result())
    print("PASS: test_tear_down_with_benchmark")


def test_tear_down_with_accounts_config() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")
    mod._accounts_config["stock"] = 100000.0
    var dt = DateTime(2024, 1, 2, 15, 0, 0, 0)
    mod.collect_daily(dt, dt, 99000.0, 100000.0, 50000.0, 1.0, 100000.0, 1.0, 0.01, 1000.0)
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, None)
    assert_true("stock" in mod.get_result())
    print("PASS: test_tear_down_with_accounts_config")


def test_data_structs() raises:
    var dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var bp = BenchmarkPortfolio(date=dt, unit_net_value=1.05, total_value=105000.0)
    assert_close(bp.unit_net_value, 1.05, 0.001)

    var pr = PortfolioRecord(
        date="2024-01-01", cash=50000.0, total_value=100000.0,
        market_value=50000.0, unit_net_value=1.0, units=100000.0,
        static_unit_net_value=1.0
    )
    assert_equal(pr.date, "2024-01-01")

    var ar = AccountRecord(
        date="2024-01-01", cash=50000.0, transaction_cost=100.0,
        market_value=50000.0, total_value=100000.0,
        position_pnl=0.0, trading_pnl=0.0, daily_pnl=0.0, margin=0.0
    )
    assert_close(ar.transaction_cost, 100.0, 0.1)

    var tr = TradeRecord(
        datetime="2024-01-01 10:00:00", trading_datetime="2024-01-01 09:30:00",
        order_book_id="000001.XSHE", symbol="平安银行",
        side="BUY", position_effect="OPEN", exec_id="1",
        tax=5.0, commission=10.0, last_quantity=100, last_price=10.5,
        order_id=1, transaction_cost=15.0
    )
    assert_equal(tr.datetime, "2024-01-01 10:00:00")
    assert_equal(tr.trading_datetime, "2024-01-01 09:30:00")

    var pm = create_performance_metrics()
    assert_close(pm.total_returns, 0.0, 0.001)

    var ts = create_trade_summary()
    assert_equal(ts.total_trades, 0)

    var ptp = PressureTestPeriod(title="test", start_date="2020-01-01", end_date="2020-12-31")
    assert_equal(ptp.title, "test")
    print("PASS: test_data_structs")


def test_writable_traits() raises:
    var mod = create_analyser_mod()
    var s1 = String.write(mod)
    assert_true(s1.find("AnalyserMod") != -1)

    var dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var bp = BenchmarkPortfolio(date=dt, unit_net_value=1.05, total_value=105000.0)
    var s2 = String.write(bp)
    assert_true(s2.find("BenchmarkPortfolio") != -1)

    var pm = PerformanceMetrics(total_returns=0.1, annualized_returns=0.2, max_drawdown=0.05, sharpe_ratio=1.5, win_rate=0.6)
    var s3 = String.write(pm)
    assert_true(s3.find("PerformanceMetrics") != -1)
    print("PASS: test_writable_traits")


def test_calculate_summary_with_benchmark() raises:
    var mod = create_analyser_mod()
    mod.start_up("env", "config")
    mod._benchmark_daily_returns.append(0.008)
    mod._benchmark_daily_returns.append(-0.003)
    mod._portfolio_daily_returns.append(0.01)
    mod._portfolio_daily_returns.append(-0.005)
    var summary = mod.calculate_summary()
    assert_true("benchmark_total_returns" in summary)
    print("PASS: test_calculate_summary_with_benchmark")


def test_getter_methods() raises:
    var mod = create_analyser_mod()
    assert_equal(len(mod.get_benchmark_portfolios()), 0)
    assert_equal(len(mod.get_benchmark_daily_returns()), 0)
    assert_equal(len(mod.get_portfolio_daily_returns()), 0)
    assert_equal(len(mod.get_orders()), 0)
    assert_equal(len(mod.get_trades()), 0)
    assert_equal(len(mod.get_total_portfolios()), 0)
    assert_equal(len(mod.get_daily_pnl()), 0)
    assert_equal(len(mod.get_sub_accounts()), 0)
    assert_equal(len(mod.get_positions()), 0)
    assert_equal(len(mod.get_result()), 0)
    print("PASS: test_getter_methods")


def main() raises:
    var passed = 0
    var failed = 0

    print("=== AnalyserMod Test Suite ===")

    try:
        test_parse_benchmark()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_parse_benchmark - ", e)

    try:
        test_safe_convert()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_safe_convert - ", e)

    try:
        test_is_null_oid()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_is_null_oid - ", e)

    try:
        test_format_functions()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_format_functions - ", e)

    try:
        test_is_long_only_instrument()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_is_long_only_instrument - ", e)

    try:
        test_parse_float_list_from_json()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_parse_float_list_from_json - ", e)

    try:
        test_module_constants()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_module_constants - ", e)

    try:
        test_create_and_start_up()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_create_and_start_up - ", e)

    try:
        test_collect_daily_and_summary()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_collect_daily_and_summary - ", e)

    try:
        test_collect_account_daily()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_collect_account_daily - ", e)

    try:
        test_collect_position_daily()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_collect_position_daily - ", e)

    try:
        test_to_trade_record_trading_datetime()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_to_trade_record_trading_datetime - ", e)

    try:
        test_get_set_state()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_get_set_state - ", e)

    try:
        test_tear_down()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_tear_down - ", e)

    try:
        test_tear_down_with_data()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_tear_down_with_data - ", e)

    try:
        test_tear_down_with_benchmark()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_tear_down_with_benchmark - ", e)

    try:
        test_tear_down_with_accounts_config()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_tear_down_with_accounts_config - ", e)

    try:
        test_data_structs()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_data_structs - ", e)

    try:
        test_writable_traits()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_writable_traits - ", e)

    try:
        test_calculate_summary_with_benchmark()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_calculate_summary_with_benchmark - ", e)

    try:
        test_getter_methods()
        passed += 1
    except e:
        failed += 1
        print("FAIL: test_getter_methods - ", e)

    print("=== Results: " + String(passed) + " passed, " + String(failed) + " failed ===")
    if failed > 0:
        raise Error("Some tests failed")
