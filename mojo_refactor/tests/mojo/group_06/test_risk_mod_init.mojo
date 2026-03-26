"""
Test for mod/rqmojo_mod_sys_risk/__init__.mojo
Group 06 - File 01
"""

from rqmojo.mod.rqmojo_mod_sys_risk.mod import RiskMod, create_risk_mod


def test_create_risk_mod() -> Bool:
    print("Test: create_risk_mod function")
    try:
        var mod = create_risk_mod()
        print("  RiskMod created: ", mod.name)
        return True
    except:
        print("  create_risk_mod failed")
        return False


def test_risk_mod_name() -> Bool:
    print("Test: RiskMod name property")
    try:
        var mod = create_risk_mod()
        if mod.name == "risk":
            print("  RiskMod name is correct: ", mod.name)
            return True
        else:
            print("  Expected 'risk', got: ", mod.name)
            return False
    except:
        print("  RiskMod name test failed")
        return False


def main() -> None:
    print("=== Group 06 File 01: Risk Mod Init Tests ===")
    print("")
    
    var passed = 0
    var failed = 0
    
    if test_create_risk_mod():
        passed += 1
    else:
        failed += 1
    
    if test_risk_mod_name():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
