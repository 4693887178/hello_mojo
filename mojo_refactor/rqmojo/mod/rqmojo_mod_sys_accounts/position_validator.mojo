"""
RQAlpha Mojo - Position Validator
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/position_validator.py
"""

from std.collections import Optional
from rqmojo.const import SIDE, POSITION_EFFECT
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidatorInterface
from rqmojo.portfolio.account import Account


@fieldwise_init
struct PositionValidator(FrontendValidatorInterface, Movable):
    var enabled: Bool
    
    def validate_order(self, order: Order) -> Bool:
        return True
    
    def can_submit_order(self, order: Order) -> Bool:
        return self.enabled
    
    def can_cancel_order(self, order_id: Int) -> Bool:
        return self.enabled
    
    def validate_submission(self, order: Order, account: Optional[Account] = None) -> Optional[String]:
        if not self.enabled:
            return None
        
        if order.position_effect == POSITION_EFFECT.CLOSE or order.position_effect == POSITION_EFFECT.CLOSE_TODAY:
            return "Position validation for close order"
        
        return None
    
    def validate_cancellation(self, order: Order, account: Optional[Account] = None) -> Optional[String]:
        return None


def create_position_validator(enabled: Bool = True) -> PositionValidator:
    return PositionValidator(enabled=enabled)
