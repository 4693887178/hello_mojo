# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_analyser/plot/utils.py
Group 07 - File 04 - Comprehensive Tests

Validates Python original implementation behavior as reference for Mojo refactoring.
"""
import pytest
import numpy as np
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestPlotUtilsStructure:
    """Verify namedtuples and IndexRange structure."""

    def test_indicator_info_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import IndicatorInfo
        assert IndicatorInfo is not None

    def test_line_info_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import LineInfo
        assert LineInfo is not None

    def test_spot_info_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import SpotInfo
        assert SpotInfo is not None

    def test_index_range_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import IndexRange
        assert IndexRange is not None

    def test_index_range_fields(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import IndexRange
        ir = IndexRange(start=1, end=5, start_date="2020-01-02", end_date="2020-01-06")
        assert ir.start == 1
        assert ir.end == 5
        assert ir.start_date == "2020-01-02"
        assert ir.end_date == "2020-01-06"

    def test_index_range_repr(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import IndexRange, max_dd
        import pandas as pd
        index = pd.date_range("2020-01-01", periods=5)
        arr = np.array([100, 110, 105, 95, 90])
        result = max_dd(arr, index)
        assert hasattr(result, "repr")
        repr_str = result.repr
        assert "days" in repr_str or "~" in repr_str


class TestMaxDD:
    """Test max_drawdown (max_dd) function."""

    def setup_method(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import max_dd
        self.max_dd = max_dd

    def test_max_dd_basic(self):
        """arr = [100, 110, 105, 95, 90, 100]
        Peak at idx=1 (110), trough at idx=4 (90).
        Expected: start=1, end=4.
        """
        import pandas as pd
        arr = np.array([100.0, 110.0, 105.0, 95.0, 90.0, 100.0])
        index = pd.date_range("2020-01-01", periods=6)
        result = self.max_dd(arr, index)
        assert result is not None
        assert result.start == 1, f"Expected start=1, got {result.start}"
        assert result.end == 4, f"Expected end=4, got {result.end}"

    def test_max_dd_no_drawdown(self):
        """Monotonically increasing: numpy argmax of all-ones ratio returns 0,
        then Python sets end=len-1."""
        import pandas as pd
        arr = np.array([100, 110, 120, 130, 140])
        index = pd.date_range("2020-01-01", periods=5)
        result = self.max_dd(arr, index)
        assert result is not None
        assert result.end == len(arr) - 1, f"Expected end={len(arr)-1}, got {result.end}"

    def test_max_dd_all_equal(self):
        """All equal values: argmax returns 0 (first), end becomes n-1.
        Start is argmax of arr[:n-1] which is also 0 (first of equals)."""
        import pandas as pd
        arr = np.array([100.0, 100.0, 100.0, 100.0])
        index = pd.date_range("2020-01-01", periods=4)
        result = self.max_dd(arr, index)
        assert result.start == 0, f"Expected start=0 (first occurrence), got {result.start}"
        assert result.end == len(arr) - 1

    def test_max_dd_decline_then_recover(self):
        """arr = [100, 90, 80, 70, 80, 90]
        Peak stays at 100 (idx 0), worst trough at idx 3 (70).
        """
        import pandas as pd
        arr = np.array([100.0, 90.0, 80.0, 70.0, 80.0, 90.0])
        index = pd.date_range("2020-01-01", periods=6)
        result = self.max_dd(arr, index)
        assert result.start == 0, f"Expected start=0, got {result.start}"
        assert result.end == 3, f"Expected end=3, got {result.end}"

    def test_max_dd_empty(self):
        """Empty array: Python original raises ValueError (numpy argmax on empty).
        Mojo version handles this gracefully by returning zeroed IndexRange.
        """
        import pandas as pd
        arr = np.array([])
        index = pd.DatetimeIndex([])
        with pytest.raises(ValueError):
            self.max_dd(arr, index)


class TestMaxDDD:
    """Test max drawdown duration (max_ddd) function."""

    def setup_method(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import max_ddd
        self.max_ddd = max_ddd

    def test_max_ddd_basic(self):
        """arr = [100, 90, 80, 70, 80, 90, 110]
        New peak above previous (110 > 100) ends the drawdown period.
        """
        import pandas as pd
        arr = np.array([100.0, 90.0, 80.0, 70.0, 80.0, 90.0, 110.0])
        index = pd.date_range("2020-01-01", periods=7)
        result = self.max_ddd(arr, index)
        assert result is not None
        assert result.start < result.end, f"Start ({result.start}) should be < end ({result.end})"
        assert (result.end - result.start) > 0

    def test_max_ddd_no_drawdown(self):
        """Monotonically increasing: no drawdown at all."""
        import pandas as pd
        arr = np.array([100, 110, 120, 130])
        index = pd.date_range("2020-01-01", periods=4)
        result = self.max_ddd(arr, index)
        assert result.start == 0
        assert result.end == 0

    def test_max_ddd_returns_to_exact_peak(self):
        """When price returns to exact peak value (not above),
        drawdown does NOT end (neither > nor < branch triggers)."""
        import pandas as pd
        arr = np.array([100.0, 90.0, 95.0, 90.0, 85.0, 95.0, 100.0])
        index = pd.date_range("2020-01-01", periods=7)
        result = self.max_ddd(arr, index)
        # At i=6: arr[6]=100 == max_seen=100 → neither branch → ddd stays at defaults
        assert result.start == 0
        assert result.end == 0


class TestWeeklyReturns:
    """Test weekly returns computation."""

    def setup_method(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import weekly_returns
        self.weekly_returns = weekly_returns

    def test_weekly_returns_basic(self):
        """Weekly returns across week boundaries using DataFrame."""
        import pandas as pd
        dates = pd.date_range("2020-01-01", periods=14, freq="B")
        portfolio = pd.DataFrame({
            "unit_net_value": np.linspace(1.0, 1.1, 14)
        }, index=dates)
        result = self.weekly_returns(portfolio)
        assert result is not None
        assert len(result) >= 1

    def test_weekly_returns_returns_series(self):
        """Result should be a Series with positive length."""
        import pandas as pd
        dates = pd.date_range("2020-01-01", periods=20, freq="B")
        portfolio = pd.DataFrame({
            "unit_net_value": np.linspace(1.0, 1.2, 20)
        }, index=dates)
        result = self.weekly_returns(portfolio)
        assert isinstance(result, pd.Series)


class TestTradingDatesIndex:
    """Test trading_dates_index function."""

    def setup_method(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import trading_dates_index
        self.trading_dates_index = trading_dates_index

    def test_trading_dates_index_basic(self):
        """Should return indices for matching trade dates."""
        import pandas as pd
        trades = pd.DataFrame({
            "position_effect": ["OPEN", "OPEN"],
            "trading_datetime": pd.to_datetime(["2020-01-05", "2020-01-15"])
        })
        index = pd.DatetimeIndex([
            "2020-01-01", "2020-01-02", "2020-01-03", "2020-01-06",
            "2020-01-07", "2020-01-10", "2020-01-14", "2020-01-16"
        ])
        result = self.trading_dates_index(trades, "OPEN", index)
        assert result is not None
        assert len(result) == 2


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
