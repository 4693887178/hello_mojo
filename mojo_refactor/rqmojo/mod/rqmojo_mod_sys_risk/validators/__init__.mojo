"""
RQAlpha Mojo - Risk Validators
"""

from rqmojo.mod.rqmojo_mod_sys_risk.validators.cash_validator import CashValidator
from rqmojo.mod.rqmojo_mod_sys_risk.validators.price_validator import PriceValidator
from rqmojo.mod.rqmojo_mod_sys_risk.validators.is_trading_validator import IsTradingValidator
from rqmojo.mod.rqmojo_mod_sys_risk.validators.self_trade_validator import SelfTradeValidator


def create_cash_validator(env_name: String = "", enabled: Bool = True) -> CashValidator:
    from rqmojo.mod.rqmojo_mod_sys_risk.validators.cash_validator import create_cash_validator as _create
    return _create(env_name, enabled)


def create_price_validator(env_name: String = "", enabled: Bool = True) -> PriceValidator:
    from rqmojo.mod.rqmojo_mod_sys_risk.validators.price_validator import create_price_validator as _create
    return _create(enabled)


def create_is_trading_validator(env_name: String = "", enabled: Bool = True) -> IsTradingValidator:
    from rqmojo.mod.rqmojo_mod_sys_risk.validators.is_trading_validator import create_is_trading_validator as _create
    return _create(env_name, enabled)


def create_self_trade_validator(env_name: String = "", enabled: Bool = True) -> SelfTradeValidator:
    from rqmojo.mod.rqmojo_mod_sys_risk.validators.self_trade_validator import create_self_trade_validator as _create
    return _create(enabled)
