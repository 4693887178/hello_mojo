"""
RQAlpha Mojo - Deprecated Module Test
Tests for data/base_data_source/deprecated.mojo
"""

from std.collections import List
from rqmojo.data.base_data_source.deprecated import (
    deprecated_get_price, deprecated_get_volume,
    DeprecatedWarning, warn_deprecated,
    InstrumentStore, create_instrument_store
)
from rqmojo.const import INSTRUMENT_TYPE



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_deprecated_get_price() raises:
    """Test that deprecated_get_price returns 0.0."""
    var price = deprecated_get_price("000001.XSHE", "2024-01-01")
    assert_equal(price, 0.0, "deprecated_get_price should return 0.0")
    print("  deprecated_get_price test passed!")


def test_deprecated_get_volume() raises:
    """Test that deprecated_get_volume returns 0."""
    var volume = deprecated_get_volume("000001.XSHE", "2024-01-01")
    assert_equal(volume, 0, "deprecated_get_volume should return 0")
    print("  deprecated_get_volume test passed!")


def test_deprecated_warning_creation() raises:
    """Test that DeprecatedWarning can be created."""
    var warning = DeprecatedWarning(
        function_name="old_function",
        message="Use new_function instead",
        since_version="1.0.0",
        removed_in_version="2.0.0"
    )
    assert_equal(warning.function_name, "old_function", "function_name should match")
    print("  DeprecatedWarning creation test passed!")


def test_warn_deprecated() raises:
    """Test that warn_deprecated function works."""
    var warning = DeprecatedWarning(
        function_name="test_func",
        message="This is deprecated",
        since_version="1.0.0",
        removed_in_version="2.0.0"
    )
    warn_deprecated(warning)
    print("  warn_deprecated test passed!")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()