"""
Test for rqalpha/mod/rqalpha_mod_sys_transaction_cost/mod.py
"""

import pytest
from unittest.mock import Mock, MagicMock, patch


class TestTransactionCostMod:
    """Test TransactionCostMod"""

    @pytest.fixture
    def mod(self):
        """Create a TransactionCostMod instance"""
        from rqalpha.mod.rqalpha_mod_sys_transaction_cost.mod import TransactionCostMod
        return TransactionCostMod()

    @pytest.fixture
    def mock_env(self):
        """Create mock environment"""
        env = Mock()
        env.set_transaction_cost_decider = Mock()
        env.event_bus = Mock()
        env.event_bus.add_listener = Mock()
        return env

    @pytest.fixture
    def mock_config(self):
        """Create mock config"""
        config = Mock()
        config.stock_commission_multiplier = 1.0
        config.futures_commission_multiplier = 1.0
        config.cn_stock_min_commission = None
        config.stock_min_commission = 5.0
        config.tax_multiplier = 1.0
        config.pit_tax = False
        return config

    def test_start_up_sets_stock_decider(self, mod, mock_env, mock_config):
        """Test start_up sets stock transaction cost decider"""
        with patch('rqalpha.environment.Environment.get_instance', return_value=mock_env):
            mod.start_up(mock_env, mock_config)
        
        assert mock_env.set_transaction_cost_decider.called

    def test_start_up_sets_future_decider(self, mod, mock_env, mock_config):
        """Test start_up sets future transaction cost decider"""
        with patch('rqalpha.environment.Environment.get_instance', return_value=mock_env):
            mod.start_up(mock_env, mock_config)
        
            call_args = [call[0][0] for call in mock_env.set_transaction_cost_decider.call_args_list]
            from rqalpha.const import INSTRUMENT_TYPE
            assert INSTRUMENT_TYPE.FUTURE in call_args

    def test_start_up_uses_stock_min_commission(self, mod, mock_env, mock_config):
        """Test start_up uses stock_min_commission when cn_stock_min_commission is None"""
        mock_config.cn_stock_min_commission = None
        mock_config.stock_min_commission = 10.0
        
        with patch('rqalpha.environment.Environment.get_instance', return_value=mock_env):
            mod.start_up(mock_env, mock_config)

    def test_start_up_warns_deprecated_cn_stock_min_commission(self, mod, mock_env, mock_config):
        """Test start_up warns about deprecated cn_stock_min_commission"""
        mock_config.cn_stock_min_commission = 5.0
        
        with patch('rqalpha.environment.Environment.get_instance', return_value=mock_env):
            with patch('rqalpha.mod.rqalpha_mod_sys_transaction_cost.mod.user_log') as mock_log:
                mod.start_up(mock_env, mock_config)
                mock_log.warning.assert_called()

    def test_tear_down(self, mod):
        """Test tear_down does nothing"""
        result = mod.tear_down(0)
        assert result is None

    def test_tear_down_with_exception(self, mod):
        """Test tear_down with exception"""
        exc = Exception("test exception")
        result = mod.tear_down(1, exc)
        assert result is None


class TestTransactionCostModIntegration:
    """Integration tests for TransactionCostMod"""

    def test_full_lifecycle(self):
        """Test full mod lifecycle"""
        from rqalpha.mod.rqalpha_mod_sys_transaction_cost.mod import TransactionCostMod
        
        mod = TransactionCostMod()
        
        mock_env = Mock()
        mock_env.set_transaction_cost_decider = Mock()
        mock_env.event_bus = Mock()
        mock_env.event_bus.add_listener = Mock()
        
        mock_config = Mock()
        mock_config.stock_commission_multiplier = 1.0
        mock_config.futures_commission_multiplier = 1.0
        mock_config.cn_stock_min_commission = None
        mock_config.stock_min_commission = 5.0
        mock_config.tax_multiplier = 1.0
        mock_config.pit_tax = False
        
        with patch('rqalpha.environment.Environment.get_instance', return_value=mock_env):
            mod.start_up(mock_env, mock_config)
        mod.tear_down(0)
