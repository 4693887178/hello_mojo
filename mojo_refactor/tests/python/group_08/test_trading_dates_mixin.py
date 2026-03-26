# -*- coding: utf-8 -*-
"""
Test for data/trading_dates_mixin.py
Group 08 - File 5
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
from datetime import datetime, date
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestTradingDatesMixin:
    def test_trading_dates_mixin_class_exists(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert TradingDatesMixin is not None

    def test_trading_dates_mixin_has_get_trading_calendar(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert hasattr(TradingDatesMixin, 'get_trading_calendar')

    def test_trading_dates_mixin_has_get_trading_dates(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert hasattr(TradingDatesMixin, 'get_trading_dates')

    def test_trading_dates_mixin_has_get_previous_trading_date(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert hasattr(TradingDatesMixin, 'get_previous_trading_date')

    def test_trading_dates_mixin_has_get_next_trading_date(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert hasattr(TradingDatesMixin, 'get_next_trading_date')

    def test_trading_dates_mixin_has_is_trading_date(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert hasattr(TradingDatesMixin, 'is_trading_date')

    def test_trading_dates_mixin_has_get_trading_dt(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert hasattr(TradingDatesMixin, 'get_trading_dt')

    def test_trading_dates_mixin_has_get_future_trading_date(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert hasattr(TradingDatesMixin, 'get_future_trading_date')

    def test_trading_dates_mixin_has_get_n_trading_dates_until(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert hasattr(TradingDatesMixin, 'get_n_trading_dates_until')

    def test_trading_dates_mixin_has_count_trading_dates(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert hasattr(TradingDatesMixin, 'count_trading_dates')

    def test_trading_dates_mixin_has_batch_get_trading_date(self):
        from rqalpha.data.trading_dates_mixin import TradingDatesMixin
        assert hasattr(TradingDatesMixin, 'batch_get_trading_date')


class TestToTimestamp:
    def test_to_timestamp_function_exists(self):
        from rqalpha.data.trading_dates_mixin import _to_timestamp
        assert callable(_to_timestamp)

    def test_to_timestamp_with_string(self):
        from rqalpha.data.trading_dates_mixin import _to_timestamp
        import pandas as pd
        result = _to_timestamp("2024-01-15")
        assert isinstance(result, pd.Timestamp)

    def test_to_timestamp_with_date(self):
        from rqalpha.data.trading_dates_mixin import _to_timestamp
        import pandas as pd
        result = _to_timestamp(date(2024, 1, 15))
        assert isinstance(result, pd.Timestamp)


class TestTradingDatesMixinImports:
    def test_import_pandas(self):
        import pandas as pd
        assert pd is not None

    def test_import_numpy(self):
        import numpy as np
        assert np is not None

    def test_import_trading_calendar_type(self):
        from rqalpha.const import TRADING_CALENDAR_TYPE
        assert TRADING_CALENDAR_TYPE is not None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
