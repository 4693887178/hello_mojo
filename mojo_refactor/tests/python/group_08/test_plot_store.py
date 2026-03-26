# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_analyser/plot_store.py
Group 08 - File 10
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
from datetime import datetime, date
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestPlotStore:
    def test_plot_store_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore
        assert PlotStore is not None

    def test_plot_store_has_add_plot(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore
        assert hasattr(PlotStore, 'add_plot')

    def test_plot_store_has_get_plots(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore
        assert hasattr(PlotStore, 'get_plots')

    def test_plot_store_has_plot(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore
        assert hasattr(PlotStore, 'plot')


class TestPlotStoreMethods:
    def test_add_plot_stores_data(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore
        
        mock_env = Mock()
        store = PlotStore(mock_env)
        
        test_date = date(2024, 1, 15)
        store.add_plot(test_date, "test_series", 100.0)
        
        plots = store.get_plots()
        assert "test_series" in plots
        assert plots["test_series"][test_date] == 100.0

    def test_get_plots_returns_dict(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore
        
        mock_env = Mock()
        store = PlotStore(mock_env)
        
        plots = store.get_plots()
        assert isinstance(plots, dict)

    def test_multiple_series(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot_store import PlotStore
        
        mock_env = Mock()
        store = PlotStore(mock_env)
        
        test_date = date(2024, 1, 15)
        store.add_plot(test_date, "series1", 100.0)
        store.add_plot(test_date, "series2", 200.0)
        
        plots = store.get_plots()
        assert "series1" in plots
        assert "series2" in plots


class TestPlotStoreImports:
    def test_import_environment(self):
        from rqalpha.environment import Environment
        assert Environment is not None

    def test_import_execution_context(self):
        from rqalpha.core.execution_context import ExecutionContext
        assert ExecutionContext is not None

    def test_import_const(self):
        from rqalpha.const import EXECUTION_PHASE
        assert EXECUTION_PHASE is not None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
