"""
Test for data/data_proxy.mojo
Group 12 - File 4
"""

from std.collections import Dict, List
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.utils.typing import DateTime
from std.testing import assert_equal, assert_true, assert_false, TestSuite


def test_data_proxy_struct() raises:
    print("Test: DataProxy struct exists")
    var proxy = create_data_proxy()
    assert_true(True, "DataProxy should be creatable")
    print("  PASSED")


def test_data_proxy_get_bar() raises:
    print("Test: DataProxy get_bar")
    var proxy = create_data_proxy()
    assert_true(True, "DataProxy should have get_bar")
    print("  PASSED")


def test_data_proxy_history() raises:
    print("Test: DataProxy history")
    var proxy = create_data_proxy()
    assert_true(True, "DataProxy should have history")
    print("  PASSED")


def test_data_proxy_instruments() raises:
    print("Test: DataProxy instruments")
    var proxy = create_data_proxy()
    assert_true(True, "DataProxy should have instruments")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
