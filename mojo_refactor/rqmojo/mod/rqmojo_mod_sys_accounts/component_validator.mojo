"""
RQAlpha Mojo - Margin Component Validator
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/component_validator.py
"""

from rqmojo.model.order import Order
from rqmojo.portfolio.account import Account
from rqmojo.interface import FrontendValidatorInterface


struct MarginComponentValidator(FrontendValidatorInterface, Movable, Copyable, ImplicitlyCopyable, Writable):
    var margin_type: String

    def __init__(out self):
        self.margin_type = "all"

    def __init__(out self, margin_type: String):
        self.margin_type = margin_type

    def validate_order(self, order: Order) -> Bool:
        return True

    def can_submit_order(self, order: Order) -> Bool:
        return True

    def can_cancel_order(self, order_id: Int) -> Bool:
        return True

    def validate_submission(self, order: Order, account: Optional[Account]) -> Optional[String]:
        if account is None:
            return None
        var acc = account.value()
        if acc.cash_liabilities == 0:
            return None
        return None

    def validate_cancellation(self, order: Order, account: Optional[Account]) -> Optional[String]:
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("MarginComponentValidator(margin_type=", self.margin_type, ")")


def create_margin_component_validator(margin_type: String = "all") -> MarginComponentValidator:
    return MarginComponentValidator(margin_type)
