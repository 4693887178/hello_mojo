"""
Test for mod/rqmojo_mod_sys_analyser/__init__.mojo
Group 07 - File 03
"""

from std.python import PythonObject
from rqmojo.mod.rqmojo_mod_sys_analyser import AnalyserConfig, create_config, get_cli_prefix

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_config_exists() raises:
    print("Test: AnalyserConfig exists")
    var config = create_config()
    print("  PASSED")


def test_config_defaults() raises:
    print("Test: AnalyserConfig defaults")
    var config = create_config()
    assert_true(config.record, "record should be True by default")
    assert_false(config.plot, "plot should be False by default")
    print("  PASSED")


def test_cli_prefix() raises:
    print("Test: cli_prefix constant")
    var prefix = get_cli_prefix()
    assert_equal(prefix, "mod__sys_analyser__", "cli_prefix should match")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
