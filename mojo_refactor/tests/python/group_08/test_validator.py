# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_accounts/validator.py
Group 08 - File 8
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestMarginInstrumentValidator:
    def test_margin_instrument_validator_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_accounts.validator import MarginInstrumentValidator
        assert MarginInstrumentValidator is not None

    def test_margin_instrument_validator_has_validate_submission(self):
        from rqalpha.mod.rqalpha_mod_sys_accounts.validator import MarginInstrumentValidator
        assert hasattr(MarginInstrumentValidator, 'validate_submission')

    def test_margin_instrument_validator_has_validate_cancellation(self):
        from rqalpha.mod.rqalpha_mod_sys_accounts.validator import MarginInstrumentValidator
        assert hasattr(MarginInstrumentValidator, 'validate_cancellation')

    def test_margin_instrument_validator_inherits_abstract_frontend_validator(self):
        from rqalpha.mod.rqalpha_mod_sys_accounts.validator import MarginInstrumentValidator
        from rqalpha.interface import AbstractFrontendValidator
        assert issubclass(MarginInstrumentValidator, AbstractFrontendValidator)


class TestMarginInstrumentValidatorMethods:
    def test_validate_submission_returns_none_when_no_cash_liabilities(self):
        from rqalpha.mod.rqalpha_mod_sys_accounts.validator import MarginInstrumentValidator
        
        validator = MarginInstrumentValidator()
        
        mock_order = Mock()
        mock_order.order_book_id = "000001.XSHE"
        
        mock_account = Mock()
        mock_account.cash_liabilities = 0
        
        result = validator.validate_submission(mock_order, mock_account)
        assert result is None

    def test_validate_submission_returns_reason_when_cash_liabilities(self):
        from rqalpha.mod.rqalpha_mod_sys_accounts.validator import MarginInstrumentValidator
        
        validator = MarginInstrumentValidator()
        
        mock_order = Mock()
        mock_order.order_book_id = "000001.XSHE"
        
        mock_account = Mock()
        mock_account.cash_liabilities = 1000
        
        result = validator.validate_submission(mock_order, mock_account)
        assert result is not None
        assert "Order Creation Failed" in result

    def test_validate_cancellation_returns_none(self):
        from rqalpha.mod.rqalpha_mod_sys_accounts.validator import MarginInstrumentValidator
        
        validator = MarginInstrumentValidator()
        mock_order = Mock()
        mock_account = Mock()
        
        result = validator.validate_cancellation(mock_order, mock_account)
        assert result is None


class TestValidatorImports:
    def test_import_abstract_frontend_validator(self):
        from rqalpha.interface import AbstractFrontendValidator
        assert AbstractFrontendValidator is not None

    def test_import_order(self):
        from rqalpha.model.order import Order
        assert Order is not None

    def test_import_account(self):
        from rqalpha.portfolio.account import Account
        assert Account is not None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
