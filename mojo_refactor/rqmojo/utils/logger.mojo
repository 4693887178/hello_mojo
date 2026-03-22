"""
RQAlpha Mojo - Logger
Ported from rqalpha/utils/logger.py
Uses Mojo native logger module
"""

from std.logger import Logger, Level
from std.collections import List


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
struct RQAlphaLogger(Writable, Copyable, Movable, ImplicitlyCopyable):
    var name: String
    var _logger: Logger[Level.DEBUG]
    var _level: Level

    def __init__(out self, name: String, level: Level = Level.DEBUG):
        self.name = name
        self._level = level
        var prefix = "[" + name + "] "
        self._logger = Logger[Level.DEBUG](prefix=prefix)

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.name)

    @staticmethod
    def create(name: String) -> Self:
        return Self(name, Level.DEBUG)

    def trace(self, message: String):
        self._logger.trace(message)

    def debug(self, message: String):
        self._logger.debug(message)

    def info(self, message: String):
        self._logger.info(message)

    def warning(self, message: String):
        self._logger.warning(message)

    def warn(self, message: String):
        self.warning(message)

    def error(self, message: String):
        self._logger.error(message)

    def critical(self, message: String):
        self._logger.critical(message)

    def exception(self, message: String):
        self.error(message)

    def set_level(mut self, level: Level):
        self._level = level


@fieldwise_init
struct LoggerManager(Writable, Copyable, Movable, ImplicitlyCopyable):
    var _user_log: RQAlphaLogger
    var _system_log: RQAlphaLogger
    var _user_system_log: RQAlphaLogger
    var _initialized: Bool

    def __init__(out self):
        self._user_log = RQAlphaLogger.create("user_log")
        self._system_log = RQAlphaLogger.create("system_log")
        self._user_system_log = RQAlphaLogger.create("user_system_log")
        self._initialized = False

    @staticmethod
    def create() -> Self:
        return Self()

    def write_to(self, mut writer: Some[Writer]):
        writer.write("LoggerManager")

    def user_log(self) -> RQAlphaLogger:
        return self._user_log

    def system_log(self) -> RQAlphaLogger:
        return self._system_log

    def user_system_log(self) -> RQAlphaLogger:
        return self._user_system_log

    def init(mut self):
        self._user_log = RQAlphaLogger.create("user_log")
        self._system_log = RQAlphaLogger.create("system_log")
        self._user_system_log = RQAlphaLogger.create("user_system_log")
        self._initialized = True


def _get_logger_manager() -> LoggerManager:
    return LoggerManager.create()


def user_log() -> RQAlphaLogger:
    return _get_logger_manager().user_log()


def system_log() -> RQAlphaLogger:
    return _get_logger_manager().system_log()


def user_system_log() -> RQAlphaLogger:
    return _get_logger_manager().user_system_log()


def init_logger():
    var manager = _get_logger_manager()
    manager.init()


def user_print(message: String):
    user_log().info(message)


def release_print():
    pass
