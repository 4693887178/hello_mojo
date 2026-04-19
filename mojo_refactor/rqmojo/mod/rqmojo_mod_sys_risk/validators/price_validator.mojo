"""
RQAlpha Mojo - Price Validator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/price_validator.py
"""

from std.collections import Optional
from rqmojo.const import ORDER_TYPE, POSITION_EFFECT
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidatorInterface
from rqmojo.portfolio.account import Account
from rqmojo.data.data_proxy import DataProxy


struct PriceValidator(FrontendValidatorInterface, Movable, Writable):
    var _data_proxy: DataProxy

    def __init__(out self, var data_proxy: DataProxy):
        self._data_proxy = data_proxy^

    def validate_order(self, order: Order) -> Bool:
        return True

    def can_submit_order(self, order: Order) -> Bool:
        return True

    def can_cancel_order(self, order_id: Int) -> Bool:
        return True

    def validate_submission(self, order: Order, account: Optional[Account]) -> Optional[String]:
        if order.order_type() != ORDER_TYPE.LIMIT or order.position_effect == POSITION_EFFECT.EXERCISE:
            return None

        var limit_up = round(self._data_proxy.get_limit_up(order.order_book_id) * 10000.0) / 10000.0
        if order.price > limit_up:
            return "Order Creation Failed: limit order price " + _format_float(order.price) + " is higher than limit up " + _format_float(limit_up) + ", order_book_id=" + order.order_book_id

        var limit_down = round(self._data_proxy.get_limit_down(order.order_book_id) * 10000.0) / 10000.0
        if order.price < limit_down:
            return "Order Creation Failed: limit order price " + _format_float(order.price) + " is lower than limit down " + _format_float(limit_down) + ", order_book_id=" + order.order_book_id

        return None

    def validate_cancellation(self, order: Order, account: Optional[Account]) -> Optional[String]:
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("PriceValidator")


def _format_float(value: Float64) -> String:
    var rounded = round(value * 10000.0) / 10000.0
    return String(rounded)


def create_price_validator(var data_proxy: DataProxy) -> PriceValidator:
    return PriceValidator(data_proxy^)
