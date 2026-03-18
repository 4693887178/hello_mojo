# test_L04_01_interface.py
# Module: rqalpha.interface
# Level: L04 - Interface Layer
# Dependencies: const, model

import pytest


class TestExchangeRate:
    """Test ExchangeRate NamedTuple"""
    
    def test_exchange_rate_exists(self):
        """Test ExchangeRate exists"""
        from rqalpha.interface import ExchangeRate
        assert ExchangeRate is not None
    
    def test_exchange_rate_fields(self):
        """Test ExchangeRate fields"""
        from rqalpha.interface import ExchangeRate
        
        rate = ExchangeRate(
            bid_reference=7.0,
            ask_reference=7.1,
            bid_settlement_sh=7.05,
            ask_settlement_sh=7.08,
            bid_settlement_sz=7.04,
            ask_settlement_sz=7.09
        )
        assert rate.bid_reference == 7.0
        assert rate.ask_reference == 7.1


class TestTransactionCostArgs:
    """Test TransactionCostArgs NamedTuple"""
    
    def test_transaction_cost_args_exists(self):
        """Test TransactionCostArgs exists"""
        from rqalpha.interface import TransactionCostArgs
        assert TransactionCostArgs is not None


class TestTransactionCost:
    """Test TransactionCost NamedTuple"""
    
    def test_transaction_cost_exists(self):
        """Test TransactionCost exists"""
        from rqalpha.interface import TransactionCost
        assert TransactionCost is not None
    
    def test_transaction_cost_total(self):
        """Test TransactionCost total property"""
        from rqalpha.interface import TransactionCost
        
        cost = TransactionCost(commission=10.0, tax=5.0, other_fees=2.0)
        assert cost.total == 17.0
    
    def test_transaction_cost_zero(self):
        """Test TransactionCost.zero() class method"""
        from rqalpha.interface import TransactionCost
        
        cost = TransactionCost.zero()
        assert cost.commission == 0
        assert cost.tax == 0
        assert cost.other_fees == 0


class TestAbstractInterfaces:
    """Test Abstract Interface classes"""
    
    def test_persistable_exists(self):
        """Test Persistable exists"""
        from rqalpha.interface import Persistable
        assert Persistable is not None
    
    def test_abstract_data_source_exists(self):
        """Test AbstractDataSource exists"""
        from rqalpha.interface import AbstractDataSource
        assert AbstractDataSource is not None
    
    def test_abstract_broker_exists(self):
        """Test AbstractBroker exists"""
        from rqalpha.interface import AbstractBroker
        assert AbstractBroker is not None
    
    def test_abstract_mod_exists(self):
        """Test AbstractMod exists"""
        from rqalpha.interface import AbstractMod
        assert AbstractMod is not None
    
    def test_abstract_persist_provider_exists(self):
        """Test AbstractPersistProvider exists"""
        from rqalpha.interface import AbstractPersistProvider
        assert AbstractPersistProvider is not None
    
    def test_abstract_event_source_exists(self):
        """Test AbstractEventSource exists"""
        from rqalpha.interface import AbstractEventSource
        assert AbstractEventSource is not None
    
    def test_abstract_price_board_exists(self):
        """Test AbstractPriceBoard exists"""
        from rqalpha.interface import AbstractPriceBoard
        assert AbstractPriceBoard is not None
    
    def test_abstract_frontend_validator_exists(self):
        """Test AbstractFrontendValidator exists"""
        from rqalpha.interface import AbstractFrontendValidator
        assert AbstractFrontendValidator is not None
    
    def test_abstract_transaction_cost_decider_exists(self):
        """Test AbstractTransactionCostDecider exists"""
        from rqalpha.interface import AbstractTransactionCostDecider
        assert AbstractTransactionCostDecider is not None
