# test_L01_01_class_helper.py
# Module: rqalpha.utils.class_helper
# Mojo: rqmojo.utils.class_helper
# Level: L01 - Utils module
# Dependencies: logger, i18n

import pytest
from rqalpha.utils import class_helper


class TestL01ClassHelper:
    """L01 - class_helper module tests"""

    class TestCachedProperty:
        """CachedProperty class tests"""

        def test_cached_property_exists(self):
            """Test cached_property exists"""
            assert hasattr(class_helper, 'cached_property')

        def test_cached_property_decorator(self):
            """Test cached_property as decorator"""
            class TestClass:
                def __init__(self):
                    self._call_count = 0
                
                @class_helper.cached_property
                def expensive_property(self):
                    self._call_count += 1
                    return "computed_value"
            
            obj = TestClass()
            result1 = obj.expensive_property
            result2 = obj.expensive_property
            
            assert result1 == "computed_value"
            assert result2 == "computed_value"
            assert obj._call_count == 1

        def test_cached_property_caches_value(self):
            """Test cached_property caches the value"""
            class TestClass:
                def __init__(self):
                    self._computed = False
                
                @class_helper.cached_property
                def lazy_value(self):
                    self._computed = True
                    return 42
            
            obj = TestClass()
            assert obj._computed == False
            _ = obj.lazy_value
            assert obj._computed == True

    class TestDeprecatedProperty:
        """deprecated_property function tests"""

        def test_deprecated_property_exists(self):
            """Test deprecated_property exists"""
            assert hasattr(class_helper, 'deprecated_property')

        def test_deprecated_property(self):
            """Test deprecated_property functionality"""
            class TestClass:
                def __init__(self):
                    self._new_value = "new_value"
                
                old_prop = class_helper.deprecated_property("old_prop", "_new_value")
            
            obj = TestClass()
            result = obj.old_prop
            assert result == "new_value"

    class TestModuleStructure:
        """Module structure tests"""

        def test_cached_property_class_exists(self):
            """Test CachedProperty class exists"""
            assert hasattr(class_helper, 'CachedProperty')

        def test_deprecated_property_exists(self):
            """Test deprecated_property function exists"""
            assert hasattr(class_helper, 'deprecated_property')
