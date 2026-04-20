"""
Comprehensive unit tests for rqmojo.utils.arg_checker
Tests all functionality to ensure consistency with Python version.
"""

from std.testing import assert_equal, assert_true, TestSuite
from std.python import Python, PythonObject
from std.collections import Dict, List

from rqmojo.utils.arg_checker import (
    ArgumentCheckerBase,
    ArgumentChecker,
    ArgumentConverter,
    ApiArgumentsChecker,
    verify_that,
    assure_that,
)


def test_argument_checker_base_creation() raises:
    """Test ArgumentCheckerBase can be created."""
    var base = ArgumentCheckerBase("test_arg")
    assert_equal(base.arg_name(), "test_arg")
    print("[PASS] test_argument_checker_base_creation")


def test_argument_checker_base_write_to() raises:
    """Test ArgumentCheckerBase write_to method."""
    var base = ArgumentCheckerBase("my_param")
    var result = String.write(base)
    print("[INFO] Base repr:", result)
    assert_true(result.find("ArgumentCheckerBase") != -1)
    print("[PASS] test_argument_checker_base_write_to")


def test_argument_checker_creation() raises:
    """Test ArgumentChecker creation with default pre_check=False."""
    var checker = ArgumentChecker("param1")
    assert_equal(checker.arg_name(), "param1")
    assert_true(not checker.pre_check())
    print("[PASS] test_argument_checker_creation")


def test_argument_checker_pre_check() raises:
    """Test ArgumentChecker with pre_check=True."""
    var checker = ArgumentChecker("pre_param", True)
    assert_true(checker.pre_check())
    print("[PASS] test_argument_checker_pre_check")


def test_is_number_valid() raises:
    """Test is_number validation passes for valid numbers."""
    var checker = ArgumentChecker("count")
    checker.is_number()

    var args = Dict[String, PythonObject]()
    args["count"] = PythonObject(42)

    try:
        checker.verify("test_func", args)
        print("[PASS] test_is_number_valid (int)")
    except e:
        raise Error("Should not raise error for valid int: " + String(e))


def test_is_number_valid_float() raises:
    """Test is_number validation passes for valid float."""
    var checker = ArgumentChecker("price")
    checker.is_number()

    var args = Dict[String, PythonObject]()
    args["price"] = PythonObject(3.14)

    try:
        checker.verify("test_func", args)
        print("[PASS] test_is_number_valid_float")
    except e:
        raise Error("Should not raise error for valid float: " + String(e))


def test_is_number_invalid_string() raises:
    """Test is_number validation fails for non-numeric string."""
    var checker = ArgumentChecker("value")
    checker.is_number()

    var args = Dict[String, PythonObject]()
    args["value"] = PythonObject("not_a_number")

    var raised_error: Bool = False
    try:
        checker.verify("test_func", args)
    except e:
        raised_error = True

    if not raised_error:
        raise Error("Expected RQInvalidArgument for invalid number string")

    print("[PASS] test_is_number_invalid_string")


def test_is_in_valid_value() raises:
    """Test is_in validation passes for value in list."""
    var checker = ArgumentChecker("type")
    var valid_values: PythonObject = Python.list("stock", "future", "fund")
    checker.is_in(valid_values)

    var args = Dict[String, PythonObject]()
    args["type"] = PythonObject("stock")

    try:
        checker.verify("test_func", args)
        print("[PASS] test_is_in_valid_value")
    except e:
        raise Error("Should not raise error for valid value: " + String(e))


def test_is_in_invalid_value() raises:
    """Test is_in validation fails for value not in list."""
    var checker = ArgumentChecker("type")
    var valid_values: PythonObject = Python.list("stock", "future")
    checker.is_in(valid_values)

    var args = Dict[String, PythonObject]()
    args["type"] = PythonObject("invalid_type")

    var raised_error: Bool = False
    try:
        checker.verify("test_func", args)
    except e:
        raised_error = True

    if not raised_error:
        raise Error("Expected RQInvalidArgument for invalid value in is_in")

    print("[PASS] test_is_in_invalid_value")


def test_is_in_ignore_none() raises:
    """Test is_in ignores None when ignore_none=True."""
    var checker = ArgumentChecker("optional")
    var valid_values: PythonObject = Python.list("a", "b")
    checker.is_in(valid_values, ignore_none=True)

    var args = Dict[String, PythonObject]()
    args["optional"] = Python.none()

    try:
        checker.verify("test_func", args)
        print("[PASS] test_is_in_ignore_none")
    except e:
        raise Error("Should ignore None values: " + String(e))


def test_is_valid_interval_valid() raises:
    """Test is_valid_interval passes for valid intervals."""
    var valid_intervals = List[String]()
    valid_intervals.append("1d")
    valid_intervals.append("3m")
    valid_intervals.append("4q")
    valid_intervals.append("2y")

    for i in range(len(valid_intervals)):
        var interval = valid_intervals[i]
        var checker = ArgumentChecker("interval")
        checker.is_valid_interval()

        var args = Dict[String, PythonObject]()
        args["interval"] = PythonObject(interval)

        try:
            checker.verify("test_func", args)
        except e:
            raise Error("Should accept interval '" + interval + "': " + String(e))

    print("[PASS] test_is_valid_interval_valid")


def test_is_valid_interval_invalid() raises:
    """Test is_valid_interval rejects invalid intervals."""
    var checker = ArgumentChecker("interval")
    checker.is_valid_interval()

    var args = Dict[String, PythonObject]()
    args["interval"] = PythonObject("invalid")

    var raised_error: Bool = False
    try:
        checker.verify("test_func", args)
    except e:
        raised_error = True

    if not raised_error:
        raise Error("Expected RQInvalidArgument for invalid interval")

    print("[PASS] test_is_valid_interval_invalid")


def test_is_valid_quarter_valid() raises:
    """Test is_valid_quarter passes for valid quarters."""
    var valid_quarters = List[String]()
    valid_quarters.append("2012q3")
    valid_quarters.append("2020q1")
    valid_quarters.append("1999q4")

    for i in range(len(valid_quarters)):
        var quarter = valid_quarters[i]
        var checker = ArgumentChecker("quarter")
        checker.is_valid_quarter()

        var args = Dict[String, PythonObject]()
        args["quarter"] = PythonObject(quarter)

        try:
            checker.verify("test_func", args)
        except e:
            raise Error("Should accept quarter '" + quarter + "': " + String(e))

    # Test None case
    var checker_none = ArgumentChecker("quarter")
    checker_none.is_valid_quarter()
    var args_none = Dict[String, PythonObject]()
    args_none["quarter"] = Python.none()
    try:
        checker_none.verify("test_func", args_none)
    except e:
        raise Error("Should accept None for quarter: " + String(e))

    print("[PASS] test_is_valid_quarter_valid")


def test_is_valid_frequency_valid() raises:
    """Test is_valid_frequency passes for valid frequencies."""
    var valid_frequencies = List[String]()
    valid_frequencies.append("1m")
    valid_frequencies.append("5m")
    valid_frequencies.append("1d")
    valid_frequencies.append("1w")
    valid_frequencies.append("15m")

    for i in range(len(valid_frequencies)):
        var freq = valid_frequencies[i]
        var checker = ArgumentChecker("frequency")
        checker.is_valid_frequency()

        var args = Dict[String, PythonObject]()
        args["frequency"] = PythonObject(freq)

        try:
            checker.verify("test_func", args)
        except e:
            raise Error("Should accept frequency '" + freq + "': " + String(e))

    print("[PASS] test_is_valid_frequency_valid")


def test_is_valid_frequency_invalid() raises:
    """Test is_valid_frequency rejects invalid frequencies."""
    var checker = ArgumentChecker("frequency")
    checker.is_valid_frequency()

    var args = Dict[String, PythonObject]()
    args["frequency"] = PythonObject("1h")  # 'h' is not valid

    var raised_error: Bool = False
    try:
        checker.verify("test_func", args)
    except e:
        raised_error = True

    if not raised_error:
        raise Error("Expected RQInvalidArgument for invalid frequency '1h'")

    print("[PASS] test_is_valid_frequency_invalid")


def test_is_greater_or_equal_than_valid() raises:
    """Test is_greater_or_equal_than passes for valid value."""
    var checker = ArgumentChecker("min_value")
    checker.is_greater_or_equal_than(0.0)

    var args = Dict[String, PythonObject]()
    args["min_value"] = PythonObject(10.0)

    try:
        checker.verify("test_func", args)
        print("[PASS] test_is_greater_or_equal_than_valid")
    except e:
        raise Error("Should accept value >= 0: " + String(e))


def test_is_less_or_equal_than_valid() raises:
    """Test is_less_or_equal_than passes for valid value."""
    var checker = ArgumentChecker("max_value")
    checker.is_less_or_equal_than(100.0)

    var args = Dict[String, PythonObject]()
    args["max_value"] = PythonObject(50.0)

    try:
        checker.verify("test_func", args)
        print("[PASS] test_is_less_or_equal_than_valid")
    except e:
        raise Error("Should accept value <= 100: " + String(e))


def test_verify_that_factory() raises:
    """Test verify_that factory function."""
    var checker = verify_that("param")
    assert_equal(checker.arg_name(), "param")
    print("[PASS] test_verify_that_factory")


def test_assure_that_factory() raises:
    """Test assure_that factory function."""
    var converter = assure_that("order_id")
    assert_equal(converter.arg_name(), "order_id")
    print("[PASS] test_assure_that_factory")


def test_api_arguments_checker_creation() raises:
    """Test ApiArgumentsChecker creation and methods."""
    var api_checker = ApiArgumentsChecker()
    api_checker.add_checker(ArgumentChecker("arg1"))
    api_checker.add_converter(ArgumentConverter("conv1"))

    print("[PASS] test_api_arguments_checker_creation")


def test_argument_converter_creation() raises:
    """Test ArgumentConverter creation."""
    var converter = ArgumentConverter("instrument_id")
    assert_equal(converter.arg_name(), "instrument_id")
    print("[PASS] test_argument_converter_creation")


def test_multiple_rules_combined() raises:
    """Test combining multiple validation rules."""
    var checker = ArgumentChecker("config")
    checker.is_number()
    checker.is_greater_or_equal_than(0.0)
    checker.is_less_or_equal_than(100.0)

    var args = Dict[String, PythonObject]()
    args["config"] = PythonObject(50.0)

    try:
        checker.verify("configure", args)
        print("[PASS] test_multiple_rules_combined - valid case")
    except e:
        raise Error("Should pass all validations: " + String(e))

    # Test invalid case (value > 100)
    var args2 = Dict[String, PythonObject]()
    args2["config"] = PythonObject(150.0)

    var raised_error: Bool = False
    try:
        checker.verify("configure", args2)
    except e:
        raised_error = True

    if not raised_error:
        raise Error("Expected RQInvalidArgument for value > 100")

    print("[PASS] test_multiple_rules_combined - invalid case rejected")


def main() raises:
    """Run all tests."""
    print("=" * 60)
    print("Running rqmojo.utils.arg_checker Unit Tests")
    print("=" * 60)
    print("")

    test_argument_checker_base_creation()
    test_argument_checker_base_write_to()
    test_argument_checker_creation()
    test_argument_checker_pre_check()
    test_is_number_valid()
    test_is_number_valid_float()
    test_is_number_invalid_string()
    test_is_in_valid_value()
    test_is_in_invalid_value()
    test_is_in_ignore_none()
    test_is_valid_interval_valid()
    test_is_valid_interval_invalid()
    test_is_valid_quarter_valid()
    test_is_valid_frequency_valid()
    test_is_valid_frequency_invalid()
    test_is_greater_or_equal_than_valid()
    test_is_less_or_equal_than_valid()
    test_verify_that_factory()
    test_assure_that_factory()
    test_api_arguments_checker_creation()
    test_argument_converter_creation()
    test_multiple_rules_combined()

    print("")
    print("=" * 60)
    print("All tests passed successfully!")
    print("=" * 60)
