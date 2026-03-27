"""
Test for core/strategy.mojo
Group 09 - File 9
"""

from rqmojo.core.strategy import BaseStrategy, create_base_strategy
from rqmojo.core.events import create_event_bus

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_strategy_init() raises:
    print("Test: BaseStrategy init")
    var event_bus = create_event_bus()
    var _ = create_base_strategy(event_bus=event_bus^)
    print("  PASSED")


def test_strategy_with_name() raises:
    print("Test: BaseStrategy with name")
    var event_bus = create_event_bus()
    var _ = create_base_strategy(event_bus=event_bus^, name="MyStrategy")
    print("  PASSED")


def test_strategy_str() raises:
    print("Test: BaseStrategy str")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    var _ = String(strategy)
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
