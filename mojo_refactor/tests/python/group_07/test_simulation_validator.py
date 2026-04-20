# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_simulation/validator.py
Group 07 - File 08
"""

import pytest
from unittest.mock import Mock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestOrderStyleValidatorStructure:
    def test_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.validator import OrderStyleValidator
        assert OrderStyleValidator is not None

    def test_inherits_abstract_frontend_validator(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.validator import OrderStyleValidator
        from rqalpha.interface import AbstractFrontendValidator
        assert issubclass(OrderStyleValidator, AbstractFrontendValidator)

    def test_class_methods(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.validator import OrderStyleValidator
        expected_methods = ['__init__', 'validate_submission', 'validate_cancellation']
        for method in expected_methods:
            assert method in dir(OrderStyleValidator), f"Missing method: {method}"


class TestOrderStyleValidatorInit:
    def test_init(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.validator import OrderStyleValidator
        
        validator = OrderStyleValidator(frequency="1d")
        assert validator._frequency == "1d"


class TestOrderStyleValidatorSubmission:
    def test_validate_submission_market_order(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.validator import OrderStyleValidator
        from rqalpha.const import ORDER_TYPE
        
        validator = OrderStyleValidator(frequency="1d")
        
        mock_order = Mock()
        mock_order.style = Mock()
        mock_order.style.style_type = ORDER_TYPE.MARKET
        
        result = validator.validate_submission(mock_order, None)
        
        # Market order should pass
        assert result is None

    def test_validate_submission_tick_frequency(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.validator import OrderStyleValidator
        from rqalpha.model.order import ALGO_ORDER_STYLES
        
        validator = OrderStyleValidator(frequency="tick")
        
        mock_order = Mock()
        mock_order.style = Mock()
        
        # Test with non-algo style
        result = validator.validate_submission(mock_order, None)
        assert result is None


class TestOrderStyleValidatorCancellation:
    def test_validate_cancellation(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.validator import OrderStyleValidator
        
        validator = OrderStyleValidator(frequency="1d")
        
        result = validator.validate_cancellation(Mock(), None)
        
        # Should always return None
        assert result is None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
