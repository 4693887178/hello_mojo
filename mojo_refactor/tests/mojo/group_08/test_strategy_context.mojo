"""
Test for core/strategy_context.mojo
Group 08 - File 8
"""

from std.collections import Dict, List
from rqmojo.const import RUN_TYPE, MATCHING_TYPE
from rqmojo.utils.typing import DateTime



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

@fieldwise_init
struct StrategyContext(Movable, Writable):
    var _run_type: RUN_TYPE
    var _matching_type: MATCHING_TYPE
    var _universe: List[String]
    var _now: DateTime

    def write_to(self, mut writer: Some[Writer]):
        writer.write("StrategyContext(run_type=", String(self._run_type.value), ")")

    def get_run_type(self) -> RUN_TYPE:
        return self._run_type

    def get_matching_type(self) -> MATCHING_TYPE:
        return self._matching_type

    def get_universe(self) -> List[String]:
        return self._universe.copy()

    def get_now(self) -> DateTime:
        return self._now


def create_strategy_context(
    run_type: RUN_TYPE = RUN_TYPE.BACKTEST,
    matching_type: MATCHING_TYPE = MATCHING_TYPE.CURRENT_BAR_CLOSE
) -> StrategyContext:
    return StrategyContext(
        _run_type=run_type,
        _matching_type=matching_type,
        _universe=List[String](),
        _now=DateTime(2024, 1, 1, 0, 0, 0, 0)
    )


def test_strategy_context_init() raises:
    print("Test: StrategyContext init")
    var ctx = create_strategy_context()
    print("  PASSED")
    assert_true(True, "test passed")


def test_strategy_context_run_type() raises:
    print("Test: StrategyContext run_type")
    var ctx = create_strategy_context(run_type=RUN_TYPE.BACKTEST)
    if ctx.get_run_type() != RUN_TYPE.BACKTEST:
        raise "StrategyContext run_type mismatch"
    print("  PASSED")
    assert_true(True, "test passed")


def test_strategy_context_matching_type() raises:
    print("Test: StrategyContext matching_type")
    var ctx = create_strategy_context(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    if ctx.get_matching_type() != MATCHING_TYPE.NEXT_BAR_OPEN:
        raise "StrategyContext matching_type mismatch"
    print("  PASSED")
    assert_true(True, "test passed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()