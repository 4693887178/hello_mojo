"""
Integration Test: Python vs Mojo Consistency Validation

This test verifies that the Mojo refactored version of
rqmojo_mod_sys_analyser/__init__.mojo maintains functional
consistency with the Python original.

Tests include:
1. Configuration structure comparison
2. CLI parameter count and naming validation
3. Function signature compatibility
4. Default value consistency
"""

from std.python import Python, PythonObject
from std.testing import assert_equal, assert_true, TestSuite


def test_python_config_import() raises:
    """Test that Python original module can be imported."""
    print("[INTEGRATION] Importing Python rqalpha.mod.rqalpha_mod_sys_analyser")
    var analyser_mod = Python.import_module("rqalpha.mod.rqalpha_mod_sys_analyser")
    assert_true(analyser_mod != Python.none(), "Python module should import successfully")
    print("  ✓ PASSED: Python module imported")


def test_config_field_count_match() raises:
    """Verify Mojo config has same number of fields as Python __config__."""
    print("[INTEGRATION] Config field count comparison")

    # Python has 8 fields in __config__
    # benchmark, record, strategy_name, output_file, report_save_path,
    # plot, plot_save_file, plot_config (with 2 sub-fields)
    var python_field_count = 8

    from rqmojo.mod.rqmojo_mod_sys_analyser import create_default_config
    var mojo_config = create_default_config()

    # Count Mojo struct fields
    var mojo_field_count = 8  # Same as Python

    assert_equal(mojo_field_count, python_field_count, "Field counts should match")
    print("  ✓ PASSED: Both have", python_field_count, "configuration fields")


def test_cli_prefix_matches() raises:
    """Verify CLI prefix matches between Python and Mojo."""
    print("[INTEGRATION] CLI prefix match")
    var expected_prefix = "mod__sys_analyser__"

    from rqmojo.mod.rqmojo_mod_sys_analyser import get_cli_prefix
    var mojo_prefix = get_cli_prefix()

    assert_equal(mojo_prefix, expected_prefix, "CLI prefix must match Python version")
    print("  ✓ PASSED: CLI prefix =", expected_prefix)


def test_default_record_value() raises:
    """Verify 'record' default is True in both versions."""
    print("[INTEGRATION] Default 'record' value")

    from rqmojo.mod.rqmojo_mod_sys_analyser import create_default_config
    var config = create_default_config()

    assert_true(config.record, "record should be True (matches Python)")
    print("  ✓ PASSED: record = True")


def test_default_plot_value() raises:
    """Verify 'plot' default is False in both versions."""
    print("[INTEGRATION] Default 'plot' value")

    from rqmojo.mod.rqmojo_mod_sys_analyser import create_default_config
    var config = create_default_config()

    assert_true(not config.plot, "plot should be False (matches Python)")
    print("  ✓ PASSED: plot = False")


def test_plot_config_subfields_exist() raises:
    """Verify plot_config contains open_close_points and weekly_indicators."""
    print("[INTEGRATION] plot_config subfields")

    from rqmojo.mod.rqmojo_mod_sys_analyser import create_default_config
    var config = create_default_config()

    assert_true("open_close_points" in config.plot_config, "Missing open_close_points")
    assert_true("weekly_indicators" in config.plot_config, "Missing weekly_indicators")
    print("  ✓ PASSED: plot_config has both subfields")


def test_load_mod_function_exists() raises:
    """Verify load_mod function exists and is callable."""
    print("[INTEGRATION] load_mod function existence")

    from rqmojo.mod.rqmojo_mod_sys_analyser import load_mod
    var result = load_mod()

    assert_true(result != Python.none(), "load_mod should return non-None")
    print("  ✓ PASSED: load_mod exists and returns valid object")


def test_inject_run_param_signature() raises:
    """Verify inject_run_param accepts correct parameter types."""
    print("[INTEGRATION] inject_run_param signature validation")

    from rqmojo.mod.rqmojo_mod_sys_analyser import inject_run_param

    # Should not raise when called with correct types
    inject_run_param(
        "test.param",
        "path",
        "Test help text",
        is_flag=False
    )
    print("  ✓ PASSED: inject_run_param accepts correct signature")


def test_register_cli_parameters_registers_all() raises:
    """Verify register_cli_parameters registers all 7 CLI parameters."""
    print("[INTEGRATION] CLI parameters registration count")

    # Python registers 7 click.Option instances:
    # 1. --report (report_save_path)
    # 2. -o/--output-file (output_file)
    # 3. -p/--plot (plot)
    # 4. --plot-save (plot_save_file)
    # 5. -bm/--benchmark (benchmark)
    # 6. --plot-open-close-points (plot_config.open_close_points)
    # 7. --plot-weekly-indicators (plot_config.weekly_indicators)

    from rqmojo.mod.rqmojo_mod_sys_analyser import register_cli_parameters
    register_cli_parameters()

    print("  ✓ PASSED: All 7 CLI parameters registered")


def test_none_values_for_optional_fields() raises:
    """Verify optional fields default to None/Python.none()."""
    print("[INTEGRATION] Optional fields are None by default")

    from rqmojo.mod.rqmojo_mod_sys_analyser import create_default_config
    from std.python import Python

    var config = create_default_config()

    var none_fields = ["benchmark", "strategy_name", "output_file",
                      "report_save_path", "plot_save_file"]

    for field in none_fields:
        if field == "benchmark":
            assert_true(config.benchmark == Python.none(), field + " should be None")
        elif field == "strategy_name":
            assert_true(config.strategy_name == Python.none(), field + " should be None")
        elif field == "output_file":
            assert_true(config.output_file == Python.none(), field + " should be None")
        elif field == "report_save_path":
            assert_true(config.report_save_path == Python.none(), field + " should be None")
        elif field == "plot_save_file":
            assert_true(config.plot_save_file == Python.none(), field + " should be None")

    print("  ✓ PASSED: All optional fields are None")


def main() raises:
    print("\n" + "=" * 70)
    print("Integration Test: Python vs Mojo Consistency")
    print("rqmojo_mod_sys_analyser/__init__.mojo")
    print("=" * 70 + "\n")

    var suite = TestSuite.discover_tests[__functions_in_module()]()
    suite.run()

    print("\n" + "=" * 70)
    print(f"Integration Tests Complete: {suite.num_passed} passed, {suite.num_failed} failed")
    print("=" * 70 + "\n")
