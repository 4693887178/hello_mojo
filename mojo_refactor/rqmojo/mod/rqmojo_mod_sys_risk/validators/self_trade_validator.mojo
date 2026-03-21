"""
RQAlpha Mojo - Self Trade Validator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/self_trade_validator.py
"""

from std.collections import List
from rqmojo.const import SIDE
from rqmojo.model.order import Order


@fieldwise_init
struct SelfTradeValidator(Movable, Copyable, ImplicitlyCopyable):
    var enabled: Bool
    
    def validate_order(self, order: Order) -> Bool:
        return self.enabled
    
    def can_submit_order(self, order: Order) -> Bool:
        return self.enabled
    
    def can_cancel_order(self, order_id: Int) -> Bool:
        return True
    
    def validate_submission(self, order: Order, existing_orders: List[Order] = List[Order]()) -> Optional[String]:
        if not self.enabled:
            return None
        
        for existing_order in existing_orders:
            if existing_order.order_book_id == order.order_book_id:
                if existing_order.side != order.side:
                    return "Self trade detected: order would match with existing order " + String(existing_order.order_id)
        
        return None
    
    def validate_cancellation(self, order: Order) -> Optional[String]:
        return None


def create_self_trade_validator(enabled: Bool = True) -> SelfTradeValidator:
    return SelfTradeValidator(enabled=enabled)
