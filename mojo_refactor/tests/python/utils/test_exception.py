# -*- coding: utf-8 -*-
"""
Python Test for rqalpha/utils/exception.py
Tests the exception classes
"""

import pytest


def test_custom_error():
    """Test CustomError class"""
    from rqalpha.utils.exception import CustomError
    
    err = CustomError()
    err.set_msg("Test error message")
    assert err.msg == "Test error message"


def test_rq_user_error():
    """Test RQUserError class"""
    from rqalpha.utils.exception import RQUserError
    
    err = RQUserError("User error test")
    assert str(err) == "User error test"


def test_rq_invalid_argument():
    """Test RQInvalidArgument class"""
    from rqalpha.utils.exception import RQInvalidArgument
    
    err = RQInvalidArgument("Invalid argument test")
    assert "Invalid argument test" in str(err)


def test_rq_type_error():
    """Test RQTypeError class"""
    from rqalpha.utils.exception import RQTypeError
    
    err = RQTypeError("Type error test")
    assert "Type error test" in str(err)


def test_rq_api_not_supported_error():
    """Test RQApiNotSupportedError class"""
    from rqalpha.utils.exception import RQApiNotSupportedError
    
    err = RQApiNotSupportedError("API not supported test")
    assert "API not supported test" in str(err)


def test_instrument_not_found():
    """Test InstrumentNotFound class"""
    from rqalpha.utils.exception import InstrumentNotFound
    
    err = InstrumentNotFound("000001.XSHE")
    assert "000001.XSHE" in str(err)


def test_environment_not_initialized():
    """Test EnvironmentNotInitialized class"""
    from rqalpha.utils.exception import EnvironmentNotInitialized
    
    err = EnvironmentNotInitialized()
    assert "not been initialized" in str(err)


def test_patch_user_exc():
    """Test patch_user_exc function"""
    from rqalpha.utils.exception import patch_user_exc
    from rqalpha import const
    
    result = patch_user_exc(Exception("test"))
    assert hasattr(result, const.EXC_EXT_NAME)


def test_patch_system_exc():
    """Test patch_system_exc function"""
    from rqalpha.utils.exception import patch_system_exc
    from rqalpha import const
    
    result = patch_system_exc(Exception("test"))
    assert hasattr(result, const.EXC_EXT_NAME)


def test_is_user_exc():
    """Test is_user_exc function"""
    from rqalpha.utils.exception import is_user_exc, patch_user_exc
    from rqalpha import const
    
    exc = Exception("test")
    patch_user_exc(exc)
    assert is_user_exc(exc) == True


def test_is_system_exc():
    """Test is_system_exc function"""
    from rqalpha.utils.exception import is_system_exc, patch_system_exc
    from rqalpha import const
    
    exc = Exception("test")
    patch_system_exc(exc)
    assert is_system_exc(exc) == True


def test_exception_group():
    """Test ExceptionGroup class"""
    from rqalpha.utils.exception import ExceptionGroup
    
    exceptions = [ValueError("Error 1"), TypeError("Error 2")]
    group = ExceptionGroup("Multiple errors", exceptions)
    
    assert group.message == "Multiple errors"
    assert len(group.exceptions) == 2


def test_base_exception_group():
    """Test BaseExceptionGroup class"""
    from rqalpha.utils.exception import BaseExceptionGroup
    
    exceptions = [ValueError("Error 1"), TypeError("Error 2")]
    group = BaseExceptionGroup("Multiple errors", exceptions)
    
    assert group.message == "Multiple errors"
    assert len(group.exceptions) == 2


def test_exception_group_str():
    """Test ExceptionGroup __str__ method"""
    from rqalpha.utils.exception import ExceptionGroup
    
    exceptions = [ValueError("Error 1")]
    group = ExceptionGroup("Single error", exceptions)
    
    result = str(group)
    assert "1 sub-exception" in result


def test_format_exception_group():
    """Test format_exception_group function"""
    from rqalpha.utils.exception import ExceptionGroup, format_exception_group
    
    exceptions = [ValueError("Error 1"), TypeError("Error 2")]
    group = ExceptionGroup("Test group", exceptions)
    
    result = format_exception_group(group)
    assert "Test group" in result
    assert "Error 1" in result


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
