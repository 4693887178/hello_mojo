"""
Python Tests for PlotStore Behavior Parity Verification
Tests the Python original to establish baseline behavior for comparison with Mojo refactored version.
"""

import pytest
from datetime import date, datetime
from collections import defaultdict
from unittest.mock import Mock


class TestPlotStorePythonOriginal:
    """Test suite for Python original PlotStore behavior."""

    def _create_mock_env(self, trading_dt=None):
        """Create a mock Environment object."""
        env = Mock()
        if trading_dt is None:
            trading_dt = datetime(2024, 1, 15, 10, 30, 0)
        env.trading_dt.date.return_value = trading_dt.date()
        return env

    def test_init_empty_plots(self):
        """Test PlotStore initialization with empty plots dict."""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore

        env = self._create_mock_env()
        ps = PlotStore(env)
        assert ps.get_plots() == {}

    def test_add_plot_single_point(self):
        """Test adding a single data point to a new series."""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore

        env = self._create_mock_env()
        ps = PlotStore(env)

        dt = date(2024, 1, 15)
        ps.add_plot(dt, "test_series", 100.5)

        plots = ps.get_plots()
        assert len(plots) == 1
        assert "test_series" in plots
        assert plots["test_series"][dt] == 100.5

    def test_add_plot_multiple_points_same_series(self):
        """Test adding multiple data points to the same series."""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore

        env = self._create_mock_env()
        ps = PlotStore(env)

        dt1 = date(2024, 1, 15)
        dt2 = date(2024, 1, 16)
        dt3 = date(2024, 1, 17)

        ps.add_plot(dt1, "price", 100.0)
        ps.add_plot(dt2, "price", 101.5)
        ps.add_plot(dt3, "price", 102.3)

        plots = ps.get_plots()
        assert len(plots) == 1
        assert len(plots["price"]) == 3
        assert plots["price"][dt1] == 100.0
        assert plots["price"][dt2] == 101.5
        assert plots["price"][dt3] == 102.3

    def test_add_plot_multiple_series(self):
        """Test adding data points to multiple different series."""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore

        env = self._create_mock_env()
        ps = PlotStore(env)

        dt = date(2024, 1, 15)
        ps.add_plot(dt, "OPEN", 10.5)
        ps.add_plot(dt, "CLOSE", 11.2)
        ps.add_plot(dt, "HIGH", 11.8)
        ps.add_plot(dt, "LOW", 10.2)

        plots = ps.get_plots()
        assert len(plots) == 4
        assert "OPEN" in plots
        assert "CLOSE" in plots
        assert "HIGH" in plots
        assert "LOW" in plots
        assert plots["OPEN"][dt] == 10.5
        assert plots["CLOSE"][dt] == 11.2
        assert plots["HIGH"][dt] == 11.8
        assert plots["LOW"][dt] == 10.2

    def test_add_plot_overwrite_same_date(self):
        """Test that adding a point with the same date overwrites the previous value."""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore

        env = self._create_mock_env()
        ps = PlotStore(env)

        dt = date(2024, 1, 15)
        ps.add_plot(dt, "series1", 100.0)
        ps.add_plot(dt, "series1", 200.0)

        plots = ps.get_plots()
        assert len(plots["series1"]) == 1
        assert plots["series1"][dt] == 200.0

    def test_get_plots_returns_reference(self):
        """Test that get_plots returns reference (Python defaultdict behavior)."""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore

        env = self._create_mock_env()
        ps = PlotStore(env)

        dt = date(2024, 1, 15)
        ps.add_plot(dt, "test", 42.0)

        plots1 = ps.get_plots()
        assert len(plots1) == 1

        dt2 = date(2024, 1, 16)
        ps.add_plot(dt2, "test2", 99.0)

        plots2 = ps.get_plots()
        assert len(plots2) == 2
        # In Python, get_plots returns the same dict object
        assert len(plots1) == 2

    def test_plot_uses_trading_dt_date(self):
        """Test that plot() method uses environment's trading_dt.date() - via add_plot."""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore

        # Simulate what plot() does: get trading_dt.date() and call add_plot
        trading_dt = datetime(2024, 6, 15, 9, 30, 0)
        env = self._create_mock_env(trading_dt=trading_dt)
        ps = PlotStore(env)

        # Directly call add_plot with the date from env.trading_dt.date()
        ps.add_plot(env.trading_dt.date(), "benchmark", 1500.25)

        plots = ps.get_plots()
        assert "benchmark" in plots
        assert date(2024, 6, 15) in plots["benchmark"]
        assert plots["benchmark"][date(2024, 6, 15)] == 1500.25

    def test_negative_values(self):
        """Test that negative float values are stored correctly."""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore

        env = self._create_mock_env()
        ps = PlotStore(env)

        dt = date(2024, 1, 15)
        ps.add_plot(dt, "pnl", -500.75)

        plots = ps.get_plots()
        assert plots["pnl"][dt] == -500.75

    def test_zero_value(self):
        """Test that zero value is stored correctly."""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore

        env = self._create_mock_env()
        ps = PlotStore(env)

        dt = date(2024, 1, 15)
        ps.add_plot(dt, "drawdown", 0.0)

        plots = ps.get_plots()
        assert plots["drawdown"][dt] == 0.0

    def test_large_values(self):
        """Test that large float values are stored correctly."""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore

        env = self._create_mock_env()
        ps = PlotStore(env)

        dt = date(2024, 1, 15)
        ps.add_plot(dt, "nav", 999999999.99)

        plots = ps.get_plots()
        assert plots["nav"][dt] == 999999999.99

    def test_special_series_names(self):
        """Test series names with underscores and numbers."""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore

        env = self._create_mock_env()
        ps = PlotStore(env)

        dt = date(2024, 1, 15)
        ps.add_plot(dt, "series_name_123", 50.0)
        ps.add_plot(dt, "UPPER_CASE", 60.0)
        ps.add_plot(dt, "lower_case", 70.0)

        plots = ps.get_plots()
        assert len(plots) == 3
        assert "series_name_123" in plots
        assert "UPPER_CASE" in plots
        assert "lower_case" in plots

    def test_defaultdict_behavior(self):
        """Test that _plots uses defaultdict and auto-creates nested dicts."""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore

        env = self._create_mock_env()
        ps = PlotStore(env)

        # Accessing a new series should not raise KeyError when using add_plot
        dt = date(2024, 1, 15)
        ps.add_plot(dt, "new_series", 123.45)

        assert "new_series" in ps.get_plots()


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
