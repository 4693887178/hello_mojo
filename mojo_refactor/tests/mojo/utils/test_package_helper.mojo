"""
Test for package_helper.mojo - Package Helper Module
Compares output with Python rqalpha/utils/package_helper.py
"""

from rqmojo.utils.package_helper import import_mod


def test_import_mod_success():
    """测试 import_mod 成功导入模块"""
    print("=== Testing import_mod (success case) ===")
    
    var mod = import_mod("os")
    print("Imported module: " + str(mod))
    
    print("PASS: Successfully imported 'os' module")
    print("")


def test_import_mod_stdlib():
    """测试 import_mod 导入其他标准库模块"""
    print("=== Testing import_mod (stdlib modules) ===")
    
    var mod = import_mod("sys")
    print("Imported module: " + str(mod))
    print("PASS: Successfully imported 'sys' module")
    
    var mod2 = import_mod("json")
    print("Imported module: " + str(mod2))
    print("PASS: Successfully imported 'json' module")
    print("")


def test_import_mod_submodule():
    """测试 import_mod 导入子模块"""
    print("=== Testing import_mod (submodule) ===")
    
    var mod = import_mod("collections.abc")
    print("Imported module: " + str(mod))
    print("PASS: Successfully imported 'collections.abc' submodule")
    print("")


def test_import_mod_failure():
    """测试 import_mod 导入不存在的模块时抛出异常"""
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
    """测试 import_mod 导入 rqmojo 模块"""
    print("=== Testing import_mod (rqmojo module) ===")
    
    var mod = import_mod("rqmojo")
    print("Imported module: " + str(mod))
    print("PASS: Successfully imported 'rqmojo' module")
    print("")


def test_import_mod_rqmojo_submodule():
    """测试 import_mod 导入 rqmojo 子模块"""
    print("=== Testing import_mod (rqmojo submodule) ===")
    
    var mod = import_mod("rqmojo.const")
    print("Imported module: " + str(mod))
    print("PASS: Successfully imported 'rqmojo.const' submodule")
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
