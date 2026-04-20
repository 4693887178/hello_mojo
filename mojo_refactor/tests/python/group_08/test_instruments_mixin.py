# -*- coding: utf-8 -*-
"""
Test for data/instruments_mixin.py
Group 08 - File 4
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
from datetime import datetime
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestInstrumentsMixin:
    def test_instruments_mixin_class_exists(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert InstrumentsMixin is not None

    def test_instruments_mixin_has_get_active_instrument(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert hasattr(InstrumentsMixin, 'get_active_instrument')

    def test_instruments_mixin_has_get_instrument_history(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert hasattr(InstrumentsMixin, 'get_instrument_history')

    def test_instruments_mixin_has_get_active_instruments(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert hasattr(InstrumentsMixin, 'get_active_instruments')

    def test_instruments_mixin_has_get_instruments_history(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert hasattr(InstrumentsMixin, 'get_instruments_history')

    def test_instruments_mixin_has_get_all_instruments(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert hasattr(InstrumentsMixin, 'get_all_instruments')

    def test_instruments_mixin_has_assure_order_book_id(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert hasattr(InstrumentsMixin, 'assure_order_book_id')


class TestInstrumentsMixinDeprecatedMethods:
    def test_instruments_mixin_has_all_instruments_deprecated(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert hasattr(InstrumentsMixin, 'all_instruments')

    def test_instruments_mixin_has_instrument_not_none_deprecated(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert hasattr(InstrumentsMixin, 'instrument_not_none')

    def test_instruments_mixin_has_instrument_deprecated(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert hasattr(InstrumentsMixin, 'instrument')

    def test_instruments_mixin_has_instruments_deprecated(self):
        from rqalpha.data.instruments_mixin import InstrumentsMixin
        assert hasattr(InstrumentsMixin, 'instruments')


class TestInstrumentsMixinImports:
    def test_import_instrument(self):
        from rqalpha.model.instrument import Instrument
        assert Instrument is not None

    def test_import_instrument_not_found(self):
        from rqalpha.utils.exception import InstrumentNotFound
        assert InstrumentNotFound is not None

    def test_import_lru_cache(self):
        from rqalpha.utils.functools import lru_cache
        assert lru_cache is not None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
