"""
Python Tests for Report Module Behavior Parity Verification
Tests the Python original to establish baseline behavior for comparison with Mojo refactored version.
"""

import pytest
import pandas as pd
import numpy as np
from datetime import date, datetime


class TestReportPythonOriginal:
    """Test suite for Python original report module behavior."""

    def test_returns_basic_calculation(self):
        """Test _returns calculates daily returns correctly."""
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.report import _returns

        dates = pd.date_range("2024-01-01", periods=5, freq="D")
        nav = pd.Series([1.0, 1.02, 1.01, 1.05, 1.03], index=dates)
        result = _returns(nav)

        assert len(result) == 5
        assert abs(result.iloc[0]) < 1e-10
        assert abs(result.iloc[1] - 0.02) < 1e-4

    def test_returns_handles_single_value(self):
        """Test _returns handles single-value series."""
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.report import _returns

        nav = pd.Series([100.0], index=pd.date_range("2024-01-01", periods=1))
        result = _returns(nav)
        assert len(result) == 1

    def test_gen_positions_weight_basic(self):
        """Test _gen_positions_weight converts DataFrame to nested dict."""
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.report import _gen_positions_weight

        idx = pd.MultiIndex.from_tuples(
            [(date(2024, 6, 15), "000001.XSHE"), (date(2024, 6, 15), "600000.XSHG")],
            names=["date", "book_id"],
        )
        df = pd.Series([0.3, 0.7], index=idx, name="weight")

        result = _gen_positions_weight(df)
        assert isinstance(result, dict)
        assert len(result) > 0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
