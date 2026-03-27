"""
Test for mod/rqmojo_mod_sys_simulation/testing.mojo
Group 09 - File 7
"""

from std.collections import Dict, List

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_testing_module_exists() raises:
    print("Test: testing module exists")
    from rqmojo.mod.rqmojo_mod_sys_simulation import testing
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
