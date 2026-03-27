"""
Test for mod/rqmojo_mod_sys_risk/__init__.mojo
Group 06 - File 01
"""

from rqmojo.mod.rqmojo_mod_sys_risk.mod import RiskMod, create_risk_mod



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_create_risk_mod() raises:
    print("Test: create_risk_mod function")
    try:
        var mod = create_risk_mod()
        print("  RiskMod created: ", mod.name)
        assert_true(True, "test passed")
    except:
        print("  create_risk_mod failed")
        assert_true(False, "test failed")


def test_risk_mod_name() raises:
    print("Test: RiskMod name property")
    try:
        var mod = create_risk_mod()
        if mod.name == "risk":
            print("  RiskMod name is correct: ", mod.name)
            assert_true(True, "test passed")
        else:
            print("  Expected 'risk', got: ", mod.name)
            assert_true(False, "test failed")
    except:
        print("  RiskMod name test failed")
        assert_true(False, "test failed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()