"""
RQAlpha Mojo - Order Validator
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/validator.py
"""

from rqmojo.const import ORDER_TYPE, MATCHING_TYPE
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidatorInterface


struct OrderStyleValidator(FrontendValidatorInterface, Movable, Copyable):
    var frequency: String
    
    def __init__(out self, frequency: String = "1d"):
        self.frequency = frequency
    
    def validate_order(self, order: Order) -> Bool:
        return True
    
    def can_submit_order(self, order: Order) -> Bool:
        return True
    
    def can_cancel_order(self, order_id: Int) -> Bool:
        return True
    
    def validate_submission(self, order: Order, account_name: String) -> Optional[String]:
        if order.style.style_type == ORDER_TYPE.LIMIT:
            if order.style.limit_price <= 0:
                return Optional[String]("Limit order price must be positive")
        if self.frequency == "tick":
            pass
        return Optional[String](None)
    
    def validate_cancellation(self, order: Order, account_name: String) -> Optional[String]:
        return Optional[String](None)


def create_order_style_validator(frequency: String = "1d") -> OrderStyleValidator:
    return OrderStyleValidator(frequency=frequency)
