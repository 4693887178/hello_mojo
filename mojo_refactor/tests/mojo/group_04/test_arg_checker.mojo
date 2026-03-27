"""
第四组测试 - utils/arg_checker.mojo
测试Mojo版本的参数检查模块
"""

from rqmojo.utils.arg_checker import (
    check_string,
    check_int,
    check_float,
    check_percentage,
    check_order_book_id,
)


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_check_string_valid() raises:
    try:
        var result = check_string("hello", "test_arg")
        assert_true(result, "check_string should pass")
    except:
        assert_true(False, "check_string should not raise")


def test_check_string_empty() raises:
    try:
        check_string("", "test_arg")
        assert_true(False, "should raise for empty string")
    except:
        assert_true(True, "raised as expected")


def test_check_int_valid() raises:
    try:
        var result = check_int(42, "test_arg")
        assert_true(result, "check_int should pass")
    except:
        assert_true(False, "check_int should not raise")


def test_check_int_with_range() raises:
    try:
        var result = check_int(50, "test_arg", 0, 100)
        assert_true(result, "check_int with range should pass")
    except:
        assert_true(False, "check_int with range should not raise")


def test_check_int_below_min() raises:
    try:
        check_int(-1, "test_arg", 0, 100)
        assert_true(False, "should raise for below min")
    except:
        assert_true(True, "raised as expected")


def test_check_int_above_max() raises:
    try:
        check_int(101, "test_arg", 0, 100)
        assert_true(False, "should raise for above max")
    except:
        assert_true(True, "raised as expected")


def test_check_float_valid() raises:
    try:
        var result = check_float(3.14, "test_arg")
        assert_true(result, "check_float should pass")
    except:
        assert_true(False, "check_float should not raise")


def test_check_float_with_range() raises:
    try:
        var result = check_float(0.5, "test_arg", 0.0, 1.0)
        assert_true(result, "check_float with range should pass")
    except:
        assert_true(False, "check_float with range should not raise")


def test_check_percentage_valid() raises:
    try:
        var result = check_percentage(0.5, "test_arg")
        assert_true(result, "check_percentage should pass")
    except:
        assert_true(False, "check_percentage should not raise")


def test_check_percentage_invalid() raises:
    try:
        check_percentage(1.5, "test_arg")
        assert_true(False, "should raise for invalid percentage")
    except:
        assert_true(True, "raised as expected")


def test_check_order_book_id_valid() raises:
    try:
        var result = check_order_book_id("000001.XSHE", "test_arg")
        assert_true(result, "check_order_book_id should pass")
    except:
        assert_true(False, "check_order_book_id should not raise")


def test_check_order_book_id_invalid() raises:
    try:
        check_order_book_id("invalid", "test_arg")
        assert_true(False, "should raise for invalid order_book_id")
    except:
        assert_true(True, "raised as expected")


def test_check_order_book_id_empty() raises:
    try:
        check_order_book_id("", "test_arg")
        assert_true(False, "should raise for empty order_book_id")
    except:
        assert_true(True, "raised as expected")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
