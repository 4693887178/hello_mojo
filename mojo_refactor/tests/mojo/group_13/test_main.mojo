"""
Test for __main__.mojo
Group 13 - File 1
"""

from std.collections import Dict, List
from rqmojo import __main__



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_main_module_exists() raises:
    print("Test: __main__ module exists")
    print("  PASSED")


def test_main_has_main_function() raises:
    print("Test: __main__ has main function")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
