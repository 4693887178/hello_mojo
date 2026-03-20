"""
L00_10_version Module Tests
对应模块: rqmojo._version / rqalpha._version
层级: L00 - 叶子模块
依赖: 无
"""

from rqmojo._version import Version, get_version


fn main():
    var tests_passed = 0
    var tests_failed = 0

    print("=" * 60)
    print("L00_10_version Module Tests")
    print("=" * 60)

    # Test 1: Version struct exists and has correct constants
    try:
        print("Test: Version struct constants")
        print("  MAJOR:", Version.MAJOR)
        print("  MINOR:", Version.MINOR)
        print("  PATCH:", Version.PATCH)
        print("  VERSION:", Version.VERSION)
        if Version.MAJOR == 0 and Version.MINOR == 1 and Version.PATCH == 0:
            print("  PASS: Version constants correct")
            tests_passed += 1
        else:
            print("  FAIL: Version constants mismatch")
            tests_failed += 1
    except e:
        print("  FAIL: Exception -", e)
        tests_failed += 1

    # Test 2: get_version function returns string
    try:
        print("Test: get_version() function")
        var version_str = get_version()
        print("  get_version() returned:", version_str)
        if len(version_str) > 0:
            print("  PASS: get_version returns non-empty string")
            tests_passed += 1
        else:
            print("  FAIL: get_version returns empty string")
            tests_failed += 1
    except e:
        print("  FAIL: Exception -", e)
        tests_failed += 1

    # Test 3: Version string format
    try:
        print("Test: Version string format")
        var version_str = get_version()
        # Should be like "0.1.0"
        var parts = version_str.split(".")
        if len(parts) == 3:
            print("  PASS: Version string format is X.Y.Z")
            tests_passed += 1
        else:
            print("  FAIL: Version string format incorrect")
            tests_failed += 1
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
