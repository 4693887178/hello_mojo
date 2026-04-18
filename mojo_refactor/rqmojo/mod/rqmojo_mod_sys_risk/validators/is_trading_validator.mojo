"""
RQAlpha Mojo - Is Trading Validator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/is_trading_validator.py
"""

from std.collections import Optional
from rqmojo.const import INSTRUMENT_TYPE
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidatorInterface
from rqmojo.model.instrument import Instrument
from rqmojo.portfolio.account import Account
from rqmojo.utils.typing import DateTime
from rqmojo.utils.i18n import gettext as `_`
from rqmojo.data.data_proxy import DataProxy


struct IsTradingValidator(FrontendValidatorInterface):
    var _data_proxy: DataProxy

    def __init__(out self, var data_proxy: DataProxy):
        self._data_proxy = data_proxy^

    def write_to(self, mut writer: Some[Writer]):
        writer.write("IsTradingValidator")

    def validate_order(self, order: Order) -> Bool:
        return True

    def can_submit_order(self, order: Order) -> Bool:
        return True

    def can_cancel_order(self, order_id: Int) -> Bool:
        return True

    def validate_submission(self, order: Order, account: Optional[Account]) -> Optional[String]:
        var instrument = self._data_proxy.get_instrument(order.order_book_id)

        if instrument.type() == INSTRUMENT_TYPE.CS and self._data_proxy.is_suspended(order.order_book_id, DateTime(2024, 1, 1, 0, 0, 0, 0)):
            return "Order Creation Failed: security " + order.order_book_id + " is suspended on " + _format_date(DateTime(2024, 1, 1, 0, 0, 0, 0))

        return None

    def validate_cancellation(self, order: Order, account: Optional[Account]) -> Optional[String]:
        return None


def _format_date(dt: DateTime) -> String:
    return String(dt.year) + "-" + _pad_zero(dt.month) + "-" + _pad_zero(dt.day)


def _pad_zero(value: Int) -> String:
    if value < 10:
        return "0" + String(value)
    return String(value)


def create_is_trading_validator(var data_proxy: DataProxy) -> IsTradingValidator:
    return IsTradingValidator(data_proxy^)
