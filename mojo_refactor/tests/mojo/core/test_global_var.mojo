"""
Test for global_var.mojo - Global Variables
Compares output with Python rqalpha/core/global_var.py
"""

from std.collections import Dict
from rqmojo.core.global_var import GlobalVars, create_global_vars


def test_global_vars_init():
    """测试 GlobalVars 初始化"""
    print("=== Testing GlobalVars init ===")
    
    var g = create_global_vars()
    print("GlobalVars instance created")
    print("PASS: GlobalVars initialized correctly")
    print("")


def test_global_vars_set_get():
    """测试 GlobalVars set/get"""
    print("=== Testing GlobalVars set/get ===")
    
    var g = create_global_vars()
    g.set("test_value", 42)
    g.set("test_string", "hello")
    
    var val1 = g.get("test_value")
    var val2 = g.get("test_string")
    
    print("test_value: " + String(val1))
    print("test_string: " + String(val2))
    print("PASS: GlobalVars set/get works")
    print("")


def test_global_vars_contains():
    """测试 GlobalVars contains"""
    print("=== Testing GlobalVars contains ===")
    
    var g = create_global_vars()
    g.set("key1", "value1")
    
    if g.contains("key1"):
        print("PASS: contains returns True for existing key")
    else:
        print("FAIL: contains should return True")
    
    if not g.contains("nonexistent"):
        print("PASS: contains returns False for non-existing key")
    else:
        print("FAIL: contains should return False")
    
    print("")


def test_global_vars_remove():
    """测试 GlobalVars remove"""
    print("=== Testing GlobalVars remove ===")
    
    var g = create_global_vars()
    g.set("key1", "value1")
    
    var result = g.remove("key1")
    if result:
        print("PASS: remove returns True for existing key")
    else:
        print("FAIL: remove should return True")
    
    if not g.contains("key1"):
        print("PASS: key removed successfully")
    else:
        print("FAIL: key should be removed")
    
    print("")


def test_global_vars_clear():
    """测试 GlobalVars clear"""
    print("=== Testing GlobalVars clear ===")
    
    var g = create_global_vars()
    g.set("key1", "value1")
    g.set("key2", "value2")
    
    g.clear()
    
    var keys = g.keys()
    if len(keys) == 0:
        print("PASS: clear removes all keys")
    else:
        print("FAIL: clear should remove all keys")
    
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo core/global_var.mojo Test")
    print("=" * 60)
    print("")
    
    test_global_vars_init()
    test_global_vars_set_get()
    test_global_vars_contains()
    test_global_vars_remove()
    test_global_vars_clear()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
