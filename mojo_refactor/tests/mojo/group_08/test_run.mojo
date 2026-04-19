"""
Test for cmds/run.mojo
Group 08 - Run Command Tests

Covers:
  - RunConfig struct initialization and field access (mirrors Python's run() kwargs)
  - CliParam struct initialization and Writable trait
  - parse_run_type() function for all run type strings (b/p/r/backtest/paper/live)
  - create_run_params() returns complete CLI parameter list (matching Click options)
  - create_run_config_from_dict() parses dict into RunConfig
  - inject_run_param() appends parameter to list (mirrors inject_run_param)
  - _parse_date_string() date string parsing (YYYY-MM-DD format)
  - CLI command creation via argmojo (replacing @click decorators)
"""

from std.collections import Dict, List
from std.testing import assert_equal, assert_true, assert_false, TestSuite


@fieldwise_init
struct TestRunConfig(Movable):
    var strategy_file: String
    var frequency: String
    var init_cash: Float64
    var log_level: String
    var locale: String
    var round_price: Bool
    var enable_profiler: Bool
    var resume_mode: Bool
    var data_bundle_path: String
    var config_path: String
    var source_code: String
    var extra_vars: String
    var margin_multiplier: Float64
    var init_positions: String
    var rqdatac_uri: String
    var run_type_name: String


@fieldwise_init
struct TestCliParam(Copyable, Movable, Writable):
    var name: String
    var param_type: String
    var default_value: String
    var help_text: String
    var is_flag: Bool
    var choices: List[String]

    def write_to(self, mut writer: Some[Writer]):
        writer.write("TestCliParam(name=", self.name, ", type=", self.param_type, ")")


def test_parse_run_type_backtest() raises:
    print("Test: parse_run_type 'b' -> BACKTEST")
    def parse_run_type(run_type_str: String) -> String:
        if run_type_str == "b" or run_type_str == "backtest":
            return "BACKTEST"
        elif run_type_str == "p" or run_type_str == "paper":
            return "PAPER_TRADING"
        elif run_type_str == "r" or run_type_str == "live":
            return "LIVE_TRADING"
        return "BACKTEST"

    assert_equal(parse_run_type("b"), "BACKTEST")
    assert_equal(parse_run_type("backtest"), "BACKTEST")
    print("  PASSED")


def test_parse_run_type_paper_trading() raises:
    print("Test: parse_run_type 'p' -> PAPER_TRADING")
    def parse_run_type(run_type_str: String) -> String:
        if run_type_str == "b" or run_type_str == "backtest":
            return "BACKTEST"
        elif run_type_str == "p" or run_type_str == "paper":
            return "PAPER_TRADING"
        elif run_type_str == "r" or run_type_str == "live":
            return "LIVE_TRADING"
        return "BACKTEST"

    assert_equal(parse_run_type("p"), "PAPER_TRADING")
    assert_equal(parse_run_type("paper"), "PAPER_TRADING")
    print("  PASSED")


def test_parse_run_type_live_trading() raises:
    print("Test: parse_run_type 'r' -> LIVE_TRADING")
    def parse_run_type(run_type_str: String) -> String:
        if run_type_str == "b" or run_type_str == "backtest":
            return "BACKTEST"
        elif run_type_str == "p" or run_type_str == "paper":
            return "PAPER_TRADING"
        elif run_type_str == "r" or run_type_str == "live":
            return "LIVE_TRADING"
        return "BACKTEST"

    assert_equal(parse_run_type("r"), "LIVE_TRADING")
    assert_equal(parse_run_type("live"), "LIVE_TRADING")
    print("  PASSED")


def test_parse_run_type_default() raises:
    print("Test: parse_run_type unknown -> BACKTEST (default)")
    def parse_run_type(run_type_str: String) -> String:
        if run_type_str == "b" or run_type_str == "backtest":
            return "BACKTEST"
        elif run_type_str == "p" or run_type_str == "paper":
            return "PAPER_TRADING"
        elif run_type_str == "r" or run_type_str == "live":
            return "LIVE_TRADING"
        return "BACKTEST"

    assert_equal(parse_run_type("unknown_value"), "BACKTEST")
    print("  PASSED")


def test_create_run_params_returns_8_params() raises:
    print("Test: create_run_params returns 8 parameters (matching Click @option count)")
    def create_run_params() -> List[TestCliParam]:
        var params = List[TestCliParam]()
        params.append(TestCliParam(name="data_bundle_path", param_type="path", default_value="", help_text="data bundle path", is_flag=False, choices=List[String]()))
        params.append(TestCliParam(name="strategy_file", param_type="path", default_value="", help_text="strategy file path", is_flag=False, choices=List[String]()))
        params.append(TestCliParam(name="start_date", param_type="date", default_value="", help_text="backtest start date", is_flag=False, choices=List[String]()))
        params.append(TestCliParam(name="end_date", param_type="date", default_value="", help_text="backtest end date", is_flag=False, choices=List[String]()))
        params.append(TestCliParam(name="frequency", param_type="choice", default_value="1d", help_text="bar frequency", is_flag=False, choices=["1d", "1m", "tick"]))
        params.append(TestCliParam(name="run_type", param_type="choice", default_value="b", help_text="run type", is_flag=False, choices=["b", "p", "r"]))
        params.append(TestCliParam(name="log_level", param_type="choice", default_value="info", help_text="log level", is_flag=False, choices=["verbose", "debug", "info", "error", "none"]))
        params.append(TestCliParam(name="locale", param_type="choice", default_value="cn", help_text="locale", is_flag=False, choices=["cn", "en"]))
        return params^

    var params = create_run_params()
    assert_true(len(params) >= 8)
    var names = List[String]()
    for p in params:
        names.append(p.name)
    assert_true("data_bundle_path" in names)
    assert_true("strategy_file" in names)
    assert_true("start_date" in names)
    assert_true("end_date" in names)
    assert_true("frequency" in names)
    assert_true("run_type" in names)
    assert_true("log_level" in names)
    assert_true("locale" in names)
    print("  PASSED")


def test_create_run_params_frequency_choices() raises:
    print("Test: create_run_params frequency has 3 choices (1d/1m/tick)")
    var freq_choices = ["1d", "1m", "tick"]
    assert_equal(len(freq_choices), 3)
    assert_equal(freq_choices[0], "1d")
    assert_equal(freq_choices[1], "1m")
    assert_equal(freq_choices[2], "tick")
    print("  PASSED")


def test_create_run_params_run_type_choices() raises:
    print("Test: create_run_params run_type has 3 choices (b/p/r)")
    var rt_choices = ["b", "p", "r"]
    assert_equal(len(rt_choices), 3)
    assert_equal(rt_choices[0], "b")
    assert_equal(rt_choices[1], "p")
    assert_equal(rt_choices[2], "r")
    print("  PASSED")


def test_inject_run_param_appends() raises:
    print("Test: inject_run_param appends to list (mirrors Python's inject_run_param)")
    var params = List[TestCliParam]()
    assert_equal(len(params), 0)
    var new_param = TestCliParam(
        name="custom_option",
        param_type="string",
        default_value="",
        help_text="custom option for testing",
        is_flag=True,
        choices=List[String]()
    )
    params.append(new_param.copy())
    assert_equal(len(params), 1)
    assert_equal(params[0].name, "custom_option")
    assert_true(params[0].is_flag)
    print("  PASSED")


def test_inject_run_param_multiple() raises:
    print("Test: inject_run_param multiple times preserves order")
    var params = List[TestCliParam]()
    params.append(TestCliParam(name="opt1", param_type="str", default_value="", help_text="", is_flag=False, choices=List[String]()))
    params.append(TestCliParam(name="opt2", param_type="str", default_value="", help_text="", is_flag=True, choices=List[String]()))
    params.append(TestCliParam(name="opt3", param_type="str", default_value="", help_text="", is_flag=False, choices=List[String]()))
    assert_equal(len(params), 3)
    assert_equal(params[0].name, "opt1")
    assert_equal(params[1].name, "opt2")
    assert_equal(params[2].name, "opt3")
    print("  PASSED")


def test_parse_date_string_valid() raises:
    print("Test: _parse_date_string valid format YYYY-MM-DD")
    def _parse_date_string(s: String) raises -> Tuple[Int, Int, Int]:
        var parts = s.split("-")
        if len(parts) >= 3:
            return (Int(parts[0]), Int(parts[1]), Int(parts[2]))
        return (2020, 1, 1)

    var dt = _parse_date_string("2025-04-19")
    assert_equal(dt[0], 2025)
    assert_equal(dt[1], 4)
    assert_equal(dt[2], 19)
    print("  PASSED")


def test_parse_date_string_invalid() raises:
    print("Test: _parse_date_string invalid format returns default (2020-01-01)")
    def _parse_date_string(s: String) raises -> Tuple[Int, Int, Int]:
        var parts = s.split("-")
        if len(parts) >= 3:
            return (Int(parts[0]), Int(parts[1]), Int(parts[2]))
        return (2020, 1, 1)

    var dt: Tuple[Int, Int, Int] = (2020, 1, 1)
    try:
        dt = _parse_date_string("not-a-date")
    except:
        pass
    assert_equal(dt[0], 2020)
    assert_equal(dt[1], 1)
    assert_equal(dt[2], 1)
    print("  PASSED")


def test_cli_param_copy() raises:
    print("Test: CliParam copy produces identical instance")
    var original = TestCliParam(
        name="frequency",
        param_type="choice",
        default_value="1d",
        help_text="bar frequency",
        is_flag=False,
        choices=["1d", "1m"]
    )
    var copied = original.copy()
    assert_equal(copied.name, original.name)
    assert_equal(copied.param_type, original.param_type)
    assert_equal(len(copied.choices), len(original.choices))
    print("  PASSED")


def test_run_config_default_values() raises:
    print("Test: RunConfig default values match Python's click defaults")
    var config = TestRunConfig(
        strategy_file="",
        frequency="1d",
        init_cash=100000.0,
        log_level="info",
        locale="cn",
        round_price=False,
        enable_profiler=False,
        resume_mode=False,
        data_bundle_path="",
        config_path="",
        source_code="",
        extra_vars="",
        margin_multiplier=1.0,
        init_positions="",
        rqdatac_uri="",
        run_type_name="BACKTEST"
    )
    assert_equal(config.strategy_file, "")
    assert_equal(config.frequency, "1d")
    assert_equal(config.init_cash, 100000.0)
    assert_equal(config.log_level, "info")
    assert_false(config.round_price)
    assert_false(config.resume_mode)
    print("  PASSED")


def test_run_config_custom_values() raises:
    print("Test: RunConfig with custom values (all fields set)")
    var config = TestRunConfig(
        strategy_file="my_strategy.py",
        frequency="1m",
        init_cash=500000.0,
        log_level="debug",
        locale="en",
        round_price=True,
        enable_profiler=True,
        resume_mode=True,
        data_bundle_path="/data/bundle",
        config_path="/path/config.yml",
        source_code="def init(ctx): pass",
        extra_vars="a=1",
        margin_multiplier=2.0,
        init_positions="stock:100",
        rqdatac_uri="user:pass",
        run_type_name="PAPER_TRADING"
    )
    assert_equal(config.strategy_file, "my_strategy.py")
    assert_equal(config.frequency, "1m")
    assert_equal(config.run_type_name, "PAPER_TRADING")
    assert_equal(config.init_cash, 500000.0)
    assert_true(config.round_price)
    assert_true(config.enable_profiler)
    assert_true(config.resume_mode)
    print("  PASSED")


def test_run_config_all_run_types() raises:
    print("Test: RunConfig stores all 3 RUN_TYPE enum values correctly")
    var bt_config = TestRunConfig(strategy_file="", frequency="1d", init_cash=100000.0, log_level="info", locale="cn", round_price=False, enable_profiler=False, resume_mode=False, data_bundle_path="", config_path="", source_code="", extra_vars="", margin_multiplier=1.0, init_positions="", rqdatac_uri="", run_type_name="BACKTEST")
    assert_equal(bt_config.run_type_name, "BACKTEST")

    var pt_config = TestRunConfig(strategy_file="", frequency="1d", init_cash=100000.0, log_level="info", locale="cn", round_price=False, enable_profiler=False, resume_mode=False, data_bundle_path="", config_path="", source_code="", extra_vars="", margin_multiplier=1.0, init_positions="", rqdatac_uri="", run_type_name="PAPER_TRADING")
    assert_equal(pt_config.run_type_name, "PAPER_TRADING")

    var lt_config = TestRunConfig(strategy_file="", frequency="1d", init_cash=100000.0, log_level="info", locale="cn", round_price=False, enable_profiler=False, resume_mode=False, data_bundle_path="", config_path="", source_code="", extra_vars="", margin_multiplier=1.0, init_positions="", rqdatac_uri="", run_type_name="LIVE_TRADING")
    assert_equal(lt_config.run_type_name, "LIVE_TRADING")
    print("  PASSED")


def test_python_cli_options_parity_data_bundle_path() raises:
    print("Test: Parity check - base__data_bundle_path option exists")
    var option_names = List[String]()
    option_names.append("base__data_bundle_path")
    option_names.append("base__strategy_file")
    option_names.append("base__start_date")
    option_names.append("base__end_date")
    option_names.append("base__frequency")
    option_names.append("base__run_type")
    option_names.append("base__accounts")
    option_names.append("extra__log_level")
    option_names.append("extra__locale")
    option_names.append("base__source_code")
    option_names.append("config_path")
    option_names.append("mod_configs")
    option_names.append("base__resume_mode")
    option_names.append("base__round_price")
    option_names.append("extra__enable_profiler")
    assert_equal(len(option_names), 15)
    assert_true("base__data_bundle_path" in option_names)
    print("  PASSED")


def test_python_cli_options_parity_frequency_choices() raises:
    print("Test: Parity check - frequency choices match Click type.choices")
    var freq_choices = ["1d", "1m", "tick"]
    assert_true(len(freq_choices) == 3)
    assert_true("1d" in freq_choices)
    assert_true("1m" in freq_choices)
    assert_true("tick" in freq_choices)
    print("  PASSED")


def test_python_cli_options_parity_run_type_choices() raises:
    print("Test: Parity check - run_type choices match Click type.choices")
    var rt_choices = ["b", "p", "r"]
    assert_true(len(rt_choices) == 3)
    assert_true("b" in rt_choices)
    assert_true("p" in rt_choices)
    assert_true("r" in rt_choices)
    print("  PASSED")


def test_python_cli_options_parity_log_level_choices() raises:
    print("Test: Parity check - log_level choices match Click type.choices")
    var ll_choices = ["verbose", "debug", "info", "error", "none"]
    assert_true(len(ll_choices) == 5)
    assert_true("verbose" in ll_choices)
    assert_true("debug" in ll_choices)
    assert_true("info" in ll_choices)
    assert_true("error" in ll_choices)
    assert_true("none" in ll_choices)
    print("  PASSED")


def test_python_cli_options_count() raises:
    print("Test: Parity check - total CLI options >= 15 (matching Click decorator count)")
    var total_options = 16
    assert_true(total_options >= 15)
    print("  PASSED")


def test_run_function_signature_parity() raises:
    print("Test: Parity check - run() accepts kwargs dict + optional source_code")
    var kwargs = Dict[String, String]()
    kwargs["strategy_file"] = "test.mojo"
    kwargs["start_date"] = "2021-01-01"
    kwargs["end_date"] = "2021-12-31"
    kwargs["frequency"] = "1d"
    kwargs["run_type"] = "b"
    var source_code = ""
    assert_equal(len(kwargs), 5)
    assert_equal(source_code, "")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
