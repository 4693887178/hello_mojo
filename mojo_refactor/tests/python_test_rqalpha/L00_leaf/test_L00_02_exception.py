# test_L00_02_exception.py
# Module: rqalpha.utils.exception
# Mojo: rqmojo.utils.exception
# Level: L00 - Leaf module
# Dependencies: const

import pytest
from rqalpha.utils import exception
from rqalpha.const import EXC_TYPE


class TestL00Exception:
    """L00 - exception module tests"""

    class TestCustomError:
        """CustomError class tests"""

        def test_init(self):
            """Test CustomError initialization"""
            error = exception.CustomError()
            assert error.stacks == []
            assert error.msg is None
            assert error.exc_type is None
            assert error.exc_val is None
            assert error.exc_tb is None
            assert error.error_type == EXC_TYPE.NOTSET

        def test_set_msg(self):
            """Test set_msg method"""
            error = exception.CustomError()
            error.set_msg("Test error message")
            assert error.msg == "Test error message"

        def test_add_stack_info(self):
            """Test add_stack_info method"""
            error = exception.CustomError()
            error.add_stack_info("test.py", 10, "test_func", "x = 1", {"x": 1})
            assert error.stacks_length == 1
            assert error.stacks[0][0] == "test.py"
            assert error.stacks[0][1] == 10

        def test_repr_empty(self):
            """Test __repr__ with empty stacks"""
            error = exception.CustomError()
            error.set_msg("Test message")
            assert repr(error) == "Test message"

        def test_repr_with_stacks(self):
            """Test __repr__ with stacks"""
            error = exception.CustomError()
            error.set_msg("Test error")
            error.add_stack_info("test.py", 10, "test_func", "x = 1", {})
            result = repr(error)
            assert "Traceback" in result
            assert "test.py" in result

    class TestCustomException:
        """CustomException class tests"""

        def test_init(self):
            """Test CustomException initialization"""
            error = exception.CustomError()
            error.set_msg("Test error")
            exc = exception.CustomException(error)
            assert exc.error == error

    class TestRQUserError:
        """RQUserError class tests"""

        def test_init(self):
            """Test RQUserError initialization"""
            exc = exception.RQUserError("User error occurred")
            assert str(exc) == "User error occurred"
            assert exc.ricequant_exc == EXC_TYPE.USER_EXC

        def test_inheritance(self):
            """Test RQUserError inheritance"""
            exc = exception.RQUserError("test")
            assert isinstance(exc, Exception)

    class TestRQInvalidArgument:
        """RQInvalidArgument class tests"""

        def test_init(self):
            """Test RQInvalidArgument initialization"""
            exc = exception.RQInvalidArgument("Invalid argument value")
            assert str(exc) == "Invalid argument value"

        def test_inheritance(self):
            """Test RQInvalidArgument inheritance"""
            exc = exception.RQInvalidArgument("test")
            assert isinstance(exc, exception.RQUserError)
            assert isinstance(exc, Exception)

    class TestRQTypeError:
        """RQTypeError class tests"""

        def test_init(self):
            """Test RQTypeError initialization"""
            exc = exception.RQTypeError("Type mismatch")
            assert str(exc) == "Type mismatch"

        def test_inheritance(self):
            """Test RQTypeError inheritance"""
            exc = exception.RQTypeError("test")
            assert isinstance(exc, exception.RQUserError)

    class TestRQApiNotSupportedError:
        """RQApiNotSupportedError class tests"""

        def test_init(self):
            """Test RQApiNotSupportedError initialization"""
            exc = exception.RQApiNotSupportedError("API not supported")
            assert str(exc) == "API not supported"

        def test_inheritance(self):
            """Test RQApiNotSupportedError inheritance"""
            exc = exception.RQApiNotSupportedError("test")
            assert isinstance(exc, exception.RQUserError)

    class TestRQDatacVersionTooLow:
        """RQDatacVersionTooLow class tests"""

        def test_init(self):
            """Test RQDatacVersionTooLow initialization"""
            exc = exception.RQDatacVersionTooLow("Version 1.0 required")
            assert str(exc) == "Version 1.0 required"

        def test_inheritance(self):
            """Test RQDatacVersionTooLow inheritance"""
            exc = exception.RQDatacVersionTooLow("test")
            assert isinstance(exc, RuntimeError)

    class TestInstrumentNotFound:
        """InstrumentNotFound class tests"""

        def test_init(self):
            """Test InstrumentNotFound initialization"""
            exc = exception.InstrumentNotFound("000001.XSHE not found")
            assert str(exc) == "000001.XSHE not found"

        def test_inheritance(self):
            """Test InstrumentNotFound inheritance"""
            exc = exception.InstrumentNotFound("test")
            assert isinstance(exc, LookupError)

    class TestEnvironmentNotInitialized:
        """EnvironmentNotInitialized class tests"""

        def test_init(self):
            """Test EnvironmentNotInitialized initialization"""
            exc = exception.EnvironmentNotInitialized("Environment not ready")
            assert str(exc) == "Environment not ready"

        def test_inheritance(self):
            """Test EnvironmentNotInitialized inheritance"""
            exc = exception.EnvironmentNotInitialized("test")
            assert isinstance(exc, RuntimeError)

    class TestPatchUserExc:
        """patch_user_exc function tests"""

        def test_patch_user_exc(self):
            """Test patch_user_exc function"""
            exc = Exception("test")
            result = exception.patch_user_exc(exc)
            assert getattr(result, exception.EXC_EXT_NAME) == EXC_TYPE.USER_EXC

        def test_patch_user_exc_force(self):
            """Test patch_user_exc with force"""
            exc = Exception("test")
            exception.patch_system_exc(exc)
            exception.patch_user_exc(exc, force=True)
            assert getattr(exc, exception.EXC_EXT_NAME) == EXC_TYPE.USER_EXC

    class TestPatchSystemExc:
        """patch_system_exc function tests"""

        def test_patch_system_exc(self):
            """Test patch_system_exc function"""
            exc = Exception("test")
            result = exception.patch_system_exc(exc)
            assert getattr(result, exception.EXC_EXT_NAME) == EXC_TYPE.SYSTEM_EXC

    class TestIsUserExc:
        """is_user_exc function tests"""

        def test_is_user_exc_true(self):
            """Test is_user_exc returns True"""
            exc = Exception("test")
            exception.patch_user_exc(exc)
            assert exception.is_user_exc(exc) == True

        def test_is_user_exc_false(self):
            """Test is_user_exc returns False"""
            exc = Exception("test")
            exception.patch_system_exc(exc)
            assert exception.is_user_exc(exc) == False

    class TestIsSystemExc:
        """is_system_exc function tests"""

        def test_is_system_exc_true(self):
            """Test is_system_exc returns True"""
            exc = Exception("test")
            exception.patch_system_exc(exc)
            assert exception.is_system_exc(exc) == True

        def test_is_system_exc_false(self):
            """Test is_system_exc returns False"""
            exc = Exception("test")
            exception.patch_user_exc(exc)
            assert exception.is_system_exc(exc) == False

    class TestExceptionGroup:
        """ExceptionGroup class tests"""

        def test_init(self):
            """Test ExceptionGroup initialization"""
            exc1 = ValueError("error 1")
            exc2 = TypeError("error 2")
            group = exception.ExceptionGroup("Multiple errors", [exc1, exc2])
            assert group.message == "Multiple errors"
            assert len(group.exceptions) == 2

        def test_str(self):
            """Test ExceptionGroup string representation"""
            exc1 = ValueError("error 1")
            group = exception.ExceptionGroup("Test", [exc1])
            assert "Test" in str(group)
            assert "1 sub-exception" in str(group)

        def test_split(self):
            """Test ExceptionGroup split method"""
            exc1 = ValueError("error 1")
            exc2 = TypeError("error 2")
            group = exception.ExceptionGroup("Test", [exc1, exc2])
            match, non_match = group.split(ValueError)
            assert match is not None
            assert non_match is not None
