"""
RQAlpha Mojo - Cash Validator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/cash_validator.py
"""

from std.collections import Optional
from rqmojo.const import SIDE, POSITION_EFFECT
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidator
from rqmojo.portfolio.account import Account
from rqmojo.model.instrument import Instrument
from rqmojo.utils.typing import DateTime
from rqmojo.utils.i18n import gettext as _


def validate_cash(
    order: Order,
    cash: Float64,
    instrument: Instrument,
    trading_date: DateTime
) -> Optional[String]:
    var cost_money = instrument.calc_cash_occupation(
        order.frozen_price,
        order.quantity,
        order.position_direction,
        trading_date
    )
    cost_money = cost_money + order.estimated_transaction_cost
    if cost_money <= cash:
        return None
    var reason = "Order Creation Failed: not enough money to buy " + order.order_book_id + ", needs " + String(cost_money) + ", cash " + String(cash)
    return reason


@fieldwise_init
struct CashValidator(Writable, Movable, Copyable, ImplicitlyCopyable):
    var _env_name: String
    var enabled: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("CashValidator(enabled=", String(self.enabled), ")")

    def validate_submission(
        self,
        order: Order,
        account: Optional[Account],
        instrument: Optional[Instrument] = None,
        trading_date: DateTime = DateTime(1970, 1, 1, 0, 0, 0, 0)
    ) -> Optional[String]:
        if not self.enabled:
            return None

        if account is None:
            return None

        if order.position_effect != POSITION_EFFECT.OPEN:
            return None

        var acc = account
        var available_cash = acc.available_cash_for(instrument)
        return validate_cash(order, available_cash, instrument, trading_date)

    def validate_cancellation(
        self,
        order: Order,
        account: Optional[Account]
    ) -> Optional[String]:
        return None


def create_cash_validator(env_name: String = "", enabled: Bool = True) -> CashValidator:
    return CashValidator(_env_name=env_name, enabled=enabled)
