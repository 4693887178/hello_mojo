# test_L02_02_strategy_context.py
# Module: rqalpha.core.strategy_context
# Level: L02 - Core Base
# Dependencies: portfolio, const, environment, logger

import pytest


class TestRunInfo:
    """Test RunInfo class"""
    
    def test_run_info_exists(self):
        """Test RunInfo class exists"""
        from rqalpha.core.strategy_context import RunInfo
        assert RunInfo is not None
    
    def test_run_info_properties(self):
        """Test RunInfo properties"""
        from rqalpha.core.strategy_context import RunInfo
        from rqalpha.const import RUN_TYPE
        
        class MockConfig:
            class Base:
                start_date = "2024-01-01"
                end_date = "2024-12-31"
                frequency = "1d"
                accounts = {"stock": 100000}
                margin_multiplier = 1.0
                run_type = RUN_TYPE.BACKTEST
            
            base = Base()
            
            class Mod:
                class SysSimulation:
                    matching_type = "current_bar_close"
                    slippage = 0.0
                
                class SysTransactionCost:
                    stock_commission_multiplier = 0.0003
                    futures_commission_multiplier = 0.0001
                
                sys_simulation = SysSimulation()
                sys_transaction_cost = SysTransactionCost()
            
            mod = Mod()
        
        run_info = RunInfo(MockConfig())
        assert run_info.frequency == "1d"
        assert run_info.run_type == RUN_TYPE.BACKTEST


class TestStrategyContext:
    """Test StrategyContext class"""
    
    def test_strategy_context_exists(self):
        """Test StrategyContext class exists"""
        from rqalpha.core.strategy_context import StrategyContext
        assert StrategyContext is not None
    
    def test_strategy_context_init(self):
        """Test StrategyContext initialization"""
        from rqalpha.core.strategy_context import StrategyContext
        ctx = StrategyContext()
        assert ctx is not None
    
    def test_strategy_context_repr(self):
        """Test StrategyContext repr"""
        from rqalpha.core.strategy_context import StrategyContext
        ctx = StrategyContext()
        repr_str = repr(ctx)
        assert "Context" in repr_str


class TestStrategyContextState:
    """Test StrategyContext state management"""
    
    def test_get_state(self):
        """Test get_state method"""
        from rqalpha.core.strategy_context import StrategyContext
        ctx = StrategyContext()
        ctx.test_value = 123
        state = ctx.get_state()
        assert state is not None
    
    def test_set_state(self):
        """Test set_state method"""
        from rqalpha.core.strategy_context import StrategyContext
        ctx = StrategyContext()
        ctx.test_value = 123
        state = ctx.get_state()
        
        ctx2 = StrategyContext()
        ctx2.set_state(state)
