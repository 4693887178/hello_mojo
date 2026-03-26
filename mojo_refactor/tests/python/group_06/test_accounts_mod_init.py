# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_accounts/__init__.py
Group 06 - File 03
"""

import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestAccountsModInit:
    """Test Accounts Mod __init__.py"""
    
    def test_config_exists(self):
        """Test that __config__ is defined"""
        from rqalpha.mod.rqalpha_mod_sys_accounts import __config__
        assert isinstance(__config__, dict)
    
    def test_config_keys(self):
        """Test configuration keys exist"""
        from rqalpha.mod.rqalpha_mod_sys_accounts import __config__
        expected_keys = [
            "stock_t1",
            "dividend_reinvestment",
            "dividend_tax_rate",
            "cash_return_by_stock_delisted",
            "auto_switch_order_value",
            "validate_stock_position",
            "validate_future_position",
            "financing_rate",
            "financing_stocks_restriction_enabled",
            "futures_settlement_price_type"
        ]
        for key in expected_keys:
            assert key in __config__, f"Missing key: {key}"
    
    def test_config_defaults(self):
        """Test default configuration values"""
        from rqalpha.mod.rqalpha_mod_sys_accounts import __config__
        assert __config__["stock_t1"] == True
        assert __config__["dividend_reinvestment"] == False
        assert __config__["dividend_tax_rate"] == 0.0
        assert __config__["cash_return_by_stock_delisted"] == True
        assert __config__["auto_switch_order_value"] == False
        assert __config__["validate_stock_position"] == True
        assert __config__["validate_future_position"] == True
        assert __config__["financing_rate"] == 0.0
        assert __config__["financing_stocks_restriction_enabled"] == False
        assert __config__["futures_settlement_price_type"] == "close"
    
    def test_load_mod_function(self):
        """Test load_mod function exists and returns correct type"""
        from rqalpha.mod.rqalpha_mod_sys_accounts import load_mod
        mod = load_mod()
        assert mod is not None
        assert hasattr(mod, 'start_up')
        assert hasattr(mod, 'tear_down')
    
    def test_cli_prefix(self):
        """Test CLI prefix is defined"""
        from rqalpha.mod.rqalpha_mod_sys_accounts import cli_prefix
        assert cli_prefix == "mod__sys_accounts__"
    
    def test_module_imports(self):
        """Test that module can be imported"""
        import rqalpha.mod.rqalpha_mod_sys_accounts
        assert rqalpha.mod.rqalpha_mod_sys_accounts is not None


class TestAccountsModIntegration:
    """Integration tests for Accounts Mod"""
    
    def test_mod_name(self):
        """Test mod name"""
        from rqalpha.mod.rqalpha_mod_sys_accounts import load_mod
        mod = load_mod()
        assert mod.__class__.__name__ == "AccountMod"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
