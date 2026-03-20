"""
RQAlpha Mojo - Price Validator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/price_validator.py
"""

from rqmojo.const import SIDE, ORDER_TYPE
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidator


@fieldwise_init
struct PriceValidator(FrontendValidator, Movable):
    var enabled: Bool
    
    fn validate_submission(self, order: Order, account: Optional[object], limit_up: Float64 = 0.0, limit_down: Float64 = 0.0) -> Optional[String]:
        if not self.enabled:
            return None
        
        if order.order_type != ORDER_TYPE.LIMIT:
            return None
        
        if limit_up > 0 and order.price > limit_up:
            return "Order price " + String(order.price) + " exceeds limit up " + String(limit_up)
        
        if limit_down > 0 and order.price < limit_down:
            return "Order price " + String(order.price) + " below limit down " + String(limit_down)
        
        return None
    
    fn validate_cancellation(self, order: Order, account: Optional[object]) -> Optional[String]:
        return None


fn create_price_validator(enabled: Bool = True) -> PriceValidator:
    return PriceValidator(enabled=enabled)
