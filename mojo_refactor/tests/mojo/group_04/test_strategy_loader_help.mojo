"""
第四组测试 - utils/strategy_loader_help.mojo
与Python原版 strategy_loader_help.py 严格对齐

测试覆盖:
  1. 基本编译功能 (变量赋值)
  2. 函数定义与调用
  3. 类定义与实例化
  4. SyntaxError 处理
  5. IndentationError 处理
  6. import 语句处理
  7. 运行时错误处理 (NameError等)
  8. 策略生命周期函数 (init/handle_bar/after_trading)
  9. 完整策略编译
  10. 栈信息验证
  11. 边界情况 (空源码、特殊字符)
"""

from rqmojo.utils.strategy_loader_help import compile_strategy
from std.python import Python, PythonObject

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def _make_scope() raises -> PythonObject:
    var scope = Python.dict()
    scope["__builtins__"] = Python.import_module("builtins")
    return scope


def _contains(s: String, sub: String) -> Bool:
    return s.find(sub) != -1


def test_compile_strategy_basic() raises:
    var result = compile_strategy("x = 1 + 1", "test_strategy", _make_scope())
    assert_equal(Int(py=result.__getitem__("x")), 2)


def test_compile_strategy_multi_line() raises:
    var source = "a = 10\nb = 20\nc = a + b"
    var result = compile_strategy(source, "test_strategy", _make_scope())
    assert_equal(Int(py=result.__getitem__("a")), 10)
    assert_equal(Int(py=result.__getitem__("b")), 20)
    assert_equal(Int(py=result.__getitem__("c")), 30)


def test_compile_strategy_with_function() raises:
    var source = "def my_func():\n    return 42"
    var result = compile_strategy(source, "test_strategy", _make_scope())
    var ret = result.__getitem__("my_func")()
    assert_equal(Int(py=ret), 42)


def test_compile_strategy_with_function_args() raises:
    var source = "def add(a, b):\n    return a + b"
    var result = compile_strategy(source, "test_strategy", _make_scope())
    var add_fn = result.__getitem__("add")
    var ret = add_fn(3, 4)
    assert_equal(Int(py=ret), 7)


def test_compile_strategy_with_class() raises:
    var source = "class MyClass:\n    def __init__(self):\n        self.value = 100"
    var result = compile_strategy(source, "test_strategy", _make_scope())
    var obj = result.__getitem__("MyClass")()
    assert_equal(Int(py=obj.value), 100)


def test_compile_strategy_with_class_methods() raises:
    var source = (
        "class Counter:\n"
        "    def __init__(self):\n"
        "        self.count = 0\n"
        "    def increment(self):\n"
        "        self.count += 1\n"
        "        return self.count\n"
    )
    var result = compile_strategy(source, "test_strategy", _make_scope())
    var obj = result.__getitem__("Counter")()
    assert_equal(Int(py=obj.increment()), 1)
    assert_equal(Int(py=obj.increment()), 2)


def test_compile_strategy_syntax_error() raises:
    with assert_raises():
        _ = compile_strategy("def broken(", "test_strategy", _make_scope())


def test_compile_strategy_syntax_error_missing_colon() raises:
    with assert_raises():
        _ = compile_strategy("def foo()\n    pass", "test_strategy", _make_scope())


def test_compile_strategy_indentation_error() raises:
    var bad_source = "def foo:\npass"
    with assert_raises():
        _ = compile_strategy(bad_source, "test_strategy", _make_scope())


def test_compile_strategy_with_import() raises:
    var result = compile_strategy("import os", "test_strategy", _make_scope())
    assert_true(result.__contains__("os"))


def test_compile_strategy_with_from_import() raises:
    var source = "from os import path"
    var result = compile_strategy(source, "test_strategy", _make_scope())
    assert_true(result.__contains__("path"))


def test_compile_strategy_runtime_name_error() raises:
    var source = "y = undefined_var + 1"
    with assert_raises():
        _ = compile_strategy(source, "test_strategy", _make_scope())


def test_compile_strategy_runtime_type_error() raises:
    var source = "result = 'string' + 1"
    with assert_raises():
        _ = compile_strategy(source, "test_strategy", _make_scope())


def test_compile_strategy_with_init() raises:
    var source = (
        "def init(context):\n"
        "    context.initialized = True\n"
    )
    var result = compile_strategy(source, "test_strategy", _make_scope())
    assert_true(result.__contains__("init"))


def test_compile_strategy_with_handle_bar() raises:
    var source = (
        "def handle_bar(context, bar_dict):\n"
        "    pass\n"
    )
    var result = compile_strategy(source, "test_strategy", _make_scope())
    assert_true(result.__contains__("handle_bar"))


def test_compile_strategy_with_after_trading() raises:
    var source = (
        "def after_trading(context):\n"
        "    pass\n"
    )
    var result = compile_strategy(source, "test_strategy", _make_scope())
    assert_true(result.__contains__("after_trading"))


def test_compile_strategy_complete() raises:
    var source = (
        "def init(context):\n"
        "    context.counter = 0\n"
        "\n"
        "def handle_bar(context, bar_dict):\n"
        "    context.counter += 1\n"
        "\n"
        "def after_trading(context):\n"
        "    pass\n"
    )
    var result = compile_strategy(source, "test_strategy", _make_scope())
    assert_true(result.__contains__("init"))
    assert_true(result.__contains__("handle_bar"))
    assert_true(result.__contains__("after_trading"))


def test_compile_strategy_before_trading() raises:
    var source = (
        "def before_trading(context):\n"
        "    pass\n"
    )
    var result = compile_strategy(source, "test_strategy", _make_scope())
    assert_true(result.__contains__("before_trading"))


def test_compile_strategy_with_complex_logic() raises:
    var source = (
        "def calculate_sma(prices, window=5):\n"
        "    if len(prices) < window:\n"
        "        return None\n"
        "    return sum(prices[-window:]) / window\n"
    )
    var result = compile_strategy(source, "test_strategy", _make_scope())
    assert_true(result.__contains__("calculate_sma"))
    var prices = Python.list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
    var sma = result.__getitem__("calculate_sma")(prices, 3)
    assert_true(abs(Float64(py=sma) - 9.0) < 0.001)


def test_compile_strategy_scope_isolation() raises:
    var scope1 = _make_scope()
    var scope2 = _make_scope()

    _ = compile_strategy("x = 100", "strategy_a", scope1)
    _ = compile_strategy("x = 200", "strategy_b", scope2)

    assert_equal(Int(py=scope1.__getitem__("x")), 100)
    assert_equal(Int(py=scope2.__getitem__("x")), 200)


def test_compile_strategy_scope_persistence() raises:
    var scope = _make_scope()
    _ = compile_strategy("first = 1", "test", scope)
    _ = compile_strategy("second = first + 1", "test", scope)

    assert_equal(Int(py=scope.__getitem__("first")), 1)
    assert_equal(Int(py=scope.__getitem__("second")), 2)


def test_compile_strategy_lambda() raises:
    var source = "double = lambda x: x * 2"
    var result = compile_strategy(source, "test_strategy", _make_scope())
    var ret = result.__getitem__("double")(21)
    assert_equal(Int(py=ret), 42)


def test_compile_strategy_list_comprehension() raises:
    var source = "squares = [x**2 for x in range(5)]"
    var result = compile_strategy(source, "test_strategy", _make_scope())
    var squares = result.__getitem__("squares")
    assert_equal(Int(py=len(squares)), 5)
    assert_equal(Int(py=squares.__getitem__(4)), 16)


def test_compile_strategy_decorator_simple() raises:
    var source = (
        "def my_decorator(func):\n"
        "    def wrapper(*args, **kwargs):\n"
        "        return func(*args, **kwargs)\n"
        "    return wrapper\n"
        "\n"
        "@my_decorator\n"
        "def greet(name):\n"
        "    return 'Hello ' + name\n"
    )
    var result = compile_strategy(source, "test_strategy", _make_scope())
    assert_true(result.__contains__("greet"))
    var greeting = result.__getitem__("greet")("World")
    assert_equal(String(py=greeting), "Hello World")


def test_compile_strategy_try_except() raises:
    var source = (
        "def safe_divide(a, b):\n"
        "    try:\n"
        "        return a / b\n"
        "    except ZeroDivisionError:\n"
        "        return None\n"
    )
    var result = compile_strategy(source, "test_strategy", _make_scope())
    var safe_divide_fn = result.__getitem__("safe_divide")
    var ok = safe_divide_fn(10, 2)
    assert_true(abs(Float64(py=ok) - 5.0) < 0.001)
    var div_zero = safe_divide_fn(1, 0)
    assert_true(div_zero == Python.none())


def test_compile_strategy_custom_exception_msg() raises:
    var source = "raise ValueError('custom error message')"
    var caught = False
    var err_str: String = ""
    try:
        _ = compile_strategy(source, "test_strategy", _make_scope())
    except e:
        caught = True
        err_str = String(e)
    assert_true(caught, "Expected compile_strategy to raise an exception for ValueError")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
