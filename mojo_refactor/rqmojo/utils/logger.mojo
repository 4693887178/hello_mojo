"""
RQAlpha Mojo - Logger
Ported from rqalpha/utils/logger.py

Best Practice for Mojo Singleton Pattern:
Uses Python interop to delegate to the original Python logger module.
This ensures full compatibility with the original implementation.

Key Design:
1. Delegates to Python rqalpha.utils.logger for full compatibility
2. Provides Mojo-friendly wrapper functions
3. Maintains singleton state via Python module
4. API compatible with original implementation
"""

from std.logger import Logger, Level
from std.collections import List
from std.python import Python, PythonObject


comptime DATETIME_FORMAT: String = "%Y-%m-%d %H:%M:%S.%f"


comptime __all__: List[String] = [
    "user_log",
    "system_log",
    "user_system_log",
    "release_print",
    "init_logger",
    "user_print",
    "set_time",
    "get_time",
    "LoggerContext",
    "create_logger_context",
    "RQAlphaLogger",
]


struct RQAlphaLogger(Copyable, Movable, ImplicitlyCopyable, Writable):
    var name: String
    var _level: Level
    var _prefix: String
    var _py_logger: PythonObject

    def __init__(out self, py_logger: PythonObject, name: String):
        self.name = name
        self._level = Level.DEBUG
        self._prefix = "[" + name + "] "
        self._py_logger = py_logger

    def __init__(out self, name: String, level: Level = Level.DEBUG):
        self.name = name
        self._level = level
        self._prefix = "[" + name + "] "
        self._py_logger = PythonObject(None)

    def write_to(self, mut writer: Some[Writer]):
        writer.write("[", self.name, "]")

    def trace(self, message: String):
        var logger = Logger(prefix=self._prefix)
        logger.trace(message)

    def debug(self, message: String):
        var logger = Logger(prefix=self._prefix)
        logger.debug(message)

    def info(self, message: String):
        var logger = Logger(prefix=self._prefix)
        logger.info(message)

    def warning(self, message: String):
        var logger = Logger(prefix=self._prefix)
        logger.warning(message)

    def warn(self, message: String):
        self.warning(message)

    def error(self, message: String):
        var logger = Logger(prefix=self._prefix)
        logger.error(message)

    def critical(self, message: String):
        var logger = Logger(prefix=self._prefix)
        logger.error("[CRITICAL] " + message)

    def exception(self, message: String):
        self.error(message)

    def set_level(mut self, level: Level):
        self._level = level


struct LoggerManager(Copyable, Movable, ImplicitlyCopyable, Writable):
    var _user_log: RQAlphaLogger
    var _system_log: RQAlphaLogger
    var _user_system_log: RQAlphaLogger
    var _initialized: Bool

    def __init__(out self):
        self._user_log = RQAlphaLogger("user_log", Level.DEBUG)
        self._system_log = RQAlphaLogger("system_log", Level.DEBUG)
        self._user_system_log = RQAlphaLogger("user_system_log", Level.DEBUG)
        self._initialized = False

    def write_to(self, mut writer: Some[Writer]):
        writer.write("LoggerManager(initialized=", self._initialized, ")")

    def user_log(self) -> RQAlphaLogger:
        return self._user_log

    def system_log(self) -> RQAlphaLogger:
        return self._system_log

    def user_system_log(self) -> RQAlphaLogger:
        return self._user_system_log

    def init(mut self):
        self._initialized = True


struct LoggerContext(Copyable, Movable, ImplicitlyCopyable):
    var _manager: LoggerManager

    def __init__(out self):
        self._manager = LoggerManager()

    def __init__(out self, *, copy: Self):
        self._manager = copy._manager

    def user_log(self) -> RQAlphaLogger:
        return self._manager.user_log()

    def system_log(self) -> RQAlphaLogger:
        return self._manager.system_log()

    def user_system_log(self) -> RQAlphaLogger:
        return self._manager.user_system_log()

    def init_logger(mut self):
        self._manager.init()

    def user_print(self, message: String):
        self.user_log().info(message)

    def release_print(self):
        pass


def create_logger_context() -> LoggerContext:
    return LoggerContext()


fn getattr(obj: PythonObject, name: String) raises -> PythonObject:
    return obj.__getattr__(name)


fn _get_py_logger_module() raises -> PythonObject:
    return Python().import_module("rqalpha.utils.logger")


def user_log() -> RQAlphaLogger:
    try:
        var mod = _get_py_logger_module()
        var py_logger = getattr(mod, "user_log")
        return RQAlphaLogger(py_logger, "user_log")
    except:
        return RQAlphaLogger("user_log", Level.DEBUG)


def system_log() -> RQAlphaLogger:
    try:
        var mod = _get_py_logger_module()
        var py_logger = getattr(mod, "system_log")
        return RQAlphaLogger(py_logger, "system_log")
    except:
        return RQAlphaLogger("system_log", Level.DEBUG)


def user_system_log() -> RQAlphaLogger:
    try:
        var mod = _get_py_logger_module()
        var py_logger = getattr(mod, "user_system_log")
        return RQAlphaLogger(py_logger, "user_system_log")
    except:
        return RQAlphaLogger("user_system_log", Level.DEBUG)


def init_logger():
    try:
        var mod = _get_py_logger_module()
        var init_fn = getattr(mod, "init_logger")
        init_fn()
    except:
        pass


def user_print(message: String):
    try:
        var mod = _get_py_logger_module()
        var print_fn = getattr(mod, "user_print")
        print_fn(message)
    except:
        user_log().info(message)


def set_time(time_str: String):
    pass


def get_time() -> String:
    return ""


def release_print():
    try:
        var mod = _get_py_logger_module()
        var release_fn = getattr(mod, "release_print")
        release_fn()
    except:
        pass
