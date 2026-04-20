"""
Simple test for exception.mojo
"""

from rqmojo.const import EXC_TYPE
from rqmojo.utils.exception import (
    CustomError, RQUserError, RQInvalidArgument,
    InstrumentNotFound, EnvironmentNotInitialized,
    patch_user_exc, patch_system_exc, is_user_exc, is_system_exc
)


def test_custom_error():
    var err = CustomError.create("Test error message")
    print("CustomError created successfully")


def test_rq_user_error():
    var err = RQUserError.create("User error test")
    print("RQUserError created successfully")


def test_rq_invalid_argument():
    var err = RQInvalidArgument.create("Invalid argument test")
    print("RQInvalidArgument created successfully")


def test_instrument_not_found():
    var err = InstrumentNotFound.create("000001.XSHE")
    print("InstrumentNotFound created successfully")


def test_environment_not_initialized():
    var err = EnvironmentNotInitialized.create()
    print("EnvironmentNotInitialized created successfully")


def test_patch_user_exc():
    var result = patch_user_exc(EXC_TYPE.NOTSET)
    print("patch_user_exc result: " + result.name)
    assert result == EXC_TYPE.USER_EXC


def test_patch_system_exc():
    var result = patch_system_exc(EXC_TYPE.NOTSET)
    print("patch_system_exc result: " + result.name)
    assert result == EXC_TYPE.SYSTEM_EXC


def test_is_user_exc():
    var result = is_user_exc(EXC_TYPE.USER_EXC)
    print("is_user_exc: " + String(result))
    assert result == True


def test_is_system_exc():
    var result = is_system_exc(EXC_TYPE.SYSTEM_EXC)
    print("is_system_exc: " + String(result))
    assert result == True


fn main():
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
