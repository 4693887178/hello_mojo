"""
RQAlpha Mojo - Position Validator
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/position_validator.py
"""

from rqmojo.const import SIDE, POSITION_EFFECT
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidator
from rqmojo.mod.rqmojo_mod_sys_accounts.position_model import PositionModel


@fieldwise_init
struct PositionValidator(FrontendValidator, Movable):
    var enabled: Bool
    
    def validate_submission(self, order: Order, account: Optional[object], position: Optional[PositionModel] = None) -> Optional[String]:
        if not self.enabled:
            return None
        
        if order.position_effect == POSITION_EFFECT.CLOSE or order.position_effect == POSITION_EFFECT.CLOSE_TODAY:
            if position is None:
                return "Position not found for " + order.order_book_id
            
            if order.quantity > position.closable():
                return "Insufficient position to close: required=" + String(order.quantity) + ", available=" + String(position.closable())
        
        return None
    
    def validate_cancellation(self, order: Order, account: Optional[object]) -> Optional[String]:
        return None


def create_position_validator(enabled: Bool = True) -> PositionValidator:
    return PositionValidator(enabled=enabled)
