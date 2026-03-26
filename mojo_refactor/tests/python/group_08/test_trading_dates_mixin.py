# -*- coding: utf-8 -*-
"""
Test for data/trading_dates_mixin.py
Group 08 - File 05
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestTradingDatesMixinStructure:
    def test_class_exists(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert TradingDatesMixin is not None

    def test_has_get_trading_dates_method(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert 'get_trading_dates' in dir(TradingDatesMixin)

    def test_has_get_previous_trading_date_method(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert 'get_previous_trading_date' in dir(TradingDatesMixin)

    def test_has_get_next_trading_date_method(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert 'get_next_trading_date' in dir(TradingDatesMixin)

    def test_has_is_trading_date_method(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert 'is_trading_date' in dir(TradingDatesMixin)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
