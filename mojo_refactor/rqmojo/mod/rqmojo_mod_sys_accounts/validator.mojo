"""
RQAlpha Mojo - Account Validator
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/validator.py
"""

from rqmojo.const import SIDE, POSITION_EFFECT, DEFAULT_ACCOUNT_TYPE
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidator


@fieldwise_init
struct AccountValidator(FrontendValidator, Movable):
    var enabled: Bool
    
    fn validate_submission(self, order: Order, account: Optional[object]) -> Optional[String]:
        if not self.enabled:
            return None
        
        return None
    
    fn validate_cancellation(self, order: Order, account: Optional[object]) -> Optional[String]:
        return None


fn create_account_validator(enabled: Bool = True) -> AccountValidator:
    return AccountValidator(enabled=enabled)
