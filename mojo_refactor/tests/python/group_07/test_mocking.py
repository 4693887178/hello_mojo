# -*- coding: utf-8 -*-
"""
Test for utils/testing/mocking.py
Group 07 - File 10
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestMockInstrument:
    def test_mock_instrument_default(self):
        from rqalpha.utils.testing.mocking import mock_instrument
        
        result = mock_instrument()
        
        assert result is not None
        assert result.order_book_id == "000001"
        assert result.type == "CS"
        assert result.exchange == "XSHE"

    def test_mock_instrument_custom(self):
        from rqalpha.utils.testing.mocking import mock_instrument
        
        result = mock_instrument(
            order_book_id="600000.XSHG",
            _type="CS",
            exchange="XSHG"
        )
        
        assert result.order_book_id == "600000.XSHG"


class TestMockBar:
    def test_mock_bar_exists(self):
        from rqalpha.utils.testing.mocking import mock_bar
        assert callable(mock_bar)


class TestMockTick:
    def test_mock_tick_exists(self):
        from rqalpha.utils.testing.mocking import mock_tick
        assert callable(mock_tick)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
