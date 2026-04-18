# -*- coding: utf-8 -*-
"""
Integration Test for rqalpha/utils/testing/mocking.py (Python Original)
Group 07 - File 10

Purpose: Verify Python original behavior as reference for Mojo refactoring alignment.
Note: Some tests require RQAlpha Environment (BarObject), others are standalone.
"""

import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestMockInstrument:
    """Test mock_instrument() - Python original behavior (standalone, no Env needed)."""

    def test_default_params(self):
        from rqalpha.utils.testing.mocking import mock_instrument
        ins = mock_instrument()
        assert ins.order_book_id == "000001"
        assert ins.type == "CS"
        assert ins.exchange == "XSHE"

    def test_custom_order_book_id(self):
        from rqalpha.utils.testing.mocking import mock_instrument
        ins = mock_instrument(order_book_id="600000.XSHG")
        assert ins.order_book_id == "600000.XSHG"

    def test_custom_type_and_exchange(self):
        from rqalpha.utils.testing.mocking import mock_instrument
        ins = mock_instrument(order_book_id="CU2409", _type="FUTURE", exchange="SHFE")
        assert ins.order_book_id == "CU2409"
        assert ins.type == "Future"
        assert ins.exchange == "SHFE"

    def test_kwargs_support(self):
        """Python original supports **kwargs passed to Instrument."""
        from rqalpha.utils.testing.mocking import mock_instrument
        ins = mock_instrument(order_book_id="000001", symbol="CUSTOM")
        assert hasattr(ins, 'symbol')

    def test_returns_instrument_instance(self):
        from rqalpha.utils.testing.mocking import mock_instrument
        from rqalpha.model.instrument import Instrument
        ins = mock_instrument()
        assert isinstance(ins, Instrument)


class TestMockBar:
    """
    Test mock_bar() - Python original behavior.
    NOTE: BarObject requires RQAlpha Environment -> these tests verify the API signature only.
    """

    def test_mock_bar_is_callable(self):
        from rqalpha.utils.testing.mocking import mock_bar
        assert callable(mock_bar)

    def test_mock_bar_signature_accepts_kwargs(self):
        """Verify mock_bar accepts instrument + **kwargs (Python idiom)."""
        from rqalpha.utils.testing.mocking import mock_bar, mock_instrument
        import inspect
        sig = inspect.signature(mock_bar)
        params = list(sig.parameters.keys())
        assert 'instrument' in params


class TestMockTick:
    """Test mock_tick() - Python original behavior."""

    def test_mock_tick_is_callable(self):
        from rqalpha.utils.testing.mocking import mock_tick
        assert callable(mock_tick)

    def test_mock_tick_returns_tick_object(self):
        from rqalpha.utils.testing.mocking import mock_tick, mock_instrument
        from rqalpha.model.tick import TickObject
        ins = mock_instrument()
        tick = mock_tick(ins)
        assert isinstance(tick, TickObject)

    def test_mock_tick_kwargs_support(self):
        from rqalpha.utils.testing.mocking import mock_tick, mock_instrument
        ins = mock_instrument()
        tick = mock_tick(ins, last=15.5, volume=999)
        assert tick is not None


class TestPythonVsMojoAlignment:
    """
    Document behavioral differences between Python and Mojo implementations.

    Key Design Differences (intentional):
    ┌─────────────────────┬──────────────────────┬──────────────────────┐
    │ Feature             │ Python Original       │ Mojo Refactored      │
    ├─────────────────────┼──────────────────────┼──────────────────────┤
    │ Parameters          │ **kwargs (flexible)  │ Explicit (type-safe) │
    │ Type param name     │ _type                │ ins_type             │
    │ Env dependency      │ BarObject needs Env  │ No Env needed         │
    │ Extra utilities     │ None                 │ MockDataProxy,       │
    │                     │                      │ create_mock_order    │
    └─────────────────────┴──────────────────────┴──────────────────────┘
    """

    def test_python_uses_kwargs(self):
        from rqalpha.utils.testing.mocking import mock_instrument
        ins = mock_instrument(order_book_id="000001", custom_field="value")
        assert ins.order_book_id == "000001"

    def test_python_type_param_name_is_underscore_type(self):
        from rqalpha.utils.testing.mocking import mock_instrument
        ins = mock_instrument(order_book_id="000001", _type="CS")
        assert ins.type.value == "CS"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
