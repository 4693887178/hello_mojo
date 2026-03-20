"""
L00_12_user_module Module Tests
对应模块: rqmojo.user_module / rqalpha.user_module
层级: L00 - 叶子模块
依赖: const, interface, environment
"""

from rqmojo.user_module import UserModule, create_user_module
from rqmojo.const import EXIT_CODE


fn main():
    var tests_passed = 0
    var tests_failed = 0

    print("=" * 60)
    print("L00_12_user_module Module Tests")
    print("=" * 60)

    # Test 1: UserModule struct exists
    try:
        print("Test: UserModule struct exists")
        var module = create_user_module("test")
        print("  PASS: UserModule created with name:", module.name)
        tests_passed += 1
    except e:
        print("  FAIL: Exception -", e)
        tests_failed += 1

    # Test 2: create_user_module function
    try:
        print("Test: create_user_module function")
        var module = create_user_module()
        print("  PASS: Default module created, enabled:", module.enabled)
        tests_passed += 1
    except e:
        print("  FAIL: Exception -", e)
        tests_failed += 1

    # Summary
    print("=" * 60)
    print("Results:", tests_passed, "/", tests_passed + tests_failed, "tests passed")
    if tests_failed > 0:
        print("Status: FAILED")
    else:
        print("Status: PASSED")
    print("=" * 60)
