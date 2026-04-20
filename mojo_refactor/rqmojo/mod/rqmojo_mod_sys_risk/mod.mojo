"""
RQAlpha Mojo - Risk Manager Mod
Ported from rqalpha/mod/rqalpha_mod_sys_risk/mod.py

Design (vs Python original):
  Python: class RiskManagerMod(AbstractMod)
          start_up(self, env, mod_config) -> env.add_frontend_validator(Validator(env))
  Mojo:  struct RiskManagerMod(ModInterface)
          start_up_with_config(mut self, mut env, config) -> env.add_frontend_validator(...)
"""

from std.collections import Dict, Optional
from rqmojo.interface import ModInterface
from rqmojo.const import EXIT_CODE, INSTRUMENT_TYPE
from rqmojo.environment import Environment, FrontendValidator
from rqmojo.mod.rqmojo_mod_sys_risk.validators import (
    CashValidator,
    PriceValidator,
    IsTradingValidator,
    SelfTradeValidator,
)
from rqmojo.mod.rqmojo_mod_sys_risk.validators.cash_validator import create_cash_validator
from rqmojo.mod.rqmojo_mod_sys_risk.validators.price_validator import create_price_validator
from rqmojo.mod.rqmojo_mod_sys_risk.validators.is_trading_validator import create_is_trading_validator
from rqmojo.mod.rqmojo_mod_sys_risk.validators.self_trade_validator import create_self_trade_validator


struct SysRiskModConfig:
    var validate_price: Bool
    var validate_is_trading: Bool
    var validate_cash: Bool
    var validate_self_trade: Bool

    def __init__(out self):
        self.validate_price = True
        self.validate_is_trading = True
        self.validate_cash = True
        self.validate_self_trade = False

    def __init__(out self, validate_price: Bool, validate_is_trading: Bool,
                 validate_cash: Bool, validate_self_trade: Bool):
        self.validate_price = validate_price
        self.validate_is_trading = validate_is_trading
        self.validate_cash = validate_cash
        self.validate_self_trade = validate_self_trade


@fieldwise_init
struct RiskManagerMod(ModInterface):

    def start_up(mut self, env_name: String, mod_config_name: String):
        pass

    def start_up_with_config(mut self, mut env: Environment, config: SysRiskModConfig) raises:
        if config.validate_price:
            env.add_frontend_validator(
                FrontendValidator(name="PriceValidator", instrument_type=INSTRUMENT_TYPE.CS)
            )

        if config.validate_is_trading:
            env.add_frontend_validator(
                FrontendValidator(name="IsTradingValidator", instrument_type=INSTRUMENT_TYPE.CS)
            )

        if config.validate_cash:
            env.add_frontend_validator(
                FrontendValidator(name="CashValidator", instrument_type=INSTRUMENT_TYPE.CS)
            )

        if config.validate_self_trade:
            env.add_frontend_validator(
                FrontendValidator(name="SelfTradeValidator", instrument_type=INSTRUMENT_TYPE.CS)
            )

    def tear_down(mut self, code: EXIT_CODE, exception_msg: Optional[String]):
        pass


def create_risk_manager_mod() -> RiskManagerMod:
    return RiskManagerMod()


def create_sys_risk_mod_config(
    validate_price: Bool = True,
    validate_is_trading: Bool = True,
    validate_cash: Bool = True,
    validate_self_trade: Bool = False,
) -> SysRiskModConfig:
    return SysRiskModConfig(
        validate_price=validate_price,
        validate_is_trading=validate_is_trading,
        validate_cash=validate_cash,
        validate_self_trade=validate_self_trade,
    )
