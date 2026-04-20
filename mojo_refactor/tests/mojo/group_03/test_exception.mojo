"""
RQAlpha Mojo - Exception Module Test
Tests for utils/exception.mojo
"""

from rqmojo.utils.exception import (
    CustomError, CustomException,
    RQUserError, RQInvalidArgument, RQTypeError,
    RQApiNotSupportedError, InstrumentNotFound,
    EnvironmentNotInitialized, ExceptionGroup,
    patch_user_exc, patch_system_exc, is_user_exc, is_system_exc
)
from rqmojo.const import EXC_TYPE



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_custom_error_creation() raises:
    """Test that CustomError can be created."""
    var ce = CustomError.create("test message")
    assert_equal(ce.msg, "test message", "Message should match")
    print("  CustomError creation test passed!")


def test_custom_error_add_stack() raises:
    """Test that CustomError can add stack info."""
    var ce = CustomError.create("test message")
    ce.add_stack_info("test.py", 10, "test_func", "code line")
    assert_equal(ce.stacks_length(), 1, "Should have 1 stack frame")
    print("  CustomError add_stack test passed!")


def test_custom_exception_creation() raises:
    """Test that CustomException can be created."""
    var exc = CustomException.create("test error")
    print("  CustomException creation test passed!")


def test_rq_user_error_creation() raises:
    """Test that RQUserError can be created."""
    var err = RQUserError.create("user error message")
    print("  RQUserError creation test passed!")


def test_rq_invalid_argument_creation() raises:
    """Test that RQInvalidArgument can be created."""
    var err = RQInvalidArgument.create("invalid argument")
    print("  RQInvalidArgument creation test passed!")


def test_rq_type_error_creation() raises:
    """Test that RQTypeError can be created."""
    var err = RQTypeError.create("type error")
    print("  RQTypeError creation test passed!")


def test_instrument_not_found_creation() raises:
    """Test that InstrumentNotFound can be created."""
    var err = InstrumentNotFound.create("000001.XSHE")
    print("  InstrumentNotFound creation test passed!")


def test_environment_not_initialized_creation() raises:
    """Test that EnvironmentNotInitialized can be created."""
    var err = EnvironmentNotInitialized.create()
    print("  EnvironmentNotInitialized creation test passed!")


def test_patch_functions() raises:
    """Test that patch functions work."""
    var result = patch_user_exc(EXC_TYPE.NOTSET)
    result = patch_system_exc(result)
    print("  Patch functions test passed!")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()