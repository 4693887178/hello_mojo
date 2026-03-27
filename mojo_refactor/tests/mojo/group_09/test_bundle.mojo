"""
Test for cmds/bundle.mojo
Group 09 - File 1
"""

from rqmojo.cmds.bundle import BundleCommand, create_bundle_command
from std.collections import Dict

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_bundle_command_init() raises:
    print("Test: BundleCommand init")
    var _ = create_bundle_command()
    print("  PASSED")


def test_bundle_command_name() raises:
    print("Test: BundleCommand name")
    var cmd = create_bundle_command()
    assert_equal(cmd.name, "bundle", "Command name should be 'bundle'")
    print("  PASSED")


def test_bundle_command_help() raises:
    print("Test: BundleCommand help")
    var cmd = create_bundle_command()
    var _ = cmd.help()
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
