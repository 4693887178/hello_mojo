# -*- coding: utf-8 -*-
"""
第四组测试 - utils/strategy_loader_help.py
测试Python版本的策略加载辅助模块
"""

import unittest
import sys
import os

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')


class TestStrategyLoaderHelp(unittest.TestCase):
    """测试rqalpha.utils.strategy_loader_help模块"""

    def setUp(self):
        from rqalpha.utils import strategy_loader_help
        self.module = strategy_loader_help

    def test_compile_strategy_exists(self):
        """测试compile_strategy函数存在"""
        self.assertTrue(hasattr(self.module, 'compile_strategy'))
        self.assertTrue(callable(self.module.compile_strategy))

    def test_compile_strategy_basic(self):
        """测试compile_strategy基本功能"""
        source_code = "x = 1 + 1"
        strategy = "test_strategy"
        scope = {}
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIsInstance(result, dict)
        self.assertEqual(result.get('x'), 2)

    def test_compile_strategy_with_function(self):
        """测试compile_strategy编译函数"""
        source_code = """
def my_func():
    return 42
"""
        strategy = "test_strategy"
        scope = {}
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('my_func', result)
        self.assertTrue(callable(result['my_func']))
        self.assertEqual(result['my_func'](), 42)

    def test_compile_strategy_with_class(self):
        """测试compile_strategy编译类"""
        source_code = """
class MyClass:
    def __init__(self):
        self.value = 100
"""
        strategy = "test_strategy"
        scope = {}
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('MyClass', result)
        obj = result['MyClass']()
        self.assertEqual(obj.value, 100)

    def test_compile_strategy_syntax_error(self):
        """测试compile_strategy语法错误处理"""
        source_code = "def broken("
        strategy = "test_strategy"
        scope = {}
        with self.assertRaises(Exception):
            self.module.compile_strategy(source_code, strategy, scope)

    def test_compile_strategy_with_import(self):
        """测试compile_strategy导入语句"""
        source_code = "import os"
        strategy = "test_strategy"
        scope = {}
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('os', result)


class TestStrategyLoaderHelpIntegration(unittest.TestCase):
    """测试策略加载辅助模块集成"""

    def setUp(self):
        from rqalpha.utils import strategy_loader_help
        self.module = strategy_loader_help

    def test_strategy_with_init(self):
        """测试包含init的策略"""
        source_code = """
def init(context):
    context.initialized = True
"""
        strategy = "test_strategy"
        scope = {}
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('init', result)

    def test_strategy_with_handle_bar(self):
        """测试包含handle_bar的策略"""
        source_code = """
def handle_bar(context, bar_dict):
    pass
"""
        strategy = "test_strategy"
        scope = {}
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('handle_bar', result)

    def test_strategy_complete(self):
        """测试完整策略"""
        source_code = """
def init(context):
    context.counter = 0

def handle_bar(context, bar_dict):
    context.counter += 1

def after_trading(context):
    pass
"""
        strategy = "test_strategy"
        scope = {}
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('init', result)
        self.assertIn('handle_bar', result)
        self.assertIn('after_trading', result)


if __name__ == '__main__':
    unittest.main(verbosity=2)
