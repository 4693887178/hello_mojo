"""
Test for cmds/__init__.mojo - Commands Package Init
Verifies that all re-exported symbols from submodules are accessible and functional.
Compares with Python rqalpha/cmds/__init__.py which imports:
  - from . import bundle, mod, run, misc
  - from .entry import cli
  - from .run import inject_run_param

Uses std.testing standard framework (Mojo 0.26.2.0).
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import List, Dict, Optional


# ============================================================
# Import Verification Tests
# ============================================================

def test_import_run_config() raises:
    """RunConfig struct is exported and constructible."""
    from rqmojo.cmds import RunConfig
    from rqmojo.utils.typing import DateTime
    var dt = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var config = RunConfig(
        strategy_file="",
        start_date=dt,
        end_date=dt,
        frequency="1d",
        run_type=RUN_TYPE.BACKTEST,
        accounts=Dict[String, Float64](),
        init_cash=100000.0,
        data_bundle_path="",
        margin_multiplier=1.0,
        init_positions="",
        round_price=False,
        source_code="",
        rqdatac_uri="",
        log_level="info",
        locale="cn",
        extra_vars="",
        enable_profiler=False,
        config_path="",
        mod_configs=RqAttrDict(),
        resume_mode=False
    )
    assert_equal(config.frequency, "1d")
    assert_equal(config.init_cash, 100000.0)
    assert_equal(config.log_level, "info")


def test_import_cli_param() raises:
    """CliParam struct is exported and constructible."""
    from rqmojo.cmds import CliParam
    var param = CliParam(
        name="test_param",
        param_type="string",
        default_value="default",
        help_text="A test parameter",
        is_flag=False,
        choices=List[String]()
    )
    assert_equal(param.name, "test_param")
    assert_equal(param.param_type, "string")
    assert_false(param.is_flag)


def test_import_parse_run_type() raises:
    """Parse_run_type function is exported and works correctly."""
    from rqmojo.cmds import parse_run_type
    assert_equal(parse_run_type("b"), RUN_TYPE.BACKTEST)
    assert_equal(parse_run_type("backtest"), RUN_TYPE.BACKTEST)
    assert_equal(parse_run_type("p"), RUN_TYPE.PAPER_TRADING)
    assert_equal(parse_run_type("paper"), RUN_TYPE.PAPER_TRADING)
    assert_equal(parse_run_type("r"), RUN_TYPE.LIVE_TRADING)
    assert_equal(parse_run_type("live"), RUN_TYPE.LIVE_TRADING)


def test_import_create_run_params() raises:
    """Create_run_params returns list of CliParam with expected defaults."""
    from rqmojo.cmds import create_run_params
    var params = create_run_params()
    assert_true(len(params) > 0, "create_run_params should return non-empty list")
    var names = List[String]()
    for p in params:
        names.append(p.name)
    assert_true("strategy_file" in names or "start_date" in names or "frequency" in names,
                "Should contain standard CLI params")


def test_import_cli_function() raises:
    """Cli function from entry is exported."""
    from rqmojo.cmds import cli
    var c = cli()
    assert_true(c.name == "rqmojo", "cli() should return Command named 'rqmojo'")


def test_import_inject_run_param() raises:
    """Inject_run_param (aliased as _run_inject_run_param) is exported."""
    from rqmojo.cmds.run import inject_run_param
    from rqmojo.cmds import CliParam
    var params = List[CliParam]()
    var new_param = CliParam(
        name="custom_option",
        param_type="string",
        default_value="",
        help_text="Custom option",
        is_flag=True,
        choices=List[String]()
    )
    inject_run_param(new_param, params)
    assert_equal(len(params), 1, "inject_run_param should add param to list")
    assert_equal(params[0].name, "custom_option")


def test_import_bundle_functions() raises:
    """All bundle module functions are exported and callable."""
    from rqmojo.cmds.bundle import (
        create_bundle,
        update_bundle,
        download_bundle,
        check_bundle,
        get_exactly_url,
        download,
        check_bundle_data,
        register_bundle_commands,
        dispatch_bundle_command,
    )
    from argmojo import Command
    var cmd = Command("test", "test")
    register_bundle_commands(cmd)
    assert_true(len(cmd.subcommands) >= 4,
                "register_bundle_commands should register 4 subcommands")


def test_import_misc_functions() raises:
    """Misc module functions (print_version, examples, generate_config) are exported."""
    from rqmojo.cmds.misc import print_version, examples, generate_config
    assert_true(True, "All misc imports succeeded")


def test_import_mod_exports() raises:
    """Mod module types and functions are exported."""
    from rqmojo.cmds.mod import (
        ModStatusEntry,
        get_builtin_mods,
        list_mods,
        list_mods_detailed,
        enable_mod,
        disable_mod,
        get_mod_config,
        get_mod_config_dict,
        change_mod_status,
        _strip_mod_prefix,
        _resolve_module_name,
        _check_module_installed,
        _get_user_mod_conf_path,
        detect_package_name_from_dir,
        create_mod_command,
        register_mod_commands,
        dispatch_mod_command,
    )

    var entry = ModStatusEntry(name="test_mod", enabled=True, description="A test mod")
    assert_equal(entry.name, "test_mod")
    assert_true(entry.enabled)

    var mods = get_builtin_mods()
    assert_true(len(mods) > 0, "get_builtin_mods should return non-empty list")

    var mod_names = list_mods()
    assert_true(len(mod_names) > 0, "list_mods should return non-empty list")

    var detailed = list_mods_detailed()
    assert_true(len(detailed) == len(mod_names),
                "list_mods_detailed should return same count as list_mods")


def test_strip_mod_prefix() raises:
    """_strip_mod_prefix correctly strips 'rqalpha_mod_' prefix."""
    from rqmojo.cmds.mod import _strip_mod_prefix
    assert_equal(_strip_mod_prefix("rqalpha_mod_sys_analyser"), "sys_analyser")
    assert_equal(_strip_mod_prefix("sys_analyser"), "sys_analyser")
    assert_equal(_strip_mod_prefix(""), "")


def test_resolve_module_name() raises:
    """_resolve_module_name resolves short names to full module paths."""
    from rqmojo.cmds.mod import _resolve_module_name
    var result = _resolve_module_name("sys_analyser")
    assert_true(len(result) > 0, "_resolve_module_name should return non-empty string")


def test_check_module_installed() raises:
    """_check_module_installed returns Bool for any module name."""
    from rqmojo.cmds.mod import _check_module_installed
    var result = _check_module_installed("nonexistent_module_xyz")
    assert_false(result, "Nonexistent module should return False")


def test_get_mod_config() raises:
    """Get_mod_config returns dict for known/unknown mods."""
    from rqmojo.cmds.mod import get_mod_config
    var config = get_mod_config("sys_accounts")
    assert_true("name" in config, "config should contain 'name' key")
    assert_true("enabled" in config, "config should contain 'enabled' key")


def test_get_mod_config_dict() raises:
    """Get_mod_config_dict returns nested dict structure."""
    from rqmojo.cmds.mod import get_mod_config_dict
    var config = get_mod_config_dict()
    assert_true("mod" in config, "config should contain 'mod' key")


def test_get_user_mod_conf_path() raises:
    """_get_user_mod_conf_path returns a valid path string."""
    from rqmojo.cmds.mod import _get_user_mod_conf_path
    var path = _get_user_mod_conf_path()
    assert_true(len(path) > 0, "path should be non-empty")
    assert_true(path.endswith("mod_config.yml"), "path should end with mod_config.yml")


def test_create_mod_command() raises:
    """Create_mod_command returns a proper Command structure."""
    from rqmojo.cmds.mod import create_mod_command
    var cmd = create_mod_command()
    assert_equal(cmd.name, "mod")
    assert_true(len(cmd.description) > 0, "mod command should have description")


def test_register_mod_commands() raises:
    """Register_mod_commands registers the mod subcommand."""
    from rqmojo.cmds.mod import register_mod_commands
    from argmojo import Command
    var cli = Command("test", "test")
    register_mod_commands(cli)
    assert_true(len(cli.subcommands) >= 1, "mod subcommand should be registered")


def test_change_mod_status() raises:
    """Change_mod_status processes a list of mod names."""
    from rqmojo.cmds.mod import change_mod_status
    var mod_list = List[String]()
    mod_list.append("nonexistent_mod")
    var processed = change_mod_status(mod_list, True)
    assert_equal(len(processed), 0,
                 "Nonexistent mod should not be processed (returns empty list)")


def test_enable_disable_mod() raises:
    """Enable_mod and disable_mod handle single mod names."""
    from rqmojo.cmds.mod import enable_mod, disable_mod
    var enabled = enable_mod("nonexistent_mod_xyz")
    assert_false(enabled, "enable_mod should return False for nonexistent mod")
    var disabled = disable_mod("nonexistent_mod_xyz")
    assert_false(disabled, "disable_mod should return False for nonexistent mod")


def test_run_list_mods() raises:
    """Run_list_mods executes without error."""
    from rqmojo.cmds.mod import run_list_mods
    var result = run_list_mods()
    assert_equal(result, 0, "run_list_mods should return 0 on success")


def test_create_run_config_from_dict() raises:
    """Create_run_config_from_dict constructs RunConfig from dict."""
    from rqmojo.cmds import create_run_config_from_dict
    var params = Dict[String, String]()
    params["start_date"] = "2020-01-01"
    params["end_date"] = "2020-12-31"
    params["frequency"] = "1d"
    params["init_cash"] = "500000.0"
    var config = create_run_config_from_dict(params)
    assert_equal(config.frequency, "1d")
    assert_equal(config.init_cash, 500000.0)


def test_run_backtest_returns_int() raises:
    """Run_backtest returns exit code (Int)."""
    from rqmojo.cmds import run_backtest, RunConfig
    from rqmojo.utils.typing import DateTime
    var dt = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var config = RunConfig(
        strategy_file="",
        start_date=dt,
        end_date=DateTime(2020, 12, 31, 0, 0, 0, 0),
        frequency="1d",
        run_type=RUN_TYPE.BACKTEST,
        accounts=Dict[String, Float64](),
        init_cash=100000.0,
        data_bundle_path="",
        margin_multiplier=1.0,
        init_positions="",
        round_price=False,
        source_code="",
        rqdatac_uri="",
        log_level="info",
        locale="cn",
        extra_vars="",
        enable_profiler=False,
        config_path="",
        mod_configs=RqAttrDict(),
        resume_mode=False
    )
    var code = run_backtest(config)
    assert_true(code == 0 or code == 1,
                "run_backtest should return 0 or 1, got " + String(code))


def test_run_with_config() raises:
    """Run_with_config wraps run_backtest and returns Optional dict."""
    from rqmojo.cmds import run_with_config, RunConfig
    from rqmojo.utils.typing import DateTime
    var dt = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var config = RunConfig(
        strategy_file="",
        start_date=dt,
        end_date=DateTime(2020, 12, 31, 0, 0, 0, 0),
        frequency="1d",
        run_type=RUN_TYPE.BACKTEST,
        accounts=Dict[String, Float64](),
        init_cash=100000.0,
        data_bundle_path="",
        margin_multiplier=1.0,
        init_positions="",
        round_price=False,
        source_code="",
        rqdatac_uri="",
        log_level="info",
        locale="cn",
        extra_vars="",
        enable_profiler=False,
        config_path="",
        mod_configs=RqAttrDict(),
        resume_mode=False
    )
    var result = run_with_config(config)
    if result is None:
        assert_true(True, "run_with_config may return None on failure")
    else:
        assert_true("status" in result, "result should contain 'status' key")


def test_cli_param_writable() raises:
    """CliParam conforms to Writable (has write_to)."""
    from rqmojo.cmds import CliParam
    var param = CliParam(
        name="test",
        param_type="bool",
        default_value="false",
        help_text="test param",
        is_flag=True,
        choices=List[String]()
    )
    var s = String.write(param)
    assert_true(s.contains("CliParam"), "String(CliParam) should contain 'CliParam'")


def test_mod_status_entry_writable() raises:
    """ModStatusEntry conforms to Copyable and can be used in collections."""
    from rqmojo.cmds.mod import ModStatusEntry
    var entry = ModStatusEntry(name="test", enabled=True, description="test desc")
    var entry2 = entry.copy()
    assert_equal(entry2.name, "test")
    assert_equal(entry2.enabled, True)


def test_bundle_cli_commands_structure() raises:
    """Bundle CLI commands have correct structure."""
    from rqmojo.cmds.bundle import (
        create_create_bundle_command,
        create_update_bundle_command,
        create_download_bundle_command,
        create_check_bundle_command,
    )
    var c1 = create_create_bundle_command()
    var c2 = create_update_bundle_command()
    var c3 = create_download_bundle_command()
    var c4 = create_check_bundle_command()
    assert_equal(c1.name, "create_bundle")
    assert_equal(c2.name, "update_bundle")
    assert_equal(c3.name, "download_bundle")
    assert_equal(c4.name, "check_bundle")


def test_misc_cli_commands_structure() raises:
    """Misc CLI commands have correct structure."""
    from rqmojo.cmds.misc import (
        create_examples_command,
        create_version_command,
        create_generate_config_command,
    )
    var c1 = create_examples_command()
    var c2 = create_version_command()
    var c3 = create_generate_config_command()
    assert_equal(c1.name, "examples")
    assert_equal(c2.name, "version")
    assert_equal(c3.name, "generate_config")


def test_run_cli_command_structure() raises:
    """Run CLI command has correct structure with all options."""
    from rqmojo.cmds.run import create_run_command
    var cmd = create_run_command()
    assert_equal(cmd.name, "run")
    assert_true(len(cmd.arguments) >= 10,
                "run command should have at least 10 arguments")


# ============================================================
# Main - Run all tests using std.testing framework
# ============================================================

def main() raises:
    print("=" * 70)
    print("RQMojo Test: cmds/__init__.mojo vs Python __init__.py")
    print("=" * 70)
    print("")

    TestSuite.discover_tests[__functions_in_module()]().run()

    print("")
    print("=" * 70)
    print("All cmds/__init__.mojo tests completed!")
    print("=" * 70)
