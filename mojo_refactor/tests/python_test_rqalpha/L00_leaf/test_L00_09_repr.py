# test_L00_09_repr.py
# Module: rqalpha.utils.repr
# Mojo: rqmojo.utils.repr
# Level: L00 - Leaf module
# Dependencies: class_helper

import pytest
from rqalpha.utils import repr as repr_utils
from rqalpha.utils.class_helper import cached_property


class TestL00Repr:
    """L00 - repr module tests"""

    class TestReprFunctions:
        """_repr function tests"""

        def test_repr_returns_function(self):
            """Test _repr returns a function (closure)"""
            result = repr_utils._repr("TestClass", ["name", "value"])
            assert callable(result)

        def test_repr_function_format(self):
            """Test _repr returned function formats correctly"""
            repr_func = repr_utils._repr("TestClass", ["name", "value"])
            
            class MockObj:
                name = "test_name"
                value = 42
            
            result = repr_func(MockObj())
            assert "TestClass" in result
            assert "test_name" in result
            assert "42" in result

        def test_repr_empty_properties(self):
            """Test _repr with empty properties"""
            repr_func = repr_utils._repr("EmptyClass", [])
            
            class MockObj:
                pass
            
            result = repr_func(MockObj())
            assert result == "EmptyClass()"

        def test_repr_single_property(self):
            """Test _repr with single property"""
            repr_func = repr_utils._repr("SingleClass", ["name"])
            
            class MockObj:
                name = "test"
            
            result = repr_func(MockObj())
            assert "SingleClass" in result
            assert "test" in result

    class TestPropertyRepr:
        """property_repr function tests"""

        def test_property_repr_with_properties(self):
            """Test property_repr with property decorated methods"""
            class TestClass:
                @property
                def name(self):
                    return "test"
                
                @property
                def value(self):
                    return 42
            
            obj = TestClass()
            result = repr_utils.property_repr(obj)
            assert "TestClass" in result
            assert "name" in result

        def test_property_repr_excludes_private(self):
            """Test property_repr excludes private attributes"""
            class TestClass:
                @property
                def name(self):
                    return "test"
                
                @property
                def _private(self):
                    return "hidden"
            
            obj = TestClass()
            result = repr_utils.property_repr(obj)
            assert "_private" not in result

    class TestSlotsRepr:
        """slots_repr function tests"""

        def test_slots_repr_basic(self):
            """Test slots_repr with slots class"""
            class TestClass:
                __slots__ = ["name", "value"]
                
                def __init__(self):
                    self.name = "test"
                    self.value = 42
            
            obj = TestClass()
            result = repr_utils.slots_repr(obj)
            assert "TestClass" in result
            assert "name" in result

    class TestDictRepr:
        """dict_repr function tests"""

        def test_dict_repr_basic(self):
            """Test dict_repr with basic class"""
            class TestClass:
                def __init__(self):
                    self.name = "test"
                    self.value = 42
                    self._private = "hidden"
            
            obj = TestClass()
            result = repr_utils.dict_repr(obj)
            assert "TestClass" in result
            assert "name" in result
            assert "_private" not in result

    class TestProperties:
        """properties function tests"""

        def test_properties_with_property_decorator(self):
            """Test properties extraction with @property"""
            class TestClass:
                @property
                def name(self):
                    return "test"
                
                @property
                def value(self):
                    return 42
            
            obj = TestClass()
            props = repr_utils.properties(obj)
            assert "name" in props
            assert "value" in props

        def test_properties_with_cached_property(self):
            """Test properties with cached_property"""
            class TestClass:
                @cached_property
                def name(self):
                    return "test"
            
            obj = TestClass()
            props = repr_utils.properties(obj)
            assert "name" in props

        def test_properties_with_abandon(self):
            """Test properties with __abandon_properties__"""
            class TestClass:
                __abandon_properties__ = ["value"]
                
                @property
                def name(self):
                    return "test"
                
                @property
                def value(self):
                    return 42
            
            obj = TestClass()
            props = repr_utils.properties(obj)
            assert "name" in props
            assert "value" not in props

    class TestSlots:
        """slots function tests"""

        def test_slots_basic(self):
            """Test slots extraction"""
            class TestClass:
                __slots__ = ["name", "value"]
                
                def __init__(self):
                    self.name = "test"
                    self.value = 42
            
            obj = TestClass()
            slots_dict = repr_utils.slots(obj)
            assert "name" in slots_dict
            assert "value" in slots_dict

    class TestIterPropertiesOfClass:
        """iter_properties_of_class function tests"""

        def test_iter_properties(self):
            """Test iterating properties of class"""
            class TestClass:
                @property
                def name(self):
                    return "test"
                
                @property
                def value(self):
                    return 42
            
            props = list(repr_utils.iter_properties_of_class(TestClass))
            assert "name" in props
            assert "value" in props

        def test_iter_properties_with_cached_property(self):
            """Test iterating properties with cached_property"""
            class TestClass:
                @cached_property
                def name(self):
                    return "test"
            
            props = list(repr_utils.iter_properties_of_class(TestClass))
            assert "name" in props

    class TestPropertyReprMeta:
        """PropertyReprMeta tests"""

        def test_metaclass_creates_repr(self):
            """Test PropertyReprMeta creates __repr__"""
            class TestClass(metaclass=repr_utils.PropertyReprMeta):
                __repr_properties__ = ["name", "value"]
                
                def __init__(self):
                    self.name = "test"
                    self.value = 42
            
            obj = TestClass()
            result = repr(obj)
            assert "TestClass" in result
            assert "test" in result
            assert "42" in result

        def test_metaclass_auto_detect_properties(self):
            """Test PropertyReprMeta auto-detects properties"""
            class TestClass(metaclass=repr_utils.PropertyReprMeta):
                @property
                def name(self):
                    return "test"
                
                @property
                def value(self):
                    return 42
            
            obj = TestClass()
            result = repr(obj)
            assert "TestClass" in result

    class TestMojoCompatibility:
        """Tests for Mojo compatibility"""

        def test_repr_function_callable(self):
            """Test _repr returns callable"""
            result = repr_utils._repr("TestClass", ["name", "value"])
            assert callable(result)

        def test_properties_dict_format(self):
            """Test properties returns dict"""
            class TestClass:
                @property
                def name(self):
                    return "test"
            
            obj = TestClass()
            props = repr_utils.properties(obj)
            assert isinstance(props, dict)

        def test_private_attribute_filtering(self):
            """Test private attributes are filtered"""
            class TestClass:
                @property
                def name(self):
                    return "test"
                
                @property
                def _private(self):
                    return "hidden"
            
            obj = TestClass()
            props = repr_utils.properties(obj)
            assert "_private" not in props
