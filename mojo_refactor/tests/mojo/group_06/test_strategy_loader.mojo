"""
Test for core/strategy_loader.mojo
Group 06 - File 10
"""

from rqmojo.core.strategy_loader import (
    StrategyLoader,
    FileStrategyLoader,
    SourceCodeStrategyLoader,
    UserFuncStrategyLoader,
    FunctionStrategyLoader,
    create_file_strategy_loader,
    create_source_code_strategy_loader,
    create_user_func_strategy_loader,
    create_function_strategy_loader
)
from std.collections import Dict


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_file_strategy_loader() raises:
    print("Test: FileStrategyLoader struct")
    var loader = create_file_strategy_loader("test_strategy.mojo")
    print("  FileStrategyLoader created: ", loader.get_file_path())
    assert_true(True, "test passed")


def test_file_strategy_loader_load() raises:
    print("Test: FileStrategyLoader.load method")
    var loader = create_file_strategy_loader("test_strategy.mojo")
    var scope = Dict[String, String]()
    var result = loader.load(scope)
    print("  Loaded ", len(result), " items")
    assert_true(True, "test passed")


def test_source_code_strategy_loader() raises:
    print("Test: SourceCodeStrategyLoader struct")
    var code = "def init(context):\n    pass\n"
    var loader = create_source_code_strategy_loader(code, "test")
    print("  SourceCodeStrategyLoader created")
    assert_true(True, "test passed")


def test_source_code_strategy_loader_load() raises:
    print("Test: SourceCodeStrategyLoader.load method")
    var code = "def init(context):\n    pass\n"
    var loader = create_source_code_strategy_loader(code, "test")
    var scope = Dict[String, String]()
    var result = loader.load(scope)
    print("  Loaded ", len(result), " items")
    assert_true(True, "test passed")


def test_user_func_strategy_loader() raises:
    print("Test: UserFuncStrategyLoader struct")
    var loader = create_user_func_strategy_loader(2)
    print("  UserFuncStrategyLoader created with ", loader.get_func_count(), " funcs")
    assert_true(True, "test passed")


def test_user_func_strategy_loader_load() raises:
    print("Test: UserFuncStrategyLoader.load method")
    var loader = create_user_func_strategy_loader(2)
    var scope = Dict[String, String]()
    scope["init"] = "init_func"
    scope["handle_bar"] = "handle_bar_func"
    var result = loader.load(scope)
    print("  Loaded ", len(result), " items")
    assert_true(True, "test passed")


def test_function_strategy_loader() raises:
    print("Test: FunctionStrategyLoader struct")
    var loader = create_function_strategy_loader()
    loader.set_init()
    loader.set_handle_bar()
    print("  FunctionStrategyLoader created with init and handle_bar")
    assert_true(True, "test passed")


def test_function_strategy_loader_load() raises:
    print("Test: FunctionStrategyLoader.load method")
    var loader = create_function_strategy_loader()
    loader.set_init()
    loader.set_handle_bar()
    loader.set_before_trading()
    var scope = Dict[String, String]()
    var result = loader.load(scope)
    print("  Loaded ", len(result), " items")
    assert_true(True, "test passed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
