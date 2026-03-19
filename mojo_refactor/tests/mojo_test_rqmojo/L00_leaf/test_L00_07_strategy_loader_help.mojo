# test_L00_07_strategy_loader_help.mojo
# Module: rqmojo.utils.strategy_loader_help
# Python: rqalpha.utils.strategy_loader_help
# Level: L00 - Leaf module
# Dependencies: Python, six, rqalpha.utils.exception

from python import Python, PythonObject
from rqmojo.utils.strategy_loader_help import (
    compile_strategy,
    load_strategy_from_code,
    validate_strategy_functions,
    extract_strategy_functions
)


fn py_bool_to_bool(obj: PythonObject) raises -> Bool:
    var _ = Python()
    var s = Python().import_module("builtins").str(obj)
    return String(s) == "True"


fn py_len(obj: PythonObject) raises -> Int:
    var _ = Python()
    var builtins = Python().import_module("builtins")
    var l = builtins.len(obj)
    var s = builtins.str(l)
    return Int(String(s))


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

    fn test_compile_strategy_simple(mut self) raises:
        var _ = Python()
        var builtins = Python().import_module("builtins")
        
        var scope = Python().dict()
        scope["__builtins__"] = builtins
        
        var code = "x = 1\ny = 2"
        var result = compile_strategy(code, "test.py", scope)
        
        var has_x = result.__contains__("x")
        var has_y = result.__contains__("y")
        self.check(py_bool_to_bool(has_x) and py_bool_to_bool(has_y), "compile_strategy simple code")

    fn test_compile_strategy_with_functions(mut self) raises:
        var _ = Python()
        var builtins = Python().import_module("builtins")
        
        var scope = Python().dict()
        scope["__builtins__"] = builtins
        
        var code = '''
def init(context):
    pass

def handle_bar(context, bar_dict):
    pass
'''
        var result = compile_strategy(code, "strategy.py", scope)
        var is_valid = validate_strategy_functions(result)
        self.check(is_valid, "compile_strategy with strategy functions")

    fn test_validate_strategy_functions_init(mut self) raises:
        var _ = Python()
        var builtins = Python().import_module("builtins")
        
        var scope = Python().dict()
        scope["__builtins__"] = builtins
        
        var code = "def init(context):\n    pass"
        var result = compile_strategy(code, "test.py", scope)
        var is_valid = validate_strategy_functions(result)
        self.check(is_valid, "validate_strategy_functions with init")

    fn test_validate_strategy_functions_handle_bar(mut self) raises:
        var _ = Python()
        var builtins = Python().import_module("builtins")
        
        var scope = Python().dict()
        scope["__builtins__"] = builtins
        
        var code = "def handle_bar(context, bar_dict):\n    pass"
        var result = compile_strategy(code, "test.py", scope)
        var is_valid = validate_strategy_functions(result)
        self.check(is_valid, "validate_strategy_functions with handle_bar")

    fn test_validate_strategy_functions_handle_tick(mut self) raises:
        var _ = Python()
        var builtins = Python().import_module("builtins")
        
        var scope = Python().dict()
        scope["__builtins__"] = builtins
        
        var code = "def handle_tick(context, tick):\n    pass"
        var result = compile_strategy(code, "test.py", scope)
        var is_valid = validate_strategy_functions(result)
        self.check(is_valid, "validate_strategy_functions with handle_tick")

    fn test_validate_strategy_functions_invalid(mut self) raises:
        var _ = Python()
        var builtins = Python().import_module("builtins")
        
        var scope = Python().dict()
        scope["__builtins__"] = builtins
        
        var code = "def other_function():\n    pass"
        var result = compile_strategy(code, "test.py", scope)
        var is_valid = validate_strategy_functions(result)
        self.check(not is_valid, "validate_strategy_functions invalid strategy")

    fn test_extract_strategy_functions(mut self) raises:
        var _ = Python()
        var builtins = Python().import_module("builtins")
        
        var scope = Python().dict()
        scope["__builtins__"] = builtins
        
        var code = '''
def init(context):
    pass

def handle_bar(context, bar_dict):
    pass

def before_trading(context):
    pass

def other_function():
    pass
'''
        var result = compile_strategy(code, "test.py", scope)
        var functions = extract_strategy_functions(result)
        var func_count = py_len(functions)
        self.check(func_count == 3, "extract_strategy_functions extracts correct count")

    fn test_load_strategy_from_code(mut self) raises:
        var code = '''
def init(context):
    context.a = 1

def handle_bar(context, bar_dict):
    pass
'''
        var result = load_strategy_from_code(code, "test_strategy.py")
        var is_valid = validate_strategy_functions(result)
        self.check(is_valid, "load_strategy_from_code")

    fn run_all(mut self) raises:
        print("=" * 60)
        print("L00_07_strategy_loader_help Module Tests")
        print("=" * 60)
        
        self.test_compile_strategy_simple()
        self.test_compile_strategy_with_functions()
        self.test_validate_strategy_functions_init()
        self.test_validate_strategy_functions_handle_bar()
        self.test_validate_strategy_functions_handle_tick()
        self.test_validate_strategy_functions_invalid()
        self.test_extract_strategy_functions()
        self.test_load_strategy_from_code()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main() raises:
    var runner = TestRunner(0, 0)
    runner.run_all()
