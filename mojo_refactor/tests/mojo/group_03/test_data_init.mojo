"""
RQAlpha Mojo - Data Package Init Test
Tests for data/__init__.mojo
"""

from rqmojo.data import DataProxy



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_data_module_imports() raises:
    """Test that data module can be imported."""
    print("  data module imports test passed!")


def test_data_proxy_import() raises:
    """Test that DataProxy can be imported."""
    print("  DataProxy import test passed!")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()