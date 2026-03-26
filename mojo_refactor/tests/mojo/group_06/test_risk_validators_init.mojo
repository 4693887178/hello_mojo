"""
Test for mod/rqmojo_mod_sys_risk/validators/__init__.mojo
Group 06 - File 02
"""

from rqmojo.mod.rqmojo_mod_sys_risk.validators import (
    CashValidator,
    PriceValidator,
    IsTradingValidator,
    SelfTradeValidator,
    create_cash_validator,
    create_price_validator,
    create_is_trading_validator,
    create_self_trade_validator
)


def test_cash_validator() -> Bool:
    print("Test: CashValidator exists")
    var validator = create_cash_validator()
    print("  CashValidator created successfully")
    return True


def test_price_validator() -> Bool:
    print("Test: PriceValidator exists")
    var validator = create_price_validator()
    print("  PriceValidator created successfully")
    return True


def test_is_trading_validator() -> Bool:
    print("Test: IsTradingValidator exists")
    var validator = create_is_trading_validator()
    print("  IsTradingValidator created successfully")
    return True


def test_self_trade_validator() -> Bool:
    print("Test: SelfTradeValidator exists")
    var validator = create_self_trade_validator()
    print("  SelfTradeValidator created successfully")
    return True


def main() -> None:
    print("=== Group 06 File 02: Risk Validators Init Tests ===")
    print("")
    
    var passed = 0
    var failed = 0
    
    if test_cash_validator():
        passed += 1
    else:
        failed += 1
    
    if test_price_validator():
        passed += 1
    else:
        failed += 1
    
    if test_is_trading_validator():
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
