"""
RQAlpha Mojo - Is Trading Validator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/is_trading_validator.py
"""

from std.collections import Optional
from rqmojo.const import INSTRUMENT_TYPE
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidator
from rqmojo.model.instrument import Instrument
from rqmojo.portfolio.account import Account
from rqmojo.utils.typing import DateTime
from rqmojo.utils.i18n import gettext as gettext_func
from rqmojo.utils.exception import InstrumentNotFound


@fieldwise_init
struct IsTradingValidator(Writable, Movable, Copyable, ImplicitlyCopyable):
    var _env_name: String
    var enabled: Bool
    var _data_proxy_name: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("IsTradingValidator(enabled=", String(self.enabled), ")")

    def validate_submission(
        self,
        order: Order,
        account: Optional[Account],
        instrument: Optional[Instrument] = None,
        trading_date: DateTime = DateTime(1970, 1, 1, 0, 0, 0, 0),
        is_suspended: Bool = False
    ) -> Optional[String]:
        if not self.enabled:
            return None

        if instrument is None:
            return "Order Creation Failed: " + order.order_book_id + " is not listing!"

        var ins = instrument

        if ins.instrument_type == INSTRUMENT_TYPE.CS:
            if is_suspended:
                var reason = "Order Creation Failed: security " + order.order_book_id + " is suspended on " + trading_date.__str__()
                return reason

        return None

    def validate_cancellation(
        self,
        order: Order,
        account: Optional[Account]
    ) -> Optional[String]:
        return None


def create_is_trading_validator(env_name: String = "", enabled: Bool = True) -> IsTradingValidator:
    return IsTradingValidator(_env_name=env_name, enabled=enabled, _data_proxy_name="")
