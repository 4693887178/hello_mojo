"""
RQAlpha Mojo - Price Validator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/price_validator.py
"""

from rqmojo.const import SIDE, ORDER_TYPE, ORDER_TYPE_LIMIT
from rqmojo.model.order import Order


@fieldwise_init
struct PriceValidator(Movable, Copyable, ImplicitlyCopyable):
    var enabled: Bool
    
    def validate_order(self, order: Order) -> Bool:
        return self.enabled
    
    def can_submit_order(self, order: Order) -> Bool:
        return self.enabled
    
    def can_cancel_order(self, order_id: Int) -> Bool:
        return True
    
    def validate_submission(self, order: Order, limit_up: Float64 = 0.0, limit_down: Float64 = 0.0) -> Optional[String]:
        if not self.enabled:
            return None
        
        if order.order_type() != ORDER_TYPE_LIMIT:
            return None
        
        if limit_up > 0 and order.price > limit_up:
            return "Order price " + String(order.price) + " exceeds limit up " + String(limit_up)
        
        if limit_down > 0 and order.price < limit_down:
            return "Order price " + String(order.price) + " below limit down " + String(limit_down)
        
        return None
    
    def validate_cancellation(self, order: Order) -> Optional[String]:
        return None


def create_price_validator(enabled: Bool = True) -> PriceValidator:
    return PriceValidator(enabled=enabled)
