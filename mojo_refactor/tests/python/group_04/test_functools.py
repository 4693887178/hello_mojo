# -*- coding: utf-8 -*-
"""
第四组测试 - utils/functools.py
测试Python版本的函数工具模块
"""

import unittest
import sys
import os

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')


class TestFunctoolsModule(unittest.TestCase):
    """测试rqalpha.utils.functools模块"""

    def setUp(self):
        from rqalpha.utils import functools
        self.module = functools

    def test_lru_cache_exists(self):
        """测试lru_cache函数存在"""
        self.assertTrue(hasattr(self.module, 'lru_cache'))
        self.assertTrue(callable(self.module.lru_cache))

    def test_clear_all_cached_functions_exists(self):
        """测试clear_all_cached_functions函数存在"""
        self.assertTrue(hasattr(self.module, 'clear_all_cached_functions'))
        self.assertTrue(callable(self.module.clear_all_cached_functions))

    def test_SingleDispatchProtocol_exists(self):
        """测试SingleDispatchProtocol存在"""
        self.assertTrue(hasattr(self.module, 'SingleDispatchProtocol'))

    def test_cast_singledispatch_exists(self):
        """测试cast_singledispatch函数存在"""
        self.assertTrue(hasattr(self.module, 'cast_singledispatch'))
        self.assertTrue(callable(self.module.cast_singledispatch))

    def test_instype_singledispatch_exists(self):
        """测试instype_singledispatch函数存在"""
        self.assertTrue(hasattr(self.module, 'instype_singledispatch'))
        self.assertTrue(callable(self.module.instype_singledispatch))


class TestLruCache(unittest.TestCase):
    """测试lru_cache装饰器"""

    def setUp(self):
        from rqalpha.utils.functools import lru_cache
        self.lru_cache = lru_cache

    def test_lru_cache_basic(self):
        """测试lru_cache基本功能"""
        call_count = [0]
        
        @self.lru_cache(maxsize=128)
        def expensive_func(x):
            call_count[0] += 1
            return x * 2
        
        result1 = expensive_func(5)
        result2 = expensive_func(5)
        self.assertEqual(result1, 10)
        self.assertEqual(result2, 10)
        self.assertEqual(call_count[0], 1)

    def test_lru_cache_different_args(self):
        """测试lru_cache不同参数"""
        call_count = [0]
        
        @self.lru_cache(maxsize=128)
        def func(x):
            call_count[0] += 1
            return x * 2
        
        result1 = func(5)
        result2 = func(10)
        self.assertEqual(result1, 10)
        self.assertEqual(result2, 20)
        self.assertEqual(call_count[0], 2)

    def test_lru_cache_maxsize(self):
        """测试lru_cache最大缓存大小"""
        @self.lru_cache(maxsize=2)
        def func(x):
            return x
        
        func(1)
        func(2)
        func(3)
        func(1)
        self.assertEqual(func.cache_info().hits, 0)


class TestClearAllCachedFunctions(unittest.TestCase):
    """测试clear_all_cached_functions函数"""

    def setUp(self):
        from rqalpha.utils.functools import lru_cache, clear_all_cached_functions
        self.lru_cache = lru_cache
        self.clear_all = clear_all_cached_functions

    def test_clear_all_cached_functions(self):
        """测试清除所有缓存函数"""
        call_count = [0]
        
        @self.lru_cache(maxsize=128)
        def cached_func(x):
            call_count[0] += 1
            return x
        
        cached_func(5)
        cached_func(5)
        self.assertEqual(call_count[0], 1)
        
        self.clear_all()
        
        cached_func(5)
        self.assertEqual(call_count[0], 2)


class TestInstypeSingledispatch(unittest.TestCase):
    """测试instype_singledispatch装饰器"""

    def setUp(self):
        from rqalpha.utils.functools import instype_singledispatch
        self.instype_singledispatch = instype_singledispatch

    def test_instype_singledispatch_exists(self):
        """测试instype_singledispatch存在"""
        self.assertTrue(callable(self.instype_singledispatch))

    def test_instype_singledispatch_register(self):
        """测试instype_singledispatch注册方法"""
        @self.instype_singledispatch
        def process(id_or_ins):
            return "default"
        
        self.assertTrue(hasattr(process, 'register'))
        self.assertTrue(callable(process.register))


if __name__ == '__main__':
    unittest.main(verbosity=2)
