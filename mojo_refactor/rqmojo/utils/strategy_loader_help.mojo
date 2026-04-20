"""
RQAlpha Mojo - Strategy Loader Helper
Ported from rqalpha/utils/strategy_loader_help.py

Behavioral equivalence with Python original:
  1. compile() + exec() source_code in scope
  2. On exception: patch exc_val as user exc, extract msg, build CustomError
  3. SyntaxError/IndentationError: single stack frame from exc_val attrs
  4. Other errors: filter stack frames by strategy filename, fallback to last frame
"""

from std.python import Python, PythonObject

from rqmojo.utils.exception import CustomError, CustomException


def _py_bool(obj: PythonObject) raises -> Bool:
    var check = Python.evaluate("lambda o: True if o else False")
    var result = check(obj)
    if result == PythonObject(True):
        return True
    return False


def _py_eq(a: PythonObject, b: PythonObject) raises -> Bool:
    var check = Python.evaluate("lambda x, y: x == y")
    var result = check(a, b)
    return _py_bool(result)


def _py_ne(a: PythonObject, b: PythonObject) raises -> Bool:
    var check = Python.evaluate("lambda x, y: x != y")
    var result = check(a, b)
    return _py_bool(result)


def compile_strategy(source_code: String, strategy: String, scope: PythonObject) raises -> PythonObject:
    var builtins = Python.import_module("builtins")

    try:
        var code = builtins.compile(source_code, strategy, "exec")
        builtins.exec(code, scope)
        return scope
    except:
        var sys = Python.import_module("sys")
        var traceback_mod = Python.import_module("traceback")

        var exc_info = sys.exc_info()
        var exc_type = exc_info.__getitem__(0)
        var exc_val = exc_info.__getitem__(1)
        var exc_tb = exc_info.__getitem__(2)

        exc_val = _patch_user_exc_obj(exc_val, force=True)

        var msg: String
        try:
            msg = String(builtins.str(exc_val))
        except:
            msg = ""
            try:
                var inner_e = sys.exc_info().__getitem__(1)
                var six_print = Python.evaluate("print")
                six_print(inner_e)
            except:
                pass

        var error = CustomError(msg)
        error.set_exc(
            String(builtins.str(exc_type)),
            String(builtins.str(exc_val)),
            String(builtins.str(exc_tb)),
        )

        var stackinfos = builtins.list(traceback_mod.extract_tb(exc_tb))

        if _is_syntax_error(exc_type):
            error.add_stack_info(
                String(exc_val.filename),
                Int(py=exc_val.lineno),
                "",
                String(exc_val.text),
            )
        else:
            var last_item: PythonObject = Python.none()
            for item in stackinfos:
                if _py_eq(builtins.str(item.__getitem__(0)), builtins.str(strategy)):
                    error.add_stack_info(
                        String(item.__getitem__(0)),
                        Int(py=item.__getitem__(1)),
                        String(item.__getitem__(2)),
                        String(item.__getitem__(3)),
                    )
                last_item = item
            if error.stacks_length() == 0 and _py_ne(last_item, Python.none()):
                error.add_stack_info(
                    String(last_item.__getitem__(0)),
                    Int(py=last_item.__getitem__(1)),
                    String(last_item.__getitem__(2)),
                    String(last_item.__getitem__(3)),
                )

        raise CustomException(error^)


def _is_syntax_error(exc_type_obj: PythonObject) raises -> Bool:
    var builtins = Python.import_module("builtins")
    try:
        var syntax_error = Python.evaluate("SyntaxError")
        var indentation_error = Python.evaluate("IndentationError")
        check1 = builtins.issubclass(exc_type_obj, syntax_error)
        check2 = builtins.issubclass(exc_type_obj, indentation_error)
        return _py_bool(check1) or _py_bool(check2)
    except:
        return False


def _patch_user_exc_obj(exc_val: PythonObject, force: Bool = False) raises -> PythonObject:
    var attr_name = "ricequant_exc"
    var current = Python.none()
    try:
        var getattr_fn = Python.import_module("builtins").getattr
        var notset_val = Python.evaluate("object()")
        current = getattr_fn(exc_val, attr_name, notset_val)
    except:
        pass

    if _py_eq(current, Python.none()) or force:
        try:
            exc_val.__setattr__(attr_name, "USER_EXC")
        except:
            pass
    return exc_val
