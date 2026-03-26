# -*- coding: utf-8 -*-
"""
Test for data/base_data_source/storage_interface.py
Group 08 - File 3
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestAbstractDayBarStore:
    def test_abstract_day_bar_store_exists(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractDayBarStore
        assert AbstractDayBarStore is not None

    def test_abstract_day_bar_store_has_get_bars(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractDayBarStore
        assert hasattr(AbstractDayBarStore, 'get_bars')

    def test_abstract_day_bar_store_has_get_date_range(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractDayBarStore
        assert hasattr(AbstractDayBarStore, 'get_date_range')


class TestAbstractCalendarStore:
    def test_abstract_calendar_store_exists(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractCalendarStore
        assert AbstractCalendarStore is not None

    def test_abstract_calendar_store_has_get_trading_calendar(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractCalendarStore
        assert hasattr(AbstractCalendarStore, 'get_trading_calendar')


class TestAbstractDateSet:
    def test_abstract_date_set_exists(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractDateSet
        assert AbstractDateSet is not None

    def test_abstract_date_set_has_contains(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractDateSet
        assert hasattr(AbstractDateSet, 'contains')


class TestAbstractDividendStore:
    def test_abstract_dividend_store_exists(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractDividendStore
        assert AbstractDividendStore is not None

    def test_abstract_dividend_store_has_get_dividend(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractDividendStore
        assert hasattr(AbstractDividendStore, 'get_dividend')


class TestAbstractSimpleFactorStore:
    def test_abstract_simple_factor_store_exists(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractSimpleFactorStore
        assert AbstractSimpleFactorStore is not None

    def test_abstract_simple_factor_store_has_get_factors(self):
        from rqalpha.data.base_data_source.storage_interface import AbstractSimpleFactorStore
        assert hasattr(AbstractSimpleFactorStore, 'get_factors')


class TestStorageInterfaceImports:
    def test_import_abc(self):
        import abc
        assert abc is not None

    def test_import_numpy(self):
        import numpy as np
        assert np is not None

    def test_import_pandas(self):
        import pandas
        assert pandas is not None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
