"""
Test for data/base_data_source/data_source.mojo
Group 09 - File 6
"""

from rqmojo.data.base_data_source import BaseDataSource, create_base_data_source
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_base_data_source_init() raises:
    print("Test: BaseDataSource init")
    var _ = create_base_data_source()
    print("  PASSED")


def test_base_data_source_get_bar() raises:
    print("Test: BaseDataSource get_bar")
    var source = create_base_data_source()
    var _ = source.get_bar("000001.XSHE", DateTime(2024, 1, 2, 0, 0, 0, 0))
    print("  PASSED")


def test_base_data_source_get_instrument() raises:
    print("Test: BaseDataSource get_instrument")
    var source = create_base_data_source()
    var _ = source.get_instrument("000001.XSHE")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
