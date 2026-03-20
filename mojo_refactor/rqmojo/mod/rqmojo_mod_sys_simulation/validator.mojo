"""
RQAlpha Mojo - Order Validator
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/validator.py
"""

from rqmojo.const import ORDER_TYPE, MATCHING_TYPE
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidator


@fieldwise_init
struct OrderStyleValidator(FrontendValidator, Movable):
    var frequency: String
    
    fn validate_submission(self, order: Order, account: Optional[object]) -> Optional[String]:
        if order.order_type == ORDER_TYPE_LIMIT:
            if order.price <= 0:
                return "Limit order price must be positive"
        
        if self.frequency == "tick":
            pass
        
        return None
    
    fn validate_cancellation(self, order: Order, account: Optional[object]) -> Optional[String]:
        return None


fn create_order_style_validator(frequency: String = "1d") -> OrderStyleValidator:
    return OrderStyleValidator(frequency=frequency)
