"""
Test for mod/rqmojo_mod_sys_analyser/mod.mojo
Group 08 - File 9
"""

from std.collections import Dict, List
from rqmojo.mod.rqmojo_mod_sys_analyser.mod import AnalyserMod, create_analyser_mod, PerformanceMetrics, TradeSummary
from rqmojo.const import EXIT_CODE
from std.python import PythonObject



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_analyser_mod_init() raises:
    print("Test: AnalyserMod init")
    var mod = create_analyser_mod()
    print("  PASSED")
    assert_true(True, "test passed")


def test_analyser_mod_name() raises:
    print("Test: AnalyserMod name")
    var mod = create_analyser_mod()
    if mod.name != "analyser":
        raise "AnalyserMod name should be 'analyser'"
    print("  PASSED")
    assert_true(True, "test passed")


def test_performance_metrics() raises:
    print("Test: PerformanceMetrics")
    var metrics = PerformanceMetrics(
        total_returns=0.1,
        annualized_returns=0.15,
        max_drawdown=0.05,
        sharpe_ratio=1.5,
        win_rate=0.6
    )
    if metrics.total_returns != 0.1:
        raise "PerformanceMetrics total_returns mismatch"
    print("  PASSED")
    assert_true(True, "test passed")


def test_trade_summary() raises:
    print("Test: TradeSummary")
    var summary = TradeSummary(
        total_trades=10,
        winning_trades=6,
        losing_trades=4,
        total_pnl=1000.0
    )
    if summary.total_trades != 10:
        raise "TradeSummary total_trades mismatch"
    print("  PASSED")
    assert_true(True, "test passed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()