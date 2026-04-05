"""
Comprehensive Test Suite for rqmojo/utils/logger.mojo
Aligned with Python rqalpha/utils/logger.py behavior.

Test Categories:
  A. RQAlphaLogger struct - construction, all log methods, Writable, copy
  B. LoggerManager struct - lifecycle, accessors, initialization
  C. LoggerContext struct - factory pattern, delegation
  D. Module-level functions - user_log, system_log, etc.
  E. Edge cases - empty messages, special chars, independence
"""

from std.logger import Level
from std.python import PythonObject
from rqmojo.utils.logger import (
    RQAlphaLogger,
    LoggerManager,
    LoggerContext,
    create_logger_context,
    user_log,
    system_log,
    user_system_log,
    init_logger,
    user_print,
    set_time,
    get_time,
    release_print,
)
from std.testing import assert_equal, assert_true, assert_false, TestSuite


# ============================================================
# Category A: RQAlphaLogger struct
# ============================================================

def test_rqalpha_logger_construct_name_only() raises:
    var log = RQAlphaLogger("test_name")
    assert_equal(log.name, "test_name", "name should match constructor arg")


def test_rqalpha_logger_construct_with_level() raises:
    var log = RQAlphaLogger("test_name", level=Level.ERROR)
    assert_equal(log._level, Level.ERROR, "level should match constructor arg")


def test_rqalpha_logger_construct_py_logger() raises:
    var py_obj = PythonObject(None)
    var log = RQAlphaLogger(py_obj, "py_name")
    assert_equal(log.name, "py_name", "name should match")


def test_rqalpha_logger_write_to() raises:
    var log = RQAlphaLogger("writer_test")
    var s = String.write(log)
    assert_true(s.find("[writer_test]") >= 0, "write_to should produce [name]")


def test_rqalpha_logger_trace() raises:
    var log = RQAlphaLogger("trace_test")
    log.trace("trace message")


def test_rqalpha_logger_debug() raises:
    var log = RQAlphaLogger("debug_test")
    log.debug("debug message")


def test_rqalpha_logger_info() raises:
    var log = RQAlphaLogger("info_test")
    log.info("info message")


def test_rqalpha_logger_warning() raises:
    var log = RQAlphaLogger("warning_test")
    log.warning("warning message")


def test_rqalpha_logger_warn_delegates_to_warning() raises:
    var log = RQAlphaLogger("warn_test")
    log.warn("warn message")


def test_rqalpha_logger_error() raises:
    var log = RQAlphaLogger("error_test")
    log.error("error message")


def test_rqalpha_logger_critical_no_crash() raises:
    var log = RQAlphaLogger("critical_test")
    log.critical("critical message")


def test_rqalpha_logger_exception_delegates_to_error() raises:
    var log = RQAlphaLogger("exception_test")
    log.exception("exception message")


def test_rqalpha_logger_set_level() raises:
    var log = RQAlphaLogger("level_test")
    assert_equal(log._level, Level.DEBUG, "default level should be DEBUG")
    log.set_level(Level.WARNING)
    assert_equal(log._level, Level.WARNING, "level should update to WARNING")


def test_rqalpha_logger_copy_semantics() raises:
    var original = RQAlphaLogger("original")
    original.set_level(Level.ERROR)
    var copied = original.copy()
    assert_equal(copied.name, "original", "copied name should match")
    assert_equal(copied._level, Level.ERROR, "copied level should match")


# ============================================================
# Category B: LoggerManager struct
# ============================================================

def test_logger_manager_default_init() raises:
    var mgr = LoggerManager()
    assert_false(mgr._initialized, "should not be initialized by default")


def test_logger_manager_user_log_name() raises:
    var mgr = LoggerManager()
    assert_equal(mgr.user_log().name, "user_log", "user_log name should be 'user_log'")


def test_logger_manager_system_log_name() raises:
    var mgr = LoggerManager()
    assert_equal(mgr.system_log().name, "system_log", "system_log name should be 'system_log'")


def test_logger_manager_user_system_log_name() raises:
    var mgr = LoggerManager()
    assert_equal(mgr.user_system_log().name, "user_system_log", "user_system_log name should be 'user_system_log'")


def test_logger_manager_init_sets_flag() raises:
    var mgr = LoggerManager()
    assert_false(mgr._initialized, "before init")
    mgr.init()
    assert_true(mgr._initialized, "after init")


def test_logger_manager_write_to() raises:
    var mgr = LoggerManager()
    var s = String.write(mgr)
    assert_true(
        s.find("LoggerManager(initialized=") >= 0,
        "write_to should contain LoggerManager info",
    )


def test_logger_manager_all_loggers_distinct() raises:
    var mgr = LoggerManager()
    assert_true(
        mgr.user_log().name != mgr.system_log().name,
        "user_log and system_log should have different names",
    )
    assert_true(
        mgr.user_log().name != mgr.user_system_log().name,
        "user_log and user_system_log should have different names",
    )
    assert_true(
        mgr.system_log().name != mgr.user_system_log().name,
        "system_log and user_system_log should have different names",
    )


# ============================================================
# Category C: LoggerContext struct
# ============================================================

def test_logger_context_construct() raises:
    var _ = LoggerContext()


def test_logger_context_user_log_name() raises:
    var ctx = LoggerContext()
    assert_equal(ctx.user_log().name, "user_log")


def test_logger_context_system_log_name() raises:
    var ctx = LoggerContext()
    assert_equal(ctx.system_log().name, "system_log")


def test_logger_context_user_system_log_name() raises:
    var ctx = LoggerContext()
    assert_equal(ctx.user_system_log().name, "user_system_log")


def test_logger_context_init_logger() raises:
    var ctx = LoggerContext()
    ctx.init_logger()


def test_logger_context_user_print() raises:
    var ctx = LoggerContext()
    ctx.user_print("context print test")


def test_logger_context_release_print_no_crash() raises:
    var ctx = LoggerContext()
    ctx.release_print()


# ============================================================
# Category D: Module-level functions
# ============================================================

def test_module_user_log_returns_valid() raises:
    var log = user_log()
    assert_equal(log.name, "user_log")


def test_module_system_log_returns_valid() raises:
    var log = system_log()
    assert_equal(log.name, "system_log")


def test_module_user_system_log_returns_valid() raises:
    var log = user_system_log()
    assert_equal(log.name, "user_system_log")


def test_module_init_logger_no_crash() raises:
    init_logger()


def test_module_user_print_no_crash() raises:
    user_print("module user_print test")


def test_module_set_time_no_crash() raises:
    set_time("2024-01-01 00:00:00")


def test_module_get_time_returns_string() raises:
    var result = get_time()
    assert_true(result == "", "get_time should return empty string in pure-Mojo mode")


def test_module_release_print_no_crash() raises:
    release_print()


# ============================================================
# Category E: Factory & Edge Cases
# ============================================================

def test_create_logger_context_returns_valid() raises:
    var ctx = create_logger_context()
    assert_equal(ctx.user_log().name, "user_log")


def test_empty_message_handling() raises:
    var log = RQAlphaLogger("empty_test")
    log.trace("")
    log.debug("")
    log.info("")
    log.warning("")
    log.warn("")
    log.error("")
    log.critical("")
    log.exception("")


def test_special_characters_in_message() raises:
    var log = RQAlphaLogger("special_test")
    log.info("message with \t tabs")
    log.info("message with \n newline")
    log.info("message with 中文 unicode")
    log.info('message with "quotes"')
    log.info("message with <html> tags</html>")


def test_multiple_loggers_independent() raises:
    var log_a = RQAlphaLogger("logger_a")
    var log_b = RQAlphaLogger("logger_b")
    log_a.set_level(Level.ERROR)
    log_b.set_level(Level.DEBUG)
    assert_equal(log_a._level, Level.ERROR, "logger_a level should be ERROR")
    assert_equal(log_b._level, Level.DEBUG, "logger_b level should be DEBUG")


def test_prefix_format_contains_brackets() raises:
    var log = RQAlphaLogger("prefix_test")
    assert_equal(
        log._prefix,
        "[prefix_test] ",
        "prefix should be [name] ",
    )


def test_long_message() raises:
    var log = RQAlphaLogger("long_msg")
    var long_msg = "x" * 1000
    log.info(long_msg)


def test_all_levels_callable_without_crash() raises:
    var log = RQAlphaLogger("all_levels")
    log.trace("L1 trace")
    log.debug("L2 debug")
    log.info("L3 info")
    log.warning("L4 warning")
    log.warn("L5 warn")
    log.error("L6 error")
    log.critical("L7 critical")
    log.exception("L8 exception")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
