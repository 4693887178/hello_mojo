# -*- coding: utf-8 -*-
"""
Python Test for rqalpha/model/__init__.py
Tests the model package exports
"""

import pytest


def test_order_import():
    """Test that Order can be imported from model package"""
    from rqalpha.model import Order
    assert Order is not None


def test_order_style_import():
    """Test that OrderStyle can be imported from model package"""
    from rqalpha.model import OrderStyle
    assert OrderStyle is not None


def test_trade_import():
    """Test that Trade can be imported from model package"""
    from rqalpha.model import Trade
    assert Trade is not None


def test_instrument_import():
    """Test that Instrument can be imported from model package"""
    from rqalpha.model import Instrument
    assert Instrument is not None


def test_bar_object_import():
    """Test that BarObject can be imported from model package"""
    from rqalpha.model import BarObject
    assert BarObject is not None


def test_tick_object_import():
    """Test that TickObject can be imported from model package"""
    from rqalpha.model import TickObject
    assert TickObject is not None


def test_model_package_structure():
    """Test the model package structure"""
    import rqalpha.model as model_pkg
    assert hasattr(model_pkg, 'Order')
    assert hasattr(model_pkg, 'OrderStyle')
    assert hasattr(model_pkg, 'Trade')
    assert hasattr(model_pkg, 'Instrument')
    assert hasattr(model_pkg, 'BarObject')
    assert hasattr(model_pkg, 'TickObject')


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
