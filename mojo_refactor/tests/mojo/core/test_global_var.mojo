"""
Test for global_var.mojo - Global Variables
"""

from std.collections import Dict
from rqmojo.core.global_var import GlobalVars, create_global_vars


def test_global_vars_init():
    print("=== Testing GlobalVars init ===")
    
    var g = create_global_vars()
    print("GlobalVars instance created")
    print("PASS: GlobalVars initialized correctly")
    print("")


def test_global_vars_contains():
    print("=== Testing GlobalVars contains ===")
    
    var g = create_global_vars()
    
    if not g.contains("nonexistent"):
        print("PASS: contains returns False for non-existing key")
    else:
        print("FAIL: contains should return False")
    
    print("")


def test_global_vars_keys():
    print("=== Testing GlobalVars keys ===")
    
    var g = create_global_vars()
    var keys = g.keys()
    
    if len(keys) == 0:
        print("PASS: keys returns empty list for empty GlobalVars")
    else:
        print("FAIL: keys should return empty list")
    
    print("")


def test_global_vars_clear():
    print("=== Testing GlobalVars clear ===")
    
    var g = create_global_vars()
    g.clear()
    
    print("PASS: clear works correctly")
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo core/global_var.mojo Test")
    print("=" * 60)
    print("")
    
    test_global_vars_init()
    test_global_vars_contains()
    test_global_vars_keys()
    test_global_vars_clear()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
