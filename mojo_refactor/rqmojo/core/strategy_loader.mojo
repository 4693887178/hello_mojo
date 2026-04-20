"""
RQAlpha Mojo - Strategy Loader Implementation
Ported from rqalpha/core/strategy_loader.py

Three strategy loaders:
  - FileStrategyLoader:     Load strategy from file path
  - SourceCodeStrategyLoader: Load strategy from source code string
  - UserFuncStrategyLoader:   Load strategy from user-provided function dict.
"""

from std.python import Python, PythonObject
from rqmojo.interface import StrategyLoader
from rqmojo.utils.strategy_loader_help import compile_strategy


@fieldwise_init
struct FileStrategyLoader(StrategyLoader, Movable, Writable):
    var _strategy_file_path: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("FileStrategyLoader(path=", self._strategy_file_path, ")")

    def load(mut self, scope: PythonObject) raises -> PythonObject:
        """Load strategy from file, compile and return scope."""
        var builtins = Python.import_module("builtins")

        var f = builtins.open(self._strategy_file_path, PythonObject("r"))
        var source_code = f.read()
        f.close()

        return compile_strategy(
            String(py=source_code), self._strategy_file_path, scope
        )


@fieldwise_init
struct SourceCodeStrategyLoader(StrategyLoader, Movable, Writable):
    var _code: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write(
            "SourceCodeStrategyLoader(code_length=", String(len(self._code)), ")"
        )

    def load(mut self, scope: PythonObject) raises -> PythonObject:
        """Load strategy from source code string, compile and return scope."""
        return compile_strategy(self._code, "strategy.py", scope)


@fieldwise_init
struct UserFuncStrategyLoader(StrategyLoader, Movable, Writable):
    var _user_funcs: PythonObject
    var _func_count: Int

    def __init__(out self, user_funcs: PythonObject) raises:
        self._user_funcs = user_funcs
        var builtins = Python.import_module("builtins")
        self._func_count = Int(py=builtins.len(user_funcs))

    def __init__(out self, *, copy: Self):
        self._user_funcs = copy._user_funcs
        self._func_count = copy._func_count

    def write_to(self, mut writer: Some[Writer]):
        writer.write(
            "UserFuncStrategyLoader(funcs=", String(self._func_count), ")"
        )

    def load(mut self, scope: PythonObject) raises -> PythonObject:
        """Update each function's globals with scope and return funcs."""
        var six = Python.import_module("six")
        for user_func in six.itervalues(self._user_funcs):
            var func_globals = user_func.__globals__
            func_globals.update(scope)
        return self._user_funcs


def create_file_strategy_loader(
    strategy_file_path: String,
) -> FileStrategyLoader:
    """Create a file strategy loader."""
    return FileStrategyLoader(_strategy_file_path=strategy_file_path)


def create_source_code_strategy_loader(code: String) -> SourceCodeStrategyLoader:
    """Create a source code strategy loader."""
    return SourceCodeStrategyLoader(_code=code)


def create_user_func_strategy_loader(
    user_funcs: PythonObject,
) raises -> UserFuncStrategyLoader:
    """Create a user function strategy loader."""
    return UserFuncStrategyLoader(user_funcs)
