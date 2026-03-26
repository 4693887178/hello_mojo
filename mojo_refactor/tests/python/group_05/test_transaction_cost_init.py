"""
Test for rqalpha/mod/rqalpha_mod_sys_transaction_cost/__init__.py
"""

import pytest


class TestTransactionCostInit:
    """Test transaction_cost module initialization"""

    def test_config_exists(self):
        """Test __config__ dictionary exists and has correct keys"""
        from rqalpha.mod.rqalpha_mod_sys_transaction_cost import __config__
        
        assert isinstance(__config__, dict)
        assert "cn_stock_min_commission" in __config__
        assert "stock_min_commission" in __config__
        assert "stock_commission_multiplier" in __config__
        assert "futures_commission_multiplier" in __config__
        assert "tax_multiplier" in __config__
        assert "pit_tax" in __config__

    def test_config_default_values(self):
        """Test __config__ default values"""
        from rqalpha.mod.rqalpha_mod_sys_transaction_cost import __config__
        
        assert __config__["cn_stock_min_commission"] is None
        assert __config__["stock_min_commission"] == 5
        assert __config__["stock_commission_multiplier"] == 1
        assert __config__["futures_commission_multiplier"] == 1
        assert __config__["tax_multiplier"] == 1
        assert __config__["pit_tax"] is False

    def test_cli_prefix_exists(self):
        """Test cli_prefix constant exists"""
        from rqalpha.mod.rqalpha_mod_sys_transaction_cost import cli_prefix
        
        assert cli_prefix == "mod__sys_transaction_cost__"

    def test_load_mod_function_exists(self):
        """Test load_mod function exists"""
        from rqalpha.mod.rqalpha_mod_sys_transaction_cost import load_mod
        
        assert callable(load_mod)

    def test_load_mod_returns_transaction_cost_mod(self):
        """Test load_mod returns TransactionCostMod instance"""
        from rqalpha.mod.rqalpha_mod_sys_transaction_cost import load_mod
        
        mod = load_mod()
        assert mod is not None
        assert hasattr(mod, 'start_up')
        assert hasattr(mod, 'tear_down')

    def test_mod_name(self):
        """Test module name"""
        from rqalpha.mod.rqalpha_mod_sys_transaction_cost import load_mod
        
        mod = load_mod()
        assert mod.__class__.__name__ == "TransactionCostMod"


class TestTransactionCostConfig:
    """Test transaction cost configuration"""

    def test_stock_min_commission_config(self):
        """Test stock minimum commission configuration"""
        from rqalpha.mod.rqalpha_mod_sys_transaction_cost import __config__
        
        assert __config__["stock_min_commission"] == 5

    def test_commission_multiplier_config(self):
        """Test commission multiplier configuration"""
        from rqalpha.mod.rqalpha_mod_sys_transaction_cost import __config__
        
        assert __config__["stock_commission_multiplier"] == 1
        assert __config__["futures_commission_multiplier"] == 1

    def test_tax_config(self):
        """Test tax configuration"""
        from rqalpha.mod.rqalpha_mod_sys_transaction_cost import __config__
        
        assert __config__["tax_multiplier"] == 1
        assert __config__["pit_tax"] is False


class TestCLIOptions:
    """Test CLI options registration"""

    def test_cli_options_registered(self):
        """Test CLI options are registered"""
        from rqalpha import cli
        
        run_cmd = cli.commands.get('run')
        assert run_cmd is not None
        
        param_names = [p.name for p in run_cmd.params]
        
        assert 'commission_multiplier' in param_names or 'mod__sys_transaction_cost__commission_multiplier' in param_names
