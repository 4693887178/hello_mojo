"""
RQAlpha Mojo - Strategy Loader Helper
Ported from rqalpha/utils/strategy_loader_help.py
Uses Python interop for strategy compilation
"""

from python import Python, PythonObject
from collections import Dict


fn py_bool_to_bool(obj: PythonObject) raises -> Bool:
    var _ = Python()
    var s = Python().import_module("builtins").str(obj)
    return String(s) == "True"


fn compile_strategy(source_code: String, strategy: String, scope: PythonObject) raises -> PythonObject:
    var _ = Python()
    var builtins = Python().import_module("builtins")
    var six = Python().import_module("six")
    
    var code = builtins.compile(source_code, strategy, "exec")
    six.exec_(code, scope)
    return scope


fn compile_strategy_safe(source_code: String, strategy: String, scope: PythonObject) raises -> PythonObject:
    var _ = Python()
    var builtins = Python().import_module("builtins")
    var traceback = Python().import_module("traceback")
    var six = Python().import_module("six")
    
    var exception_module = Python().import_module("rqalpha.utils.exception")
    var patch_user_exc = exception_module.patch_user_exc
    var CustomError = exception_module.CustomError
    var CustomException = exception_module.CustomException
    
    var compile_and_exec = Python().evaluate('''
def _compile_and_exec(source_code, strategy, scope, builtins, six):
    try:
        code = builtins.compile(source_code, strategy, 'exec')
        six.exec_(code, scope)
        return scope, None
    except Exception as e:
        import sys
        exc_type, exc_val, exc_tb = sys.exc_info()
        return None, (exc_type, exc_val, exc_tb)
_compile_and_exec
''')
    
    var result = compile_and_exec(source_code, strategy, scope, builtins, six)
    var scope_result = result.__getitem__(0)
    var exc_tuple = result.__getitem__(1)
    var py_none = Python().evaluate("None")
    
    if exc_tuple != py_none:
        var exc_type = exc_tuple.__getitem__(0)
        var exc_val = exc_tuple.__getitem__(1)
        var exc_tb = exc_tuple.__getitem__(2)
        
        exc_val = patch_user_exc(exc_val, force=True)
        
        var msg = String(builtins.str(exc_val))
        
        var error = CustomError()
        error.set_msg(msg)
        error.set_exc(exc_type, exc_val, exc_tb)
        
        var extract_tb = traceback.extract_tb(exc_tb)
        var stackinfos = builtins.list(extract_tb)
        
        var is_syntax_error = Python().evaluate("lambda t: issubclass(t, (SyntaxError, IndentationError))")
        if py_bool_to_bool(is_syntax_error(exc_type)):
            var filename = exc_val.filename
            var lineno = exc_val.lineno
            var text = exc_val.text
            error.add_stack_info(filename, lineno, "", text)
        else:
            var last_item = py_none
            for item in stackinfos:
                var filename = item.__getitem__(0)
                if builtins.str(filename) == builtins.str(strategy):
                    error.add_stack_info(item.__getitem__(0), item.__getitem__(1), item.__getitem__(2), item.__getitem__(3))
                last_item = item
            if error.stacks_length == 0:
                if last_item != py_none:
                    error.add_stack_info(last_item.__getitem__(0), last_item.__getitem__(1), last_item.__getitem__(2), last_item.__getitem__(3))
        
        raise CustomException(error)
    
    return scope_result


fn load_strategy_from_file(file_path: String) raises -> PythonObject:
    var _ = Python()
    var builtins = Python().import_module("builtins")
    
    var scope = Python().dict()
    scope["__builtins__"] = builtins
    
    var source_code = builtins.open(file_path).read()
    return compile_strategy(String(source_code), file_path, scope)


fn load_strategy_from_code(code: String, strategy_name: String) raises -> PythonObject:
    var _ = Python()
    var builtins = Python().import_module("builtins")
    
    var scope = Python().dict()
    scope["__builtins__"] = builtins
    
    return compile_strategy(code, strategy_name, scope)


fn validate_strategy_functions(scope: PythonObject) raises -> Bool:
    var has_init = scope.__contains__("init")
    var has_handle_bar = scope.__contains__("handle_bar")
    var has_handle_tick = scope.__contains__("handle_tick")
    
    return py_bool_to_bool(has_init) or py_bool_to_bool(has_handle_bar) or py_bool_to_bool(has_handle_tick)


fn extract_strategy_functions(scope: PythonObject) raises -> PythonObject:
    var _ = Python()
    var result = Python().dict()
    
    var func_names = ["init", "handle_bar", "handle_tick", "before_trading", "after_trading"]
    
    for name in func_names:
        var key = String(name)
        if scope.__contains__(key):
            result[key] = scope[key]
    
    return result
