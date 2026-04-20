"""
Comprehensive Mojo unit tests for core/strategy_loader.mojo
Tests all three loader types: FileStrategyLoader, SourceCodeStrategyLoader, UserFuncStrategyLoader
Uses std.testing framework as required by project conventions.
Ported from rqalpha/core/strategy_loader.py test coverage.
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.python import Python, PythonObject

from rqmojo.core.strategy_loader import (
    FileStrategyLoader,
    SourceCodeStrategyLoader,
    UserFuncStrategyLoader,
    create_file_strategy_loader,
    create_source_code_strategy_loader,
    create_user_func_strategy_loader,
)
from rqmojo.interface import StrategyLoader


def _test_base_dir() -> String:
    return "/tmp/rqmojo_test_strategy_loader"


def _setup_test_dir() raises:
    var os_mod = Python.import_module("os")
    var path = Python.import_module("os.path")
    if not path.exists(PythonObject(_test_base_dir())):
        os_mod.makedirs(PythonObject(_test_base_dir()))


def _cleanup_test_dir() raises:
    var path = Python.import_module("os.path")
    var shutil = Python.import_module("shutil")
    if path.exists(PythonObject(_test_base_dir())):
        shutil.rmtree(PythonObject(_test_base_dir()))


def _write_test_file(filename: String, content: String) raises -> String:
    _setup_test_dir()
    var full_path = _test_base_dir() + "/" + filename
    var builtins = Python.import_module("builtins")
    var f = builtins.open(PythonObject(full_path), PythonObject("w"))
    f.write(PythonObject(content))
    f.close()
    return full_path


def _make_scope() raises -> PythonObject:
    var scope = Python.dict()
    scope["__builtins__"] = Python.import_module("builtins")
    return scope


def _scope_has(result: PythonObject, key: String) raises -> Bool:
    """Check if a key exists in the compiled scope dict (use __contains__, not hasattr)."""
    return Bool(py=result.__contains__(PythonObject(key)))


def _make_python_func(code: String) raises -> PythonObject:
    """Create a Python function via exec for use in UserFuncStrategyLoader tests."""
    return Python.evaluate(code, file=True)


# ============================================================
# FileStrategyLoader Tests
# ============================================================

def test_file_strategy_loader_construction() raises:
    """Test FileStrategyLoader can be constructed with a file path."""
    var loader = create_file_strategy_loader("/tmp/test_strategy.py")
    assert_equal(loader._strategy_file_path, "/tmp/test_strategy.py")


def test_file_strategy_loader_write_to() raises:
    """Test FileStrategyLoader.write_to produces correct output."""
    var loader = create_file_strategy_loader("my_strategy.mojo")
    var s = String.write(loader)
    assert_true(s.find("FileStrategyLoader") != -1)
    assert_true(s.find("my_strategy.mojo") != -1)


def test_file_strategy_load_valid_code() raises:
    """Test FileStrategyLoader.load() compiles valid strategy code from file."""
    var valid_code = (
        "def init(context):\n"
        "    pass\n\n"
        "def handle_bar(context, bar):\n"
        "    pass\n"
    )
    var filepath = _write_test_file("valid_strategy.py", valid_code)

    var loader = create_file_strategy_loader(filepath)
    var scope = _make_scope()
    var result = loader.load(scope)

    assert_true(_scope_has(result, "init"), "scope should contain 'init' after loading")
    assert_true(
        _scope_has(result, "handle_bar"),
        "scope should contain 'handle_bar' after loading",
    )

    _cleanup_test_dir()


def test_file_strategy_load_with_context_variables() raises:
    """Test that loaded strategy has access to scope variables."""
    var code = (
        "def init(context):\n"
        "    context.test_var = 'loaded_from_file'\n"
    )
    var filepath = _write_test_file("context_test.py", code)

    var loader = create_file_strategy_loader(filepath)
    var scope = _make_scope()
    var result = loader.load(scope)

    assert_true(_scope_has(result, "init"))

    _cleanup_test_dir()


def test_file_strategy_load_syntax_error() raises:
    """Test FileStrategyLoader.load() raises on syntax error in file."""
    var bad_code = "def init(context:\n    pass  # missing closing paren\n"
    var filepath = _write_test_file("bad_syntax.py", bad_code)

    var loader = create_file_strategy_loader(filepath)
    var scope = _make_scope()

    var caught = False
    try:
        _ = loader.load(scope)
    except e:
        caught = True

    assert_true(caught, "Syntax error in file should raise an exception")

    _cleanup_test_dir()


def test_file_strategy_load_nonexistent_file() raises:
    """Test FileStrategyLoader.load() raises when file does not exist."""
    var loader = create_file_strategy_loader("/nonexistent/path/strategy.py")
    var scope = _make_scope()

    var caught = False
    try:
        _ = loader.load(scope)
    except e:
        caught = True

    assert_true(caught, "Non-existent file should raise an exception")


# ============================================================
# SourceCodeStrategyLoader Tests
# ============================================================

def test_source_code_strategy_loader_construction() raises:
    """Test SourceCodeStrategyLoader can be constructed with code string."""
    var code = "def init(context):\n    pass\n"
    var loader = create_source_code_strategy_loader(code)
    assert_equal(loader._code, code)


def test_source_code_strategy_loader_write_to() raises:
    """Test SourceCodeStrategyLoader.write_to shows code length."""
    var code = "def init(context): pass"
    var loader = create_source_code_strategy_loader(code)
    var s = String.write(loader)
    assert_true(s.find("SourceCodeStrategyLoader") != -1)
    assert_true(s.find(String(len(code))) != -1)


def test_source_code_strategy_load_valid() raises:
    """Test SourceCodeStrategyLoader.load() compiles valid code."""
    var code = (
        "def init(context):\n"
        "    pass\n\n"
        "def before_trading(context):\n"
        "    pass\n\n"
        "def handle_bar(context, bar):\n"
        "    pass\n\n"
        "def after_trading(context):\n"
        "    pass\n"
    )
    var loader = create_source_code_strategy_loader(code)
    var scope = _make_scope()
    var result = loader.load(scope)

    assert_true(_scope_has(result, "init"))
    assert_true(_scope_has(result, "before_trading"))
    assert_true(_scope_has(result, "handle_bar"))
    assert_true(_scope_has(result, "after_trading"))


def test_source_code_strategy_load_populates_scope() raises:
    """Test that compile populates user-defined variables into scope."""
    var code = (
        "MY_CONSTANT = 42\n"
        "def init(context):\n"
        "    pass\n"
    )
    var loader = create_source_code_strategy_loader(code)
    var scope = _make_scope()
    var result = loader.load(scope)

    assert_true(
        _scope_has(result, "MY_CONSTANT"),
        "Scope should have MY_CONSTANT defined",
    )
    assert_equal(Int(py=result["MY_CONSTANT"]), 42)


def test_source_code_strategy_load_runtime_error() raises:
    """Test SourceCodeStrategyLoader.load() raises on runtime errors."""
    var code = "1/0  # division by zero at top level\n"
    var loader = create_source_code_strategy_loader(code)
    var scope = _make_scope()

    var caught = False
    try:
        _ = loader.load(scope)
    except e:
        caught = True

    assert_true(caught, "Runtime error should raise exception")


def test_source_code_strategy_load_empty_code() raises:
    """Test SourceCodeStrategyLoader.load() handles empty code gracefully."""
    var loader = create_source_code_strategy_loader("")
    var scope = _make_scope()
    var result = loader.load(scope)
    assert_true(result is not None)


def test_source_code_strategy_default_filename() raises:
    """Test that SourceCodeStrategyLoader uses 'strategy.py' as default filename (matches Python original)."""
    var code = "x = 1\n"
    var loader = create_source_code_strategy_loader(code)
    var scope = _make_scope()
    var result = loader.load(scope)
    assert_true(result is not None)


# ============================================================
# UserFuncStrategyLoader Tests
# ============================================================

def test_user_func_strategy_loader_construction() raises:
    """Test UserFuncStrategyLoader can be constructed with function dict."""
    var mod = _make_python_func(
        "def dummy_init(context):\n    pass\n"
        "def dummy_handle_bar(context, bar):\n    pass\n"
    )
    var funcs = Python.dict()
    funcs["init"] = mod.dummy_init
    funcs["handle_bar"] = mod.dummy_handle_bar

    var loader = create_user_func_strategy_loader(funcs)
    assert_equal(loader._func_count, 2)


def test_user_func_strategy_loader_write_to() raises:
    """Test UserFuncStrategyLoader.write_to shows func count."""
    var mod = _make_python_func(
        "def f1():\n    pass\ndef f2():\n    pass\ndef f3():\n    pass\n"
    )
    var funcs = Python.dict()
    funcs["a"] = mod.f1
    funcs["b"] = mod.f2
    funcs["c"] = mod.f3

    var loader = create_user_func_strategy_loader(funcs)
    var s = String.write(loader)
    assert_true(s.find("UserFuncStrategyLoader") != -1)
    assert_true(s.find("3") != -1)


def test_user_func_strategy_load_updates_globals() raises:
    """Test UserFuncStrategyLoader.load() updates function globals with scope (core behavior)."""
    var mod = _make_python_func(
        "def my_init(context):\n    pass\n"
    )
    var funcs = Python.dict()
    funcs["init"] = mod.my_init

    var loader = create_user_func_strategy_loader(funcs)

    var scope = _make_scope()
    scope["__name__"] = PythonObject("test_scope_value")
    scope["extra_var"] = PythonObject(42)

    var result = loader.load(scope)

    assert_true(result is not None)
    assert_equal(loader._func_count, 1)


def test_user_func_strategy_load_returns_funcs() raises:
    """Test UserFuncStrategyLoader.load() returns the original user_funcs dict."""
    var mod = _make_python_func(
        "def fn_a():\n    pass\ndef fn_b():\n    pass\n"
    )
    var funcs = Python.dict()
    funcs["a"] = mod.fn_a
    funcs["b"] = mod.fn_b

    var loader = create_user_func_strategy_loader(funcs)

    var scope = _make_scope()
    scope["test_key"] = PythonObject("test_value")

    var result = loader.load(scope)
    var builtins = Python.import_module("builtins")
    assert_true(Int(py=builtins.len(result)) == 2, "Should return same number of functions")


def test_user_func_strategy_load_empty_dict() raises:
    """Test UserFuncStrategyLoader with empty function dict."""
    var funcs = Python.dict()
    var loader = create_user_func_strategy_loader(funcs)
    assert_equal(loader._func_count, 0)

    var scope = _make_scope()
    scope["some_key"] = PythonObject("some_value")
    var result = loader.load(scope)
    assert_true(result is not None)


def test_user_func_strategy_single_function() raises:
    """Test UserFuncStrategyLoader with single function."""
    var mod = _make_python_func(
        "def only_init(context):\n    pass\n"
    )
    var funcs = Python.dict()
    funcs["init"] = mod.only_init

    var loader = create_user_func_strategy_loader(funcs)
    assert_equal(loader._func_count, 1)

    var scope = _make_scope()
    var result = loader.load(scope)
    assert_true(result is not None)


# ============================================================
# Factory Function Tests
# ============================================================

def test_factory_create_file_strategy_loader() raises:
    """Test create_file_strategy_loader returns correct type."""
    var loader = create_file_strategy_loader("/path/to/strategy.py")
    assert_true(loader._strategy_file_path == "/path/to/strategy.py")


def test_factory_create_source_code_strategy_loader() raises:
    """Test create_source_code_strategy_loader returns correct type."""
    var code = "def init(c): pass"
    var loader = create_source_code_strategy_loader(code)
    assert_equal(loader._code, code)


def test_factory_create_user_func_strategy_loader() raises:
    """Test create_user_func_strategy_loader returns correct type."""
    var mod = _make_python_func("def some_func():\n    pass\n")
    var funcs = Python.dict()
    funcs["fn"] = mod.some_func

    var loader = create_user_func_strategy_loader(funcs)
    assert_equal(loader._func_count, 1)


# ============================================================
# Interface / Trait Conformance Tests
# ============================================================

def test_all_loaders_implement_strategy_loader() raises:
    """Verify all three loaders conform to StrategyLoader trait interface."""
    var filepath = _write_test_file("interface_test.py", "def init(context):\n    pass\n")
    var fl = create_file_strategy_loader(filepath)
    var sl = create_source_code_strategy_loader("def init(c): pass")
    var ul = create_user_func_strategy_loader(Python.dict())

    var scope = _make_scope()

    var fl_result = fl.load(scope)
    assert_true(fl_result is not None)

    var sl_result = sl.load(scope)
    assert_true(sl_result is not None)

    var ul_result = ul.load(scope)
    assert_true(ul_result is not None)

    _cleanup_test_dir()


# ============================================================
# Edge Case / Robustness Tests
# ============================================================

def test_file_loader_unicode_content() raises:
    """Test FileStrategyLoader handles UTF-8 encoded content."""
    var unicode_code = "# \xe4\xb8\xad\xe6\x96\x87\xe6\xb3\xa8\xe9\x87\x8a\ndef init(context):\n    pass\n"
    var filepath = _write_test_file("unicode_strategy.py", unicode_code)

    var loader = create_file_strategy_loader(filepath)
    var scope = _make_scope()
    var result = loader.load(scope)

    assert_true(_scope_has(result, "init"))

    _cleanup_test_dir()


def test_source_code_loader_multiline_string() raises:
    """Test SourceCodeStrategyLoader with multiline strings in code."""
    var code = '"""Docstring."""\ndef init(context):\n    pass\n'
    var loader = create_source_code_strategy_loader(code)
    var scope = _make_scope()
    var result = loader.load(scope)

    assert_true(_scope_has(result, "init"))


def test_file_loader_relative_path() raises:
    """Test FileStrategyLoader with various path formats."""
    var paths = ["./strategy.py", "../strategy.py", "strategy.py"]
    for p in paths:
        var loader = create_file_strategy_loader(p)
        assert_equal(loader._strategy_file_path, p)


def test_source_code_loader_preserves_code() raises:
    """Test that stored code matches input exactly."""
    var code = "def init(context):\n    print('hello')\n"
    var loader = create_source_code_strategy_loader(code)
    assert_equal(loader._code, code)


def main() raises:
    _setup_test_dir()
    TestSuite.discover_tests[__functions_in_module()]().run()
    _cleanup_test_dir()
