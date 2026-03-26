# -*- coding: utf-8 -*-
"""
Test for model/instrument.py
Group 09 - File 8
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
from datetime import datetime
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestInstrument:
    def test_instrument_class_exists(self):
        from rqalpha.model.instrument import Instrument
        assert Instrument is not None

    def test_instrument_has_order_book_id(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'order_book_id')

    def test_instrument_has_symbol(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'symbol')

    def test_instrument_has_type(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'type')

    def test_instrument_has_exchange(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'exchange')


class TestInstrumentMethods:
    def test_instrument_has_active_at(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'active_at')

    def test_instrument_has_listed_at(self):
        from rqalpha.model.instrument import Instrument
        assert hasattr(Instrument, 'listed_at')


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
