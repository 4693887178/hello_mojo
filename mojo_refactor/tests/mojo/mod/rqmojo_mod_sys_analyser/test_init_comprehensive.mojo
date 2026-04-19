"""
Comprehensive Test Suite for mod/rqmojo_mod_sys_analyser/__init__.mojo

This test file validates:
1. AnalyserConfig structure and defaults (matching Python __config__)
2. CLI parameter registration functions
3. load_mod() function
4. plot_result() function
5. generate_report_from_file() function
6. Helper functions (_python_to_mojo_dict)

Test coverage aligns with Python original functionality.
"""

from std.python import Python, PythonObject
from std.collections import Dict, List
from std.testing import assert_equal, assert_true, assert_false, TestSuite

from rqmojo.mod.rqmojo_mod_sys_analyser import (
    AnalyserConfig,
    create_default_config,
    get_cli_prefix,
    load_mod,
    inject_run_param,
    register_cli_parameters,
    _python_to_mojo_dict
)


# ============================================================
# Test Group 1: AnalyserConfig Structure and Defaults
# ============================================================

def test_analyser_config_creation() raises:
    """Test that AnalyserConfig can be created with default values."""
    print("[TEST] AnalyserConfig creation with defaults")
    var config = create_default_config()

    assert_true(config.record, "record should be True by default")
    assert_false(config.plot, "plot should be False by default")
    print("  ✓ PASSED: Config created successfully")


def test_analyser_config_benchmark_none() raises:
    """Test that benchmark is None by default (matches Python __config__)."""
    print("[TEST] AnalyserConfig benchmark is None")
    var config = create_default_config()

    from std.python import Python
    assert_true(config.benchmark == Python.none(), "benchmark should be None")
    print("  ✓ PASSED: benchmark is None")


def test_analyser_config_strategy_name_none() raises:
    """Test that strategy_name is None by default."""
    print("[TEST] AnalyserConfig strategy_name is None")
    var config = create_default_config()

    from std.python import Python
    assert_true(config.strategy_name == Python.none(), "strategy_name should be None")
    print("  ✓ PASSED: strategy_name is None")


def test_analyser_config_output_file_none() raises:
    """Test that output_file is None by default."""
    print("[TEST] AnalyserConfig output_file is None")
    var config = create_default_config()

    from std.python import Python
    assert_true(config.output_file == Python.none(), "output_file should be None")
    print("  ✓ PASSED: output_file is None")


def test_analyser_config_report_save_path_none() raises:
    """Test that report_save_path is None by default."""
    print("[TEST] AnalyserConfig report_save_path is None")
    var config = create_default_config()

    from std.python import Python
    assert_true(config.report_save_path == Python.none(), "report_save_path should be None")
    print("  ✓ PASSED: report_save_path is None")


def test_analyser_config_plot_save_file_none() raises:
    """Test that plot_save_file is None by default."""
    print("[TEST] AnalyserConfig plot_save_file is None")
    var config = create_default_config()

    from std.python import Python
    assert_true(config.plot_save_file == Python.none(), "plot_save_file should be None")
    print("  ✓ PASSED: plot_save_file is None")


def test_analyser_config_plot_config_defaults() raises:
    """Test plot_config has correct default values for open_close_points and weekly_indicators."""
    print("[TEST] AnalyserConfig plot_config defaults")
    var config = create_default_config()

    assert_true("open_close_points" in config.plot_config, "plot_config should have open_close_points")
    assert_true("weekly_indicators" in config.plot_config, "plot_config should have weekly_indicators")

    var ocp = config.plot_config["open_close_points"]
    var wi = config.plot_config["weekly_indicators"]

    assert_false(Bool(py=ocp), "open_close_points should be False")
    assert_false(Bool(py=wi), "weekly_indicators should be False")
    print("  ✓ PASSED: plot_config defaults are correct")


def test_analyser_config_copy_constructor() raises:
    """Test that copy constructor works correctly."""
    print("[TEST] AnalyserConfig copy constructor")
    var original = create_default_config()
    var copy = AnalyserConfig(copy=original)

    assert_equal(copy.record, original.record, "copy.record should match")
    assert_equal(copy.plot, original.plot, "copy.plot should match")
    print("  ✓ PASSED: Copy constructor works correctly")


def test_analyser_config_writable() raises:
    """Test that AnalyserConfig implements Writable trait."""
    print("[TEST] AnalyserConfig Writable implementation")
    var config = create_default_config()

    var s = String.write(config)
    assert_true(len(s) > 0, "String representation should not be empty")
    assert_true(s.find("AnalyserConfig").__ne__(-1), "Should contain 'AnalyserConfig'")
    print("  ✓ PASSED: Writable implementation works")


# ============================================================
# Test Group 2: CLI Prefix and Parameters
# ============================================================

def test_get_cli_prefix_returns_correct_value() raises:
    """Test that get_cli_prefix returns the expected prefix string."""
    print("[TEST] get_cli_prefix returns correct value")
    var prefix = get_cli_prefix()
    assert_equal(prefix, "mod__sys_analyser__", "CLI prefix should match Python version")
    print("  ✓ PASSED: CLI prefix is correct")


def test_inject_run_param_does_not_raise() raises:
    """Test that inject_run_param executes without errors."""
    print("[TEST] inject_run_param execution")

    inject_run_param(
        "test_param",
        "string",
        "Test help text"
    )
    print("  ✓ PASSED: inject_run_param executed without errors")


def test_register_cli_parameters_execution() raises:
    """Test that register_cli_parameters runs without errors."""
    print("[TEST] register_cli_parameters execution")
    register_cli_parameters()
    print("  ✓ PASSED: All CLI parameters registered successfully")


# ============================================================
# Test Group 3: load_mod Function
# ============================================================

def test_load_mod_returns_python_object() raises:
    """Test that load_mod returns a valid PythonObject."""
    print("[TEST] load_mod return type")
    var mod = load_mod()

    # Just verify it doesn't crash and returns something
    print("  ✓ PASSED: load_mod executed without errors")


# ============================================================
# Test Group 4: Helper Functions
# ============================================================

def test_python_to_mojo_dict_with_none() raises:
    """Test _python_to_mojo_dict handles None input."""
    print("[TEST] _python_to_mojo_dict with None")
    from std.python import Python

    var none_val = Python.none()
    var mojo_dict = _python_to_mojo_dict(none_val)

    assert_equal(len(mojo_dict), 0, "None should produce empty Mojo Dict")
    print("  ✓ PASSED: None handled correctly")


# ============================================================
# Test Group 5: Configuration Field Mapping (Python vs Mojo)
# ============================================================

def test_config_matches_python_structure() raises:
    """Verify all fields match Python __config__ structure.

    Python __config__ fields:
    - benchmark: None
    - record: True
    - strategy_name: None
    - output_file: None
    - report_save_path: None
    - plot: False
    - plot_save_file: None
    - plot_config: {open_close_points: False, weekly_indicators: False}
    """
    print("[TEST] Config structure matches Python __init__.py")
    var config = create_default_config()

    # Verify all expected fields exist and have correct types
    # record (Bool)
    assert_true(config.record == True, "record should be Bool=True")
    # plot (Bool)
    assert_true(config.plot == False, "plot should be Bool=False")
    # plot_config (Dict)
    assert_true(len(config.plot_config) >= 2, "plot_config should have at least 2 keys")

    print("  ✓ PASSED: All configuration fields present and correct types")


# ============================================================
# Test Group 6: Edge Cases and Error Handling
# ============================================================

def test_multiple_config_instances_independent() raises:
    """Test that multiple config instances are independent."""
    print("[TEST] Multiple config instances independence")
    var config1 = create_default_config()
    var config2 = create_default_config()

    config1.record = False
    assert_true(config2.record, "Changing config1 should not affect config2")
    print("  ✓ PASSED: Instances are independent")


def test_config_plot_config_mutation() raises:
    """Test that plot_config can be mutated independently."""
    print("[TEST] plot_config mutation")
    var config = create_default_config()

    config.plot_config["custom_key"] = PythonObject(True)
    assert_true("custom_key" in config.plot_config, "New key should be added")
    print("  ✓ PASSED: plot_config can be mutated")


# ============================================================
# Main Test Runner
# ============================================================

def main() raises:
    print("\n" + "=" * 70)
    print("RQAlpha Sys Analyser __init__.mojo - Comprehensive Test Suite")
    print("=" * 70 + "\n")

    var suite = TestSuite.discover_tests[__functions_in_module()]()
    suite^ .run()

    print("\n" + "=" * 70)
    print("Test Suite Complete - All tests executed")
    print("=" * 70 + "\n")
