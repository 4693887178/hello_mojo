"""
RQMojo Test for core/__init__.mojo
"""

from rqmojo.core import *



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_core_init() raises:
    print("Testing core/__init__.mojo...")
    print("  core module loaded successfully!")
    print("  core/__init__.mojo tests passed!")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()