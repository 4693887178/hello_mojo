"""
RQAlpha Mojo - Risk Manager Mod
Ported from rqalpha/mod/rqalpha_mod_sys_risk/mod.py
"""

from std.collections import Dict, Optional, List
from rqmojo.interface import ModInterface
from rqmojo.const import EXIT_CODE, INSTRUMENT_TYPE
from rqmojo.model.order import Order
from rqmojo.portfolio.account import Account
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
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.environment import Environment


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


struct RiskManagerMod(ModInterface, Movable):
    var _price_validator: Optional[PriceValidator]
    var _is_trading_validator: Optional[IsTradingValidator]
    var _cash_validator: Optional[CashValidator]
    var _self_trade_validator: Optional[SelfTradeValidator]
    var _data_proxy: DataProxy
    var _env: Optional[Environment]

    def __init__(out self):
        self._price_validator = None
        self._is_trading_validator = None
        self._cash_validator = None
        self._self_trade_validator = None
        self._data_proxy = create_data_proxy()
        self._env = None

    def start_up(mut self, env_name: String, mod_config_name: String):
        pass

    def start_up_with_config(
        mut self,
        env: Environment,
        config: SysRiskModConfig,
    ):
        self._env = Optional[Environment](env)
        self._data_proxy = env.data_proxy()

        if config.validate_price:
            self._price_validator = create_price_validator(self._data_proxy)

        if config.validate_is_trading:
            self._is_trading_validator = create_is_trading_validator(self._data_proxy)

        if config.validate_cash:
            self._cash_validator = create_cash_validator(self._data_proxy)

        if config.validate_self_trade:
            self._self_trade_validator = create_self_trade_validator(List[Order]())

    def tear_down(self, code: EXIT_CODE, exception_msg: Optional[String]):
        pass

    def has_price_validator(self) -> Bool:
        return self._price_validator is not None

    def has_is_trading_validator(self) -> Bool:
        return self._is_trading_validator is not None

    def has_cash_validator(self) -> Bool:
        return self._cash_validator is not None

    def has_self_trade_validator(self) -> Bool:
        return self._self_trade_validator is not None

    def validator_count(self) -> Int:
        var count = 0
        if self._price_validator is not None:
            count += 1
        if self._is_trading_validator is not None:
            count += 1
        if self._cash_validator is not None:
            count += 1
        if self._self_trade_validator is not None:
            count += 1
        return count

    def get_validators(self) -> List[CashValidator]:
        var result = List[CashValidator]()
        return result^


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
