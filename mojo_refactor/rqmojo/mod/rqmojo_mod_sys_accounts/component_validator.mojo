"""
RQAlpha Mojo - Component Validator
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/component_validator.py
"""

from rqmojo.const import SIDE, POSITION_EFFECT
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidator


@fieldwise_init
struct ComponentValidator(FrontendValidator, Movable):
    var enabled: Bool
    
    fn validate_submission(self, order: Order, account: Optional[object]) -> Optional[String]:
        if not self.enabled:
            return None
        
        return None
    
    fn validate_cancellation(self, order: Order, account: Optional[object]) -> Optional[String]:
        return None


fn create_component_validator(enabled: Bool = True) -> ComponentValidator:
    return ComponentValidator(enabled=enabled)
