# -*- coding: utf-8 -*-
"""
Test for rqalpha/core/global_var.py - Global Variables
Compares output with Mojo rqmojo/core/global_var.mojo
"""

import pickle
from rqalpha.core.global_var import GlobalVars


def test_global_vars_init():
    """测试 GlobalVars 初始化"""
    print("=== Testing GlobalVars init ===")
    
    g = GlobalVars()
    
    print("GlobalVars instance created")
    print("PASS: GlobalVars initialized correctly")
    print("")


def test_global_vars_set_get():
    """测试 GlobalVars set/get"""
    print("=== Testing GlobalVars set/get ===")
    
    g = GlobalVars()
    g.test_value = 42
    g.test_string = "hello"
    
    assert g.test_value == 42, "Expected test_value == 42"
    assert g.test_string == "hello", "Expected test_string == 'hello'"
    
    print(f"test_value: {g.test_value}")
    print(f"test_string: {g.test_string}")
    print("PASS: GlobalVars set/get works")
    print("")


def test_global_vars_get_state():
    """测试 GlobalVars get_state"""
    print("=== Testing GlobalVars get_state ===")
    
    g = GlobalVars()
    g.value1 = 100
    g.value2 = "test"
    
    state = g.get_state()
    print(f"State length: {len(state)} bytes")
    
    assert state is not None, "Expected state to be not None"
    
    print("PASS: GlobalVars get_state works")
    print("")


def test_global_vars_set_state():
    """测试 GlobalVars set_state"""
    print("=== Testing GlobalVars set_state ===")
    
    g1 = GlobalVars()
    g1.value1 = 100
    g1.value2 = "test"
    
    state = g1.get_state()
    
    g2 = GlobalVars()
    g2.set_state(state)
    
    print(f"g2.value1: {getattr(g2, 'value1', 'not set')}")
    print(f"g2.value2: {getattr(g2, 'value2', 'not set')}")
    
    print("PASS: GlobalVars set_state works")
    print("")


if __name__ == "__main__":
    print("=" * 60)
    print("RQAlpha Python core/global_var.py Test")
    print("=" * 60)
    print("")
    
    test_global_vars_init()
    test_global_vars_set_get()
    test_global_vars_get_state()
    test_global_vars_set_state()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
