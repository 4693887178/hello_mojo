# -*- coding: utf-8 -*-
"""
Test for data/instruments_mixin.py
Group 08 - File 04
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestInstrumentsMixinStructure:
    def test_class_exists(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert InstrumentsMixin is not None

    def test_has_init_method(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert '__init__' in dir(InstrumentsMixin)


class TestInstrumentsMixinMethods:
    def test_get_active_instrument_method(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert 'get_active_instrument' in dir(InstrumentsMixin)

    def test_get_instrument_history_method(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert 'get_instrument_history' in dir(InstrumentsMixin)

    def test_get_all_instruments_method(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert 'get_all_instruments' in dir(InstrumentsMixin)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
