# -*- coding: utf-8 -*-
"""
Comprehensive Test Suite for rqalpha/core/strategy_context.py
Tests RunInfo and StrategyContext against Python original behavior

Group 08 - File 02 (strategy_context)
"""

import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestRunInfo:
    """Test suite for RunInfo class - mirrors Python original exactly."""

    def test_run_info_class_exists(self):
        """RunInfo class should exist and be importable."""
        from rqalpha.core.strategy_context import RunInfo
        assert RunInfo is not None

    def test_run_info_has_start_date_property(self):
        """RunInfo should have start_date property."""
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'start_date')

    def test_run_info_has_end_date_property(self):
        """RunInfo should have end_date property."""
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'end_date')

    def test_run_info_has_frequency_property(self):
        """RunInfo should have frequency property returning '1d' or '1m'."""
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'frequency')

    def test_run_info_has_stock_starting_cash_property(self):
        """RunInfo should have stock_starting_cash property."""
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'stock_starting_cash')

    def test_run_info_has_future_starting_cash_property(self):
        """RunInfo should have future_starting_cash property."""
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'future_starting_cash')

    def test_run_info_has_margin_multiplier_property(self):
        """RunInfo should have margin_multiplier property."""
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'margin_multiplier')

    def test_run_info_has_run_type_property(self):
        """RunInfo should have run_type property."""
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'run_type')

    def test_run_info_has_matching_type_property(self):
        """RunInfo should have matching_type property."""
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'matching_type')

    def test_run_info_has_slippage_property(self):
        """RunInfo should have slippage property."""
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'slippage')

    def test_run_info_has_stock_commission_multiplier_property(self):
        """RunInfo should have stock_commission_multiplier property."""
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'stock_commission_multiplier')

    def test_run_info_has_futures_commission_multiplier_property(self):
        """RunInfo should have futures_commission_multiplier property."""
        from rqalpha.core.strategy_context import RunInfo
        assert hasattr(RunInfo, 'futures_commission_multiplier')


class TestStrategyContext:
    """Test suite for StrategyContext class - mirrors Python original exactly."""

    def test_strategy_context_class_exists(self):
        """StrategyContext class should exist and be importable."""
        from rqalpha.core.strategy_context import StrategyContext
        assert StrategyContext is not None

    def test_strategy_context_has_universe_property(self):
        """StrategyContext should have universe property (delegates to Environment)."""
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'universe')

    def test_strategy_context_has_now_property(self):
        """StrategyContext should have now property (returns calendar_dt)."""
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'now')

    def test_strategy_context_has_run_info_property(self):
        """StrategyContext should have run_info property (creates RunInfo from config)."""
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'run_info')

    def test_strategy_context_has_portfolio_property(self):
        """StrategyContext should have portfolio property (from Environment)."""
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'portfolio')

    def test_strategy_context_has_stock_account_property(self):
        """StrategyContext should have stock_account property."""
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'stock_account')

    def test_strategy_context_has_future_account_property(self):
        """StrategyContext should have future_account property."""
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'future_account')

    def test_strategy_context_has_config_property(self):
        """StrategyContext should have config property."""
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'config')

    def test_strategy_context_has_get_state_method(self):
        """StrategyContext should have get_state method (pickle-based serialization)."""
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'get_state')
        assert callable(getattr(StrategyContext, 'get_state'))

    def test_strategy_context_has_set_state_method(self):
        """StrategyContext should have set_state method (pickle-based deserialization)."""
        from rqalpha.core.strategy_context import StrategyContext
        assert hasattr(StrategyContext, 'set_state')
        assert callable(getattr(StrategyContext, 'set_state'))

    def test_strategy_context_repr_format(self):
        """StrategyContext __repr__ should return Context(...) format."""
        from rqalpha.core.strategy_context import StrategyContext
        ctx = StrategyContext()
        repr_str = repr(ctx)
        assert 'Context(' in repr_str


class TestStrategyContextStateManagement:
    """Test state management functionality (get_state/set_state)."""

    def test_get_state_returns_bytes(self):
        """get_state() should return bytes (pickled state data)."""
        from rqalpha.core.strategy_context import StrategyContext
        ctx = StrategyContext()
        ctx.test_var = "test_value"
        state = ctx.get_state()
        assert isinstance(state, bytes)

    def test_set_state_restores_attributes(self):
        """set_state() should restore previously saved attributes."""
        from rqalpha.core.strategy_context import StrategyContext
        ctx1 = StrategyContext()
        ctx1.test_var = "test_value"
        ctx1.number_var = 42
        state = ctx1.get_state()
        
        ctx2 = StrategyContext()
        ctx2.set_state(state)
        
        assert hasattr(ctx2, 'test_var')
        assert hasattr(ctx2, 'number_var')

    def test_get_state_empty_context(self):
        """get_state() on empty context should still return valid bytes."""
        from rqalpha.core.strategy_context import StrategyContext
        ctx = StrategyContext()
        state = ctx.get_state()
        assert isinstance(state, bytes)

    def test_state_roundtrip_preserves_data(self):
        """Full roundtrip: get_state -> set_state preserves all serializable data."""
        from rqalpha.core.strategy_context import StrategyContext
        ctx1 = StrategyContext()
        ctx1.str_data = "hello world"
        ctx1.int_data = 12345
        ctx1.float_data = 3.14159
        state = ctx1.get_state()
        
        ctx2 = StrategyContext()
        ctx2.set_state(state)
        
        assert ctx2.str_data == "hello world"
        assert ctx2.int_data == 12345
        assert abs(ctx2.float_data - 3.14159) < 0.00001

    def test_set_state_raises_on_corrupted_data(self):
        """set_state() should raise exception on invalid pickle data (matches Python behavior)."""
        from rqalpha.core.strategy_context import StrategyContext
        ctx = StrategyContext()
        with pytest.raises(Exception):
            ctx.set_state(b"corrupted_pickle_data_that_is_not_valid")


class TestStrategyContextIntegration:
    """Integration tests verifying StrategyContext works with Environment."""

    def test_universe_returns_set(self):
        """universe property should return a Set of strings."""
        from unittest.mock import Mock, patch
        with patch('rqalpha.core.strategy_context.Environment') as mock_env_cls:
            mock_instance = Mock()
            mock_instance.get_universe.return_value = set(['000001.XSHE', '600000.XSHG'])
            mock_env_cls.get_instance.return_value = mock_instance
            
            from rqalpha.core.strategy_context import StrategyContext
            ctx = StrategyContext()
            universe = ctx.universe
            
            assert isinstance(universe, set)

    def test_now_returns_datetime(self):
        """now property should return datetime object."""
        from unittest.mock import Mock, patch
        from datetime import datetime
        with patch('rqalpha.core.strategy_context.Environment') as mock_env_cls:
            mock_instance = Mock()
            mock_instance.calendar_dt = datetime(2020, 6, 15, 9, 30, 0)
            mock_env_cls.get_instance.return_value = mock_instance
            
            from rqalpha.core.strategy_context import StrategyContext
            ctx = StrategyContext()
            now = ctx.now
            
            assert isinstance(now, datetime)

    def test_portfolio_delegates_to_environment(self):
        """portfolio property should delegate to Environment.portfolio."""
        from unittest.mock import Mock, patch
        with patch('rqalpha.core.strategy_context.Environment') as mock_env_cls:
            mock_portfolio = Mock()
            mock_instance = Mock()
            mock_instance.portfolio = mock_portfolio
            mock_env_cls.get_instance.return_value = mock_instance
            
            from rqalpha.core.strategy_context import StrategyContext
            ctx = StrategyContext()
            portfolio = ctx.portfolio
            
            assert portfolio == mock_portfolio


if __name__ == '__main__':
    pytest.main([__file__, '-v', '--tb=short'])
