"""
RQAlpha Mojo - Order Style Validator
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/validator.py
"""

from std.collections import Optional
from rqmojo.model.order import Order
from rqmojo.const import ORDER_TYPE
from rqmojo.interface import FrontendValidatorInterface
from rqmojo.portfolio.account import Account


struct OrderStyleValidator(FrontendValidatorInterface, Movable):
    var frequency: String

    def __init__(out self, frequency: String = "1d"):
        self.frequency = frequency

    def validate_order(self, order: Order) -> Bool:
        return True

    def can_submit_order(self, order: Order) -> Bool:
        return True

    def can_cancel_order(self, order_id: Int) -> Bool:
        return True

    def validate_submission(self, order: Order, account: Optional[Account]) -> Optional[String]:
        if order.style.style_type == ORDER_TYPE.ALGO:
            if self.frequency == "1m" or self.frequency == "tick":
                return Optional[String]("algo order no support 1m and tick frequency")
        return Optional[String](None)

    def validate_cancellation(self, order: Order, account: Optional[Account]) -> Optional[String]:
        return Optional[String](None)


def create_order_style_validator(frequency: String = "1d") -> OrderStyleValidator:
    return OrderStyleValidator(frequency=frequency)
