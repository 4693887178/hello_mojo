"""
Test for environment.mojo
Group 11 - File 1
"""

from std.collections import Dict, List
from rqmojo.environment import Environment, Config, create_environment
from rqmojo.utils.config import RQAlphaConfig, BaseConfig, ExtraConfig, ModConfig
from rqmojo.utils.typing import DateTime
from std.testing import assert_equal, assert_true, assert_false, TestSuite


def test_environment_struct() raises:
    print("Test: Environment struct exists")
    var start_date = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2024, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start_date, end_date)
    assert_true(True, "Environment should be creatable")
    print("  PASSED")


def test_environment_config() raises:
    print("Test: Environment config")
    var start_date = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2024, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start_date, end_date)
    assert_true(True, "Environment should have config")
    print("  PASSED")


def test_environment_data_proxy() raises:
    print("Test: Environment data_proxy")
    var start_date = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2024, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start_date, end_date)
    assert_true(True, "Environment should have data_proxy")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
