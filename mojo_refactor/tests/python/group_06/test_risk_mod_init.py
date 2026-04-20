# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_risk/__init__.py
Group 06 - File 01
"""

import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestRiskModInit:
    """Test Risk Mod __init__.py"""
    
    def test_config_exists(self):
        """Test that __config__ is defined"""
        from rqalpha.mod.rqalpha_mod_sys_risk import __config__
        assert isinstance(__config__, dict)
        assert "validate_price" in __config__
        assert "validate_is_trading" in __config__
        assert "validate_cash" in __config__
        assert "validate_self_trade" in __config__
    
    def test_config_defaults(self):
        """Test default configuration values"""
        from rqalpha.mod.rqalpha_mod_sys_risk import __config__
        assert __config__["validate_price"] == True
        assert __config__["validate_is_trading"] == True
        assert __config__["validate_cash"] == True
        assert __config__["validate_self_trade"] == False
    
    def test_load_mod_function(self):
        """Test load_mod function exists and returns correct type"""
        from rqalpha.mod.rqalpha_mod_sys_risk import load_mod
        mod = load_mod()
        assert mod is not None
        assert hasattr(mod, 'start_up')
        assert hasattr(mod, 'tear_down')
    
    def test_cli_prefix(self):
        """Test CLI prefix is defined"""
        from rqalpha.mod.rqalpha_mod_sys_risk import cli_prefix
        assert cli_prefix == "mod__sys_risk__"
    
    def test_module_imports(self):
        """Test that module can be imported"""
        import rqalpha.mod.rqalpha_mod_sys_risk
        assert rqalpha.mod.rqalpha_mod_sys_risk is not None


class TestRiskModIntegration:
    """Integration tests for Risk Mod"""
    
    def test_mod_name(self):
        """Test mod name"""
        from rqalpha.mod.rqalpha_mod_sys_risk import load_mod
        mod = load_mod()
        assert mod.__class__.__name__ == "RiskManagerMod"
    
    def test_config_modifiable(self):
        """Test that config can be modified"""
        from rqalpha.mod.rqalpha_mod_sys_risk import __config__
        original = __config__["validate_self_trade"]
        __config__["validate_self_trade"] = True
        assert __config__["validate_self_trade"] == True
        __config__["validate_self_trade"] = original


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
