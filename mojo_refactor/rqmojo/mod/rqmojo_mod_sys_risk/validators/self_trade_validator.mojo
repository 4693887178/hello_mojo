"""
RQAlpha Mojo - Self Trade Validator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/self_trade_validator.py
"""

from rqmojo.const import SIDE
from rqmojo.model.order import Order
from rqmojo.interface import FrontendValidator


@fieldwise_init
struct SelfTradeValidator(FrontendValidator, Movable):
    var enabled: Bool
    
    fn validate_submission(self, order: Order, account: Optional[object], existing_orders: List[Order] = List[Order]()) -> Optional[String]:
        if not self.enabled:
            return None
        
        for existing_order in existing_orders:
            if existing_order.order_book_id == order.order_book_id:
                if existing_order.side != order.side:
                    if order.order_book_id == existing_order.order_book_id:
                        return "Self trade detected: order would match with existing order " + String(existing_order.order_id)
        
        return None
    
    fn validate_cancellation(self, order: Order, account: Optional[object]) -> Optional[String]:
        return None


fn create_self_trade_validator(enabled: Bool = True) -> SelfTradeValidator:
    return SelfTradeValidator(enabled=enabled)
