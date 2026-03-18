"""
RQAlpha Mojo - Risk Mod
Ported from rqalpha/mod/rqalpha_mod_sys_risk/
"""

from rqmojo.const import SIDE, POSITION_EFFECT
from rqmojo.model.order import Order


@fieldwise_init
struct RiskMod(Copyable, Movable, ImplicitlyCopyable):
    var name: String
    var enabled: Bool
    
    fn __str__(self) -> String:
        return "RiskMod(" + self.name + ")"
    
    fn start(self) -> None:
        pass
    
    fn stop(self) -> None:
        pass


@fieldwise_init
struct PriceValidator(Movable):
    var _enabled: Bool
    
    fn validate(self, order: Order, limit_up: Float64, limit_down: Float64) -> Bool:
        return True
    
    fn is_enabled(self) -> Bool:
        return self._enabled


@fieldwise_init
struct CashValidator(Movable):
    var _enabled: Bool
    var _min_cash: Float64
    
    fn validate(self, order: Order, available_cash: Float64) -> Bool:
        return available_cash >= self._min_cash
    
    fn is_enabled(self) -> Bool:
        return self._enabled


@fieldwise_init
struct SelfTradeValidator(Movable):
    var _enabled: Bool
    
    fn validate(self, order: Order, existing_orders: List[Order]) -> Bool:
        return True
    
    fn is_enabled(self) -> Bool:
        return self._enabled


fn create_risk_mod() -> RiskMod:
    return RiskMod(name="risk", enabled=True)


fn create_price_validator(enabled: Bool = True) -> PriceValidator:
    return PriceValidator(_enabled=enabled)


fn create_cash_validator(enabled: Bool = True, min_cash: Float64 = 0.0) -> CashValidator:
    return CashValidator(_enabled=enabled, _min_cash=min_cash)


fn create_self_trade_validator(enabled: Bool = True) -> SelfTradeValidator:
    return SelfTradeValidator(_enabled=enabled)
