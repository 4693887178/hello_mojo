"""
Test for mod/rqmojo_mod_sys_risk/mod.mojo
Group 07 - File 05
"""

from rqmojo.mod.rqmojo_mod_sys_risk.mod import (
    RiskMod, PriceValidator, CashValidator, SelfTradeValidator,
    create_risk_mod, create_price_validator, create_cash_validator, create_self_trade_validator
)
from rqmojo.model.order import Order, OrderStyle, MarketOrder, create_order_with_id
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


fn test_risk_mod_init() -> Bool:
    print("Test: RiskMod init")
    var mod = create_risk_mod()
    if mod.name != "risk":
        return False
    print("  PASSED")
    return True


fn test_risk_mod_start() -> Bool:
    print("Test: RiskMod start")
    var mod = create_risk_mod()
    mod.start()
    print("  PASSED")
    return True


fn test_risk_mod_stop() -> Bool:
    print("Test: RiskMod stop")
    var mod = create_risk_mod()
    mod.stop()
    print("  PASSED")
    return True


fn test_price_validator() -> Bool:
    print("Test: PriceValidator")
    var validator = create_price_validator(enabled=True)
    var order = create_test_order()
    var result = validator.validate(order, 11.5, 9.5)
    if not result:
        return False
    print("  PASSED")
    return True


fn test_cash_validator() -> Bool:
    print("Test: CashValidator")
    var validator = create_cash_validator(enabled=True, min_cash=1000.0)
    var order = create_test_order()
    var result = validator.validate(order, 5000.0)
    if not result:
        return False
    print("  PASSED")
    return True


fn test_self_trade_validator() -> Bool:
    print("Test: SelfTradeValidator")
    var validator = create_self_trade_validator(enabled=True)
    var order = create_test_order()
    var result = validator.validate_order(order)
    if not result:
        return False
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 07 File 05: RiskMod Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_risk_mod_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_risk_mod_start():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_risk_mod_stop():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_price_validator():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_cash_validator():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_self_trade_validator():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
