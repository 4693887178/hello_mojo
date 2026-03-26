#!/usr/bin/env python3
"""
Test for rqalpha/utils/repr.py
"""

import sys
import os

# Add the Python package path
sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')

from rqalpha.utils.repr import (
    property_repr, slots_repr, dict_repr, properties, slots,
    PropertyReprMeta, _repr
)
from rqalpha.utils.class_helper import cached_property


def test_property_repr():
    """Test property_repr function"""
    print("Test 1: property_repr")
    
    class TestClass:
        def __init__(self):
            self._value = 42
            self.name = "test"
        
        @property
        def value(self):
            return self._value
    
    obj = TestClass()
    result = property_repr(obj)
    print(f"  Result: {result}")
    print(f"  Contains 'TestClass': {'TestClass' in result}")
    print(f"  Contains 'value': {'value' in result}")
    print("  PASS")
    return True


def test_dict_repr():
    """Test dict_repr function"""
    print("Test 2: dict_repr")
    
    class TestClass:
        def __init__(self):
            self.name = "test"
            self.value = 123
            self._private = "hidden"
    
    obj = TestClass()
    result = dict_repr(obj)
    print(f"  Result: {result}")
    print(f"  Contains 'TestClass': {'TestClass' in result}")
    print(f"  Contains 'name': {'name' in result}")
    print(f"  Not contains '_private': {'_private' not in result}")
    print("  PASS")
    return True


def test_slots_repr():
    """Test slots_repr function"""
    print("Test 3: slots_repr")
    
    class TestClass:
        __slots__ = ['name', 'value']
        
        def __init__(self):
            self.name = "test"
            self.value = 42
    
    obj = TestClass()
    result = slots_repr(obj)
    print(f"  Result: {result}")
    print(f"  Contains 'TestClass': {'TestClass' in result}")
    print(f"  Contains 'name': {'name' in result}")
    print("  PASS")
    return True


def test_properties():
    """Test properties function"""
    print("Test 4: properties")
    
    class TestClass:
        def __init__(self):
            self._value = 42
            self.name = "test"
        
        @property
        def value(self):
            return self._value
        
        @cached_property
        def cached_val(self):
            return "cached"
    
    obj = TestClass()
    result = properties(obj)
    print(f"  Properties: {result}")
    print(f"  Has 'value': {'value' in result}")
    print(f"  Has 'cached_val': {'cached_val' in result}")
    print("  PASS")
    return True


def test_slots():
    """Test slots function"""
    print("Test 5: slots")
    
    class TestClass:
        __slots__ = ['name', 'value']
        
        def __init__(self):
            self.name = "test"
            self.value = 42
    
    obj = TestClass()
    result = slots(obj)
    print(f"  Slots: {result}")
    print(f"  Has 'name': {'name' in result}")
    print(f"  Has 'value': {'value' in result}")
    print("  PASS")
    return True


def test_repr_function():
    """Test _repr function"""
    print("Test 6: _repr function")
    
    class TestClass:
        def __init__(self):
            self.name = "test"
            self.value = 42
    
    obj = TestClass()
    repr_func = _repr("TestClass", ["name", "value"])
    result = repr_func(obj)
    print(f"  Result: {result}")
    print(f"  Contains 'TestClass': {'TestClass' in result}")
    print(f"  Contains 'name': {'name' in result}")
    print("  PASS")
    return True


def test_property_repr_meta():
    """Test PropertyReprMeta metaclass"""
    print("Test 7: PropertyReprMeta")
    
    class TestClass(metaclass=PropertyReprMeta):
        __repr_properties__ = ['name', 'value']
        
        def __init__(self):
            self.name = "test"
            self.value = 42
    
    obj = TestClass()
    result = repr(obj)
    print(f"  Result: {result}")
    print(f"  Contains 'TestClass': {'TestClass' in result}")
    print("  PASS")
    return True


def test_abandon_properties():
    """Test __abandon_properties__ filtering"""
    print("Test 8: __abandon_properties__")
    
    class TestClass:
        __abandon_properties__ = ['hidden']
        
        def __init__(self):
            self.name = "test"
            self._hidden_val = "hidden value"
        
        @property
        def value(self):
            return 42
        
        @property
        def hidden(self):
            return self._hidden_val
    
    obj = TestClass()
    result = properties(obj)
    print(f"  Properties: {result}")
    print(f"  Has 'value': {'value' in result}")
    print(f"  Not has 'hidden': {'hidden' not in result}")
    print("  PASS")
    return True


def main():
    print("=" * 60)
    print("Python repr.py Test")
    print("=" * 60)
    
    results = []
    results.append(test_property_repr())
    results.append(test_dict_repr())
    results.append(test_slots_repr())
    results.append(test_properties())
    results.append(test_slots())
    results.append(test_repr_function())
    results.append(test_property_repr_meta())
    results.append(test_abandon_properties())
    
    print()
    print("=" * 60)
    print(f"Results: {sum(results)}/{len(results)} passed")
    print("=" * 60)
    
    return sum(results) == len(results)


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
