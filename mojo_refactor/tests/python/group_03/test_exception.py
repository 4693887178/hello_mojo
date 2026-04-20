# -*- coding: utf-8 -*-
"""
Test for rqalpha/utils/exception.py
Tests for exception handling classes
"""

import pytest


class TestCustomError:
    """Tests for CustomError class"""

    def test_custom_error_class_exists(self):
        """Test that CustomError class exists"""
        from rqalpha.utils.exception import CustomError
        assert CustomError is not None

    def test_custom_error_stacks(self):
        """Test that CustomError has stacks attribute"""
        from rqalpha.utils.exception import CustomError
        ce = CustomError()
        assert hasattr(ce, 'stacks')

    def test_custom_error_msg(self):
        """Test that CustomError has msg attribute"""
        from rqalpha.utils.exception import CustomError
        ce = CustomError()
        assert hasattr(ce, 'msg')

    def test_custom_error_add_stack_info(self):
        """Test that add_stack_info method exists"""
        from rqalpha.utils.exception import CustomError
        ce = CustomError()
        assert hasattr(ce, 'add_stack_info')


class TestCustomException:
    """Tests for CustomException class"""

    def test_custom_exception_class_exists(self):
        """Test that CustomException class exists"""
        from rqalpha.utils.exception import CustomException
        assert CustomException is not None


class TestRQUserError:
    """Tests for RQUserError class"""

    def test_rq_user_error_class_exists(self):
        """Test that RQUserError class exists"""
        from rqalpha.utils.exception import RQUserError
        assert RQUserError is not None

    def test_rq_user_error_is_exception(self):
        """Test that RQUserError is an Exception"""
        from rqalpha.utils.exception import RQUserError
        assert issubclass(RQUserError, Exception)


class TestRQInvalidArgument:
    """Tests for RQInvalidArgument class"""

    def test_rq_invalid_argument_class_exists(self):
        """Test that RQInvalidArgument class exists"""
        from rqalpha.utils.exception import RQInvalidArgument
        assert RQInvalidArgument is not None

    def test_rq_invalid_argument_is_rq_user_error(self):
        """Test that RQInvalidArgument is a RQUserError"""
        from rqalpha.utils.exception import RQInvalidArgument, RQUserError
        assert issubclass(RQInvalidArgument, RQUserError)


class TestRQTypeError:
    """Tests for RQTypeError class"""

    def test_rq_type_error_class_exists(self):
        """Test that RQTypeError class exists"""
        from rqalpha.utils.exception import RQTypeError
        assert RQTypeError is not None


class TestRQApiNotSupportedError:
    """Tests for RQApiNotSupportedError class"""

    def test_rq_api_not_supported_error_class_exists(self):
        """Test that RQApiNotSupportedError class exists"""
        from rqalpha.utils.exception import RQApiNotSupportedError
        assert RQApiNotSupportedError is not None


class TestInstrumentNotFound:
    """Tests for InstrumentNotFound class"""

    def test_instrument_not_found_class_exists(self):
        """Test that InstrumentNotFound class exists"""
        from rqalpha.utils.exception import InstrumentNotFound
        assert InstrumentNotFound is not None

    def test_instrument_not_found_is_lookup_error(self):
        """Test that InstrumentNotFound is a LookupError"""
        from rqalpha.utils.exception import InstrumentNotFound
        assert issubclass(InstrumentNotFound, LookupError)


class TestEnvironmentNotInitialized:
    """Tests for EnvironmentNotInitialized class"""

    def test_environment_not_initialized_class_exists(self):
        """Test that EnvironmentNotInitialized class exists"""
        from rqalpha.utils.exception import EnvironmentNotInitialized
        assert EnvironmentNotInitialized is not None

    def test_environment_not_initialized_is_runtime_error(self):
        """Test that EnvironmentNotInitialized is a RuntimeError"""
        from rqalpha.utils.exception import EnvironmentNotInitialized
        assert issubclass(EnvironmentNotInitialized, RuntimeError)


class TestExceptionGroup:
    """Tests for ExceptionGroup class"""

    def test_exception_group_class_exists(self):
        """Test that ExceptionGroup class exists"""
        from rqalpha.utils.exception import ExceptionGroup
        assert ExceptionGroup is not None


class TestPatchFunctions:
    """Tests for patch functions"""

    def test_patch_user_exc_exists(self):
        """Test that patch_user_exc function exists"""
        from rqalpha.utils.exception import patch_user_exc
        assert callable(patch_user_exc)

    def test_patch_system_exc_exists(self):
        """Test that patch_system_exc function exists"""
        from rqalpha.utils.exception import patch_system_exc
        assert callable(patch_system_exc)

    def test_is_user_exc_exists(self):
        """Test that is_user_exc function exists"""
        from rqalpha.utils.exception import is_user_exc
        assert callable(is_user_exc)

    def test_is_system_exc_exists(self):
        """Test that is_system_exc function exists"""
        from rqalpha.utils.exception import is_system_exc
        assert callable(is_system_exc)
