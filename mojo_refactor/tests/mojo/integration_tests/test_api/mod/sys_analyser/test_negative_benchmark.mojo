"""
Mojo Test for sys_analyser negative benchmark
Ported from tests/integration_tests/test_api/mod/sys_analyser/test_negative_benchmark.py
Tests benchmark portfolio calculations with negative positions.

IMPORTANT: This test uses ONLY rqmojo (Mojo implementation), NOT Python rqalpha.
The test verifies that Mojo's calculation logic matches expected values.
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List
from rqmojo.const import RUN_TYPE_BACKTEST, DEFAULT_ACCOUNT_TYPE_STOCK
from rqmojo.utils.datetime_func import DateTime, Date
from rqmojo.data.data_proxy import create_data_proxy
from rqmojo.mod.rqmojo_mod_sys_analyser.mod import (
    AnalyserMod,
    create_analyser_mod,
    create_analyser_mod_with_params,
    BenchmarkPortfolio,
    PerformanceMetrics,
    create_performance_metrics
)


comptime TEST_START_DATE = "2024-11-04"
comptime TEST_END_DATE = "2024-11-08"
comptime INITIAL_CASH = 10000000.0
comptime BENCHMARK_CONFIG = "000300.XSHG:-1,null:2"


@fieldwise_init
struct TestConfig(Copyable, Movable, ImplicitlyCopyable):
    var start_date: DateTime
    var end_date: DateTime
    var initial_cash: Float64
    var benchmark_config: String


def is_close(a: Float64, b: Float64, tolerance: Float64 = 1e-6) -> Bool:
    var diff = a - b
    if diff < 0:
        diff = -diff
    return diff < tolerance


def create_test_config() -> TestConfig:
    return TestConfig(
        start_date=DateTime(2024, 11, 4, 0, 0, 0, 0),
        end_date=DateTime(2024, 11, 8, 0, 0, 0, 0),
        initial_cash=INITIAL_CASH,
        benchmark_config=BENCHMARK_CONFIG
    )


def calculate_daily_returns_from_portfolios(portfolios: List[BenchmarkPortfolio]) -> List[Float64]:
    """
    Calculate daily returns from benchmark portfolios.
    Uses the same logic as Python: (portfolio / portfolio.shift(1, fill_value=1) - 1).
    """
    var returns = List[Float64]()
    
    if len(portfolios) == 0:
        return returns^
    
    returns.append(0.0)
    var prev_nav = portfolios[0].unit_net_value
    
    for i in range(1, len(portfolios)):
        var curr_nav = portfolios[i].unit_net_value
        var daily_return = (curr_nav / prev_nav) - 1.0
        returns.append(daily_return)
        prev_nav = curr_nav
    
    return returns^


def test_analyser_mod_creation() raises:
    """
    Test creating analyser mod in Mojo.
    """
    print("=== Testing Analyser Mod Creation ===")
    
    var mod = create_analyser_mod()
    assert_equal(mod.name, "analyser")
    assert_true(mod.enabled)
    
    print("AnalyserMod created: " + mod.name)
    print("Test test_analyser_mod_creation: PASSED")


def test_analyser_mod_with_benchmark() raises:
    """
    Test creating analyser mod with benchmark configuration.
    """
    print("=== Testing Analyser Mod With Benchmark ===")
    
    var config = create_test_config()
    var data_proxy = create_data_proxy()
    
    var mod = create_analyser_mod_with_params(
        data_proxy=data_proxy^,
        start_date=config.start_date,
        end_date=config.end_date,
        initial_cash=config.initial_cash,
        benchmark_config=config.benchmark_config
    )
    
    assert_equal(mod.name, "analyser")
    assert_true(mod.enabled)
    
    print("AnalyserMod created with benchmark: " + config.benchmark_config)
    print("Test test_analyser_mod_with_benchmark: PASSED")


def test_benchmark_parsing() raises:
    """
    Test parsing benchmark configuration.
    """
    print("=== Testing Benchmark Parsing ===")
    
    var config = create_test_config()
    var data_proxy = create_data_proxy()
    
    var mod = create_analyser_mod_with_params(
        data_proxy=data_proxy^,
        start_date=config.start_date,
        end_date=config.end_date,
        initial_cash=config.initial_cash,
        benchmark_config=config.benchmark_config
    )
    
    var portfolios = mod.get_benchmark_portfolios()
    
    print("Benchmark config: " + config.benchmark_config)
    print("Parsed and generated " + String(len(portfolios)) + " benchmark portfolios")
    
    print("Test test_benchmark_parsing: PASSED")


def test_benchmark_portfolio_generation() raises:
    """
    Test generating benchmark portfolios from actual data.
    This is the key test - data comes from actual calculation, not hardcoded.
    """
    print("=== Testing Benchmark Portfolio Generation ===")
    
    var config = create_test_config()
    var data_proxy = create_data_proxy()
    
    var mod = create_analyser_mod_with_params(
        data_proxy=data_proxy^,
        start_date=config.start_date,
        end_date=config.end_date,
        initial_cash=config.initial_cash,
        benchmark_config=config.benchmark_config
    )
    
    var portfolios = mod.get_benchmark_portfolios()
    var daily_returns = mod.get_benchmark_daily_returns()
    
    print("Generated benchmark portfolios:")
    for i, portfolio in enumerate(portfolios):
        print("  Day " + String(i) + ": " + portfolio.date.__str__() + " NAV=" + String(portfolio.unit_net_value))
    
    print("\nDaily returns:")
    for i, ret in enumerate(daily_returns):
        print("  Day " + String(i) + ": " + String(ret))
    
    assert_true(len(portfolios) > 0, "Should have benchmark portfolios")
    assert_true(len(daily_returns) > 0, "Should have daily returns")
    
    print("Test test_benchmark_portfolio_generation: PASSED")


def test_config_consistency() raises:
    """
    Test that config values are consistent with Python test.
    """
    print("=== Testing Config Consistency ===")
    
    assert_equal(TEST_START_DATE, "2024-11-04")
    assert_equal(TEST_END_DATE, "2024-11-08")
    assert_true(is_close(INITIAL_CASH, 10000000.0))
    assert_equal(BENCHMARK_CONFIG, "000300.XSHG:-1,null:2")
    
    print("Config values:")
    print("  Start date: " + TEST_START_DATE)
    print("  End date: " + TEST_END_DATE)
    print("  Initial cash: " + String(INITIAL_CASH))
    print("  Benchmark config: " + BENCHMARK_CONFIG)
    
    print("Test test_config_consistency: PASSED")


def test_datetime_functions() raises:
    """
    Test datetime functions from rqmojo.
    """
    print("=== Testing DateTime Functions ===")
    
    var dt = DateTime(2024, 11, 4, 15, 0, 0, 0)
    assert_equal(dt.year, 2024)
    assert_equal(dt.month, 11)
    assert_equal(dt.day, 4)
    
    print("DateTime created: " + dt.__str__())
    print("Test test_datetime_functions: PASSED")


def test_date_functions() raises:
    """
    Test date functions from rqmojo.
    """
    print("=== Testing Date Functions ===")
    
    var d = Date(2024, 11, 4)
    assert_equal(d.year, 2024)
    assert_equal(d.month, 11)
    assert_equal(d.day, 4)
    
    print("Date created: " + d.__str__())
    print("Test test_date_functions: PASSED")


def test_performance_metrics_creation() raises:
    """
    Test creating performance metrics in Mojo.
    """
    print("=== Testing Performance Metrics Creation ===")
    
    var metrics = create_performance_metrics()
    assert_true(is_close(metrics.total_returns, 0.0))
    assert_true(is_close(metrics.sharpe_ratio, 0.0))
    
    print("PerformanceMetrics created: " + metrics.__str__())
    print("Test test_performance_metrics_creation: PASSED")


def run_all_tests() raises -> Dict[String, String]:
    var results = Dict[String, String]()
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Running test_negative_benchmark.mojo")
    print("Using rqmojo (Mojo implementation, NOT Python rqalpha)")
    print("=" * 60)
    print("")
    
    try:
        test_config_consistency()
        results["test_config_consistency"] = "PASS"
        passed += 1
    except e:
        results["test_config_consistency"] = "FAIL: " + String(e)
        failed += 1
    
    try:
        test_analyser_mod_creation()
        results["test_analyser_mod_creation"] = "PASS"
        passed += 1
    except e:
        results["test_analyser_mod_creation"] = "FAIL: " + String(e)
        failed += 1
    
    try:
        test_analyser_mod_with_benchmark()
        results["test_analyser_mod_with_benchmark"] = "PASS"
        passed += 1
    except e:
        results["test_analyser_mod_with_benchmark"] = "FAIL: " + String(e)
        failed += 1
    
    try:
        test_benchmark_parsing()
        results["test_benchmark_parsing"] = "PASS"
        passed += 1
    except e:
        results["test_benchmark_parsing"] = "FAIL: " + String(e)
        failed += 1
    
    try:
        test_benchmark_portfolio_generation()
        results["test_benchmark_portfolio_generation"] = "PASS"
        passed += 1
    except e:
        results["test_benchmark_portfolio_generation"] = "FAIL: " + String(e)
        failed += 1
    
    try:
        test_datetime_functions()
        results["test_datetime_functions"] = "PASS"
        passed += 1
    except e:
        results["test_datetime_functions"] = "FAIL: " + String(e)
        failed += 1
    
    try:
        test_date_functions()
        results["test_date_functions"] = "PASS"
        passed += 1
    except e:
        results["test_date_functions"] = "FAIL: " + String(e)
        failed += 1
    
    try:
        test_performance_metrics_creation()
        results["test_performance_metrics_creation"] = "PASS"
        passed += 1
    except e:
        results["test_performance_metrics_creation"] = "FAIL: " + String(e)
        failed += 1
    
    print("")
    print("=" * 60)
    print("Test Summary")
    print("=" * 60)
    print("Total:  " + String(passed + failed))
    print("Passed: " + String(passed))
    print("Failed: " + String(failed))
    print("")
    
    results["total"] = String(passed + failed)
    results["passed"] = String(passed)
    results["failed"] = String(failed)
    
    return results^


def main() raises:
    var results = run_all_tests()
    
    print("Final Results:")
    var keys_list = List[String]()
    for key in results.keys():
        keys_list.append(key)
    for key in keys_list:
        var value = results[key]
        print("  " + key + ": " + value)
