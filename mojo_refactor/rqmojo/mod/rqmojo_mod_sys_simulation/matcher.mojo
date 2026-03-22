"""
RQAlpha Mojo - Order Matcher
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/matcher.py
"""

from rqmojo.const import MATCHING_TYPE, SIDE, ORDER_STATUS, MATCHING_TYPE_CURRENT_BAR_CLOSE, MATCHING_TYPE_VWAP, MATCHING_TYPE_NEXT_BAR_OPEN, SIDE_BUY, MATCHING_TYPE_CURRENT_BAR_CLOSE, MATCHING_TYPE_VWAP, MATCHING_TYPE_NEXT_BAR_OPEN, SIDE_BUY
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade, create_trade
from rqmojo.model.bar import BarObject
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct Matcher(Movable):
    var matching_type: MATCHING_TYPE
    var slippage: Float64
    var _match_count: Int
    
    def match_order(mut self, order: Order, bar: BarObject, dt: DateTime) -> Optional[Trade]:
        if order.quantity <= 0:
            return None
        
        var price = self._get_match_price(order, bar)
        if price <= 0:
            return None
        
        price = self._apply_slippage(order, price)
        
        var filled_quantity = order.quantity - order.filled_quantity
        if filled_quantity <= 0:
            return None
        
        self._match_count += 1
        
        return create_trade(
            order=order,
            quantity=filled_quantity,
            price=price,
            datetime=dt
        )
    
    def _get_match_price(self, order: Order, bar: BarObject) -> Float64:
        if self.matching_type == MATCHING_TYPE_CURRENT_BAR_CLOSE:
            return bar.close
        elif self.matching_type == MATCHING_TYPE_VWAP:
            if bar.volume > 0:
                return bar.total_turnover / Float64(bar.volume)
            return bar.close
        elif self.matching_type == MATCHING_TYPE_NEXT_BAR_OPEN:
            return bar.open
        else:
            return bar.close
    
    def _apply_slippage(self, order: Order, price: Float64) -> Float64:
        if self.slippage == 0:
            return price
        
        if order.side == SIDE_BUY:
            return price * (1.0 + self.slippage)
        else:
            return price * (1.0 - self.slippage)
    
    def get_match_count(self) -> Int:
        return self._match_count


def create_matcher(matching_type: MATCHING_TYPE = MATCHING_TYPE_CURRENT_BAR_CLOSE, slippage: Float64 = 0.0) -> Matcher:
    return Matcher(
        matching_type=matching_type,
        slippage=slippage,
        _match_count=0
    )
