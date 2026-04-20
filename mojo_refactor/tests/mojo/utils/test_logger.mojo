"""
Test for logger.mojo - Comprehensive test suite
Uses std.testing framework (TestSuite)
"""

from rqmojo.utils.logger import (
    user_log, system_log, user_system_log,
    init_logger, user_print, release_print,
    RQAlphaLogger, LoggerContext, create_logger_context,
)
from std.testing import assert_equal, assert_true, assert_false, TestSuite


def test_logger_basic() raises:
    var ul = user_log()
    var sl = system_log()
    var usl = user_system_log()

    assert_equal(ul.name, "user_log")
    assert_equal(sl.name, "system_log")
    assert_equal(usl.name, "user_system_log")


def test_logger_methods() raises:
    var logger = user_log()

    logger.debug("Debug message from Mojo")
    logger.info("Info message from Mojo")
    logger.warning("Warning message from Mojo")
    logger.error("Error message from Mojo")


def test_init_logger() raises:
    init_logger()


def test_user_print() raises:
    user_print("Hello from user_print!")


def test_release_print() raises:
    release_print()


def test_rqalpha_logger() raises:
    var log = RQAlphaLogger("test_logger")
    assert_equal(log.name, "test_logger")


def test_logger_context() raises:
    var ctx = create_logger_context()
    assert_equal(ctx.user_log().name, "user_log")


def test_critical_no_crash() raises:
    var log = RQAlphaLogger("critical_test")
    log.critical("critical should not crash")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
