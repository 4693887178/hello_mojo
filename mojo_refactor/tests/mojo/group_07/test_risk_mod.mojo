"""
Test for mod/rqmojo_mod_sys_risk/mod.mojo
Group 07 - File 05
"""

from rqmojo.mod.rqmojo_mod_sys_risk.mod import (
    RiskMod, PriceValidator, CashValidator, SelfTradeValidator,
    create_risk_mod, create_price_validator, create_cash_validator,
    create_self_trade_validator
)
from rqmojo.model.order import Order, create_order_with_id
from rqmojo.const import SIDE, POSITION_EFFECT


def test_risk_mod_init() -> Bool:
    print("Test: RiskMod init")
    
    var mod = create_risk_mod()
    
    if mod.name != "risk":
        raise "RiskMod name should be 'risk'"
    if not mod.enabled:
        raise "RiskMod should be enabled"
    print("  PASSED")
    return True


def test_price_validator() -> Bool:
    print("Test: PriceValidator")
    
    var validator = create_price_validator(enabled=True)
    
    if not validator.is_enabled():
        raise "PriceValidator should be enabled"
    
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    
    var result = validator.validate(order, 15.0, 9.0)
    
    print("  PASSED")
    return True


def test_cash_validator() -> Bool:
    print("Test: CashValidator")
    
    var validator = create_cash_validator(enabled=True, min_cash=1000.0)
    
    if not validator.is_enabled():
        raise "CashValidator should be enabled"
    
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    
    var result = validator.validate(order, 5000.0)
    
    if not result:
        raise "Should have enough cash"
    print("  PASSED")
    return True


def test_self_trade_validator() -> Bool:
    print("Test: SelfTradeValidator")
    
    var validator = create_self_trade_validator(enabled=True)
    
    if not validator.is_enabled():
        raise "SelfTradeValidator should be enabled"
    
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    
    var existing_orders = List[Order]()
    var result = validator.validate(order, existing_orders)
    
    print("  PASSED")
    return True


def main() -> None:
    print("=== Group 07 File 05: Risk Mod Tests ===")
    print("")
    
    var passed = 0
    var failed = 0
    
    if test_risk_mod_init():
        passed += 1
    else:
        failed += 1
    
    if test_price_validator():
        passed += 1
    else:
        failed += 1
    
    if test_cash_validator():
        passed += 1
    else:
        failed += 1
    
    if test_self_trade_validator():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
