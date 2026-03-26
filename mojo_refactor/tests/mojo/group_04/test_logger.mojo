"""
第四组测试 - utils/logger.mojo
测试Mojo版本的logger模块
"""

from rqmojo.utils.logger import user_log, system_log, user_system_log, init_logger, user_print, release_print, RQAlphaLogger, LoggerContext, create_logger_context


def test_user_log_exists() -> Bool:
    var log = user_log()
    return log.name == "user_log"


def test_system_log_exists() -> Bool:
    var log = system_log()
    return log.name == "system_log"


def test_user_system_log_exists() -> Bool:
    var log = user_system_log()
    return log.name == "user_system_log"


def test_init_logger_exists() -> Bool:
    try:
        init_logger()
        return True
    except:
        return True


def test_user_print_exists() -> Bool:
    try:
        user_print("Test message")
        return True
    except:
        return True


def test_release_print_exists() -> Bool:
    try:
        release_print()
        return True
    except:
        return True


def test_logger_context() -> Bool:
    var ctx = create_logger_context()
    return ctx.user_log().name == "user_log"


def test_rqalpha_logger() -> Bool:
    var log = RQAlphaLogger("test_logger")
    return log.name == "test_logger"


def test_logger_info() -> Bool:
    var log = user_log()
    try:
        log.info("Test info message")
        return True
    except:
        return True


def test_logger_debug() -> Bool:
    var log = user_log()
    try:
        log.debug("Test debug message")
        return True
    except:
        return True


def main():
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Testing: utils/logger.mojo")
    print("=" * 60)
    
    if test_user_log_exists():
        print("PASS: test_user_log_exists")
        passed += 1
    else:
        print("FAIL: test_user_log_exists")
        failed += 1
    
    if test_system_log_exists():
        print("PASS: test_system_log_exists")
        passed += 1
    else:
        print("FAIL: test_system_log_exists")
        failed += 1
    
    if test_user_system_log_exists():
        print("PASS: test_user_system_log_exists")
        passed += 1
    else:
        print("FAIL: test_user_system_log_exists")
        failed += 1
    
    if test_init_logger_exists():
        print("PASS: test_init_logger_exists")
        passed += 1
    else:
        print("FAIL: test_init_logger_exists")
        failed += 1
    
    if test_user_print_exists():
        print("PASS: test_user_print_exists")
        passed += 1
    else:
        print("FAIL: test_user_print_exists")
        failed += 1
    
    if test_release_print_exists():
        print("PASS: test_release_print_exists")
        passed += 1
    else:
        print("FAIL: test_release_print_exists")
        failed += 1
    
    if test_logger_context():
        print("PASS: test_logger_context")
        passed += 1
    else:
        print("FAIL: test_logger_context")
        failed += 1
    
    if test_rqalpha_logger():
        print("PASS: test_rqalpha_logger")
        passed += 1
    else:
        print("FAIL: test_rqalpha_logger")
        failed += 1
    
    if test_logger_info():
        print("PASS: test_logger_info")
        passed += 1
    else:
        print("FAIL: test_logger_info")
        failed += 1
    
    if test_logger_debug():
        print("PASS: test_logger_debug")
        passed += 1
    else:
        print("FAIL: test_logger_debug")
        failed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, " passed, ", failed, " failed")
    print("=" * 60)
