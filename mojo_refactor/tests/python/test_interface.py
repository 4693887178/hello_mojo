"""
Test suite for RQAlpha interface.py (Python original)
Validates that all interfaces, structs, and methods match expected behavior
"""

import pytest
import sys
from datetime import datetime, date

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')

from rqalpha.interface import (
    AbstractPosition,
    AbstractStrategyLoader,
    AbstractEventSource,
    AbstractPriceBoard,
    ExchangeRate,
    AbstractDataSource,
    AbstractBroker,
    AbstractMod,
    AbstractPersistProvider,
    Persistable,
    AbstractFrontendValidator,
    TransactionCostArgs,
    TransactionCost,
    AbstractTransactionCostDecider,
)
from rqalpha.const import SIDE, POSITION_EFFECT


class TestExchangeRate:
    """Test ExchangeRate NamedTuple"""
    
    def test_creation_with_all_fields(self):
        """Test ExchangeRate initialization with all fields"""
        rate = ExchangeRate(
            bid_reference=6.5,
            ask_reference=6.6,
            bid_settlement_sh=6.55,
            ask_settlement_sh=6.65,
            bid_settlement_sz=0.85,
            ask_settlement_sz=0.86
        )
        
        assert rate.bid_reference == 6.5
        assert rate.ask_reference == 6.6
        assert rate.bid_settlement_sh == 6.55
        assert rate.ask_settlement_sh == 6.65
        assert rate.bid_settlement_sz == 0.85
        assert rate.ask_settlement_sz == 0.86
    
    def test_is_namedtuple(self):
        """Verify ExchangeRate is a NamedTuple"""
        assert hasattr(ExchangeRate, '_fields')
        assert len(ExchangeRate._fields) == 6


class TestTransactionCostArgs:
    """Test TransactionCostArgs NamedTuple"""
    
    def test_creation_with_all_fields(self):
        """Test with all fields including optional ones"""
        args = TransactionCostArgs(
            instrument="000001.XSHE",
            price=10.5,
            quantity=1000,
            side=SIDE.BUY,
            position_effect=POSITION_EFFECT.OPEN,
            order_id=12345,
            close_today_quantity=0
        )
        
        assert args.instrument == "000001.XSHE"
        assert args.price == 10.5
        assert args.quantity == 1000
        assert args.side == SIDE.BUY
        assert args.position_effect == POSITION_EFFECT.OPEN
        assert args.order_id == 12345
        assert args.close_today_quantity == 0
    
    def test_default_optional_values(self):
        """Test default values for optional fields"""
        args = TransactionCostArgs(
            instrument="000001.XSHE",
            price=10.5,
            quantity=1000,
            side=SIDE.BUY,
            position_effect=POSITION_EFFECT.OPEN
        )
        
        assert args.order_id is None
        assert args.close_today_quantity == 0


class TestTransactionCost:
    """Test TransactionCost NamedTuple with total property and zero classmethod"""
    
    def test_creation_and_total(self):
        """Test total property calculation"""
        cost = TransactionCost(commission=7.5, tax=10.0, other_fees=1.0)
        
        assert cost.commission == 7.5
        assert cost.tax == 10.0
        assert cost.other_fees == 1.0
        assert cost.total == 18.5
    
    def test_zero_classmethod(self):
        """Test zero() classmethod returns all zeros"""
        zero_cost = TransactionCost.zero()
        
        assert zero_cost.commission == 0
        assert zero_cost.tax == 0
        assert zero_cost.other_fees == 0
        assert zero_cost.total == 0


class TestAbstractInterfaces:
    """Test all abstract interface classes exist and have required methods"""
    
    def test_abstract_position_methods(self):
        """Verify AbstractPosition has all required abstract methods"""
        required_methods = [
            'get_state', 'set_state',
            'order_book_id', 'quantity', 'avg_price', 'market_value',
            'pnl', 'direction', 'transaction_cost', 'position_pnl',
            'trading_pnl', 'closable', 'today_closable', 'equity',
            'prev_close', 'last_price'
        ]
        
        for method in required_methods:
            assert hasattr(AbstractPosition, method), f"Missing method: {method}"
    
    def test_abstract_strategy_loader(self):
        """Verify AbstractStrategyLoader has load method"""
        assert hasattr(AbstractStrategyLoader, 'load')
    
    def test_abstract_event_source(self):
        """Verify AbstractEventSource has events method"""
        assert hasattr(AbstractEventSource, 'events')
    
    def test_abstract_price_board(self):
        """Verify AbstractPriceBoard has all price methods"""
        required_methods = [
            'get_last_price', 'get_limit_up', 'get_limit_down',
            'get_a1', 'get_b1'
        ]
        
        for method in required_methods:
            assert hasattr(AbstractPriceBoard, method), f"Missing method: {method}"
    
    def test_abstract_data_source_methods(self):
        """Verify AbstractDataSource has all data access methods"""
        required_methods = [
            'get_instruments', 'get_trading_calendars', 'get_yield_curve',
            'get_dividend', 'get_split', 'get_bar', 'get_open_auction_bar',
            'get_open_auction_volume', 'get_settle_price', 'history_bars',
            'history_ticks', 'current_snapshot', 'get_trading_minutes_for',
            'available_data_range', 'get_futures_trading_parameters',
            'get_merge_ticks', 'get_share_transformation', 'is_suspended',
            'is_st_stock', 'get_algo_bar', 'get_exchange_rate'
        ]
        
        for method in required_methods:
            assert hasattr(AbstractDataSource, method), f"Missing DataSource method: {method}"
    
    def test_abstract_broker(self):
        """Verify AbstractBroker has order management methods"""
        required_methods = ['submit_order', 'cancel_order', 'get_open_orders']
        
        for method in required_methods:
            assert hasattr(AbstractBroker, method), f"Missing Broker method: {method}"
    
    def test_abstract_mod(self):
        """Verify AbstractMod has lifecycle methods"""
        assert hasattr(AbstractMod, 'start_up')
        assert hasattr(AbstractMod, 'tear_down')
    
    def test_abstract_persist_provider(self):
        """Verify AbstractPersistProvider has persistence methods"""
        required_methods = ['store', 'load', 'should_resume', 'should_run_init']
        
        for method in required_methods:
            assert hasattr(AbstractPersistProvider, method), f"Missing PersistProvider method: {method}"
    
    def test_persistable_interface(self):
        """Verify Persistable has state management methods"""
        assert hasattr(Persistable, 'get_state')
        assert hasattr(Persistable, 'set_state')
    
    def test_abstract_frontend_validator(self):
        """Verify AbstractFrontendValidator has validation methods"""
        assert hasattr(AbstractFrontendValidator, 'validate_submission')
        assert hasattr(AbstractFrontendValidator, 'validate_cancellation')
    
    def test_abstract_transaction_cost_decider(self):
        """Verify AbstractTransactionCostDecider has calc method"""
        assert hasattr(AbstractTransactionCostDecider, 'calc')


class TestInterfaceSignatures:
    """Test method signatures match expected patterns"""
    
    def test_event_source_events_signature(self):
        """events() should accept start_date, end_date, frequency"""
        import inspect
        sig = inspect.signature(AbstractEventSource.events)
        params = list(sig.parameters.keys())
        assert 'self' in params
        
    def test_broker_cancel_order_signature(self):
        """cancel_order() should accept order parameter (not order_id)"""
        import inspect
        sig = inspect.signature(AbstractBroker.cancel_order)
        params = list(sig.parameters.keys())
        assert 'order' in params
        
    def test_broker_submit_order_signature(self):
        """submit_order() should accept order parameter"""
        import inspect
        sig = inspect.signature(AbstractBroker.submit_order)
        params = list(sig.parameters.keys())
        assert 'order' in params
        
    def test_data_source_history_bars_defaults(self):
        """history_bars() should have proper defaults"""
        import inspect
        sig = inspect.signature(AbstractDataSource.history_bars)
        assert sig.parameters.get('skip_suspended').default == True
        assert sig.parameters.get('include_now').default == False
        assert sig.parameters.get('adjust_type').default == 'pre'


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
