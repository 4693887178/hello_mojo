"""
RQAlpha Mojo - Self Trade Validator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/self_trade_validator.py

Design (vs Python original):
  Python: class SelfTradeValidator(AbstractFrontendValidator)
          __init__(self, env) -> self._env = env
          validate_submission -> self._env.get_open_orders(order.order_book_id)
  Mojo:  struct SelfTradeValidator(FrontendValidatorInterface)
          __init__(out self, var open_orders: List[Order]) -> self._open_orders = open_orders
          validate_submission -> filters self._open_orders for conflicts
"""

from std.collections import Optional, List
from rqmojo.const import ORDER_TYPE, SIDE, POSITION_EFFECT
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidatorInterface
from rqmojo.portfolio.account import Account
from rqmojo.utils.i18n import gettext


struct SelfTradeValidator(FrontendValidatorInterface, Movable, Writable):
    var _open_orders: List[Order]

    def __init__(out self, var open_orders: List[Order]):
        self._open_orders = open_orders^

    def validate_order(self, order: Order) -> Bool:
        return True

    def can_submit_order(self, order: Order) -> Bool:
        return True

    def can_cancel_order(self, order_id: Int) -> Bool:
        return True

    def validate_submission(self, order: Order, account: Optional[Account]) -> Optional[String]:
        var conflicting_orders = List[Order]()
        for o in self._open_orders:
            if o.order_book_id == order.order_book_id:
                if o.side != order.side and o.position_effect != POSITION_EFFECT.EXERCISE:
                    conflicting_orders.append(o)

        if len(conflicting_orders) == 0:
            return None

        var reason = "Create order failed, there are active orders leading to the risk of self-trade: ["

        if order.order_type() == ORDER_TYPE.MARKET:
            return reason + String.write(conflicting_orders[0]) + "...]"

        if order.side == SIDE.BUY:
            for open_order in conflicting_orders:
                if order.price >= open_order.price:
                    return reason + String.write(open_order) + "...]"
        else:
            for open_order in conflicting_orders:
                if order.price <= open_order.price:
                    return reason + String.write(open_order) + "...]"

        return None

    def validate_cancellation(self, order: Order, account: Optional[Account]) -> Optional[String]:
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("SelfTradeValidator")


def create_self_trade_validator(var open_orders: List[Order]) -> SelfTradeValidator:
    return SelfTradeValidator(open_orders^)
