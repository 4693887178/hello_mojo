"""
RQAlpha Mojo - Risk Management
Ported from rqalpha/mod/rqalpha_mod_sys_risk/
"""

from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS
from rqmojo.model.order import Order
from rqmojo.model.instrument import Instrument
from rqmojo.portfolio.account import Account
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct ValidationResult(Copyable, Movable, ImplicitlyCopyable):
    var is_valid: Bool
    var error_message: String
    
    fn __str__(self) -> String:
        if self.is_valid:
            return "Valid"
        else:
            return "Invalid: " + self.error_message


fn valid_result() -> ValidationResult:
    return ValidationResult(is_valid=True, error_message="")


fn invalid_result(message: String) -> ValidationResult:
    return ValidationResult(is_valid=False, error_message=message)


@fieldwise_init
struct PriceValidator(Movable):
    var _enabled: Bool
    
    fn __str__(self) -> String:
        return "PriceValidator(enabled=" + String(self._enabled) + ")"
    
    fn validate_submission(self, order: Order, instrument: Instrument, last_price: Float64) -> ValidationResult:
        if not self._enabled:
            return valid_result()
        
        var limit_up = instrument.limit_up
        var limit_down = instrument.limit_down
        
        if limit_up <= 0 or limit_down <= 0:
            return valid_result()
        
        if order.style.style_type.value == "LIMIT":
            var order_price = order.style.limit_price
            if order_price > limit_up:
                return invalid_result("Order price exceeds limit up")
            if order_price < limit_down:
                return invalid_result("Order price below limit down")
        
        return valid_result()
    
    fn validate_cancellation(self, order: Order) -> ValidationResult:
        return valid_result()


fn create_price_validator(enabled: Bool = True) -> PriceValidator:
    return PriceValidator(_enabled=enabled)


@fieldwise_init
struct CashValidator(Movable):
    var _enabled: Bool
    
    fn __str__(self) -> String:
        return "CashValidator(enabled=" + String(self._enabled) + ")"
    
    fn validate_submission(self, order: Order, account: Account, instrument: Instrument) -> ValidationResult:
        if not self._enabled:
            return valid_result()
        
        if order.position_effect != POSITION_EFFECT.OPEN:
            return valid_result()
        
        var required_cash: Float64 = 0.0
        if order.style.style_type.value == "LIMIT":
            required_cash = order.style.limit_price * Float64(order.quantity)
        else:
            required_cash = instrument.last_price * Float64(order.quantity)
        
        if instrument.type.value == "FUTURE":
            var margin_rate = 0.1
            required_cash = required_cash * margin_rate * instrument.contract_multiplier
        
        var available = account.available_cash()
        if available < required_cash:
            return invalid_result("Insufficient cash")
        
        return valid_result()
    
    fn validate_cancellation(self, order: Order) -> ValidationResult:
        return valid_result()


fn create_cash_validator(enabled: Bool = True) -> CashValidator:
    return CashValidator(_enabled=enabled)


@fieldwise_init
struct IsTradingValidator(Movable):
    var _enabled: Bool
    
    fn __str__(self) -> String:
        return "IsTradingValidator(enabled=" + String(self._enabled) + ")"
    
    fn validate_submission(self, order: Order, instrument: Instrument, dt: DateTime) -> ValidationResult:
        if not self._enabled:
            return valid_result()
        
        if not instrument.active_at(dt):
            return invalid_result("Instrument is not active")
        
        if instrument.suspended:
            return invalid_result("Instrument is suspended")
        
        return valid_result()
    
    fn validate_cancellation(self, order: Order) -> ValidationResult:
        return valid_result()


fn create_is_trading_validator(enabled: Bool = True) -> IsTradingValidator:
    return IsTradingValidator(_enabled=enabled)


@fieldwise_init
struct PositionValidator(Movable):
    var _enabled: Bool
    
    fn __str__(self) -> String:
        return "PositionValidator(enabled=" + String(self._enabled) + ")"
    
    fn validate_submission(self, order: Order, account: Account) -> ValidationResult:
        if not self._enabled:
            return valid_result()
        
        if order.side.value == "SELL" or order.side.value == "SHORT":
            var position = account.get_position(order.order_book_id)
            var closable = position.closable()
            if closable < order.quantity:
                return invalid_result("Insufficient position")
        
        return valid_result()
    
    fn validate_cancellation(self, order: Order) -> ValidationResult:
        return valid_result()


fn create_position_validator(enabled: Bool = True) -> PositionValidator:
    return PositionValidator(_enabled=enabled)


@fieldwise_init
struct RiskManager(Movable):
    var _price_validator: PriceValidator
    var _cash_validator: CashValidator
    var _is_trading_validator: IsTradingValidator
    var _position_validator: PositionValidator
    
    fn __str__(self) -> String:
        return "RiskManager"
    
    fn validate_order(self, order: Order, account: Account, instrument: Instrument, dt: DateTime) -> ValidationResult:
        var result = self._price_validator.validate_submission(order, instrument, instrument.last_price)
        if not result.is_valid:
            return result
        
        result = self._cash_validator.validate_submission(order, account, instrument)
        if not result.is_valid:
            return result
        
        result = self._is_trading_validator.validate_submission(order, instrument, dt)
        if not result.is_valid:
            return result
        
        result = self._position_validator.validate_submission(order, account)
        if not result.is_valid:
            return result
        
        return valid_result()
    
    fn can_submit_order(self, order: Order, account: Account, instrument: Instrument, dt: DateTime) -> Bool:
        var result = self.validate_order(order, account, instrument, dt)
        return result.is_valid
    
    fn can_cancel_order(self, order: Order) -> Bool:
        return True


fn create_risk_manager(
    validate_price: Bool = True,
    validate_cash: Bool = True,
    validate_is_trading: Bool = True,
    validate_position: Bool = True
) -> RiskManager:
    return RiskManager(
        _price_validator=create_price_validator(validate_price),
        _cash_validator=create_cash_validator(validate_cash),
        _is_trading_validator=create_is_trading_validator(validate_is_trading),
        _position_validator=create_position_validator(validate_position)
    )
