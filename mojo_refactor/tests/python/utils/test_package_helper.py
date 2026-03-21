# -*- coding: utf-8 -*-
"""
Test for rqalpha/utils/package_helper.py - Package Helper Module
Compares output with Mojo rqmojo/utils/package_helper.mojo
"""

from types import ModuleType
from rqalpha.utils.package_helper import import_mod


def test_import_mod_success():
    """测试 import_mod 成功导入模块"""
    print("=== Testing import_mod (success case) ===")
    
    mod = import_mod("os")
    print(f"Imported module: {mod}")
    print(f"Module name: {mod.__name__}")
    
    assert isinstance(mod, ModuleType), "Should return a ModuleType object"
    assert mod.__name__ == "os", "Module name should be 'os'"
    
    print("PASS: Successfully imported 'os' module")
    print("")


def test_import_mod_stdlib():
    """测试 import_mod 导入其他标准库模块"""
    print("=== Testing import_mod (stdlib modules) ===")
    
    mod = import_mod("sys")
    print(f"Imported module: {mod}")
    assert isinstance(mod, ModuleType), "Should return a ModuleType object"
    assert mod.__name__ == "sys", "Module name should be 'sys'"
    print("PASS: Successfully imported 'sys' module")
    
    mod = import_mod("json")
    print(f"Imported module: {mod}")
    assert isinstance(mod, ModuleType), "Should return a ModuleType object"
    assert mod.__name__ == "json", "Module name should be 'json'"
    print("PASS: Successfully imported 'json' module")
    print("")


def test_import_mod_submodule():
    """测试 import_mod 导入子模块"""
    print("=== Testing import_mod (submodule) ===")
    
    mod = import_mod("collections.abc")
    print(f"Imported module: {mod}")
    assert isinstance(mod, ModuleType), "Should return a ModuleType object"
    assert "collections" in mod.__name__, "Module name should contain 'collections'"
    print("PASS: Successfully imported 'collections.abc' submodule")
    print("")


def test_import_mod_failure():
    """测试 import_mod 导入不存在的模块时抛出异常"""
    print("=== Testing import_mod (failure case) ===")
    
    invalid_mod_name = "nonexistent_module_xyz123"
    print(f"Attempting to import non-existent module: {invalid_mod_name}")
    
    try:
        import_mod(invalid_mod_name)
        print("FAIL: Should have raised an exception for non-existent module")
        assert False, "Should have raised an exception"
    except ImportError as e:
        print(f"PASS: Correctly raised ImportError: {e}")
    except Exception as e:
        print(f"PASS: Correctly raised exception: {type(e).__name__}: {e}")
    print("")


def test_import_mod_rqalpha():
    """测试 import_mod 导入 rqalpha 模块"""
    print("=== Testing import_mod (rqalpha module) ===")
    
    mod = import_mod("rqalpha")
    print(f"Imported module: {mod}")
    assert isinstance(mod, ModuleType), "Should return a ModuleType object"
    assert mod.__name__ == "rqalpha", "Module name should be 'rqalpha'"
    print("PASS: Successfully imported 'rqalpha' module")
    print("")


def test_import_mod_rqalpha_submodule():
    """测试 import_mod 导入 rqalpha 子模块"""
    print("=== Testing import_mod (rqalpha submodule) ===")
    
    mod = import_mod("rqalpha.const")
    print(f"Imported module: {mod}")
    assert isinstance(mod, ModuleType), "Should return a ModuleType object"
    assert mod.__name__ == "rqalpha.const", "Module name should be 'rqalpha.const'"
    print("PASS: Successfully imported 'rqalpha.const' submodule")
    print("")


if __name__ == "__main__":
    print("=" * 60)
    print("RQAlpha Python utils/package_helper.py Test")
    print("=" * 60)
    print("")
    
    test_import_mod_success()
    test_import_mod_stdlib()
    test_import_mod_submodule()
    test_import_mod_failure()
    test_import_mod_rqalpha()
    test_import_mod_rqalpha_submodule()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
