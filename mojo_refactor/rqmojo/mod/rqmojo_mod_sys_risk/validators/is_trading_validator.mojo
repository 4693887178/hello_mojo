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


@fieldwise_init
struct IsTradingValidator(FrontendValidatorInterface, Movable, Copyable, ImplicitlyCopyable):
    var _env_name: String
    var enabled: Bool
    var _data_proxy_name: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("IsTradingValidator(enabled=", String(self.enabled), ")")
    
    def validate_order(self, order: Order) -> Bool:
        return True
    
    def can_submit_order(self, order: Order) -> Bool:
        return self.enabled
    
    def can_cancel_order(self, order_id: Int) -> Bool:
        return self.enabled

    def validate_submission(self, order: Order, account_name: String) -> Optional[String]:
        if not self.enabled:
            return None
        return None

    def validate_cancellation(self, order: Order, account_name: String) -> Optional[String]:
        return None
    
    def validate_submission_full(
        self,
        order: Order,
        account: Optional[Account],
        instrument: Optional[Instrument],
        trading_date: DateTime,
        is_suspended: Bool
    ) -> Optional[String]:
        if not self.enabled:
            return None

        if instrument is None:
            return "Order Creation Failed: " + order.order_book_id + " is not listing!"

        var ins = instrument.value()

        if ins.type() == INSTRUMENT_TYPE.CS:
            if is_suspended:
                var reason = "Order Creation Failed: security " + order.order_book_id + " is suspended"
                return reason

        return None


def create_is_trading_validator(env_name: String = "", enabled: Bool = True, data_proxy_name: String = "data_proxy") -> IsTradingValidator:
    return IsTradingValidator(_env_name=env_name, enabled=enabled, _data_proxy_name=data_proxy_name)
