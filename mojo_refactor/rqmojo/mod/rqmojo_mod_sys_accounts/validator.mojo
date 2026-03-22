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
    
    def validate_order(self, order: Order) -> Bool:
        if not self.enabled:
            return True
        return True
    
    def can_submit_order(self, order: Order) -> Bool:
        return True
    
    def can_cancel_order(self, order_id: Int) -> Bool:
        return True
    
    def validate_submission(self, order: Order, account_name: String) -> Optional[String]:
        if not self.enabled:
            return None
        return None
    
    def validate_cancellation(self, order: Order, account_name: String) -> Optional[String]:
        return None


def create_account_validator(enabled: Bool = True) -> AccountValidator:
    return AccountValidator(enabled=enabled)
