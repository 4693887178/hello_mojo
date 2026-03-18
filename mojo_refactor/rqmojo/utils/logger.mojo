"""
RQAlpha Mojo - Logger
Ported from rqalpha/utils/logger.py
Uses Mojo native logger module
"""

from logger import Logger, Level
from collections import List


comptime DATETIME_FORMAT: String = "%Y-%m-%d %H:%M:%S.%f"


comptime __all__: List[String] = [
    "user_log",
    "system_log",
    "user_system_log",
    "release_print",
    "init_logger",
    "user_print",
]


@fieldwise_init
struct RQAlphaLogger(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var name: String
    var _logger: Logger
    var _level: Level

    fn __init__(out self, name: String, level: Level = Level.DEBUG):
        self.name = name
        self._level = level
        var prefix = "[" + name + "] "
        self._logger = Logger(prefix=prefix)

    fn __str__(self) -> String:
        return self.name

    @staticmethod
    fn create(name: String) -> Self:
        return Self(name, Level.DEBUG)

    fn trace(self, message: String):
        self._logger.trace(message)

    fn debug(self, message: String):
        self._logger.debug(message)

    fn info(self, message: String):
        self._logger.info(message)

    fn warning(self, message: String):
        self._logger.warning(message)

    fn warn(self, message: String):
        self.warning(message)

    fn error(self, message: String):
        self._logger.error(message)

    fn critical(self, message: String):
        self._logger.critical(message)

    fn exception(self, message: String):
        self.error(message)

    fn set_level(mut self, level: Level):
        self._level = level


@fieldwise_init
struct LoggerManager(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var _user_log: RQAlphaLogger
    var _system_log: RQAlphaLogger
    var _user_system_log: RQAlphaLogger
    var _initialized: Bool

    fn __init__(out self):
        self._user_log = RQAlphaLogger.create("user_log")
        self._system_log = RQAlphaLogger.create("system_log")
        self._user_system_log = RQAlphaLogger.create("user_system_log")
        self._initialized = False

    @staticmethod
    fn create() -> Self:
        return Self()

    fn __str__(self) -> String:
        return "LoggerManager"

    fn user_log(self) -> RQAlphaLogger:
        return self._user_log

    fn system_log(self) -> RQAlphaLogger:
        return self._system_log

    fn user_system_log(self) -> RQAlphaLogger:
        return self._user_system_log

    fn init(mut self):
        self._user_log = RQAlphaLogger.create("user_log")
        self._system_log = RQAlphaLogger.create("system_log")
        self._user_system_log = RQAlphaLogger.create("user_system_log")
        self._initialized = True


fn _get_logger_manager() -> LoggerManager:
    return LoggerManager.create()


fn user_log() -> RQAlphaLogger:
    return _get_logger_manager().user_log()


fn system_log() -> RQAlphaLogger:
    return _get_logger_manager().system_log()


fn user_system_log() -> RQAlphaLogger:
    return _get_logger_manager().user_system_log()


fn init_logger():
    var manager = _get_logger_manager()
    manager.init()


fn user_print[*Ts: Stringable](*args: Ts, sep: String = " ", end: String = ""):
    var message = String()
    var first = True
    for arg in args:
        if not first:
            message = message + sep
        message = message + str(arg)
        first = False
    message = message + end
    
    user_log().info(message)


fn release_print():
    pass
