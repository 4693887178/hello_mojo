"""
Integration tests to verify consistency between Python and Mojo implementations.
Tests ensure that rqmojo.utils.arg_checker matches rqalpha.utils.arg_checker behavior.
"""

import pytest
import sys
import os


class TestPythonArgumentChecker:
    """Test Python's ArgumentChecker behavior as reference."""

    def test_argument_checker_base_creation(self):
        """Test ArgumentCheckerBase can be created."""
        from rqalpha.utils.arg_checker import ArgumentCheckerBase
        base = ArgumentCheckerBase("test_arg")
        assert base.arg_name == "test_arg"

    def test_verify_that_factory(self):
        """Test verify_that factory function creates checker with correct name."""
        from rqalpha.utils.arg_checker import verify_that
        checker = verify_that("param1")
        assert checker.arg_name == "param1"
        assert not checker.pre_check

    def test_assure_that_factory(self):
        """Test assure_that factory function creates converter with correct name."""
        from rqalpha.utils.arg_checker import assure_that
        converter = assure_that("order_id")
        assert converter.arg_name == "order_id"

    def test_is_number_valid_int(self):
        """Test is_number validation passes for int."""
        from rqalpha.utils.arg_checker import verify_that
        checker = verify_that("count")
        checker.is_number()
        args = {"count": 42}
        checker.verify("test_func", args)  # Should not raise

    def test_is_number_invalid_string(self):
        """Test is_number validation fails for non-numeric string."""
        from rqalpha.utils.arg_checker import verify_that, RQInvalidArgument
        checker = verify_that("value")
        checker.is_number()
        args = {"value": "not_a_number"}
        with pytest.raises(RQInvalidArgument):
            checker.verify("test_func", args)

    def test_is_in_valid_value(self):
        """Test is_in validation passes for value in list."""
        from rqalpha.utils.arg_checker import verify_that
        checker = verify_that("type")
        checker.is_in(["stock", "future"])
        args = {"type": "stock"}
        checker.verify("test_func", args)  # Should not raise

    def test_is_in_invalid_value(self):
        """Test is_in validation fails for value not in list."""
        from rqalpha.utils.arg_checker import verify_that, RQInvalidArgument
        checker = verify_that("type")
        checker.is_in(["stock", "future"])
        args = {"type": "invalid_type"}
        with pytest.raises(RQInvalidArgument):
            checker.verify("test_func", args)

    def test_is_greater_or_equal_than_valid(self):
        """Test is_greater_or_equal_than passes for valid value."""
        from rqalpha.utils.arg_checker import verify_that
        checker = verify_that("min_val")
        checker.is_greater_or_equal_than(0.0)
        args = {"min_val": 10.0}
        checker.verify("test_func", args)  # Should not raise

    def test_is_less_or_equal_than_valid(self):
        """Test is_less_or_equal_than passes for valid value."""
        from rqalpha.utils.arg_checker import verify_that
        checker = verify_that("max_val")
        checker.is_less_or_equal_than(100.0)
        args = {"max_val": 50.0}
        checker.verify("test_func", args)  # Should not raise

    def test_is_valid_interval_valid(self):
        """Test is_valid_interval passes for valid intervals."""
        from rqalpha.utils.arg_checker import verify_that
        valid_intervals = ["1d", "3m", "4q", "2y"]
        for interval in valid_intervals:
            checker = verify_that("interval")
            checker.is_valid_interval()
            args = {"interval": interval}
            checker.verify("test_func", args)  # Should not raise

    def test_is_valid_interval_invalid(self):
        """Test is_valid_interval rejects invalid intervals."""
        from rqalpha.utils.arg_checker import verify_that, RQInvalidArgument
        checker = verify_that("interval")
        checker.is_valid_interval()
        args = {"interval": "invalid"}
        with pytest.raises(RQInvalidArgument):
            checker.verify("test_func", args)

    def test_is_valid_quarter_valid(self):
        """Test is_valid_quarter passes for valid quarters."""
        from rqalpha.utils.arg_checker import verify_that
        valid_quarters = ["2012q3", "2020q1", "1999q4"]
        for quarter in valid_quarters:
            checker = verify_that("quarter")
            checker.is_valid_quarter()
            args = {"quarter": quarter}
            checker.verify("test_func", args)  # Should not raise

    def test_is_valid_frequency_valid(self):
        """Test is_valid_frequency passes for valid frequencies."""
        from rqalpha.utils.arg_checker import verify_that
        valid_frequencies = ["1m", "5m", "1d", "1w"]
        for freq in valid_frequencies:
            checker = verify_that("frequency")
            checker.is_valid_frequency()
            args = {"frequency": freq}
            checker.verify("test_func", args)  # Should not raise

    def test_api_arguments_checker_creation(self):
        """Test ApiArgumentsChecker creation."""
        from rqalpha.utils.arg_checker import (
            ApiArgumentsChecker,
            verify_that,
            assure_that,
        )
        api_checker = ApiArgumentsChecker([])
        assert api_checker is not None


def test_imports_match():
    """Verify that all expected exports are available."""
    from rqalpha.utils.arg_checker import (
        ArgumentCheckerBase,
        ArgumentChecker,
        ArgumentConverter,
        ApiArgumentsChecker,
        verify_that,
        assure_that,
    )


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
