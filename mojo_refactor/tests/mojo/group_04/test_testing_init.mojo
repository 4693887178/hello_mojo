"""
第四组测试 - utils/testing/__init__.mojo
测试Mojo版本的测试工具模块
"""

from rqmojo.utils.testing import RQAlphaTestCase


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_RQAlphaTestCase_exists() raises:
    var _ = RQAlphaTestCase()
    assert_true(True, "RQAlphaTestCase exists")


def test_init_fixture_exists() raises:
    var tc = RQAlphaTestCase()
    tc.init_fixture()
    assert_true(True, "init_fixture works")


def test_assert_equal() raises:
    var tc = RQAlphaTestCase()
    var result = tc.assert_equal(42, 42, "test equal")
    assert_true(result, "assert_equal should pass")


def test_assert_equal_float() raises:
    var tc = RQAlphaTestCase()
    var result = tc.assert_equal_float(3.14, 3.14, "test float equal")
    assert_true(result, "assert_equal_float should pass")


def test_assert_equal_string() raises:
    var tc = RQAlphaTestCase()
    var result = tc.assert_equal_string("hello", "hello", "test string equal")
    assert_true(result, "assert_equal_string should pass")


def test_assert_true() raises:
    var tc = RQAlphaTestCase()
    var result = tc.assert_true(True, "test true")
    assert_true(result, "assert_true should pass")


def test_assert_false() raises:
    var tc = RQAlphaTestCase()
    var result = tc.assert_false(False, "test false")
    assert_true(result, "assert_false should pass")


def test_assert_equal_fail() raises:
    var tc = RQAlphaTestCase()
    var result = tc.assert_equal(1, 2, "expected fail")
    assert_false(result, "assert_equal should fail for different values")


def test_assert_true_fail() raises:
    var tc = RQAlphaTestCase()
    var result = tc.assert_true(False, "expected fail")
    assert_false(result, "assert_true should fail for False")


def test_assert_false_fail() raises:
    var tc = RQAlphaTestCase()
    var result = tc.assert_false(True, "expected fail")
    assert_false(result, "assert_false should fail for True")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
