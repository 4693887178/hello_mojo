# test_L03_03_tick.py
# Module: rqalpha.model.tick
# Level: L03 - Data Model
# Dependencies: instrument, datetime

import pytest
from datetime import datetime


class TestTickObject:
    """Test TickObject class"""
    
    def test_tick_object_exists(self):
        """Test TickObject class exists"""
        from rqalpha.model.tick import TickObject
        assert TickObject is not None
    
    def test_tick_object_order_book_id(self):
        """Test TickObject order_book_id property"""
        from rqalpha.model.tick import TickObject
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        
        tick = TickObject(ins, {
            "datetime": datetime(2024, 1, 1, 9, 30, 0),
            "last": 10.5,
            "open": 10.0,
            "high": 10.8,
            "low": 9.9,
            "prev_close": 10.0,
            "volume": 1000000,
            "total_turnover": 10500000,
        })
        
        assert tick.order_book_id == "000001.XSHE"
    
    def test_tick_object_datetime(self):
        """Test TickObject datetime property"""
        from rqalpha.model.tick import TickObject
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        
        tick = TickObject(ins, {
            "datetime": datetime(2024, 1, 1, 9, 30, 0),
            "last": 10.5,
        })
        
        assert tick.datetime == datetime(2024, 1, 1, 9, 30, 0)
    
    def test_tick_object_last(self):
        """Test TickObject last property"""
        from rqalpha.model.tick import TickObject
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        
        tick = TickObject(ins, {
            "datetime": datetime(2024, 1, 1, 9, 30, 0),
            "last": 10.5,
            "prev_close": 10.0,
        })
        
        assert tick.last == 10.5
    
    def test_tick_object_volume(self):
        """Test TickObject volume property"""
        from rqalpha.model.tick import TickObject
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        
        tick = TickObject(ins, {
            "datetime": datetime(2024, 1, 1, 9, 30, 0),
            "last": 10.5,
            "volume": 1000000,
        })
        
        assert tick.volume == 1000000
    
    def test_tick_object_high_low(self):
        """Test TickObject high and low properties"""
        from rqalpha.model.tick import TickObject
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        
        tick = TickObject(ins, {
            "datetime": datetime(2024, 1, 1, 9, 30, 0),
            "last": 10.5,
            "high": 10.8,
            "low": 9.9,
        })
        
        assert tick.high == 10.8
        assert tick.low == 9.9
    
    def test_tick_object_limit_up_down(self):
        """Test TickObject limit_up and limit_down properties"""
        from rqalpha.model.tick import TickObject
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        
        tick = TickObject(ins, {
            "datetime": datetime(2024, 1, 1, 9, 30, 0),
            "last": 10.5,
            "limit_up": 11.0,
            "limit_down": 9.0,
        })
        
        assert tick.limit_up == 11.0
        assert tick.limit_down == 9.0
    
    def test_tick_object_asks_bids(self):
        """Test TickObject asks and bids properties"""
        from rqalpha.model.tick import TickObject
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        
        tick = TickObject(ins, {
            "datetime": datetime(2024, 1, 1, 9, 30, 0),
            "last": 10.5,
            "asks": [10.6, 10.7, 10.8, 10.9, 11.0],
            "bids": [10.5, 10.4, 10.3, 10.2, 10.1],
            "ask_vols": [100, 200, 300, 400, 500],
            "bid_vols": [500, 400, 300, 200, 100],
        })
        
        assert len(tick.asks) == 5
        assert len(tick.bids) == 5
        assert tick.asks[0] == 10.6
        assert tick.bids[0] == 10.5
    
    def test_tick_object_repr(self):
        """Test TickObject repr"""
        from rqalpha.model.tick import TickObject
        from rqalpha.model.instrument import Instrument
        
        ins = Instrument({
            "order_book_id": "000001.XSHE",
            "symbol": "平安银行",
            "type": "CS",
            "exchange": "XSHE",
            "listed_date": "1991-04-03",
            "de_listed_date": "2999-12-31",
            "round_lot": 100,
        })
        
        tick = TickObject(ins, {
            "datetime": datetime(2024, 1, 1, 9, 30, 0),
            "last": 10.5,
            "open": 10.0,
            "high": 10.8,
            "low": 9.9,
            "prev_close": 10.0,
            "volume": 1000000,
            "total_turnover": 10500000,
        })
        
        repr_str = repr(tick)
        assert "Tick" in repr_str
