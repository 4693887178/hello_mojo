"""
Test for mod/rqmojo_mod_sys_simulation/validator.mojo
Group 07 - File 08
"""

from rqmojo.mod.rqmojo_mod_sys_simulation.validator import OrderStyleValidator, create_order_style_validator
from rqmojo.model.order import Order, create_order_with_id
from rqmojo.const import ORDER_TYPE, SIDE, POSITION_EFFECT


fn create_test_order() raises -> Order:
    return create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        position_effect=POSITION_EFFECT.OPEN
    )


fn test_order_style_validator_init() -> Bool:
    print("Test: OrderStyleValidator init")
    var validator = create_order_style_validator(frequency="1d")
    print("  PASSED")
    return True


fn test_order_style_validator_validate_order() raises -> Bool:
    print("Test: OrderStyleValidator validate_order")
    var validator = create_order_style_validator(frequency="1d")
    var order = create_test_order()
    var result = validator.validate_order(order)
    if not result:
        raise "Order should be valid"
    print("  PASSED")
    return True


fn test_order_style_validator_can_submit() raises -> Bool:
    print("Test: OrderStyleValidator can_submit_order")
    var validator = create_order_style_validator(frequency="1d")
    var order = create_test_order()
    var result = validator.can_submit_order(order)
    if not result:
        raise "Should be able to submit order"
    print("  PASSED")
    return True


fn test_order_style_validator_can_cancel() raises -> Bool:
    print("Test: OrderStyleValidator can_cancel_order")
    var validator = create_order_style_validator(frequency="1d")
    var result = validator.can_cancel_order(1)
    if not result:
        raise "Should be able to cancel order"
    print("  PASSED")
    return True


fn test_order_style_validator_validate_submission() raises -> Bool:
    print("Test: OrderStyleValidator validate_submission")
    var validator = create_order_style_validator(frequency="1d")
    var order = create_test_order()
    var result = validator.validate_submission(order, "stock")
    print("  PASSED")
    return True


fn test_order_style_validator_validate_cancellation() raises -> Bool:
    print("Test: OrderStyleValidator validate_cancellation")
    var validator = create_order_style_validator(frequency="1d")
    var order = create_test_order()
    var result = validator.validate_cancellation(order, "stock")
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 07 File 08: Simulation Validator Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_order_style_validator_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_order_style_validator_validate_order():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_order_style_validator_can_submit():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_order_style_validator_can_cancel():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_order_style_validator_validate_submission():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_order_style_validator_validate_cancellation():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
