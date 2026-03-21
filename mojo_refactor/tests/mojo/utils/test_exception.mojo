"""
Mojo Test for utils/exception.mojo
Tests the exception classes
"""

from collections import List
from rqmojo.utils.exception import (
    CustomError, RQUserError, RQInvalidArgument,
    InstrumentNotFound, EnvironmentNotInitialized,
    ExceptionGroup, BaseExceptionGroup, format_exception_group,
    patch_user_exc, patch_system_exc, is_user_exc, is_system_exc
)
from rqmojo.const import EXC_TYPE


def test_custom_error():
    var err = CustomError.create("Test error message")
    print("CustomError: " + err.__str__())
    assert err.msg == "Test error message"


def test_rq_user_error():
    var err = RQUserError.create("User error test")
    print("RQUserError: " + err.__str__())
    assert err.message == "User error test"


def test_rq_invalid_argument():
    var err = RQInvalidArgument.create("Invalid argument test")
    print("RQInvalidArgument: " + err.__str__())
    assert err.message == "Invalid argument test"


def test_instrument_not_found():
    var err = InstrumentNotFound.create("000001.XSHE")
    print("InstrumentNotFound: " + err.__str__())
    assert "000001.XSHE" in err.__str__()


def test_environment_not_initialized():
    var err = EnvironmentNotInitialized.create()
    print("EnvironmentNotInitialized: " + err.__str__())
    assert "not been initialized" in err.__str__()


def test_patch_user_exc():
    var result = patch_user_exc(EXC_TYPE.NOTSET)
    print("patch_user_exc result: " + result.name())
    assert result == EXC_TYPE.USER_EXC


def test_patch_system_exc():
    var result = patch_system_exc(EXC_TYPE.NOTSET)
    print("patch_system_exc result: " + result.name())
    assert result == EXC_TYPE.SYSTEM_EXC


def test_is_user_exc():
    var result = is_user_exc(EXC_TYPE.USER_EXC)
    print("is_user_exc: " + String(result))
    assert result == True


def test_is_system_exc():
    var result = is_system_exc(EXC_TYPE.SYSTEM_EXC)
    print("is_system_exc: " + String(result))
    assert result == True


def main():
    print("=== Testing utils/exception.mojo ===")
    test_custom_error()
    test_rq_user_error()
    test_rq_invalid_argument()
    test_instrument_not_found()
    test_environment_not_initialized()
    test_patch_user_exc()
    test_patch_system_exc()
    test_is_user_exc()
    test_is_system_exc()
    print("All exception tests passed!")
