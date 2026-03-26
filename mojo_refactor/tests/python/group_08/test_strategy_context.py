# -*- coding: utf-8 -*-
"""
Test for core/strategy_context.py
Group 08 - File 02
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestStrategyContextStructure:
    def test_class_exists(self):
        from rqalpha.core.strategy_context import StrategyContext
        assert StrategyContext is not None

    def test_class_has_properties(self):
        from rqalpha.core.strategy_context import StrategyContext
        expected_properties = ['universe', 'now', 'run_info', 'portfolio', 'stock_account', 'future_account', 'config']
        for prop in expected_properties:
            assert prop in dir(StrategyContext), f"Missing property: {prop}"


class TestStrategyContextMethods:
    def test_get_state_method(self):
        from rqalpha.core.strategy_context import StrategyContext
        assert 'get_state' in dir(StrategyContext)

    def test_set_state_method(self):
        from rqalpha.core.strategy_context import StrategyContext
        assert 'set_state' in dir(StrategyContext)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
