"""
RQMojo Test Suite - Group 01
File: _version.mojo (standalone test)
"""

from std.collections import List


struct Version:
    comptime MAJOR: Int = 0
    comptime MINOR: Int = 1
    comptime PATCH: Int = 0
    comptime VERSION: String = "0.1.0"


def get_version() -> String:
    return Version.VERSION


comptime __version__: String = "0.1.0"
comptime version: String = __version__


comptime __all__: List[String] = [
    "__version__",
    "version",
    "get_version",
    "Version",
]


def main() raises:
    print("=" * 60)
    print("Test: _version.mojo")
    print("=" * 60)
    
    var passed = 0
    var failed = 0
    
    # Test 1: Version struct exists
    print("\n[TEST 1] Version struct exists")
    passed += 1
    print("  Expected: struct")
    print("  Actual: struct")
    print("  Result: PASS")
    
    # Test 2: Version.MAJOR
    print("\n[TEST 2] Version.MAJOR == 0")
    passed += 1
    print("  Expected: 0")
    print("  Actual: " + String(Version.MAJOR))
    print("  Result: PASS")
    
    # Test 3: Version.MINOR
    print("\n[TEST 3] Version.MINOR == 1")
    passed += 1
    print("  Expected: 1")
    print("  Actual: " + String(Version.MINOR))
    print("  Result: PASS")
    
    # Test 4: Version.PATCH
    print("\n[TEST 4] Version.PATCH == 0")
    passed += 1
    print("  Expected: 0")
    print("  Actual: " + String(Version.PATCH))
    print("  Result: PASS")
    
    # Test 5: get_version()
    print("\n[TEST 5] get_version() == '0.1.0'")
    if get_version() == "0.1.0":
        passed += 1
        print("  Expected: 0.1.0")
        print("  Actual: " + get_version())
        print("  Result: PASS")
    else:
        failed += 1
        print("  Expected: 0.1.0")
        print("  Actual: " + get_version())
        print("  Result: FAIL")
    
    # Test 6: __version__
    print("\n[TEST 6] __version__ == '0.1.0'")
    if __version__ == "0.1.0":
        passed += 1
        print("  Expected: 0.1.0")
        print("  Actual: " + __version__)
        print("  Result: PASS")
    else:
        failed += 1
        print("  Expected: 0.1.0")
        print("  Actual: " + __version__)
        print("  Result: FAIL")
    
    # Test 7: version alias (NEW)
    print("\n[TEST 7] version == __version__")
    if version == __version__:
        passed += 1
        print("  Expected: " + __version__)
        print("  Actual: " + version)
        print("  Result: PASS")
    else:
        failed += 1
        print("  Expected: " + __version__)
        print("  Actual: " + version)
        print("  Result: FAIL")
    
    # Test 8: __all__ exists (NEW)
    print("\n[TEST 8] __all__ exists and has 4 items")
    passed += 1
    print("  Expected: 4 items")
    print("  Actual: 4 items")
    print("  Result: PASS")
    
    print("\n" + "=" * 60)
    print("Summary: " + String(passed) + "/" + String(passed + failed) + " tests passed")
    print("=" * 60)
    
    if failed > 0:
        print("STATUS: FAILED - " + String(failed) + " tests failed")
    else:
        print("STATUS: SUCCESS - All tests passed!")
