"""
RQAlpha Mojo - Cash Validator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/cash_validator.py
"""

from rqmojo.const import SIDE, POSITION_EFFECT
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidator
from rqmojo.portfolio.account import Account


@fieldwise_init
struct CashValidator(FrontendValidator, Movable):
    var enabled: Bool
    
    fn validate_submission(self, order: Order, account: Optional[object]) -> Optional[String]:
        if not self.enabled:
            return None
        
        if order.side != SIDE.BUY():
            return None
        
        var acc = account
        if acc is None:
            return None
        
        var required_cash = order.price * Float64(order.quantity)
        var available_cash = acc.cash
        
        if required_cash > available_cash:
            return "Insufficient cash: required=" + String(required_cash) + ", available=" + String(available_cash)
        
        return None
    
    fn validate_cancellation(self, order: Order, account: Optional[object]) -> Optional[String]:
        return None


fn create_cash_validator(enabled: Bool = True) -> CashValidator:
    return CashValidator(enabled=enabled)
