"""
RQAlpha Mojo - Cash Validator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/cash_validator.py

Design (vs Python original):
  Python: validate_cash(env, order, cash)
          - env.data_proxy.instrument_not_none(order.order_book_id)
          - instrument.calc_cash_occupation(price, qty, direction, dt.date())
  Mojo:  validate_cash(order, cash, data_proxy)
          - data_proxy.get_instrument(order.order_book_id)
          - instrument.calc_cash_occupation(price, qty, direction, dt)

  Python: CashValidator.__init__(self, env) -> self._env = env
          validate_submission -> account.available_cash_for(order.instrument)
  Mojo:  CashValidator.__init__(out self, var data_proxy: DataProxy)
          validate_submission -> account.available_cash_for(instrument)
"""

from std.collections import Optional
from rqmojo.const import POSITION_EFFECT
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidatorInterface
from rqmojo.portfolio.account import Account
from rqmojo.model.instrument import Instrument
from rqmojo.utils.typing import DateTime
from rqmojo.utils.i18n import gettext
from rqmojo.data.data_proxy import DataProxy


def validate_cash(
    order: Order,
    cash: Float64,
    data_proxy: DataProxy,
) raises -> Optional[String]:
    var instrument = data_proxy.get_instrument(order.order_book_id)
    var cost_money = instrument.calc_cash_occupation(
        order.frozen_price,
        order.quantity,
        order.position_direction(),
        order.trading_datetime(),
    )
    cost_money += order.estimated_transaction_cost()
    if cost_money <= cash:
        return None

    var reason = gettext(
        "Order Creation Failed: not enough money to buy {order_book_id}, needs {cost_money:.2f}, cash {cash:.2f}"
    )
    reason = reason.replace("{order_book_id}", order.order_book_id)
    reason = reason.replace("{cost_money:.2f}", _format_float2(cost_money))
    reason = reason.replace("{cash:.2f}", _format_float2(cash))
    return reason


def _format_float2(value: Float64) -> String:
    var int_part = Int(value)
    var frac_part = Int(round((value - Float64(int_part)) * 100.0))
    if frac_part < 0:
        frac_part = -frac_part
    var frac_str = String(frac_part)
    if frac_part < 10:
        frac_str = "0" + frac_str
    return String(int_part) + "." + frac_str


struct CashValidator(FrontendValidatorInterface, Movable, Writable):
    var _data_proxy: DataProxy

    def __init__(out self, var data_proxy: DataProxy):
        self._data_proxy = data_proxy^

    def validate_submission(self, order: Order, account: Optional[Account]) -> Optional[String]:
        if account is None:
            return None
        var pe = order.position_effect
        if pe == None:
            return None
        if pe.value() != POSITION_EFFECT.OPEN:
            return None

        var acc = account.value()
        try:
            var instrument = self._data_proxy.get_instrument(order.order_book_id)
            var available_cash = acc.available_cash_for(instrument)
            return validate_cash(
                order=order,
                cash=available_cash,
                data_proxy=self._data_proxy,
            )
        except:
            return None

    def validate_cancellation(self, order: Order, account: Optional[Account]) -> Optional[String]:
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("CashValidator")


def create_cash_validator(var data_proxy: DataProxy) -> CashValidator:
    return CashValidator(data_proxy^)
