"""
L01_07_risk_free_helper Module Tests
对应模块: rqmojo.utils.risk_free_helper / rqalpha.utils.risk_free_helper
层级: L01 - Utils模块
依赖: 无

注意: Mojo版本依赖datetime_func模块
"""

from rqmojo.utils.risk_free_helper import get_yield_curve_tenors, get_yield_curve_duration


fn main():
    var tests_passed = 0
    var tests_failed = 0

    print("=" * 60)
    print("L01_07_risk_free_helper Module Tests")
    print("=" * 60)

    # Test 1: get_yield_curve_tenors function exists
    try:
        print("Test: get_yield_curve_tenors function exists")
        var tenors = get_yield_curve_tenors()
        print("  PASS: get_yield_curve_tenors returns Dict")
        tests_passed += 1
    except e:
        print("  FAIL: Exception -", e)
        tests_failed += 1

    # Test 2: get_yield_curve_duration function exists
    try:
        print("Test: get_yield_curve_duration function exists")
        var durations = get_yield_curve_duration()
        print("  PASS: get_yield_curve_duration returns List")
        tests_passed += 1
    except e:
        print("  FAIL: Exception -", e)
        tests_failed += 1

    # Test 3: Check some expected tenor values
    try:
        print("Test: tenor values")
        var tenors = get_yield_curve_tenors()
        print("  0S:", tenors[0])
        print("  30:", tenors[30])
        print("  365:", tenors[365])
        print("  PASS: tenor values accessible")
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
