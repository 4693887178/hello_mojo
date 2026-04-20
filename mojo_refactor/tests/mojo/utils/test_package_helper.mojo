"""
Test for package_helper.mojo - Package Helper Module
"""

from std.collections import List
from python import Python
from rqmojo.utils.package_helper import import_mod


def test_import_mod_success():
    print("=== Testing import_mod (success) ===")
    
    try:
        var mod = import_mod("os")
        print("Imported module: os")
        print("PASS: Successfully imported 'os' module")
    except:
        print("FAIL: Failed to import 'os' module")
    print("")


def test_import_mod_stdlib():
    print("=== Testing import_mod (stdlib modules) ===")
    
    try:
        var mod = import_mod("sys")
        print("Imported module: sys")
        print("PASS: Successfully imported 'sys' module")
    except:
        print("FAIL: Failed to import 'sys' module")
    
    try:
        var mod2 = import_mod("json")
        print("Imported module: json")
        print("PASS: Successfully imported 'json' module")
    except:
        print("FAIL: Failed to import 'json' module")
    print("")


def test_import_mod_submodule():
    print("=== Testing import_mod (submodule) ===")
    
    try:
        var mod = import_mod("collections.abc")
        print("Imported module: collections.abc")
        print("PASS: Successfully imported 'collections.abc' submodule")
    except:
        print("FAIL: Failed to import 'collections.abc' submodule")
    print("")


def test_import_mod_failure():
    print("=== Testing import_mod (failure case) ===")
    
    var invalid_mod_name = "nonexistent_module_xyz123"
    print("Attempting to import non-existent module: " + invalid_mod_name)
    
    try:
        var mod = import_mod(invalid_mod_name)
        print("FAIL: Should have raised an exception for non-existent module")
    except:
        print("PASS: Correctly raised exception for non-existent module")
    print("")


def test_import_mod_rqmojo():
    print("=== Testing import_mod (rqmojo module) ===")
    
    try:
        var mod = import_mod("rqmojo")
        print("Imported module: rqmojo")
        print("PASS: Successfully imported 'rqmojo' module")
    except:
        print("FAIL: Failed to import 'rqmojo' module")
    print("")


def test_import_mod_rqmojo_submodule():
    print("=== Testing import_mod (rqmojo submodule) ===")
    
    try:
        var mod = import_mod("rqmojo.const")
        print("Imported module: rqmojo.const")
        print("PASS: Successfully imported 'rqmojo.const' submodule")
    except:
        print("FAIL: Failed to import 'rqmojo.const' submodule")
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo utils/package_helper.mojo Test")
    print("=" * 60)
    print("")
    
    test_import_mod_success()
    test_import_mod_stdlib()
    test_import_mod_submodule()
    test_import_mod_failure()
    test_import_mod_rqmojo()
    test_import_mod_rqmojo_submodule()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
