# -*- coding: utf-8 -*-
"""
Test for rqalpha/model/__init__.py
Tests for model package initialization
"""

import pytest


class TestModelPackageInit:
    """Tests for model package initialization"""

    def test_model_module_imports(self):
        """Test that model module can be imported"""
        from rqalpha import model
        assert model is not None

    def test_order_import(self):
        """Test that Order can be imported"""
        from rqalpha.model import Order
        assert Order is not None

    def test_trade_import(self):
        """Test that Trade can be imported"""
        from rqalpha.model import Trade
        assert Trade is not None

    def test_instrument_import(self):
        """Test that Instrument can be imported"""
        from rqalpha.model import Instrument
        assert Instrument is not None

    def test_bar_import(self):
        """Test that BarObject can be imported"""
        from rqalpha.model import BarObject
        assert BarObject is not None

    def test_tick_import(self):
        """Test that TickObject can be imported"""
        from rqalpha.model import TickObject
        assert TickObject is not None


class TestOrderStyle:
    """Tests for OrderStyle"""

    def test_order_style_import(self):
        """Test that OrderStyle can be imported"""
        from rqalpha.model import OrderStyle
        assert OrderStyle is not None


class TestBarMap:
    """Tests for BarMap"""

    def test_bar_map_import(self):
        """Test that BarMap can be imported"""
        from rqalpha.model import BarMap
        assert BarMap is not None
