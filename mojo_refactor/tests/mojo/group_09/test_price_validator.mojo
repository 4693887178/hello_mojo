"""
Test for mod/rqmojo_mod_sys_risk/validators/price_validator.mojo
Group 09 - File 2
"""

from rqmojo.mod.rqmojo_mod_sys_risk.validators.price_validator import PriceValidator, create_price_validator


fn test_price_validator_init() -> Bool:
    print("Test: PriceValidator init")
    var validator = create_price_validator(True)
    print("  PASSED")
    return True


fn test_price_validator_enabled() -> Bool:
    print("Test: PriceValidator enabled")
    var validator = create_price_validator(True)
    if not validator.enabled:
        return False
    print("  PASSED")
    return True


fn test_price_validator_disabled() -> Bool:
    print("Test: PriceValidator disabled")
    var validator = create_price_validator(False)
    if validator.enabled:
        return False
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 2: Price Validator Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    if test_price_validator_init():
        passed += 1
    else:
        failed += 1
    
    if test_price_validator_enabled():
        passed += 1
    else:
        failed += 1
    
    if test_price_validator_disabled():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
