"""
Comprehensive Unit Tests for PlotStore
Tests cover all functionality matching Python original:
  - Initialization and factory function
  - add_plot() with various scenarios
  - get_plots() return value verification
  - plot() main API method using environment trading_dt
  - Date key formatting edge cases
"""

from std.testing import assert_equal, assert_true, TestSuite
from std.collections import Dict

from rqmojo.mod.rqmojo_mod_sys_analyser.plot_store import PlotStore, create_plot_store, _date_to_key
from rqmojo.environment import Environment, create_environment
from rqmojo.const import RUN_TYPE, EXECUTION_PHASE
from rqmojo.utils.typing import DateTime


def test_date_to_key_normal_date() raises:
    """Test _date_to_key with normal date (2024-01-15)."""
    var dt = DateTime(2024, 1, 15, 0, 0, 0, 0)
    var result = _date_to_key(dt)
    assert_equal(result, "2024-01-15")


def test_date_to_key_single_digit_month() raises:
    """Test _date_to_key with single digit month (2024-03-05)."""
    var dt = DateTime(2024, 3, 5, 0, 0, 0, 0)
    var result = _date_to_key(dt)
    assert_equal(result, "2024-03-05")


def test_date_to_key_single_digit_day() raises:
    """Test _date_to_key with single digit day (2024-12-08)."""
    var dt = DateTime(2024, 12, 8, 0, 0, 0, 0)
    var result = _date_to_key(dt)
    assert_equal(result, "2024-12-08")


def test_date_to_key_both_single_digit() raises:
    """Test _date_to_key with both month and day single digit (2024-01-09)."""
    var dt = DateTime(2024, 1, 9, 0, 0, 0, 0)
    var result = _date_to_key(dt)
    assert_equal(result, "2024-01-09")


def test_create_plot_store_factory() raises:
    """Test create_plot_store factory function creates valid instance."""
    var start_dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2024, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start_dt, end_dt, RUN_TYPE.BACKTEST)
    var ps = create_plot_store(env^)
    var plots = ps.get_plots()
    assert_equal(len(plots), 0)


def test_init_empty_plots() raises:
    """Test PlotStore initialization with empty plots dict."""
    var start_dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2024, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start_dt, end_dt, RUN_TYPE.BACKTEST)
    var ps = PlotStore(env=env^)
    var plots = ps.get_plots()
    assert_equal(len(plots), 0)


def test_add_plot_single_point() raises:
    """Test adding a single data point to a new series."""
    var start_dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2024, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start_dt, end_dt, RUN_TYPE.BACKTEST)
    var ps = PlotStore(env=env^)

    var dt = DateTime(2024, 1, 15, 10, 30, 0, 0)
    ps.add_plot(dt, "test_series", 100.5)

    var plots = ps.get_plots()
    assert_equal(len(plots), 1)
    var series_data = plots["test_series"].copy()
    var val = series_data["2024-01-15"]
    assert_equal(val, 100.5)


def test_add_plot_multiple_points_same_series() raises:
    """Test adding multiple data points to the same series."""
    var start_dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2024, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start_dt, end_dt, RUN_TYPE.BACKTEST)
    var ps = PlotStore(env=env^)

    var dt1 = DateTime(2024, 1, 15, 10, 30, 0, 0)
    var dt2 = DateTime(2024, 1, 16, 10, 30, 0, 0)
    var dt3 = DateTime(2024, 1, 17, 10, 30, 0, 0)

    ps.add_plot(dt1, "price", 100.0)
    ps.add_plot(dt2, "price", 101.5)
    ps.add_plot(dt3, "price", 102.3)

    var plots = ps.get_plots()
    assert_equal(len(plots), 1)
    var series_data = plots["price"].copy()
    assert_equal(len(series_data), 3)
    assert_equal(series_data["2024-01-15"], 100.0)
    assert_equal(series_data["2024-01-16"], 101.5)
    assert_equal(series_data["2024-01-17"], 102.3)


def test_add_plot_multiple_series() raises:
    """Test adding data points to multiple different series."""
    var start_dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2024, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start_dt, end_dt, RUN_TYPE.BACKTEST)
    var ps = PlotStore(env=env^)

    var dt = DateTime(2024, 1, 15, 10, 30, 0, 0)
    ps.add_plot(dt, "OPEN", 10.5)
    ps.add_plot(dt, "CLOSE", 11.2)
    ps.add_plot(dt, "HIGH", 11.8)
    ps.add_plot(dt, "LOW", 10.2)

    var plots = ps.get_plots()
    assert_equal(len(plots), 4)
    assert_equal(plots["OPEN"].copy()["2024-01-15"], 10.5)
    assert_equal(plots["CLOSE"].copy()["2024-01-15"], 11.2)
    assert_equal(plots["HIGH"].copy()["2024-01-15"], 11.8)
    assert_equal(plots["LOW"].copy()["2024-01-15"], 10.2)


def test_add_plot_overwrite_same_date() raises:
    """Test that adding a point with the same date overwrites the previous value."""
    var start_dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2024, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start_dt, end_dt, RUN_TYPE.BACKTEST)
    var ps = PlotStore(env=env^)

    var dt = DateTime(2024, 1, 15, 10, 30, 0, 0)
    ps.add_plot(dt, "series1", 100.0)
    ps.add_plot(dt, "series1", 200.0)

    var plots = ps.get_plots()
    var series_data = plots["series1"].copy()
    assert_equal(len(series_data), 1)
    assert_equal(series_data["2024-01-15"], 200.0)


def test_get_plots_returns_copy() raises:
    """Test that get_plots returns a copy (modifications don't affect internal state)."""
    var start_dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2024, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start_dt, end_dt, RUN_TYPE.BACKTEST)
    var ps = PlotStore(env=env^)

    var dt = DateTime(2024, 1, 15, 10, 30, 0, 0)
    ps.add_plot(dt, "test", 42.0)

    var plots1 = ps.get_plots()
    assert_equal(len(plots1), 1)

    var dt2 = DateTime(2024, 1, 16, 10, 30, 0, 0)
    ps.add_plot(dt2, "test2", 99.0)

    var plots2 = ps.get_plots()
    assert_equal(len(plots2), 2)
    assert_equal(len(plots1), 1)


def test_plot_uses_trading_dt() raises:
    """Test that plot() method uses environment's trading_dt as x-coordinate."""
    var start_dt = DateTime(2024, 6, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2024, 6, 30, 0, 0, 0, 0)
    var env = create_environment(start_dt, end_dt, RUN_TYPE.BACKTEST)

    var trading_dt = DateTime(2024, 6, 15, 9, 30, 0, 0)
    env.set_trading_dt(trading_dt)

    var ps = PlotStore(env=env^)
    ps.plot("benchmark", 1500.25)

    var plots = ps.get_plots()
    var benchmark_data = plots["benchmark"].copy()
    assert_equal(benchmark_data["2024-06-15"], 1500.25)


def test_plot_multiple_calls_different_dates() raises:
    """Test multiple plot() calls with different trading dates."""
    var start_dt = DateTime(2024, 3, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2024, 3, 31, 0, 0, 0, 0)
    var env = create_environment(start_dt, end_dt, RUN_TYPE.BACKTEST)

    var dates = [
        DateTime(2024, 3, 5, 9, 30, 0, 0),
        DateTime(2024, 3, 6, 9, 30, 0, 0),
        DateTime(2024, 3, 7, 9, 30, 0, 0),
    ]
    var values = [100.0, 101.5, 102.8]

    var ps = PlotStore(env=env^)
    for i in range(3):
        ps.add_plot(dates[i], "portfolio_value", values[i])

    var plots = ps.get_plots()
    var series_data = plots["portfolio_value"].copy()
    assert_equal(len(series_data), 3)
    assert_equal(series_data["2024-03-05"], 100.0)
    assert_equal(series_data["2024-03-06"], 101.5)
    assert_equal(series_data["2024-03-07"], 102.8)


def test_negative_values() raises:
    """Test that negative float values are stored correctly."""
    var start_dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2024, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start_dt, end_dt, RUN_TYPE.BACKTEST)
    var ps = PlotStore(env=env^)

    var dt = DateTime(2024, 1, 15, 10, 30, 0, 0)
    ps.add_plot(dt, "pnl", -500.75)

    var plots = ps.get_plots()
    assert_equal(plots["pnl"].copy()["2024-01-15"], -500.75)


def test_zero_value() raises:
    """Test that zero value is stored correctly."""
    var start_dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2024, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start_dt, end_dt, RUN_TYPE.BACKTEST)
    var ps = PlotStore(env=env^)

    var dt = DateTime(2024, 1, 15, 10, 30, 0, 0)
    ps.add_plot(dt, "drawdown", 0.0)

    var plots = ps.get_plots()
    assert_equal(plots["drawdown"].copy()["2024-01-15"], 0.0)


def test_large_values() raises:
    """Test that large float values are stored correctly."""
    var start_dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2024, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start_dt, end_dt, RUN_TYPE.BACKTEST)
    var ps = PlotStore(env=env^)

    var dt = DateTime(2024, 1, 15, 10, 30, 0, 0)
    ps.add_plot(dt, "nav", 999999999.99)

    var plots = ps.get_plots()
    assert_equal(plots["nav"].copy()["2024-01-15"], 999999999.99)


def test_special_series_names() raises:
    """Test series names with underscores and numbers."""
    var start_dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2024, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start_dt, end_dt, RUN_TYPE.BACKTEST)
    var ps = PlotStore(env=env^)

    var dt = DateTime(2024, 1, 15, 10, 30, 0, 0)
    ps.add_plot(dt, "series_name_123", 50.0)
    ps.add_plot(dt, "UPPER_CASE", 60.0)
    ps.add_plot(dt, "lower_case", 70.0)

    var plots = ps.get_plots()
    assert_equal(len(plots), 3)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
