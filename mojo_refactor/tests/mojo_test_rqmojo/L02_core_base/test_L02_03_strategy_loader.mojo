# test_L02_03_strategy_loader.mojo
# Module: rqmojo.core.strategy_loader
# Python: rqalpha.core.strategy_loader
# Level: L02 - Core Base
# Dependencies: strategy, strategy_context

from rqmojo.core.strategy_loader import (
    FileStrategyLoader, SourceCodeStrategyLoader, 
    UserFuncStrategyLoader, FunctionStrategyLoader,
    create_file_strategy_loader, create_source_code_strategy_loader,
    create_user_func_strategy_loader, create_function_strategy_loader
)
from collections import Dict


fn dict_contains(d: Dict[String, String], key: String) -> Bool:
    return d.get(key, "") != ""


@fieldwise_init
struct TestRunner:
    var test_count: Int
    var pass_count: Int
    
    fn check(mut self, condition: Bool, test_name: String):
        self.test_count += 1
        if condition:
            self.pass_count += 1
            print("PASS: " + test_name)
        else:
            print("FAIL: " + test_name)

    fn test_file_strategy_loader_init(mut self):
        var loader = FileStrategyLoader("test_strategy.py", False)
        self.check(loader.strategy_file_path == "test_strategy.py", "FileStrategyLoader init file path")
        self.check(loader.loaded == False, "FileStrategyLoader init loaded False")

    fn test_file_strategy_loader_str(mut self):
        var loader = FileStrategyLoader("strategy.py", False)
        var str_repr = loader.__str__()
        self.check(str_repr.find("FileStrategyLoader") >= 0, "FileStrategyLoader __str__ contains class name")

    fn test_file_strategy_loader_load(mut self) raises:
        var loader = FileStrategyLoader("test.py", False)
        var scope = Dict[String, String]()
        var result = loader.load(scope)
        self.check(dict_contains(result, "strategy_file"), "FileStrategyLoader load returns strategy_file")
        self.check(loader.is_loaded(), "FileStrategyLoader is_loaded True after load")

    fn test_file_strategy_loader_get_file_path(mut self):
        var loader = FileStrategyLoader("/path/to/strategy.py", False)
        self.check(loader.get_file_path() == "/path/to/strategy.py", "FileStrategyLoader get_file_path")

    fn test_source_code_strategy_loader_init(mut self):
        var code = "def init(context):\n    pass\n"
        var loader = SourceCodeStrategyLoader(code, "strategy", False)
        self.check(loader.source_code == code, "SourceCodeStrategyLoader init source_code")
        self.check(loader.code_name == "strategy", "SourceCodeStrategyLoader init code_name")

    fn test_source_code_strategy_loader_str(mut self):
        var loader = SourceCodeStrategyLoader("code", "test", False)
        var str_repr = loader.__str__()
        self.check(str_repr.find("SourceCodeStrategyLoader") >= 0, "SourceCodeStrategyLoader __str__ contains class name")

    fn test_source_code_strategy_loader_load(mut self) raises:
        var loader = SourceCodeStrategyLoader("def init(): pass", "test", False)
        var scope = Dict[String, String]()
        var result = loader.load(scope)
        self.check(dict_contains(result, "source_code"), "SourceCodeStrategyLoader load returns source_code")
        self.check(loader.is_loaded(), "SourceCodeStrategyLoader is_loaded True after load")

    fn test_source_code_strategy_loader_get_source_code(mut self):
        var code = "def handle_bar(): pass"
        var loader = SourceCodeStrategyLoader(code, "test", False)
        self.check(loader.get_source_code() == code, "SourceCodeStrategyLoader get_source_code")

    fn test_user_func_strategy_loader_init(mut self):
        var loader = UserFuncStrategyLoader(1, False)
        self.check(loader.func_count == 1, "UserFuncStrategyLoader init with 1 func")

    fn test_user_func_strategy_loader_empty_init(mut self):
        var loader = UserFuncStrategyLoader(0, False)
        self.check(loader.func_count == 0, "UserFuncStrategyLoader empty init")

    fn test_user_func_strategy_loader_str(mut self):
        var loader = UserFuncStrategyLoader(0, False)
        var str_repr = loader.__str__()
        self.check(str_repr.find("UserFuncStrategyLoader") >= 0, "UserFuncStrategyLoader __str__ contains class name")

    fn test_user_func_strategy_loader_load(mut self) raises:
        var loader = UserFuncStrategyLoader(1, False)
        var scope = Dict[String, String]()
        var result = loader.load(scope)
        self.check(loader.is_loaded(), "UserFuncStrategyLoader is_loaded True after load")

    fn test_user_func_strategy_loader_add_func(mut self):
        var loader = UserFuncStrategyLoader(0, False)
        loader.add_func()
        self.check(loader.func_count == 1, "UserFuncStrategyLoader add_func increases count")

    fn test_user_func_strategy_loader_get_func_count(mut self):
        var loader = UserFuncStrategyLoader(3, False)
        self.check(loader.get_func_count() == 3, "UserFuncStrategyLoader get_func_count returns 3")

    fn test_function_strategy_loader_init(mut self):
        var loader = create_function_strategy_loader()
        self.check(loader.loaded == False, "FunctionStrategyLoader init loaded False")

    fn test_function_strategy_loader_str(mut self):
        var loader = create_function_strategy_loader()
        var str_repr = loader.__str__()
        self.check(str_repr.find("FunctionStrategyLoader") >= 0, "FunctionStrategyLoader __str__ contains class name")

    fn test_function_strategy_loader_set_init(mut self):
        var loader = create_function_strategy_loader()
        loader.set_init()
        self.check(loader.has_init, "FunctionStrategyLoader set_init")

    fn test_function_strategy_loader_set_handle_bar(mut self):
        var loader = create_function_strategy_loader()
        loader.set_handle_bar()
        self.check(loader.has_handle_bar, "FunctionStrategyLoader set_handle_bar")

    fn test_function_strategy_loader_set_handle_tick(mut self):
        var loader = create_function_strategy_loader()
        loader.set_handle_tick()
        self.check(loader.has_handle_tick, "FunctionStrategyLoader set_handle_tick")

    fn test_function_strategy_loader_set_before_trading(mut self):
        var loader = create_function_strategy_loader()
        loader.set_before_trading()
        self.check(loader.has_before_trading, "FunctionStrategyLoader set_before_trading")

    fn test_function_strategy_loader_set_after_trading(mut self):
        var loader = create_function_strategy_loader()
        loader.set_after_trading()
        self.check(loader.has_after_trading, "FunctionStrategyLoader set_after_trading")

    fn test_function_strategy_loader_load(mut self) raises:
        var loader = create_function_strategy_loader()
        loader.set_init()
        loader.set_handle_bar()
        var scope = Dict[String, String]()
        var result = loader.load(scope)
        self.check(dict_contains(result, "init"), "FunctionStrategyLoader load returns init")
        self.check(dict_contains(result, "handle_bar"), "FunctionStrategyLoader load returns handle_bar")
        self.check(loader.is_loaded(), "FunctionStrategyLoader is_loaded True after load")

    fn test_create_file_strategy_loader_fn(mut self):
        var loader = create_file_strategy_loader("test.py")
        self.check(loader.strategy_file_path == "test.py", "create_file_strategy_loader creates correct loader")

    fn test_create_source_code_strategy_loader_fn(mut self):
        var loader = create_source_code_strategy_loader("code", "test")
        self.check(loader.source_code == "code", "create_source_code_strategy_loader creates correct loader")

    fn test_create_user_func_strategy_loader_fn(mut self):
        var loader = create_user_func_strategy_loader()
        self.check(loader.func_count == 0, "create_user_func_strategy_loader creates empty loader")

    fn test_create_function_strategy_loader_fn(mut self):
        var loader = create_function_strategy_loader()
        self.check(loader.loaded == False, "create_function_strategy_loader creates unloaded loader")

    fn run_all(mut self) raises:
        print("=" * 60)
        print("L02_03_strategy_loader Module Tests")
        print("=" * 60)
        
        self.test_file_strategy_loader_init()
        self.test_file_strategy_loader_str()
        self.test_file_strategy_loader_load()
        self.test_file_strategy_loader_get_file_path()
        self.test_source_code_strategy_loader_init()
        self.test_source_code_strategy_loader_str()
        self.test_source_code_strategy_loader_load()
        self.test_source_code_strategy_loader_get_source_code()
        self.test_user_func_strategy_loader_init()
        self.test_user_func_strategy_loader_empty_init()
        self.test_user_func_strategy_loader_str()
        self.test_user_func_strategy_loader_load()
        self.test_user_func_strategy_loader_add_func()
        self.test_user_func_strategy_loader_get_func_count()
        self.test_function_strategy_loader_init()
        self.test_function_strategy_loader_str()
        self.test_function_strategy_loader_set_init()
        self.test_function_strategy_loader_set_handle_bar()
        self.test_function_strategy_loader_set_handle_tick()
        self.test_function_strategy_loader_set_before_trading()
        self.test_function_strategy_loader_set_after_trading()
        self.test_function_strategy_loader_load()
        self.test_create_file_strategy_loader_fn()
        self.test_create_source_code_strategy_loader_fn()
        self.test_create_user_func_strategy_loader_fn()
        self.test_create_function_strategy_loader_fn()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main() raises:
    var runner = TestRunner(0, 0)
    runner.run_all()
