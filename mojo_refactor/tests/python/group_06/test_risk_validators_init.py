# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_risk/validators/__init__.py
Group 06 - File 02
"""

import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestRiskValidatorsInit:
    """Test Risk Validators __init__.py"""
    
    def test_imports(self):
        """Test that all validators can be imported"""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import (
            CashValidator,
            PriceValidator,
            IsTradingValidator,
            SelfTradeValidator
        )
        assert CashValidator is not None
        assert PriceValidator is not None
        assert IsTradingValidator is not None
        assert SelfTradeValidator is not None
    
    def test_all_exports(self):
        """Test __all__ exports"""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import __all__
        assert "CashValidator" in __all__
        assert "PriceValidator" in __all__
        assert "IsTradingValidator" in __all__
        assert "SelfTradeValidator" in __all__
    
    def test_cash_validator_class(self):
        """Test CashValidator class"""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import CashValidator
        assert hasattr(CashValidator, '__init__')
    
    def test_price_validator_class(self):
        """Test PriceValidator class"""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import PriceValidator
        assert hasattr(PriceValidator, '__init__')
    
    def test_is_trading_validator_class(self):
        """Test IsTradingValidator class"""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import IsTradingValidator
        assert hasattr(IsTradingValidator, '__init__')
    
    def test_self_trade_validator_class(self):
        """Test SelfTradeValidator class"""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import SelfTradeValidator
        assert hasattr(SelfTradeValidator, '__init__')


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
