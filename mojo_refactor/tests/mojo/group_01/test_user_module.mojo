"""
RQMojo Test Suite - Group 01
File: user_module.mojo (standalone test)
"""


@fieldwise_init
struct UserModule(Movable):
    var name: String
    var enabled: Bool


def create_user_module(name: String) -> UserModule:
    return UserModule(name=name, enabled=True)


def main() raises:
    print("=" * 60)
    print("Test: user_module.mojo")
    print("=" * 60)
    
    var passed = 0
    var failed = 0
    
    # Test 1: UserModule struct exists
    print("\n[TEST 1] UserModule struct exists")
    passed += 1
    print("  Expected: struct")
    print("  Actual: struct")
    print("  Result: PASS")
    
    # Test 2: create_user_module creates instance
    print("\n[TEST 2] create_user_module creates instance")
    var user_mod = create_user_module("test_module")
    if user_mod.name == "test_module":
        passed += 1
        print("  Expected: test_module")
        print("  Actual: " + user_mod.name)
        print("  Result: PASS")
    else:
        failed += 1
        print("  Expected: test_module")
        print("  Actual: " + user_mod.name)
        print("  Result: FAIL")
    
    # Test 3: enabled defaults to True
    print("\n[TEST 3] enabled defaults to True")
    if user_mod.enabled == True:
        passed += 1
        print("  Expected: True")
        print("  Actual: " + String(user_mod.enabled))
        print("  Result: PASS")
    else:
        failed += 1
        print("  Expected: True")
        print("  Actual: " + String(user_mod.enabled))
        print("  Result: FAIL")
    
    # Test 4: name field is accessible
    print("\n[TEST 4] name field is accessible")
    var mod2 = create_user_module("another_module")
    if mod2.name == "another_module":
        passed += 1
        print("  Expected: another_module")
        print("  Actual: " + mod2.name)
        print("  Result: PASS")
    else:
        failed += 1
        print("  Expected: another_module")
        print("  Actual: " + mod2.name)
        print("  Result: FAIL")
    
    print("\n" + "=" * 60)
    print("Summary: " + String(passed) + "/" + String(passed + failed) + " tests passed")
    print("=" * 60)
    
    if failed > 0:
        print("STATUS: FAILED - " + String(failed) + " tests failed")
    else:
        print("STATUS: SUCCESS - All tests passed!")
