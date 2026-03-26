# -*- coding: utf-8 -*-
"""
第四组测试 - utils/class_helper.py
测试Python版本的类辅助模块
"""

import unittest
import sys
import os

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')


class TestClassHelperModule(unittest.TestCase):
    """测试rqalpha.utils.class_helper模块"""

    def setUp(self):
        from rqalpha.utils import class_helper
        self.module = class_helper

    def test_deprecated_property_exists(self):
        """测试deprecated_property函数存在"""
        self.assertTrue(hasattr(self.module, 'deprecated_property'))
        self.assertTrue(callable(self.module.deprecated_property))

    def test_CachedProperty_exists(self):
        """测试CachedProperty类存在"""
        self.assertTrue(hasattr(self.module, 'CachedProperty'))

    def test_cached_property_exists(self):
        """测试cached_property存在"""
        self.assertTrue(hasattr(self.module, 'cached_property'))


class TestDeprecatedProperty(unittest.TestCase):
    """测试deprecated_property函数"""

    def setUp(self):
        from rqalpha.utils.class_helper import deprecated_property
        self.deprecated_property = deprecated_property

    def test_deprecated_property_basic(self):
        """测试deprecated_property基本功能"""
        prop = self.deprecated_property("old_name", "new_name")
        self.assertIsNotNone(prop)

    def test_deprecated_property_returns_property(self):
        """测试deprecated_property返回property对象"""
        prop = self.deprecated_property("old_name", "new_name")
        self.assertIsInstance(prop, property)


class TestCachedProperty(unittest.TestCase):
    """测试CachedProperty类"""

    def setUp(self):
        from rqalpha.utils.class_helper import CachedProperty, cached_property
        self.CachedProperty = CachedProperty
        self.cached_property = cached_property

    def test_cached_property_decorator(self):
        """测试cached_property装饰器"""
        class TestClass:
            @self.cached_property
            def expensive_property(self):
                return "computed_value"
        
        obj = TestClass()
        result = obj.expensive_property
        self.assertEqual(result, "computed_value")

    def test_cached_property_caches_result(self):
        """测试cached_property缓存结果"""
        call_count = [0]
        
        class TestClass:
            @self.cached_property
            def cached_value(self):
                call_count[0] += 1
                return call_count[0]
        
        obj = TestClass()
        first = obj.cached_value
        second = obj.cached_value
        self.assertEqual(first, 1)
        self.assertEqual(second, 1)
        self.assertEqual(call_count[0], 1)

    def test_cached_property_different_instances(self):
        """测试cached_property不同实例独立缓存"""
        class TestClass:
            @self.cached_property
            def value(self):
                return id(self)
        
        obj1 = TestClass()
        obj2 = TestClass()
        self.assertNotEqual(obj1.value, obj2.value)


class TestCachedPropertyAdvanced(unittest.TestCase):
    """测试CachedProperty高级功能"""

    def setUp(self):
        from rqalpha.utils.class_helper import cached_property
        self.cached_property = cached_property

    def test_cached_property_with_dependency(self):
        """测试cached_property依赖其他属性"""
        class TestClass:
            def __init__(self, base):
                self._base = base
            
            @self.cached_property
            def computed(self):
                return self._base * 2
        
        obj = TestClass(10)
        self.assertEqual(obj.computed, 20)

    def test_cached_property_with_list(self):
        """测试cached_property返回列表"""
        class TestClass:
            @self.cached_property
            def items(self):
                return [1, 2, 3]
        
        obj = TestClass()
        items = obj.items
        items.append(4)
        self.assertEqual(len(obj.items), 4)


class TestDeprecatedPropertyIntegration(unittest.TestCase):
    """测试deprecated_property集成"""

    def setUp(self):
        from rqalpha.utils.class_helper import deprecated_property
        self.deprecated_property = deprecated_property

    def test_deprecated_property_access(self):
        """测试deprecated_property访问"""
        class TestClass:
            def __init__(self):
                self._new_value = 42
            
            new_value = property(lambda self: self._new_value)
            old_value = self.deprecated_property("old_value", "new_value")
        
        obj = TestClass()
        result = obj.old_value
        self.assertEqual(result, 42)


if __name__ == '__main__':
    unittest.main(verbosity=2)
