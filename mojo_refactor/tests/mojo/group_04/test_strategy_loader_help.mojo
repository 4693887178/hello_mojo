"""
第四组测试 - utils/strategy_loader_help.mojo
与Python原版 strategy_loader_help.py 严格对齐
"""

from rqmojo.utils.strategy_loader_help import compile_strategy
from std.python import Python, PythonObject

from std.testing import assert_equal, assert_true, assert_raises, TestSuite


def test_compile_strategy_basic() raises:
    var scope = Python.dict()
    scope["__builtins__"] = Python.import_module("builtins")

    var result = compile_strategy("x = 1 + 1", "test_strategy", scope)
    assert_equal(Int(py=result.__getitem__("x")), 2)


def test_compile_strategy_with_function() raises:
    var scope = Python.dict()
    scope["__builtins__"] = Python.import_module("builtins")

    var result = compile_strategy(
        "def my_func():\n    return 42",
        "test_strategy",
        scope,
    )
    var ret = result.__getitem__("my_func")()
    assert_equal(Int(py=ret), 42)


def test_compile_strategy_with_class() raises:
    var scope = Python.dict()
    scope["__builtins__"] = Python.import_module("builtins")

    var result = compile_strategy(
        "class MyClass:\n    def __init__(self):\n        self.value = 100",
        "test_strategy",
        scope,
    )
    var obj = result.__getitem__("MyClass")()
    assert_equal(Int(py=obj.value), 100)


def test_compile_strategy_syntax_error() raises:
    var scope = Python.dict()
    scope["__builtins__"] = Python.import_module("builtins")

    with assert_raises():
        _ = compile_strategy("def broken(", "test_strategy", scope)


def test_compile_strategy_with_import() raises:
    var scope = Python.dict()
    scope["__builtins__"] = Python.import_module("builtins")

    var result = compile_strategy("import os", "test_strategy", scope)
    assert_true(result.__contains__("os"))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
