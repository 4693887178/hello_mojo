# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_risk/validators/self_trade_validator.py
Group 09 - File 3
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestSelfTradeValidator:
    def test_self_trade_validator_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_risk.validators.self_trade_validator import SelfTradeValidator
        assert SelfTradeValidator is not None

    def test_self_trade_validator_has_validate_submission(self):
        from rqalpha.mod.rqalpha_mod_sys_risk.validators.self_trade_validator import SelfTradeValidator
        assert hasattr(SelfTradeValidator, 'validate_submission')

    def test_self_trade_validator_has_validate_cancellation(self):
        from rqalpha.mod.rqalpha_mod_sys_risk.validators.self_trade_validator import SelfTradeValidator
        assert hasattr(SelfTradeValidator, 'validate_cancellation')

    def test_self_trade_validator_inherits_abstract_frontend_validator(self):
        from rqalpha.mod.rqalpha_mod_sys_risk.validators.self_trade_validator import SelfTradeValidator
        from rqalpha.interface import AbstractFrontendValidator
        assert issubclass(SelfTradeValidator, AbstractFrontendValidator)


class TestSelfTradeValidatorMethods:
    def test_validate_cancellation_returns_none(self):
        from rqalpha.mod.rqalpha_mod_sys_risk.validators.self_trade_validator import SelfTradeValidator
        
        mock_env = Mock()
        mock_env.get_open_orders = Mock(return_value=[])
        validator = SelfTradeValidator(mock_env)
        
        mock_order = Mock()
        mock_order.order_book_id = "000001.XSHE"
        mock_order.side = Mock()
        mock_order.position_effect = Mock()
        
        mock_account = Mock()
        
        result = validator.validate_cancellation(mock_order, mock_account)
        assert result is None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
