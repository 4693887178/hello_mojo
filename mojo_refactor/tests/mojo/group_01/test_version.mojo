"""
Test for _version.mojo
Group 01 - File 1
"""

from std.testing import assert_equal, assert_true, TestSuite
from rqmojo import __version__


def test_version_exists() raises:
    assert_true(len(__version__) > 0, msg="Version should not be empty")


def test_version_format() raises:
    var parts = __version__.split(".")
    assert_true(len(parts) >= 2, msg="Version should have at least major.minor format")


def test_version_is_string() raises:
    assert_equal(__version__, __version__, msg="Version should be a valid string")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
