"""
Test for mod/validator.mojo
Group 08 - File 11
"""

from rqmojo.mod.validator import MarginInstrumentValidator, create_margin_instrument_validator
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


fn test_margin_instrument_validator_init() -> Bool:
    print("Test: MarginInstrumentValidator init")
    var validator = create_margin_instrument_validator()
    print("  PASSED")
    return True


fn test_margin_instrument_validator_validate() -> Bool:
    print("Test: MarginInstrumentValidator validate")
    var validator = create_margin_instrument_validator()
    var order = create_test_order()
    var result = validator.validate(order)
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 08 File 11: Validator Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_margin_instrument_validator_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_margin_instrument_validator_validate():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
