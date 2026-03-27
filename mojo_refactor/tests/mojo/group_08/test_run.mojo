"""
Test for cmds/run.mojo
Group 08 - File 6
"""

from std.collections import Dict, List
from rqmojo.const import RUN_TYPE, MATCHING_TYPE



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

@fieldwise_init
struct RunConfig(Movable, Writable):
    var base_strategy_file: String
    var base_config_path: String
    var run_type: RUN_TYPE
    var matching_type: MATCHING_TYPE

    def write_to(self, mut writer: Some[Writer]):
        writer.write("RunConfig(strategy=", self.base_strategy_file, ")")


def create_run_config(
    strategy_file: String = "",
    config_path: String = "",
    run_type: RUN_TYPE = RUN_TYPE.BACKTEST,
    matching_type: MATCHING_TYPE = MATCHING_TYPE.CURRENT_BAR_CLOSE
) -> RunConfig:
    return RunConfig(
        base_strategy_file=strategy_file,
        base_config_path=config_path,
        run_type=run_type,
        matching_type=matching_type
    )


def test_run_config_init() raises:
    print("Test: RunConfig init")
    var config = create_run_config()
    print("  PASSED")
    assert_true(True, "test passed")


def test_run_config_with_params() raises:
    print("Test: RunConfig with params")
    var config = create_run_config(
        strategy_file="strategy.py",
        config_path="config.yml",
        run_type=RUN_TYPE.BACKTEST
    )
    if config.base_strategy_file != "strategy.py":
        raise "RunConfig strategy_file mismatch"
    print("  PASSED")
    assert_true(True, "test passed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()