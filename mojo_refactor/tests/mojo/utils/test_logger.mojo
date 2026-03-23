"""
Test for logger.mojo - Python interop based singleton pattern
"""

from rqmojo.utils.logger import user_log, system_log, user_system_log, init_logger, user_print


def test_logger_basic():
    print("=== Testing Logger Basic Functions ===")
    
    var ul = user_log()
    var sl = system_log()
    var usl = user_system_log()
    
    print("user_log name: " + ul.name)
    print("system_log name: " + sl.name)
    print("user_system_log name: " + usl.name)
    
    print("PASS: Basic logger functions work!")
    print("")


def test_logger_methods():
    print("=== Testing Logger Methods ===")
    
    var logger = user_log()
    
    logger.debug("Debug message from Mojo")
    logger.info("Info message from Mojo")
    logger.warning("Warning message from Mojo")
    logger.error("Error message from Mojo")
    
    print("PASS: Logger methods work!")
    print("")


def test_init_logger():
    print("=== Testing init_logger ===")
    
    init_logger()
    
    print("PASS: init_logger works!")
    print("")


def test_user_print():
    print("=== Testing user_print ===")
    
    user_print("Hello from user_print!")
    
    print("PASS: user_print works!")
    print("")


def main():
    print("=" * 60)
    print("Logger Test - Python Interop Singleton Pattern")
    print("=" * 60)
    print("")
    
    test_logger_basic()
    test_logger_methods()
    test_init_logger()
    test_user_print()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
