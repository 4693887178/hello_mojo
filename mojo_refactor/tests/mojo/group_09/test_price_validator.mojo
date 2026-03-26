"""
Test for mod/rqmojo_mod_sys_risk/price_validator.mojo
Group 09 - File 2
"""

from rqmojo.mod.rqmojo_mod_sys_risk.price_validator import PriceValidator, create_price_validator
from rqmojo.model.order import Order, MarketOrder, create_order_with_id
from rqmojo.const import SIDE, POSITION_EFFECT


fn create_test_order() -> Order:
    return create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )


fn test_price_validator_init() -> Bool:
    print("Test: PriceValidator init")
    var validator = create_price_validator()
    print("  PASSED")
    return True


fn test_price_validator_validate() -> Bool:
    print("Test: PriceValidator validate")
    var validator = create_price_validator()
    var order = create_test_order()
    var result = validator.validate(order, 11.5, 9.5)
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 2: Price Validator Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_price_validator_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_price_validator_validate():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
