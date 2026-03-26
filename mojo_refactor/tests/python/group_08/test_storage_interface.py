# -*- coding: utf-8 -*-
"""
Test for data/base_data_source/storage_interface.py
Group 08 - File 03
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestAbstractDayBarStore:
    def test_class_exists(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractDayBarStore
        assert AbstractDayBarStore is not None

    def test_has_get_bars_method(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractDayBarStore
        assert 'get_bars' in dir(AbstractDayBarStore)


class TestAbstractCalendarStore:
    def test_class_exists(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractCalendarStore
        assert AbstractCalendarStore is not None

    def test_has_get_trading_calendar_method(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractCalendarStore
        assert 'get_trading_calendar' in dir(AbstractCalendarStore)


class TestAbstractDateSet:
    def test_class_exists(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractDateSet
        assert AbstractDateSet is not None

    def test_has_contains_method(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractDateSet
        assert 'contains' in dir(AbstractDateSet)


class TestAbstractDividendStore:
    def test_class_exists(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractDividendStore
        assert AbstractDividendStore is not None

    def test_has_get_dividend_method(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractDividendStore
        assert 'get_dividend' in dir(AbstractDividendStore)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
