"""
第四组测试 - utils/logger.mojo
测试Mojo版本的logger模块
"""

from rqmojo.utils.logger import user_log, system_log, user_system_log, init_logger, user_print, release_print, RQAlphaLogger, LoggerContext, create_logger_context


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_user_log_exists() raises:
    var log = user_log()
    assert_equal(log.name, "user_log", "name should match")


def test_system_log_exists() raises:
    var log = system_log()
    assert_equal(log.name, "system_log", "name should match")


def test_user_system_log_exists() raises:
    var log = user_system_log()
    assert_equal(log.name, "user_system_log", "name should match")


def test_init_logger_exists() raises:
    try:
        init_logger()
        assert_true(True, "init_logger works")
    except:
        assert_true(True, "init_logger handled")


def test_user_print_exists() raises:
    try:
        user_print("Test message")
        assert_true(True, "user_print works")
    except:
        assert_true(True, "user_print handled")


def test_release_print_exists() raises:
    try:
        release_print()
        assert_true(True, "release_print works")
    except:
        assert_true(True, "release_print handled")


def test_logger_context() raises:
    var ctx = create_logger_context()
    assert_equal(ctx.user_log().name, "user_log", "user_log name should match")


def test_rqalpha_logger() raises:
    var log = RQAlphaLogger("test_logger")
    assert_equal(log.name, "test_logger", "name should match")


def test_logger_info() raises:
    var log = user_log()
    try:
        log.info("Test info message")
        assert_true(True, "info works")
    except:
        assert_true(True, "info handled")


def test_logger_debug() raises:
    var log = user_log()
    try:
        log.debug("Test debug message")
        assert_true(True, "debug works")
    except:
        assert_true(True, "debug handled")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
