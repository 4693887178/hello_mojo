# -*- coding: utf-8 -*-
"""
Python Test for rqalpha/data/base_data_source/deprecated.py
Tests the InstrumentStore class
"""

import pytest


def test_instrument_store_import():
    """Test that InstrumentStore can be imported"""
    from rqalpha.data.base_data_source.deprecated import InstrumentStore
    assert InstrumentStore is not None


def test_abstract_instrument_store_import():
    """Test that AbstractInstrumentStore can be imported"""
    from rqalpha.data.base_data_source.deprecated import AbstractInstrumentStore
    assert AbstractInstrumentStore is not None


def test_instrument_store_creation():
    """Test creating an InstrumentStore"""
    from rqalpha.data.base_data_source.deprecated import InstrumentStore
    from rqalpha.model.instrument import Instrument
    from rqalpha.const import INSTRUMENT_TYPE
    
    instruments = []
    store = InstrumentStore(instruments, INSTRUMENT_TYPE.CS)
    assert store is not None


def test_instrument_store_instrument_type():
    """Test InstrumentStore instrument_type property"""
    from rqalpha.data.base_data_source.deprecated import InstrumentStore
    from rqalpha.const import INSTRUMENT_TYPE
    
    store = InstrumentStore([], INSTRUMENT_TYPE.CS)
    assert store.instrument_type == INSTRUMENT_TYPE.CS


def test_instrument_store_all_id_and_syms():
    """Test InstrumentStore all_id_and_syms property"""
    from rqalpha.data.base_data_source.deprecated import InstrumentStore
    from rqalpha.const import INSTRUMENT_TYPE
    
    store = InstrumentStore([], INSTRUMENT_TYPE.CS)
    result = list(store.all_id_and_syms)
    assert isinstance(result, list)


def test_instrument_store_get_instruments_none():
    """Test InstrumentStore get_instruments with None"""
    from rqalpha.data.base_data_source.deprecated import InstrumentStore
    from rqalpha.const import INSTRUMENT_TYPE
    
    store = InstrumentStore([], INSTRUMENT_TYPE.CS)
    result = list(store.get_instruments(None))
    assert isinstance(result, list)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
