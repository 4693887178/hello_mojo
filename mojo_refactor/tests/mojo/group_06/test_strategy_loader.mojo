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


def test_file_strategy_loader() -> Bool:
    print("Test: FileStrategyLoader struct")
    var loader = create_file_strategy_loader("test_strategy.mojo")
    print("  FileStrategyLoader created: ", loader.get_file_path())
    return True


def test_file_strategy_loader_load() raises -> Bool:
    print("Test: FileStrategyLoader.load method")
    var loader = create_file_strategy_loader("test_strategy.mojo")
    var scope = Dict[String, String]()
    var result = loader.load(scope)
    print("  Loaded ", len(result), " items")
    return True


def test_source_code_strategy_loader() -> Bool:
    print("Test: SourceCodeStrategyLoader struct")
    var code = "def init(context):\n    pass\n"
    var loader = create_source_code_strategy_loader(code, "test")
    print("  SourceCodeStrategyLoader created")
    return True


def test_source_code_strategy_loader_load() raises -> Bool:
    print("Test: SourceCodeStrategyLoader.load method")
    var code = "def init(context):\n    pass\n"
    var loader = create_source_code_strategy_loader(code, "test")
    var scope = Dict[String, String]()
    var result = loader.load(scope)
    print("  Loaded ", len(result), " items")
    return True


def test_user_func_strategy_loader() -> Bool:
    print("Test: UserFuncStrategyLoader struct")
    var loader = create_user_func_strategy_loader(2)
    print("  UserFuncStrategyLoader created with ", loader.get_func_count(), " funcs")
    return True


def test_user_func_strategy_loader_load() raises -> Bool:
    print("Test: UserFuncStrategyLoader.load method")
    var loader = create_user_func_strategy_loader(2)
    var scope = Dict[String, String]()
    scope["init"] = "init_func"
    scope["handle_bar"] = "handle_bar_func"
    var result = loader.load(scope)
    print("  Loaded ", len(result), " items")
    return True


def test_function_strategy_loader() -> Bool:
    print("Test: FunctionStrategyLoader struct")
    var loader = create_function_strategy_loader()
    loader.set_init()
    loader.set_handle_bar()
    print("  FunctionStrategyLoader created with init and handle_bar")
    return True


def test_function_strategy_loader_load() raises -> Bool:
    print("Test: FunctionStrategyLoader.load method")
    var loader = create_function_strategy_loader()
    loader.set_init()
    loader.set_handle_bar()
    loader.set_before_trading()
    var scope = Dict[String, String]()
    var result = loader.load(scope)
    print("  Loaded ", len(result), " items")
    return True


def main() -> None:
    print("=== Group 06 File 10: Strategy Loader Tests ===")
    print("")
    
    var passed = 0
    var failed = 0
    
    if test_file_strategy_loader():
        passed += 1
    else:
        failed += 1
    
    try:
        if test_file_strategy_loader_load():
            passed += 1
        else:
            failed += 1
    except:
        print("  test_file_strategy_loader_load raised exception")
        failed += 1
    
    if test_source_code_strategy_loader():
        passed += 1
    else:
        failed += 1
    
    try:
        if test_source_code_strategy_loader_load():
            passed += 1
        else:
            failed += 1
    except:
        print("  test_source_code_strategy_loader_load raised exception")
        failed += 1
    
    if test_user_func_strategy_loader():
        passed += 1
    else:
        failed += 1
    
    try:
        if test_user_func_strategy_loader_load():
            passed += 1
        else:
            failed += 1
    except:
        print("  test_user_func_strategy_loader_load raised exception")
        failed += 1
    
    if test_function_strategy_loader():
        passed += 1
    else:
        failed += 1
    
    try:
        if test_function_strategy_loader_load():
            passed += 1
        else:
            failed += 1
    except:
        print("  test_function_strategy_loader_load raised exception")
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
