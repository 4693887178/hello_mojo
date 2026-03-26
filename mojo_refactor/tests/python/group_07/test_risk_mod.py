# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_risk/mod.py
Group 07 - File 05
"""

import pytest
from unittest.mock import Mock, patch
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestRiskManagerModStructure:
    def test_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        assert RiskManagerMod is not None

    def test_inherits_abstract_mod(self):
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        from rqalpha.interface import AbstractMod
        assert issubclass(RiskManagerMod, AbstractMod)

    def test_class_methods(self):
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        expected_methods = ['start_up', 'tear_down']
        for method in expected_methods:
            assert method in dir(RiskManagerMod), f"Missing method: {method}"


class TestRiskManagerModInit:
    def test_init(self):
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        mod = RiskManagerMod()
        assert mod is not None


class TestRiskManagerModStartUp:
    def test_start_up_with_validators(self):
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        
        mod = RiskManagerMod()
        mock_env = Mock()
        mock_config = Mock()
        mock_config.validate_price = True
        mock_config.validate_is_trading = True
        mock_config.validate_cash = True
        mock_config.validate_self_trade = True
        
        mod.start_up(mock_env, mock_config)
        
        # Should have added validators
        assert mock_env.add_frontend_validator.call_count == 4


class TestRiskManagerModTearDown:
    def test_tear_down(self):
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        
        mod = RiskManagerMod()
        mod.tear_down(0)  # Should not raise


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
