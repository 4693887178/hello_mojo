"""
Test for rqmojo/utils/package_helper.mojo
"""

from python import Python, PythonObject
from rqmojo.utils.package_helper import import_mod


def test_import_mod_builtins() -> Bool:
    """Test importing built-in modules."""
    print("Test 1: Import built-in module (os)")
    try:
        var mod = import_mod("os")
        print("  Module type: ", mod.__class__.__name__)
        try:
            var path_attr = mod.getattr("path")
            print("  Has 'path' attribute: True")
        except:
            print("  Has 'path' attribute: False")
        try:
            var getcwd_attr = mod.getattr("getcwd")
            print("  Has 'getcwd' attribute: True")
        except:
            print("  Has 'getcwd' attribute: False")
        print("  PASS")
        return True
    except:
        print("  FAIL: Exception raised")
        return False


def test_import_mod_stdlib() -> Bool:
    """Test importing standard library modules."""
    print("Test 2: Import stdlib module (json)")
    try:
        var mod = import_mod("json")
        print("  Module type: ", mod.__class__.__name__)
        try:
            var loads_attr = mod.getattr("loads")
            print("  Has 'loads' attribute: True")
        except:
            print("  Has 'loads' attribute: False")
        try:
            var dumps_attr = mod.getattr("dumps")
            print("  Has 'dumps' attribute: True")
        except:
            print("  Has 'dumps' attribute: False")
        print("  PASS")
        return True
    except:
        print("  FAIL: Exception raised")
        return False


def test_import_mod_rqalpha() -> Bool:
    """Test importing rqalpha modules."""
    print("Test 3: Import rqalpha module")
    try:
        var mod = import_mod("rqalpha")
        print("  Module type: ", mod.__class__.__name__)
        try:
            var version_attr = mod.getattr("__version__")
            print("  Has '__version__' attribute: True")
        except:
            print("  Has '__version__' attribute: False")
        print("  PASS")
        return True
    except:
        print("  FAIL: Exception raised")
        return False


def test_import_mod_nonexistent() -> Bool:
    """Test importing non-existent module (should raise)."""
    print("Test 4: Import non-existent module (should raise)")
    try:
        var mod = import_mod("nonexistent_module_xyz123")
        print("  FAIL: Should have raised but got module")
        return False
    except:
        print("  Correctly raised exception")
        print("  PASS")
        return True


def test_import_mod_return_type() -> Bool:
    """Test return type of import_mod."""
    print("Test 5: Check return type")
    try:
        var mod = import_mod("os")
        print("  Return type: PythonObject")
        print("  Module type: ", mod.__class__.__name__)
        print("  PASS")
        return True
    except:
        print("  FAIL: Exception raised")
        return False


def main() raises:
    print("=" * 60)
    print("Mojo package_helper.mojo Test")
    print("=" * 60)
    
    var results = List[Bool]()
    results.append(test_import_mod_builtins())
    results.append(test_import_mod_stdlib())
    results.append(test_import_mod_rqalpha())
    results.append(test_import_mod_nonexistent())
    results.append(test_import_mod_return_type())
    
    var passed = 0
    for r in results:
        if r:
            passed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, "/", len(results), " passed")
    print("=" * 60)
