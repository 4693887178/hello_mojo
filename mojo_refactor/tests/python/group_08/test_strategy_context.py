# -*- coding: utf-8 -*-
"""
Test for core/strategy_context.py
Group 08 - File 2
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestRunInfo:
    def test_run_info_class_exists(self):
        from rqalpha.core.strategy_context import RunInfo
        assert RunInfo is not None

    def test_run_info_has_start_date(self):
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'start_date')

    def test_run_info_has_end_date(self):
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'end_date')

    def test_run_info_has_frequency(self):
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'frequency')

    def test_run_info_has_stock_starting_cash(self):
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'stock_starting_cash')

    def test_run_info_has_future_starting_cash(self):
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'future_starting_cash')


class TestStrategyContext:
    def test_strategy_context_class_exists(self):
        from rqalpha.core.strategy_context import StrategyContext
        assert StrategyContext is not None

    def test_strategy_context_has_universe(self):
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'universe')

    def test_strategy_context_has_now(self):
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'now')

    def test_strategy_context_has_run_info(self):
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'run_info')

    def test_strategy_context_has_portfolio(self):
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'portfolio')

    def test_strategy_context_has_stock_account(self):
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'stock_account')

    def test_strategy_context_has_future_account(self):
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'future_account')

    def test_strategy_context_has_config(self):
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'config')

    def test_strategy_context_get_state(self):
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'get_state')

    def test_strategy_context_set_state(self):
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'set_state')


class TestStrategyContextMethods:
    def test_get_state_returns_bytes(self):
        from rqalpha.core.strategy_context import StrategyContext
        ctx = StrategyContext()
        ctx.test_var = "test_value"
        state = ctx.get_state()
        assert isinstance(state, bytes)

    def test_set_state_restores_state(self):
        from rqalpha.core.strategy_context import StrategyContext
        ctx1 = StrategyContext()
        ctx1.test_var = "test_value"
        state = ctx1.get_state()
        
        ctx2 = StrategyContext()
        ctx2.set_state(state)
        assert hasattr(ctx2, 'test_var')


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
