"""
Test for rqalpha/mod/rqalpha_mod_sys_transaction_cost/deciders.py
"""

import pytest
from datetime import datetime
from unittest.mock import Mock, MagicMock, patch


class TestStockTransactionCostDecider:
    """Test StockTransactionCostDecider"""

    @pytest.fixture
    def mock_environment(self):
        """Create mock environment"""
        mock_env = Mock()
        yield mock_env

    @pytest.fixture
    def decider(self, mock_environment):
        """Create a StockTransactionCostDecider instance"""
        from rqalpha.mod.rqalpha_mod_sys_transaction_cost.deciders import StockTransactionCostDecider
        
        event_bus = Mock()
        with patch('rqalpha.mod.rqalpha_mod_sys_transaction_cost.deciders.Environment.get_instance', return_value=mock_environment):
            decider = StockTransactionCostDecider(
                commission_multiplier=1.0,
                min_commission=5.0,
                tax_multiplier=1.0,
                pit_tax=False,
                event_bus=event_bus
            )
        return decider

    def test_commission_rate_default(self, decider):
        """Test default commission rate"""
        assert decider.commission_rate == 0.0008

    def test_tax_rate_default(self, decider):
        """Test default tax rate"""
        assert decider.tax_rate == 0.0005

    def test_calc_commission_below_min(self, decider):
        """Test commission calculation below minimum"""
        from rqalpha.interface import TransactionCostArgs
        from rqalpha.model.instrument import Instrument
        
        instrument = Mock(spec=Instrument)
        instrument.type = Mock()
        
        args = TransactionCostArgs(
            order_id="test_order",
            instrument=instrument,
            side=Mock(),
            position_effect=Mock(),
            price=10.0,
            quantity=100,
            close_today_quantity=0
        )
        
        commission = decider._calc_commission(args)
        assert commission == 5.0

    def test_calc_commission_above_min(self, decider):
        """Test commission calculation above minimum"""
        from rqalpha.interface import TransactionCostArgs
        from rqalpha.model.instrument import Instrument
        
        instrument = Mock(spec=Instrument)
        instrument.type = Mock()
        
        args = TransactionCostArgs(
            order_id="test_order_2",
            instrument=instrument,
            side=Mock(),
            position_effect=Mock(),
            price=100.0,
            quantity=1000,
            close_today_quantity=0
        )
        
        commission = decider._calc_commission(args)
        assert commission == 80.0

    def test_calc_tax_buy_side(self, decider):
        """Test tax calculation for buy side"""
        from rqalpha.interface import TransactionCostArgs
        from rqalpha.const import SIDE
        from rqalpha.model.instrument import Instrument
        
        instrument = Mock(spec=Instrument)
        instrument.type = Mock()
        
        args = TransactionCostArgs(
            order_id="test_order",
            instrument=instrument,
            side=SIDE.BUY,
            position_effect=Mock(),
            price=10.0,
            quantity=100,
            close_today_quantity=0
        )
        
        tax = decider._calc_tax(args)
        assert tax == 0

    def test_calc_tax_sell_side(self, decider):
        """Test tax calculation for sell side"""
        from rqalpha.interface import TransactionCostArgs
        from rqalpha.const import SIDE, INSTRUMENT_TYPE
        from rqalpha.model.instrument import Instrument
        
        instrument = Mock(spec=Instrument)
        instrument.type = INSTRUMENT_TYPE.CS
        
        args = TransactionCostArgs(
            order_id="test_order",
            instrument=instrument,
            side=SIDE.SELL,
            position_effect=Mock(),
            price=10.0,
            quantity=100,
            close_today_quantity=0
        )
        
        tax = decider._calc_tax(args)
        assert tax == 0.5

    def test_calc_returns_transaction_cost(self, decider):
        """Test calc returns TransactionCost"""
        from rqalpha.interface import TransactionCostArgs, TransactionCost
        from rqalpha.const import SIDE, INSTRUMENT_TYPE
        from rqalpha.model.instrument import Instrument
        
        instrument = Mock(spec=Instrument)
        instrument.type = INSTRUMENT_TYPE.CS
        
        args = TransactionCostArgs(
            order_id="test_order",
            instrument=instrument,
            side=SIDE.SELL,
            position_effect=Mock(),
            price=10.0,
            quantity=100,
            close_today_quantity=0
        )
        
        result = decider.calc(args)
        assert isinstance(result, TransactionCost)
        assert result.commission == 5.0
        assert result.tax == 0.5
        assert result.other_fees == 0


class TestFuturesTransactionCostDecider:
    """Test FuturesTransactionCostDecider"""

    @pytest.fixture
    def mock_environment(self):
        """Create mock environment"""
        mock_env = Mock()
        mock_data_proxy = Mock()
        mock_env.data_proxy = mock_data_proxy
        mock_env.trading_dt = datetime(2025, 1, 15)
        
        trading_params = Mock()
        trading_params.commission_type = Mock()
        trading_params.open_commission_ratio = 0.000023
        trading_params.close_commission_ratio = 0.000023
        trading_params.close_commission_today_ratio = 0.000023
        mock_data_proxy.get_futures_trading_parameters.return_value = trading_params
        
        return mock_env

    @pytest.fixture
    def decider(self, mock_environment):
        """Create a FuturesTransactionCostDecider instance"""
        from rqalpha.mod.rqalpha_mod_sys_transaction_cost.deciders import FuturesTransactionCostDecider
        
        with patch('rqalpha.mod.rqalpha_mod_sys_transaction_cost.deciders.Environment.get_instance', return_value=mock_environment):
            decider = FuturesTransactionCostDecider(commission_multiplier=1.0)
        return decider

    def test_hedge_type_default(self, decider):
        """Test default hedge type"""
        from rqalpha.const import HEDGE_TYPE
        assert decider.hedge_type == HEDGE_TYPE.SPECULATION

    def test_calc_returns_transaction_cost(self, decider, mock_environment):
        """Test calc returns TransactionCost with zero tax"""
        from rqalpha.interface import TransactionCostArgs, TransactionCost
        from rqalpha.const import POSITION_EFFECT
        from rqalpha.model.instrument import Instrument
        
        instrument = Mock(spec=Instrument)
        instrument.order_book_id = "IF2501"
        instrument.contract_multiplier = 300
        
        args = TransactionCostArgs(
            order_id="test_order",
            instrument=instrument,
            side=Mock(),
            position_effect=POSITION_EFFECT.OPEN,
            price=4000.0,
            quantity=1,
            close_today_quantity=0
        )
        
        with patch('rqalpha.mod.rqalpha_mod_sys_transaction_cost.deciders.Environment.get_instance', return_value=mock_environment):
            result = decider.calc(args)
            assert isinstance(result, TransactionCost)
            assert result.tax == 0


class TestAbstractStockTransactionCostDecider:
    """Test AbstractStockTransactionCostDecider"""

    def test_is_subclass_of_abstract_transaction_cost_decider(self):
        from rqalpha.mod.rqalpha_mod_sys_transaction_cost.deciders import AbstractStockTransactionCostDecider
        from rqalpha.interface import AbstractTransactionCostDecider
        
        assert issubclass(AbstractStockTransactionCostDecider, AbstractTransactionCostDecider)

    def test_batch_estimate_raises_not_implemented(self):
        from rqalpha.mod.rqalpha_mod_sys_transaction_cost.deciders import AbstractStockTransactionCostDecider
        from rqalpha.interface import TransactionCostArgs, TransactionCost
        from unittest.mock import Mock
        
        class ConcreteDecider(AbstractStockTransactionCostDecider):
            def calc(self, args):
                return TransactionCost(commission=0, tax=0, other_fees=0)
        
        decider = ConcreteDecider()
        with pytest.raises(NotImplementedError):
            decider.batch_estimate(None, None)
