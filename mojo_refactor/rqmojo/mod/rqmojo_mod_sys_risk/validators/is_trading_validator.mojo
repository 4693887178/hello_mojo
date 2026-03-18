"""
RQAlpha Mojo - Is Trading Validator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/is_trading_validator.py
"""

from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidator
from rqmojo.model.instrument import Instrument


@fieldwise_init
struct IsTradingValidator(FrontendValidator, Movable):
    var enabled: Bool
    
    fn validate_submission(self, order: Order, account: Optional[object], instrument: Optional[Instrument] = None) -> Optional[String]:
        if not self.enabled:
            return None
        
        if instrument is None:
            return None
        
        if not instrument.is_trading:
            return "Instrument " + order.order_book_id + " is not trading"
        
        return None
    
    fn validate_cancellation(self, order: Order, account: Optional[object]) -> Optional[String]:
        return None


fn create_is_trading_validator(enabled: Bool = True) -> IsTradingValidator:
    return IsTradingValidator(enabled=enabled)
