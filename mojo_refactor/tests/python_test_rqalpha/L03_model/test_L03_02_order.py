# test_L03_02_order.py
# Module: rqalpha.model.order
# Level: L03 - Data Model
# Dependencies: const, instrument, environment

import pytest
from datetime import datetime


class TestOrderStyle:
    """Test OrderStyle classes"""
    
    def test_market_order_exists(self):
        """Test MarketOrder class exists"""
        from rqalpha.model.order import MarketOrder
        assert MarketOrder is not None
    
    def test_limit_order_exists(self):
        """Test LimitOrder class exists"""
        from rqalpha.model.order import LimitOrder
        assert LimitOrder is not None
    
    def test_market_order_equality(self):
        """Test MarketOrder equality"""
        from rqalpha.model.order import MarketOrder
        
        order1 = MarketOrder()
        order2 = MarketOrder()
        assert order1 == order2
    
    def test_limit_order_equality(self):
        """Test LimitOrder equality"""
        from rqalpha.model.order import LimitOrder
        
        order1 = LimitOrder(10.0)
        order2 = LimitOrder(10.0)
        assert order1 == order2
    
    def test_limit_order_get_limit_price(self):
        """Test LimitOrder get_limit_price"""
        from rqalpha.model.order import LimitOrder
        
        order = LimitOrder(15.5)
        assert order.get_limit_price() == 15.5
    
    def test_market_order_get_limit_price(self):
        """Test MarketOrder get_limit_price"""
        from rqalpha.model.order import MarketOrder
        
        order = MarketOrder()
        assert order.get_limit_price() is None


class TestOrderIdGenerator:
    """Test Order ID generator"""
    
    def test_order_id_unique(self):
        """Test order IDs are unique"""
        from rqalpha.model.order import Order
        
        id1 = next(Order.order_id_gen)
        id2 = next(Order.order_id_gen)
        assert id1 != id2


class TestOrderCreation:
    """Test Order creation"""
    
    def test_order_exists(self):
        """Test Order class exists"""
        from rqalpha.model.order import Order
        assert Order is not None


class TestOrderProperties:
    """Test Order properties - requires Environment"""
    
    @pytest.mark.skip(reason="Requires Environment initialization")
    def test_order_side(self):
        """Test order side property"""
        from rqalpha.model.order import Order, SIDE, MarketOrder
        
        order = Order.__from_create__(
            order_book_id="000001.XSHE",
            quantity=100,
            side=SIDE.BUY,
            style=MarketOrder(),
            position_effect=None
        )
        assert order.side == SIDE.BUY
    
    @pytest.mark.skip(reason="Requires Environment initialization")
    def test_order_quantity(self):
        """Test order quantity property"""
        from rqalpha.model.order import Order, SIDE, MarketOrder
        
        order = Order.__from_create__(
            order_book_id="000001.XSHE",
            quantity=100,
            side=SIDE.BUY,
            style=MarketOrder(),
            position_effect=None
        )
        assert order.quantity == 100


class TestOrderStatus:
    """Test Order status methods - requires Environment"""
    
    @pytest.mark.skip(reason="Requires Environment initialization")
    def test_order_is_active(self):
        """Test order is_active method"""
        from rqalpha.model.order import Order, SIDE, MarketOrder, ORDER_STATUS
        
        order = Order.__from_create__(
            order_book_id="000001.XSHE",
            quantity=100,
            side=SIDE.BUY,
            style=MarketOrder(),
            position_effect=None
        )
        assert order.status == ORDER_STATUS.PENDING_NEW


class TestOrderState:
    """Test Order state management - requires Environment"""
    
    @pytest.mark.skip(reason="Requires Environment initialization")
    def test_order_get_state(self):
        """Test order get_state method"""
        from rqalpha.model.order import Order, SIDE, MarketOrder
        
        order = Order.__from_create__(
            order_book_id="000001.XSHE",
            quantity=100,
            side=SIDE.BUY,
            style=MarketOrder(),
            position_effect=None
        )
        state = order.get_state()
        assert 'order_id' in state


class TestAlgoOrder:
    """Test AlgoOrder classes"""
    
    def test_twap_order_exists(self):
        """Test TWAPOrder class exists"""
        from rqalpha.model.order import TWAPOrder
        assert TWAPOrder is not None
    
    def test_vwap_order_exists(self):
        """Test VWAPOrder class exists"""
        from rqalpha.model.order import VWAPOrder
        assert VWAPOrder is not None
    
    def test_twap_order_init(self):
        """Test TWAPOrder initialization"""
        from rqalpha.model.order import TWAPOrder
        
        order = TWAPOrder(start_min=0, end_min=30)
        assert order.start_min == 0
        assert order.end_min == 30
    
    def test_vwap_order_init(self):
        """Test VWAPOrder initialization"""
        from rqalpha.model.order import VWAPOrder
        
        order = VWAPOrder(start_min=0, end_min=60)
        assert order.start_min == 0
        assert order.end_min == 60


class TestOrderConstants:
    """Test Order constants and enums"""
    
    def test_side_enum(self):
        """Test SIDE enum"""
        from rqalpha.const import SIDE
        
        assert SIDE.BUY is not None
        assert SIDE.SELL is not None
    
    def test_order_status_enum(self):
        """Test ORDER_STATUS enum"""
        from rqalpha.const import ORDER_STATUS
        
        assert ORDER_STATUS.PENDING_NEW is not None
        assert ORDER_STATUS.ACTIVE is not None
        assert ORDER_STATUS.FILLED is not None
        assert ORDER_STATUS.CANCELLED is not None
        assert ORDER_STATUS.REJECTED is not None
    
    def test_order_type_enum(self):
        """Test ORDER_TYPE enum"""
        from rqalpha.const import ORDER_TYPE
        
        assert ORDER_TYPE.MARKET is not None
        assert ORDER_TYPE.LIMIT is not None
    
    def test_position_effect_enum(self):
        """Test POSITION_EFFECT enum"""
        from rqalpha.const import POSITION_EFFECT
        
        assert POSITION_EFFECT.OPEN is not None
        assert POSITION_EFFECT.CLOSE is not None
        assert POSITION_EFFECT.CLOSE_TODAY is not None
