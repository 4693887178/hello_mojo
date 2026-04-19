"""
RQAlpha Mojo - Margin Instrument Validator
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/validator.py
"""

from rqmojo.model.order import Order
from rqmojo.portfolio.account import Account
from rqmojo.interface import FrontendValidatorInterface


struct MarginInstrumentValidator(FrontendValidatorInterface, Movable, Copyable, ImplicitlyCopyable, Writable):
    def __init__(out self):
        pass

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
        if acc.cash_liabilities > 0:
            var reason = "Order Creation Failed: cash liabilities > 0, " + order.order_book_id + " not support submit order"
            return reason
        return None

    def validate_cancellation(self, order: Order, account: Optional[Account]) -> Optional[String]:
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("MarginInstrumentValidator()")


def create_margin_instrument_validator() -> MarginInstrumentValidator:
    return MarginInstrumentValidator()
