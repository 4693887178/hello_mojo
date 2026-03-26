# -*- coding: utf-8 -*-
"""
Test for core/strategy.py
Group 09 - File 9
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestStrategy:
    def test_strategy_class_exists(self):
        from rqalpha.core.strategy import Strategy
        assert Strategy is not None

    def test_strategy_has_init(self):
        from rqalpha.core.strategy import Strategy
        assert hasattr(Strategy, 'init')

    def test_strategy_has_handle_bar(self):
        from rqalpha.core.strategy import Strategy
        assert hasattr(Strategy, 'handle_bar')

    def test_strategy_has_before_trading(self):
        from rqalpha.core.strategy import Strategy
        assert hasattr(Strategy, 'before_trading')

    def test_strategy_has_after_trading(self):
        from rqalpha.core.strategy import Strategy
        assert hasattr(Strategy, 'after_trading')


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
