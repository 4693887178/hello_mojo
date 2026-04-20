"""
RQAlpha Mojo - Is Trading Validator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/is_trading_validator.py

Design (vs Python original):
  Python: IsTradingValidator.__init__(self, env) -> self._env = env
          validate_submission -> self._env.data_proxy.get_active_instrument(...)
                                self._env.data_proxy.is_suspended(...)
                                self._env.trading_dt
  Mojo:  IsTradingValidator.__init__(out self, var data_proxy: DataProxy)
          validate_submission -> self._data_proxy.get_active_instrument(...)
                                self._data_proxy.is_suspended(...)
                                order.trading_datetime()
"""

from std.collections import Optional
from rqmojo.const import INSTRUMENT_TYPE
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidatorInterface
from rqmojo.model.instrument import Instrument
from rqmojo.portfolio.account import Account
from rqmojo.utils.typing import DateTime
from rqmojo.utils.i18n import gettext
from rqmojo.data.data_proxy import DataProxy
from rqmojo.utils.exception import InstrumentNotFound


struct IsTradingValidator(FrontendValidatorInterface, Movable, Writable):
    var _data_proxy: DataProxy

    def __init__(out self, var data_proxy: DataProxy):
        self._data_proxy = data_proxy^

    def validate_submission(self, order: Order, account: Optional[Account]) -> Optional[String]:
        var trading_dt = order.trading_datetime()
        try:
            var _ = self._data_proxy.get_active_instrument(order.order_book_id, trading_dt)
        except:
            var reason = gettext(
                "Order Creation Failed: {order_book_id} is not listing!"
            )
            reason = reason.replace("{order_book_id}", order.order_book_id)
            return reason

        if self._data_proxy.is_suspended(order.order_book_id, trading_dt):
            var instrument = self._data_proxy.get_instrument(order.order_book_id)
            if instrument.type() == INSTRUMENT_TYPE.CS:
                var reason = gettext(
                    "Order Creation Failed: security {order_book_id} is suspended on {date}"
                )
                reason = reason.replace("{order_book_id}", order.order_book_id)
                reason = reason.replace("{date}", _format_date(trading_dt))
                return reason

        return None

    def validate_cancellation(self, order: Order, account: Optional[Account]) -> Optional[String]:
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("IsTradingValidator")


def _format_date(dt: DateTime) -> String:
    return String(dt.year) + "-" + _pad_zero(dt.month) + "-" + _pad_zero(dt.day)


def _pad_zero(value: Int) -> String:
    if value < 10:
        return "0" + String(value)
    return String(value)


def create_is_trading_validator(var data_proxy: DataProxy) -> IsTradingValidator:
    return IsTradingValidator(data_proxy^)
