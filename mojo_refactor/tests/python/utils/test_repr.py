# -*- coding: utf-8 -*-
"""
Test for rqalpha/utils/repr.py - Repr Utilities
Compares output with Mojo rqmojo/utils/repr.mojo
"""

from rqalpha.utils.repr import property_repr, slots_repr, dict_repr, properties, _repr
from rqalpha.utils.class_helper import cached_property


class TestClass:
    """Test class for repr testing"""
    
    def __init__(self):
        self._private = "private_value"
        self.name = "test_name"
        self.value = 42
    
    @property
    def computed(self):
        return "computed_value"
    
    @cached_property
    def cached(self):
        return "cached_value"


class TestClassWithSlots:
    """Test class with slots"""
    
    __slots__ = ['x', 'y']
    
    def __init__(self, x, y):
        self.x = x
        self.y = y


class TestClassWithAbandon:
    """Test class with abandoned properties"""
    
    __abandon_properties__ = ['ignored']
    
    def __init__(self):
        self.name = "test"
        self.ignored = "should_be_ignored"
    
    @property
    def included(self):
        return "included_value"
    
    @property
    def ignored(self):
        return "ignored_value"


def test_property_repr():
    """测试 property_repr 函数"""
    print("=== Testing property_repr ===")
    
    obj = TestClass()
    result = property_repr(obj)
    
    print(f"property_repr result: {result}")
    
    assert "TestClass" in result
    assert "name" in result or "value" in result or "computed" in result
    
    print("PASS: property_repr works correctly")
    print("")


def test_dict_repr():
    """测试 dict_repr 函数"""
    print("=== Testing dict_repr ===")
    
    obj = TestClass()
    result = dict_repr(obj)
    
    print(f"dict_repr result: {result}")
    
    assert "TestClass" in result
    assert "_private" not in result
    
    print("PASS: dict_repr works correctly")
    print("")


def test_properties():
    """测试 properties 函数"""
    print("=== Testing properties ===")
    
    obj = TestClass()
    props = properties(obj)
    
    print(f"Properties: {props}")
    
    assert isinstance(props, dict)
    
    print("PASS: properties function works correctly")
    print("")


def test_repr_function():
    """测试 _repr 函数"""
    print("=== Testing _repr ===")
    
    result = _repr("MyClass", ["name", "value"])
    
    print(f"_repr result: {result}")
    
    assert "MyClass" in result
    assert "name" in result
    assert "value" in result
    
    print("PASS: _repr function works correctly")
    print("")


def test_slots_repr():
    """测试 slots_repr 函数"""
    print("=== Testing slots_repr ===")
    
    obj = TestClassWithSlots(10, 20)
    result = slots_repr(obj)
    
    print(f"slots_repr result: {result}")
    
    assert "TestClassWithSlots" in result
    
    print("PASS: slots_repr works correctly")
    print("")


def test_properties_excludes_private():
    """测试 properties 排除私有属性"""
    print("=== Testing properties excludes private ===")
    
    obj = TestClass()
    props = properties(obj)
    
    print(f"Properties (should exclude _private): {list(props.keys())}")
    
    assert "_private" not in props
    
    print("PASS: Private properties excluded")
    print("")


def test_properties_includes_cached():
    """测试 properties 包含 cached_property"""
    print("=== Testing properties includes cached_property ===")
    
    obj = TestClass()
    props = properties(obj)
    
    print(f"Properties keys: {list(props.keys())}")
    
    assert "cached" in props
    
    print("PASS: cached_property included")
    print("")


if __name__ == "__main__":
    print("=" * 60)
    print("RQAlpha Python utils/repr.py Test")
    print("=" * 60)
    print("")
    
    test_property_repr()
    test_dict_repr()
    test_properties()
    test_repr_function()
    test_slots_repr()
    test_properties_excludes_private()
    test_properties_includes_cached()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
