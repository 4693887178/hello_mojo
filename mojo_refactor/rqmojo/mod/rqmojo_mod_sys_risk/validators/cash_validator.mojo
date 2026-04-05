"""
RQAlpha Mojo - Cash Validator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/cash_validator.py
"""

from std.collections import Optional
from rqmojo.const import SIDE, POSITION_EFFECT
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidatorInterface
from rqmojo.portfolio.account import Account
from rqmojo.model.instrument import Instrument
from rqmojo.utils.typing import DateTime
from rqmojo.utils.i18n import gettext as gettext_func


def validate_cash(
    order: Order,
    cash: Float64,
    instrument: Instrument,
    trading_date: DateTime
) -> Optional[String]:
    var cost_money = order.price * Float64(order.quantity)
    cost_money = cost_money + order.estimated_transaction_cost
    if cost_money <= cash:
        return None
    var reason = "Order Creation Failed: not enough money to buy " + order.order_book_id + ", needs " + String(cost_money) + ", cash " + String(cash)
    return reason


@fieldwise_init
struct CashValidator(FrontendValidatorInterface, Movable):
    var _env_name: String
    var enabled: Bool

    def validate_order(self, order: Order) -> Bool:
        return True
    
    def can_submit_order(self, order: Order) -> Bool:
        return self.enabled
    
    def can_cancel_order(self, order_id: Int) -> Bool:
        return self.enabled

    def validate_submission(self, order: Order, account_name: String) -> Optional[String]:
        if not self.enabled:
            return None

        if order.position_effect != POSITION_EFFECT.OPEN:
            return None

        return None

    def validate_cancellation(self, order: Order, account_name: String) -> Optional[String]:
        return None


def create_cash_validator(env_name: String = "", enabled: Bool = True) -> CashValidator:
    return CashValidator(_env_name=env_name, enabled=enabled)
