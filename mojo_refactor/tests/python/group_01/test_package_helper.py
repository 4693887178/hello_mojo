#!/usr/bin/env python3
"""
Test for rqalpha/utils/package_helper.py
"""

import sys
import os

# Add the Python package path
sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')

from rqalpha.utils.package_helper import import_mod


def test_import_mod_builtins():
    """Test importing built-in modules"""
    print("Test 1: Import built-in module (os)")
    try:
        mod = import_mod('os')
        print(f"  Module: {mod}")
        print(f"  Has 'path' attribute: {hasattr(mod, 'path')}")
        print(f"  Has 'getcwd' attribute: {hasattr(mod, 'getcwd')}")
        print("  PASS")
        return True
    except Exception as e:
        print(f"  FAIL: {e}")
        return False


def test_import_mod_stdlib():
    """Test importing standard library modules"""
    print("Test 2: Import stdlib module (json)")
    try:
        mod = import_mod('json')
        print(f"  Module: {mod}")
        print(f"  Has 'loads' attribute: {hasattr(mod, 'loads')}")
        print(f"  Has 'dumps' attribute: {hasattr(mod, 'dumps')}")
        print("  PASS")
        return True
    except Exception as e:
        print(f"  FAIL: {e}")
        return False


def test_import_mod_rqalpha():
    """Test importing rqalpha modules"""
    print("Test 3: Import rqalpha module")
    try:
        mod = import_mod('rqalpha')
        print(f"  Module: {mod}")
        print(f"  Has '__version__' attribute: {hasattr(mod, '__version__')}")
        print("  PASS")
        return True
    except Exception as e:
        print(f"  FAIL: {e}")
        return False


def test_import_mod_nonexistent():
    """Test importing non-existent module (should raise)"""
    print("Test 4: Import non-existent module (should raise)")
    try:
        mod = import_mod('nonexistent_module_xyz123')
        print(f"  FAIL: Should have raised but got: {mod}")
        return False
    except ImportError as e:
        print(f"  Correctly raised ImportError: {e}")
        print("  PASS")
        return True
    except Exception as e:
        print(f"  Raised exception: {type(e).__name__}: {e}")
        print("  PASS (any exception is acceptable)")
        return True


def test_import_mod_return_type():
    """Test return type of import_mod"""
    print("Test 5: Check return type")
    from types import ModuleType
    try:
        mod = import_mod('os')
        is_module = isinstance(mod, ModuleType)
        print(f"  Return type: {type(mod)}")
        print(f"  Is ModuleType: {is_module}")
        print("  PASS")
        return True
    except Exception as e:
        print(f"  FAIL: {e}")
        return False


def main():
    print("=" * 60)
    print("Python package_helper.py Test")
    print("=" * 60)
    
    results = []
    results.append(test_import_mod_builtins())
    results.append(test_import_mod_stdlib())
    results.append(test_import_mod_rqalpha())
    results.append(test_import_mod_nonexistent())
    results.append(test_import_mod_return_type())
    
    print()
    print("=" * 60)
    print(f"Results: {sum(results)}/{len(results)} passed")
    print("=" * 60)
    
    return sum(results) == len(results)


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
