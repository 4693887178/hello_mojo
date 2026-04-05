"""
RQAlpha Mojo - Strategy Loader Helper
Ported from rqalpha/utils/strategy_loader_help.py
"""

from std.python import Python, PythonObject

from rqmojo.utils.exception import CustomError, CustomException, patch_user_exc
from rqmojo.const import EXC_TYPE


def compile_strategy(source_code: String, strategy: String, scope: PythonObject) raises -> PythonObject:
    var builtins = Python.import_module("builtins")
    var six = Python.import_module("six")

    try:
        var code = builtins.compile(source_code, strategy, "exec")
        six.exec_(code, scope)
        return scope
    except:
        var sys = Python.import_module("sys")
        var traceback_mod = Python.import_module("traceback")

        var exc_info = sys.exc_info()
        var exc_type = exc_info.__getitem__(0)
        var exc_val = exc_info.__getitem__(1)
        var exc_tb = exc_info.__getitem__(2)

        var msg: String = ""
        try:
            msg = String(builtins.str(exc_val))
        except:
            msg = ""
            six.print_("failed to convert exception to string")

        var error = CustomError(msg, error_type=patch_user_exc(EXC_TYPE.NOTSET, force=True))
        error.set_exc(
            String(builtins.str(exc_type)),
            String(builtins.str(exc_val)),
            String(builtins.str(exc_tb)),
        )

        var stackinfos = builtins.list(traceback_mod.extract_tb(exc_tb))

        var is_syntax_error = Python.evaluate(
            "lambda t: issubclass(t, (SyntaxError, IndentationError))"
        )
        if String(is_syntax_error(exc_type)) == "True":
            error.add_stack_info(
                String(exc_val.filename),
                Int(py=exc_val.lineno),
                "",
                String(exc_val.text),
            )
        else:
            var last_item: PythonObject = Python.none()
            for item in stackinfos:
                if builtins.str(item.__getitem__(0)) == builtins.str(strategy):
                    error.add_stack_info(
                        String(item.__getitem__(0)),
                        Int(py=item.__getitem__(1)),
                        String(item.__getitem__(2)),
                        String(item.__getitem__(3)),
                    )
                last_item = item
            if error.stacks_length() == 0 and last_item != Python.none():
                error.add_stack_info(
                    String(last_item.__getitem__(0)),
                    Int(py=last_item.__getitem__(1)),
                    String(last_item.__getitem__(2)),
                    String(last_item.__getitem__(3)),
                )

        raise CustomException(error^)
