# test_L01_03_logger.py
# Module: rqalpha.utils.logger
# Level: L01 - Utils module
# Dependencies: logbook

import pytest


class TestLoggerBasics:
    """Test basic logger functionality"""
    
    def test_user_log_exists(self):
        """Test user_log exists"""
        from rqalpha.utils.logger import user_log
        assert user_log is not None
        assert hasattr(user_log, 'info')
        assert hasattr(user_log, 'debug')
        assert hasattr(user_log, 'warning')
        assert hasattr(user_log, 'error')
    
    def test_system_log_exists(self):
        """Test system_log exists"""
        from rqalpha.utils.logger import system_log
        assert system_log is not None
        assert hasattr(system_log, 'info')
    
    def test_user_system_log_exists(self):
        """Test user_system_log exists"""
        from rqalpha.utils.logger import user_system_log
        assert user_system_log is not None
        assert hasattr(user_system_log, 'info')


class TestLoggerInit:
    """Test logger initialization"""
    
    def test_init_logger(self):
        """Test init_logger function"""
        from rqalpha.utils.logger import init_logger
        init_logger()
    
    def test_datetime_format(self):
        """Test DATETIME_FORMAT constant"""
        from rqalpha.utils.logger import DATETIME_FORMAT
        assert DATETIME_FORMAT == "%Y-%m-%d %H:%M:%S.%f"


class TestUserPrint:
    """Test user_print function"""
    
    def test_user_print_exists(self):
        """Test user_print function exists"""
        from rqalpha.utils.logger import user_print
        assert callable(user_print)
    
    @pytest.mark.skip(reason="Requires Environment initialization")
    def test_user_print_basic(self, capsys):
        """Test basic user_print functionality"""
        from rqalpha.utils.logger import user_print
        user_print("test message")
    
    @pytest.mark.skip(reason="Requires Environment initialization")
    def test_user_print_multiple_args(self, capsys):
        """Test user_print with multiple arguments"""
        from rqalpha.utils.logger import user_print
        user_print("arg1", "arg2", "arg3")


class TestReleasePrint:
    """Test release_print function"""
    
    def test_release_print_exists(self):
        """Test release_print function exists"""
        from rqalpha.utils.logger import release_print
        assert callable(release_print)
    
    def test_release_print_with_scope(self):
        """Test release_print with a scope"""
        from rqalpha.utils.logger import release_print
        scope = {"test_func": lambda: None}
        release_print(scope)


class TestLoggerNames:
    """Test logger names"""
    
    def test_user_log_name(self):
        """Test user_log name"""
        from rqalpha.utils.logger import user_log
        assert user_log.name == "user_log"
    
    def test_system_log_name(self):
        """Test system_log name"""
        from rqalpha.utils.logger import system_log
        assert system_log.name == "system_log"
    
    def test_user_system_log_name(self):
        """Test user_system_log name"""
        from rqalpha.utils.logger import user_system_log
        assert user_system_log.name == "user_system_log"
