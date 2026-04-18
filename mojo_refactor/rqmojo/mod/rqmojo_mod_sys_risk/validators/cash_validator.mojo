"""
RQAlpha Mojo - Cash Validator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/cash_validator.py
"""

from std.collections import Optional
from rqmojo.const import POSITION_EFFECT
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidatorInterface
from rqmojo.portfolio.account import Account
from rqmojo.model.instrument import Instrument
from rqmojo.utils.typing import DateTime
from rqmojo.utils.i18n import gettext as `_`
from rqmojo.data.data_proxy import DataProxy


def validate_cash(
    order: Order,
    cash: Float64,
    data_proxy: DataProxy,
) -> Optional[String]:
    var _ = data_proxy.get_instrument(order.order_book_id)
    var cost_money = order.frozen_price * Float64(order.quantity)
    cost_money += order.estimated_transaction_cost
    if cost_money <= cash:
        return None

    var reason = "Order Creation Failed: not enough money to buy " + order.order_book_id + ", needs " + _format_float(cost_money) + ", cash " + _format_float(cash)
    return reason


def _format_float(value: Float64) -> String:
    var rounded = round(value * 100.0) / 100.0
    return String(rounded)


struct CashValidator(FrontendValidatorInterface):
    var _data_proxy: DataProxy

    def __init__(out self, var data_proxy: DataProxy):
        self._data_proxy = data_proxy^

    def write_to(self, mut writer: Some[Writer]):
        writer.write("CashValidator")

    def validate_order(self, order: Order) -> Bool:
        return True

    def can_submit_order(self, order: Order) -> Bool:
        return True

    def can_cancel_order(self, order_id: Int) -> Bool:
        return True

    def validate_submission(self, order: Order, account: Optional[Account]) -> Optional[String]:
        if account is None:
            return None
        if order.position_effect != POSITION_EFFECT.OPEN:
            return None

        var acc = account.value()
        var available_cash = acc.available_cash()
        return validate_cash(
            order=order,
            cash=available_cash,
            data_proxy=self._data_proxy,
        )

    def validate_cancellation(self, order: Order, account: Optional[Account]) -> Optional[String]:
        return None


def create_cash_validator(var data_proxy: DataProxy) -> CashValidator:
    return CashValidator(data_proxy^)
