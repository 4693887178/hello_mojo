"""
Test for mod/rqmojo_mod_sys_risk/validators/self_trade_validator.mojo
Group 09 - File 3
"""

from rqmojo.mod.rqmojo_mod_sys_risk.validators.self_trade_validator import SelfTradeValidator, create_self_trade_validator


fn test_self_trade_validator_init() -> Bool:
    print("Test: SelfTradeValidator init")
    var validator = create_self_trade_validator(True)
    print("  PASSED")
    return True


fn test_self_trade_validator_enabled() -> Bool:
    print("Test: SelfTradeValidator enabled")
    var validator = create_self_trade_validator(True)
    if not validator.enabled:
        return False
    print("  PASSED")
    return True


fn test_self_trade_validator_disabled() -> Bool:
    print("Test: SelfTradeValidator disabled")
    var validator = create_self_trade_validator(False)
    if validator.enabled:
        return False
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 3: Self Trade Validator Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    if test_self_trade_validator_init():
        passed += 1
    else:
        failed += 1
    
    if test_self_trade_validator_enabled():
        passed += 1
    else:
        failed += 1
    
    if test_self_trade_validator_disabled():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
