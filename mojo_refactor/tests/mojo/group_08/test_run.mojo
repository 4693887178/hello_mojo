"""
Test for cmds/run.mojo
Group 08 - File 1
"""

from std.collections import Dict, List
from rqmojo.cmds.run import (
    RunConfig, CliParam, run_backtest, run_strategy, run_with_config,
    create_run_params, parse_run_type, create_run_config_from_dict
)
from rqmojo.const import RUN_TYPE
from rqmojo.utils.typing import DateTime


def test_run_config_struct() -> Bool:
    print("Test: RunConfig struct exists")
    var config = RunConfig(
        strategy_file="test.py",
        start_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        end_date=DateTime(2020, 12, 31, 0, 0, 0, 0),
        frequency="1d",
        run_type=RUN_TYPE.BACKTEST,
        base_port=0,
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
        mod_configs=Dict[String, String](),
        resume_mode=False
    )
    print("  PASSED")
    return True


def test_cli_param_struct() -> Bool:
    print("Test: CliParam struct exists")
    var param = CliParam(
        name="test_param",
        param_type="string",
        default_value="default",
        help_text="test help",
        is_flag=False,
        choices=List[String]()
    )
    if param.name != "test_param":
        raise "Param name should be test_param"
    print("  PASSED")
    return True


def test_create_run_params() -> Bool:
    print("Test: create_run_params function")
    var params = create_run_params()
    if len(params) < 1:
        raise "Should have at least 1 param"
    print("  PASSED")
    return True


def test_parse_run_type() -> Bool:
    print("Test: parse_run_type function")
    var rt1 = parse_run_type("b")
    if rt1 != RUN_TYPE.BACKTEST:
        raise "b should be BACKTEST"
    
    var rt2 = parse_run_type("p")
    if rt2 != RUN_TYPE.PAPER_TRADING:
        raise "p should be PAPER_TRADING"
    
    var rt3 = parse_run_type("r")
    if rt3 != RUN_TYPE.LIVE_TRADING:
        raise "r should be LIVE_TRADING"
    print("  PASSED")
    return True


def test_create_run_config_from_dict() -> Bool:
    print("Test: create_run_config_from_dict function")
    var params = Dict[String, String]()
    params["strategy_file"] = "test.py"
    params["frequency"] = "1d"
    params["run_type"] = "b"
    
    var config = create_run_config_from_dict(params)
    if config.frequency != "1d":
        raise "Frequency should be 1d"
    print("  PASSED")
    return True


def main() -> None:
    print("=== Group 08 File 1: Run Command Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    if test_run_config_struct():
        passed += 1
    else:
        failed += 1
    
    if test_cli_param_struct():
        passed += 1
    else:
        failed += 1
    
    if test_create_run_params():
        passed += 1
    else:
        failed += 1
    
    if test_parse_run_type():
        passed += 1
    else:
        failed += 1
    
    if test_create_run_config_from_dict():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
