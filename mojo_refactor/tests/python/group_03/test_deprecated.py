# -*- coding: utf-8 -*-
"""
Test for rqalpha/data/base_data_source/deprecated.py
Tests for deprecated functions and InstrumentStore
"""

import pytest


class TestAbstractInstrumentStore:
    """Tests for AbstractInstrumentStore class"""

    def test_abstract_instrument_store_exists(self):
        """Test that AbstractInstrumentStore class exists"""
        from rqalpha.data.base_data_source.deprecated import AbstractInstrumentStore
        assert AbstractInstrumentStore is not None


class TestInstrumentStore:
    """Tests for InstrumentStore class"""

    def test_instrument_store_class_exists(self):
        """Test that InstrumentStore class exists"""
        from rqalpha.data.base_data_source.deprecated import InstrumentStore
        assert InstrumentStore is not None

    def test_instrument_store_instrument_type_property(self):
        """Test that InstrumentStore has instrument_type property"""
        from rqalpha.data.base_data_source.deprecated import InstrumentStore
        from rqalpha.const import INSTRUMENT_TYPE
        assert hasattr(InstrumentStore, 'instrument_type')

    def test_instrument_store_all_id_and_syms_property(self):
        """Test that InstrumentStore has all_id_and_syms property"""
        from rqalpha.data.base_data_source.deprecated import InstrumentStore
        assert hasattr(InstrumentStore, 'all_id_and_syms')

    def test_instrument_store_get_instruments_method(self):
        """Test that InstrumentStore has get_instruments method"""
        from rqalpha.data.base_data_source.deprecated import InstrumentStore
        assert hasattr(InstrumentStore, 'get_instruments')
