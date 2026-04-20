"""
Test for utils/__init__.mojo
Group 10 - File 9
"""

from std.collections import Dict, List
from rqmojo.utils import (
    RqValue, KIND_INT, KIND_FLOAT, KIND_STRING, KIND_BOOL, KIND_DICT, KIND_LIST,
    make_int_value, make_float_value, make_string_value, make_bool_value
)
from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def test_rq_value_int() raises:
    print("Test: RqValue int type")
    var val = make_int_value(42)
    assert_equal(val.kind, KIND_INT, "Kind should be INT")
    assert_equal(val.int_val, 42, "Int value should match")
    print("  PASSED")


def test_rq_value_float() raises:
    print("Test: RqValue float type")
    var val = make_float_value(3.14)
    assert_equal(val.kind, KIND_FLOAT, "Kind should be FLOAT")
    assert_true(val.float_val > 3.0, "Float value should be greater than 3.0")
    print("  PASSED")


def test_rq_value_string() raises:
    print("Test: RqValue string type")
    var val = make_string_value("test")
    assert_equal(val.kind, KIND_STRING, "Kind should be STRING")
    assert_equal(val.string_val, "test", "String value should match")
    print("  PASSED")


def test_rq_value_bool() raises:
    print("Test: RqValue bool type")
    var val = make_bool_value(True)
    assert_equal(val.kind, KIND_BOOL, "Kind should be BOOL")
    assert_true(val.bool_val, "Bool value should be True")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
