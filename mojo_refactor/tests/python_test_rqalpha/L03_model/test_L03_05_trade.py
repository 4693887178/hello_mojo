# test_L03_05_trade.py
# Module: rqalpha.model.trade
# Level: L03 - Data Model
# Dependencies: const, order, environment

import pytest
from datetime import datetime


class TestTradeClass:
    """Test Trade class"""
    
    def test_trade_exists(self):
        """Test Trade class exists"""
        from rqalpha.model.trade import Trade
        assert Trade is not None
    
    def test_trade_id_generator_exists(self):
        """Test trade_id_gen exists"""
        from rqalpha.model.trade import Trade
        
        assert hasattr(Trade, 'trade_id_gen')


class TestTradeProperties:
    """Test Trade properties - requires Environment"""
    
    @pytest.mark.skip(reason="Requires Environment initialization")
    def test_trade_creation(self):
        """Test trade creation"""
        from rqalpha.model.trade import Trade
        from rqalpha.const import SIDE, POSITION_EFFECT
        
        trade = Trade.__from_create__(
            order_id=1,
            price=10.0,
            amount=100,
            side=SIDE.BUY,
            position_effect=POSITION_EFFECT.OPEN,
            order_book_id="000001.XSHE"
        )
        assert trade.last_price == 10.0
        assert trade.last_quantity == 100
    
    @pytest.mark.skip(reason="Requires Environment initialization")
    def test_trade_side(self):
        """Test trade side property"""
        from rqalpha.model.trade import Trade
        from rqalpha.const import SIDE, POSITION_EFFECT
        
        trade = Trade.__from_create__(
            order_id=1,
            price=10.0,
            amount=100,
            side=SIDE.BUY,
            position_effect=POSITION_EFFECT.OPEN,
            order_book_id="000001.XSHE"
        )
        assert trade.side == SIDE.BUY
    
    @pytest.mark.skip(reason="Requires Environment initialization")
    def test_trade_position_effect(self):
        """Test trade position_effect property"""
        from rqalpha.model.trade import Trade
        from rqalpha.const import SIDE, POSITION_EFFECT
        
        trade = Trade.__from_create__(
            order_id=1,
            price=10.0,
            amount=100,
            side=SIDE.BUY,
            position_effect=POSITION_EFFECT.OPEN,
            order_book_id="000001.XSHE"
        )
        assert trade.position_effect == POSITION_EFFECT.OPEN
    
    @pytest.mark.skip(reason="Requires Environment initialization")
    def test_trade_position_direction(self):
        """Test trade position_direction property"""
        from rqalpha.model.trade import Trade
        from rqalpha.const import SIDE, POSITION_EFFECT, POSITION_DIRECTION
        
        trade = Trade.__from_create__(
            order_id=1,
            price=10.0,
            amount=100,
            side=SIDE.BUY,
            position_effect=POSITION_EFFECT.OPEN,
            order_book_id="000001.XSHE"
        )
        assert trade.position_direction == POSITION_DIRECTION.LONG


class TestTradeCost:
    """Test Trade transaction cost"""
    
    @pytest.mark.skip(reason="Requires Environment initialization")
    def test_trade_commission(self):
        """Test trade commission"""
        from rqalpha.model.trade import Trade
        from rqalpha.const import SIDE, POSITION_EFFECT
        
        trade = Trade.__from_create__(
            order_id=1,
            price=10.0,
            amount=100,
            side=SIDE.BUY,
            position_effect=POSITION_EFFECT.OPEN,
            order_book_id="000001.XSHE"
        )
        assert trade.commission >= 0
    
    @pytest.mark.skip(reason="Requires Environment initialization")
    def test_trade_tax(self):
        """Test trade tax"""
        from rqalpha.model.trade import Trade
        from rqalpha.const import SIDE, POSITION_EFFECT
        
        trade = Trade.__from_create__(
            order_id=1,
            price=10.0,
            amount=100,
            side=SIDE.SELL,
            position_effect=POSITION_EFFECT.CLOSE,
            order_book_id="000001.XSHE"
        )
        assert trade.tax >= 0


class TestTradeId:
    """Test Trade ID"""
    
    @pytest.mark.skip(reason="Requires Environment initialization")
    def test_trade_id_unique(self):
        """Test trade IDs are unique"""
        from rqalpha.model.trade import Trade
        from rqalpha.const import SIDE, POSITION_EFFECT
        
        trade1 = Trade.__from_create__(
            order_id=1,
            price=10.0,
            amount=100,
            side=SIDE.BUY,
            position_effect=POSITION_EFFECT.OPEN,
            order_book_id="000001.XSHE"
        )
        trade2 = Trade.__from_create__(
            order_id=2,
            price=11.0,
            amount=200,
            side=SIDE.BUY,
            position_effect=POSITION_EFFECT.OPEN,
            order_book_id="000002.XSHE"
        )
        assert trade1.exec_id != trade2.exec_id


class TestTradeConstants:
    """Test Trade constants and enums"""
    
    def test_side_enum(self):
        """Test SIDE enum"""
        from rqalpha.const import SIDE
        
        assert SIDE.BUY is not None
        assert SIDE.SELL is not None
    
    def test_position_effect_enum(self):
        """Test POSITION_EFFECT enum"""
        from rqalpha.const import POSITION_EFFECT
        
        assert POSITION_EFFECT.OPEN is not None
        assert POSITION_EFFECT.CLOSE is not None
    
    def test_position_direction_enum(self):
        """Test POSITION_DIRECTION enum"""
        from rqalpha.const import POSITION_DIRECTION
        
        assert POSITION_DIRECTION.LONG is not None
        assert POSITION_DIRECTION.SHORT is not None
