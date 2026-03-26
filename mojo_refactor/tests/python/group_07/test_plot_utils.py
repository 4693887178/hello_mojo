# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_analyser/plot/utils.py
Group 07 - File 04
"""

import pytest
import numpy as np
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestPlotUtilsStructure:
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


class TestMaxDD:
    def test_max_dd_basic(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import max_dd
        import pandas as pd
        
        arr = np.array([100, 110, 105, 95, 90, 100])
        index = pd.date_range('2020-01-01', periods=6)
        
        result = max_dd(arr, index)
        
        assert result is not None
        assert hasattr(result, 'start')
        assert hasattr(result, 'end')

    def test_max_dd_no_drawdown(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import max_dd
        import pandas as pd
        
        arr = np.array([100, 110, 120, 130, 140])
        index = pd.date_range('2020-01-01', periods=5)
        
        result = max_dd(arr, index)
        
        assert result is not None


class TestMaxDDD:
    def test_max_ddd_basic(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import max_ddd
        import pandas as pd
        
        arr = np.array([100, 90, 80, 70, 80, 90, 100])
        index = pd.date_range('2020-01-01', periods=7)
        
        result = max_ddd(arr, index)
        
        assert result is not None
        assert hasattr(result, 'start')
        assert hasattr(result, 'end')


class TestWeeklyReturns:
    def test_weekly_returns(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import weekly_returns
        import pandas as pd
        
        dates = pd.date_range('2020-01-01', periods=14, freq='D')
        portfolio = pd.DataFrame({
            'unit_net_value': np.linspace(1.0, 1.1, 14)
        }, index=dates)
        
        result = weekly_returns(portfolio)
        
        assert result is not None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
