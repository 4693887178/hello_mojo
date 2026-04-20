# -*- coding: utf-8 -*-
"""
第四组测试 - utils/strategy_loader_help.py
测试Python版本的策略加载辅助模块
与Mojo版本 test_strategy_loader_help.mojo 严格对齐
"""

import unittest
import sys
import os

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')


class TestStrategyLoaderHelp(unittest.TestCase):
    """测试rqalpha.utils.strategy_loader_help模块 - 基础功能"""

    def setUp(self):
        from rqalpha.utils import strategy_loader_help
        self.module = strategy_loader_help

    def _make_scope(self):
        return {"__builtins__": __builtins__}

    def test_compile_strategy_exists(self):
        """测试compile_strategy函数存在"""
        self.assertTrue(hasattr(self.module, 'compile_strategy'))
        self.assertTrue(callable(self.module.compile_strategy))

    def test_compile_strategy_basic(self):
        """测试compile_strategy基本功能 - 变量赋值"""
        source_code = "x = 1 + 1"
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIsInstance(result, dict)
        self.assertEqual(result.get('x'), 2)

    def test_compile_strategy_multi_line(self):
        """测试多行代码编译"""
        source_code = "a = 10\nb = 20\nc = a + b"
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertEqual(result.get('a'), 10)
        self.assertEqual(result.get('b'), 20)
        self.assertEqual(result.get('c'), 30)

    def test_compile_strategy_with_function(self):
        """测试compile_strategy编译函数"""
        source_code = """
def my_func():
    return 42
"""
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('my_func', result)
        self.assertTrue(callable(result['my_func']))
        self.assertEqual(result['my_func'](), 42)

    def test_compile_strategy_with_function_args(self):
        """测试带参数的函数编译"""
        source_code = "def add(a, b):\n    return a + b"
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertEqual(result['add'](3, 4), 7)

    def test_compile_strategy_with_class(self):
        """测试compile_strategy编译类"""
        source_code = """
class MyClass:
    def __init__(self):
        self.value = 100
"""
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('MyClass', result)
        obj = result['MyClass']()
        self.assertEqual(obj.value, 100)

    def test_compile_strategy_with_class_methods(self):
        """测试带方法的类编译"""
        source_code = """
class Counter:
    def __init__(self):
        self.count = 0
    def increment(self):
        self.count += 1
        return self.count
"""
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        obj = result['Counter']()
        self.assertEqual(obj.increment(), 1)
        self.assertEqual(obj.increment(), 2)

    def test_compile_strategy_syntax_error(self):
        """测试compile_strategy语法错误处理"""
        source_code = "def broken("
        strategy = "test_strategy"
        scope = self._make_scope()
        with self.assertRaises(Exception):
            self.module.compile_strategy(source_code, strategy, scope)

    def test_compile_strategy_syntax_error_missing_colon(self):
        """测试缺少冒号的语法错误"""
        source_code = "def foo()\n    pass"
        strategy = "test_strategy"
        scope = self._make_scope()
        with self.assertRaises(Exception):
            self.module.compile_strategy(source_code, strategy, scope)

    def test_compile_strategy_indentation_error(self):
        """测试缩进错误处理"""
        source_code = "def foo:\npass"
        strategy = "test_strategy"
        scope = self._make_scope()
        with self.assertRaises(Exception):
            self.module.compile_strategy(source_code, strategy, scope)

    def test_compile_strategy_with_import(self):
        """测试compile_strategy导入语句"""
        source_code = "import os"
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('os', result)

    def test_compile_strategy_with_from_import(self):
        """测试from导入语句"""
        source_code = "from os import path"
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('path', result)

    def test_compile_strategy_runtime_name_error(self):
        """测试运行时NameError处理"""
        source_code = "y = undefined_var + 1"
        strategy = "test_strategy"
        scope = self._make_scope()
        with self.assertRaises(Exception):
            self.module.compile_strategy(source_code, strategy, scope)

    def test_compile_strategy_runtime_type_error(self):
        """测试运行时TypeError处理"""
        source_code = "result = 'string' + 1"
        strategy = "test_strategy"
        scope = self._make_scope()
        with self.assertRaises(Exception):
            self.module.compile_strategy(source_code, strategy, scope)


class TestStrategyLoaderHelpIntegration(unittest.TestCase):
    """测试策略加载辅助模块集成 - 策略生命周期"""

    def setUp(self):
        from rqalpha.utils import strategy_loader_help
        self.module = strategy_loader_help

    def _make_scope(self):
        return {"__builtins__": __builtins__}

    def test_strategy_with_init(self):
        """测试包含init的策略"""
        source_code = """
def init(context):
    context.initialized = True
"""
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('init', result)

    def test_strategy_with_handle_bar(self):
        """测试包含handle_bar的策略"""
        source_code = """
def handle_bar(context, bar_dict):
    pass
"""
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('handle_bar', result)

    def test_strategy_with_after_trading(self):
        """测试包含after_trading的策略"""
        source_code = """
def after_trading(context):
    pass
"""
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('after_trading', result)

    def test_strategy_with_before_trading(self):
        """测试包含before_trading的策略"""
        source_code = """
def before_trading(context):
    pass
"""
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('before_trading', result)

    def test_strategy_complete(self):
        """测试完整策略 - 所有生命周期函数"""
        source_code = """
def init(context):
    context.counter = 0

def handle_bar(context, bar_dict):
    context.counter += 1

def after_trading(context):
    pass
"""
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('init', result)
        self.assertIn('handle_bar', result)
        self.assertIn('after_trading', result)

    def test_strategy_with_complex_logic(self):
        """测试复杂策略逻辑"""
        source_code = """
def calculate_sma(prices, window=5):
    if len(prices) < window:
        return None
    return sum(prices[-window:]) / window
"""
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('calculate_sma', result)
        prices = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        sma = result['calculate_sma'](prices, 3)
        self.assertAlmostEqual(sma, 9.0)

    def test_strategy_scope_isolation(self):
        """测试作用域隔离 - 不同策略互不影响"""
        scope1 = self._make_scope()
        scope2 = self._make_scope()

        self.module.compile_strategy("x = 100", "strategy_a", scope1)
        self.module.compile_strategy("x = 200", "strategy_b", scope2)

        self.assertEqual(scope1.get('x'), 100)
        self.assertEqual(scope2.get('x'), 200)

    def test_strategy_scope_persistence(self):
        """测试作用域持久化 - 多次编译累积"""
        scope = self._make_scope()
        self.module.compile_strategy("first = 1", "test", scope)
        self.module.compile_strategy("second = first + 1", "test", scope)

        self.assertEqual(scope.get('first'), 1)
        self.assertEqual(scope.get('second'), 2)

    def test_strategy_lambda(self):
        """测试lambda表达式"""
        source_code = "double = lambda x: x * 2"
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertEqual(result['double'](21), 42)

    def test_strategy_list_comprehension(self):
        """测试列表推导式"""
        source_code = "squares = [x**2 for x in range(5)]"
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertEqual(len(result['squares']), 5)
        self.assertEqual(result['squares'][4], 16)

    def test_strategy_decorator_simple(self):
        """测试装饰器"""
        source_code = """
def my_decorator(func):
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper

@my_decorator
def greet(name):
    return 'Hello ' + name
"""
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertIn('greet', result)
        self.assertEqual(result['greet']("World"), "Hello World")

    def test_strategy_try_except(self):
        """测试try-except语句"""
        source_code = """
def safe_divide(a, b):
    try:
        return a / b
    except ZeroDivisionError:
        return None
"""
        strategy = "test_strategy"
        scope = self._make_scope()
        result = self.module.compile_strategy(source_code, strategy, scope)
        self.assertAlmostEqual(result['safe_divide'](10, 2), 5.0)
        self.assertIsNone(result['safe_divide'](1, 0))

    def test_strategy_custom_exception_msg(self):
        """测试自定义异常消息传递"""
        source_code = "raise ValueError('custom error message')"
        strategy = "test_strategy"
        scope = self._make_scope()
        caught = False
        try:
            self.module.compile_strategy(source_code, strategy, scope)
        except Exception:
            caught = True
        self.assertTrue(caught, "Expected compile_strategy to raise an exception for ValueError")


if __name__ == '__main__':
    unittest.main(verbosity=2)
