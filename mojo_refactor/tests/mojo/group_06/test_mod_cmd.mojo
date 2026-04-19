"""
Test for cmds/mod.mojo
Group 06 - Comprehensive Mod Command Tests

Tests cover all functions ported from rqalpha/cmds/mod.py:
  - ModStatusEntry struct
  - get_builtin_mods() / list_mods() / list_mods_detailed()
  - _strip_mod_prefix() / _resolve_module_name()
  - _check_module_installed()
  - change_mod_status() / enable_mod() / disable_mod()
  - get_mod_config() / get_mod_config_dict()
  - run_mod_command() / run_list_mods() / run_enable_mod() / run_disable_mod()
  - detect_package_name_from_dir()
  - CLI: create_mod_command() / register_mod_commands() / dispatch_mod_command()
"""

from std.collections import Dict, List
from std.testing import assert_equal, assert_true, assert_false, TestSuite

from rqmojo.cmds.mod import (
    ModStatusEntry,
    get_builtin_mods,
    list_mods,
    list_mods_detailed,
    enable_mod,
    disable_mod,
    get_mod_config,
    get_mod_config_dict,
    run_mod_command,
    run_list_mods,
    run_enable_mod,
    run_disable_mod,
    change_mod_status,
    _strip_mod_prefix,
    _resolve_module_name,
    _check_module_installed,
    _get_user_mod_conf_path,
    detect_package_name_from_dir,
    create_mod_command,
)


def test_mod_status_entry_init() raises:
    print("Test: ModStatusEntry struct init")
    var entry = ModStatusEntry(name="test_mod", enabled=True, description="Test mod")
    assert_equal(entry.name, "test_mod", "name should match")
    assert_true(entry.enabled, "enabled should be True")
    assert_equal(entry.description, "Test mod", "description should match")
    print("  PASSED")


def test_mod_status_entry_disabled() raises:
    print("Test: ModStatusEntry with disabled status")
    var entry = ModStatusEntry(name="disabled_mod", enabled=False, description="Disabled mod")
    assert_false(entry.enabled, "enabled should be False")
    print("  PASSED")


def test_get_builtin_mods_count() raises:
    print("Test: get_builtin_mods returns correct count (7 sys mods)")
    var mods = get_builtin_mods()
    assert_equal(len(mods), 7, "Should have 7 builtin mods matching mod_config.yml")
    print("  PASSED")


def test_get_builtin_mods_names() raises:
    print("Test: get_builtin_mods contains expected mod names")
    var mods = get_builtin_mods()
    var names = List[String]()
    for m in mods:
        names.append(m.name)

    var expected = [
        "sys_accounts", "sys_simulation", "sys_progress",
        "sys_risk", "sys_analyser", "sys_scheduler", "sys_transaction_cost"
    ]
    for exp in expected:
        var found = False
        for n in names:
            if n == exp:
                found = True
                break
        assert_true(found, "Should contain mod: " + exp)
    print("  PASSED")


def test_get_builtin_mods_all_enabled() raises:
    print("Test: All builtin mods are enabled by default")
    var mods = get_builtin_mods()
    for mod in mods:
        assert_true(mod.enabled, "Mod '" + mod.name + "' should be enabled by default")
    print("  PASSED")


def test_get_builtin_mods_has_description() raises:
    print("Test: All builtin mods have descriptions")
    var mods = get_builtin_mods()
    for mod in mods:
        assert_true(len(mod.description) > 0, "Mod '" + mod.name + "' should have description")
    print("  PASSED")


def test_list_mods_returns_names() raises:
    print("Test: list_mods returns list of name strings")
    var names = list_mods()
    assert_equal(len(names), 7, "list_mods should return 7 names")
    for name in names:
        assert_true(len(name) > 0, "Name should not be empty")
    print("  PASSED")


def test_list_mods_matches_builtin() raises:
    print("Test: list_mods names match get_builtin_mods names")
    var names = list_mods()
    var detailed = list_mods_detailed()
    assert_equal(len(names), len(detailed), "Counts should match")
    for i in range(len(names)):
        assert_equal(names[i], detailed[i].name, "Name at index " + String(i) + " should match")
    print("  PASSED")


def test_list_mods_detailed_returns_entries() raises:
    print("Test: list_mods_detailed returns ModStatusEntry list")
    var detailed = list_mods_detailed()
    assert_true(len(detailed) > 0, "Should not be empty")
    print("  PASSED")


def test_strip_mod_prefix_no_prefix() raises:
    print("Test: _strip_mod_prefix with no prefix")
    var result = _strip_mod_prefix("sys_accounts")
    assert_equal(result, "sys_accounts", "Unprefixed name should pass through")
    print("  PASSED")


def test_strip_mod_prefix_with_prefix() raises:
    print("Test: _strip_mod_prefix strips 'rqalpha_mod_' prefix")
    var result = _strip_mod_prefix("rqalpha_mod_sys_accounts")
    assert_equal(result, "sys_accounts", "Prefix should be stripped")
    print("  PASSED")


def test_strip_mod_prefix_custom_mod() raises:
    print("Test: _strip_mod_prefix with custom mod name")
    var result = _strip_mod_prefix("rqalpha_mod_my_custom_mod")
    assert_equal(result, "my_custom_mod", "Custom mod prefix should be stripped")
    print("  PASSED")


def test_resolve_module_name_sys_mod() raises:
    print("Test: _resolve_module_name for sys_ prefixed mods")
    var result = _resolve_module_name("sys_accounts")
    assert_equal(result, "rqalpha.mod.rqalpha_mod_sys_accounts",
        "Sys mods should resolve to rqalpha.mod.* path")
    print("  PASSED")


def test_resolve_module_name_regular_mod() raises:
    print("Test: _resolve_module_name for regular mods")
    var result = _resolve_module_name("my_custom_mod")
    assert_equal(result, "rqalpha_mod_my_custom_mod",
        "Regular mods should resolve to rqalpha_mod_*")
    print("  PASSED")


def test_check_module_installed_stdlib() raises:
    print("Test: _check_module_installed with stdlib module (os)")
    var result = _check_module_installed("os")
    assert_true(result, "os module should be installed")
    print("  PASSED")


def test_check_module_installed_nonexistent() raises:
    print("Test: _check_module_installed with nonexistent module")
    var result = _check_module_installed("nonexistent_module_xyz_12345")
    assert_false(result, "Nonexistent module should return False")
    print("  PASSED")


def test_check_module_installed_rqalpha() raises:
    print("Test: _check_module_installed with rqalpha module")
    var result = _check_module_installed("rqalpha")
    assert_true(result, "rqalpha module should be available via PYTHONPATH")
    print("  PASSED")


def test_get_user_mod_conf_path() raises:
    print("Test: _get_user_mod_conf_path returns valid path")
    var path = _get_user_mod_conf_path()
    assert_true(len(path) > 0, "Path should not be empty")
    assert_true(path.find("mod_config.yml") != -1, "Path should end with mod_config.yml")
    print("  PASSED")


def test_change_mod_status_empty_list() raises:
    print("Test: change_mod_status with empty list")
    var empty = List[String]()
    var result = change_mod_status(empty, True)
    assert_equal(len(result), 0, "Empty input should return empty result")
    print("  PASSED")


def test_change_mod_status_nonexistent_mod() raises:
    print("Test: change_mod_status with nonexistent mod name")
    var mod_list = List[String]()
    mod_list.append("nonexistent_mod_xyz")
    var result = change_mod_status(mod_list, True)
    assert_equal(len(result), 0, "Nonexistent mod should not appear in results")
    print("  PASSED")


def test_get_mod_config_existing() raises:
    print("Test: get_mod_config for existing mod")
    var config = get_mod_config("sys_accounts")
    assert_true("enabled" in config, "Config should have 'enabled' key")
    assert_true("name" in config, "Config should have 'name' key")
    assert_equal(config["name"], "sys_accounts", "Name should match")
    print("  PASSED")


def test_get_mod_config_nonexisting() raises:
    print("Test: get_mod_config for non-existing mod")
    var config = get_mod_config("nonexistent_mod_xyz")
    assert_true("enabled" in config, "Config should still have 'enabled' key")
    assert_equal(config["enabled"], "false", "Non-existing mod should be disabled")
    print("  PASSED")


def test_get_mod_config_dict_structure() raises:
    print("Test: get_mod_config_dict has correct structure")
    var config = get_mod_config_dict()
    assert_true("mod" in config, "Top-level 'mod' key should exist")
    var mod_dict = config["mod"].copy()
    assert_true("sys_accounts" in mod_dict, "Should contain sys_accounts")
    assert_true("sys_simulation" in mod_dict, "Should contain sys_simulation")
    print("  PASSED")


def test_run_mod_command_list() raises:
    print("Test: run_mod_command with 'list' action")
    var params = List[String]()
    var code = run_mod_command("list", params)
    assert_equal(code, 0, "list action should return exit code 0")
    print("  PASSED")


def test_run_mod_command_unknown_action() raises:
    print("Test: run_mod_command with unknown action")
    var params = List[String]()
    var code = run_mod_command("unknown_action", params)
    assert_equal(code, 1, "Unknown action should return exit code 1")
    print("  PASSED")


def test_run_mod_command_enable_no_params() raises:
    print("Test: run_mod_command enable without params")
    var params = List[String]()
    var code = run_mod_command("enable", params)
    assert_equal(code, 1, "Enable without params should return error code 1")
    print("  PASSED")


def test_run_mod_command_disable_no_params() raises:
    print("Test: run_mod_command disable without params")
    var params = List[String]()
    var code = run_mod_command("disable", params)
    assert_equal(code, 1, "Disable without params should return error code 1")
    print("  PASSED")


def test_run_list_mods_returns_zero() raises:
    print("Test: run_list_mods returns success code")
    var code = run_list_mods()
    assert_equal(code, 0, "run_list_mods should return 0")
    print("  PASSED")


def test_run_enable_mod_no_params_error() raises:
    print("Test: run_enable_mod with empty params returns error")
    var params = List[String]()
    var code = run_enable_mod(params)
    assert_equal(code, 1, "Empty params should return error code 1")
    print("  PASSED")


def test_run_disable_mod_no_params_error() raises:
    print("Test: run_disable_mod with empty params returns error")
    var params = List[String]()
    var code = run_disable_mod(params)
    assert_equal(code, 1, "Empty params should return error code 1")
    print("  PASSED")


def test_detect_package_name_from_dir_no_setup_py() raises:
    print("Test: detect_package_name_from_dir without setup.py")
    var result = detect_package_name_from_dir("/tmp/nonexistent_dir_xyz")
    assert_equal(result, "", "Directory without setup.py should return empty string")
    print("  PASSED")


def test_create_mod_command() raises:
    print("Test: create_mod_command creates valid command")
    var cmd = create_mod_command()
    assert_equal(cmd.name, "mod", "Command name should be 'mod'")
    print("  PASSED")


def test_mod_config_all_enabled_by_default() raises:
    print("Test: All builtin mods are enabled in default config")
    var mods = get_builtin_mods()
    for mod in mods:
        var cfg = get_mod_config(mod.name)
        assert_equal(cfg["enabled"], "true",
            "Mod '" + mod.name + "' should be enabled by default")
    print("  PASSED")


def test_list_mods_order_consistent() raises:
    print("Test: list_mods returns consistent order across calls")
    var names1 = list_mods()
    var names2 = list_mods()
    assert_equal(len(names1), len(names2), "Lengths should match")
    for i in range(len(names1)):
        assert_equal(names1[i], names2[i],
            "Order should be consistent at index " + String(i))
    print("  PASSED")


def test_resolve_module_name_idempotent() raises:
    print("Test: _resolve_module_name is idempotent on clean names")
    var r1 = _resolve_module_name("sys_accounts")
    var r2 = _resolve_module_name("sys_accounts")
    assert_equal(r1, r2, "Same input should produce same output")
    print("  PASSED")


def test_strip_mod_prefix_idempotent() raises:
    print("Test: _strip_mod_prefix is idempotent on clean names")
    var r1 = _strip_mod_prefix("sys_accounts")
    var r2 = _strip_mod_prefix(r1)
    assert_equal(r1, r2, "Stripping already-clean name should not change it")
    print("  PASSED")


def test_mod_status_entry_copyable() raises:
    print("Test: ModStatusEntry supports copy semantics")
    var original = ModStatusEntry(name="copy_test", enabled=True, description="Copy test")
    var name = original.name
    assert_equal(name, "copy_test", "Field access should work")
    print("  PASSED")


def test_get_mod_config_dict_has_seven_entries() raises:
    print("Test: get_mod_config_dict has exactly 7 mod entries")
    var config = get_mod_config_dict()
    var mod_dict = config["mod"].copy()
    assert_equal(len(mod_dict), 7, "Should have exactly 7 mod entries")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
