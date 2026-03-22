"""
RQAlpha Mojo - Logger
Ported from rqalpha/utils/logger.py
Uses Mojo native logger module
"""

from logger import Logger, Level


struct DATETIME_FORMAT:
    comptime VALUE: String = "%Y-%m-%d %H:%M:%S.%f"


comptime UserLogLevel: Level = Level.DEBUG
comptime SystemLogLevel: Level = Level.DEBUG
comptime UserSystemLogLevel: Level = Level.DEBUG


@fieldwise_init
struct RQAlphaLogger(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var name: String
    var _logger: Logger[Level.DEBUG]
    var _level: Level

    def __init__(out self, name: String, level: Level = Level.DEBUG):
        self.name = name
        self._level = level
        var prefix = "[" + name + "] "
        self._logger = Logger[Level.DEBUG](prefix=prefix)

    def __str__(self) -> String:
        return self.name

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
struct LoggerManager(Stringable, Copyable, Movable, ImplicitlyCopyable):
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

    def __str__(self) -> String:
        return "LoggerManager"

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


def get_logger_manager() -> LoggerManager:
    return LoggerManager.create()


def user_log() -> RQAlphaLogger:
    return get_logger_manager().user_log()


def system_log() -> RQAlphaLogger:
    return get_logger_manager().system_log()


def user_system_log() -> RQAlphaLogger:
    return get_logger_manager().user_system_log()


def init_logger():
    var manager = get_logger_manager()
    manager.init()


def user_print(message: String):
    user_log().info(message)


def release_print():
    pass
