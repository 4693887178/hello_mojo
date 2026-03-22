"""
RQAlpha Mojo - Position Model
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/position_model.py
"""

from rqmojo.const import POSITION_DIRECTION, SIDE, POSITION_DIRECTION_LONG, POSITION_DIRECTION_LONG
from rqmojo.model.instrument import Instrument
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct PositionModel(Movable):
    var order_book_id: String
    var direction: POSITION_DIRECTION
    var quantity: Int
    var today_quantity: Int
    var frozen_quantity: Int
    var avg_price: Float64
    var prev_close: Float64
    var last_price: Float64
    
    def market_value(self) -> Float64:
        return self.last_price * Float64(self.quantity)
    
    def pnl(self) -> Float64:
        if self.quantity == 0:
            return 0.0
        return (self.last_price - self.avg_price) * Float64(self.quantity)
    
    def position_pnl(self) -> Float64:
        if self.quantity == 0:
            return 0.0
        return (self.last_price - self.prev_close) * Float64(self.quantity)
    
    def closable(self) -> Int:
        return self.quantity - self.frozen_quantity
    
    def apply_trade(mut self, quantity: Int, price: Float64) -> None:
        if quantity > 0:
            var new_quantity = self.quantity + quantity
            var new_value = self.avg_price * Float64(self.quantity) + price * Float64(quantity)
            if new_quantity > 0:
                self.avg_price = new_value / Float64(new_quantity)
            self.quantity = new_quantity
            self.today_quantity += quantity
        else:
            var closed_quantity = -quantity
            if closed_quantity > self.quantity:
                closed_quantity = self.quantity
            self.quantity -= closed_quantity
            if closed_quantity > self.today_quantity:
                self.today_quantity = 0
            else:
                self.today_quantity -= closed_quantity
    
    def freeze(mut self, quantity: Int) -> Bool:
        if quantity > self.closable():
            return False
        self.frozen_quantity += quantity
        return True
    
    def unfreeze(mut self, quantity: Int) -> None:
        if quantity > self.frozen_quantity:
            quantity = self.frozen_quantity
        self.frozen_quantity -= quantity


def create_position_model(order_book_id: String, direction: POSITION_DIRECTION = POSITION_DIRECTION_LONG) -> PositionModel:
    return PositionModel(
        order_book_id=order_book_id,
        direction=direction,
        quantity=0,
        today_quantity=0,
        frozen_quantity=0,
        avg_price=0.0,
        prev_close=0.0,
        last_price=0.0
    )
