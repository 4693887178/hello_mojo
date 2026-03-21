"""
RQAlpha Mojo - Account Validator
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/validator.py
"""

from rqmojo.const import SIDE, POSITION_EFFECT, DEFAULT_ACCOUNT_TYPE
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidatorInterface


@fieldwise_init
struct AccountValidator(FrontendValidatorInterface, Movable):
    var enabled: Bool
    
    fn validate_order(self, order: Order) -> Bool:
        if not self.enabled:
            return True
        return True
    
    fn can_submit_order(self, order: Order) -> Bool:
        return True
    
    fn can_cancel_order(self, order_id: Int) -> Bool:
        return True
    
    fn validate_submission(self, order: Order, account_name: String) -> Optional[String]:
        if not self.enabled:
            return None
        return None
    
    fn validate_cancellation(self, order: Order, account_name: String) -> Optional[String]:
        return None


fn create_account_validator(enabled: Bool = True) -> AccountValidator:
    return AccountValidator(enabled=enabled)
