"""
Test for core/strategy_universe.mojo
Group 07 - File 01
"""

from std.collections import Set, List
from rqmojo.core.strategy_universe import (
    StrategyUniverse, UniverseChangeRecord,
    create_strategy_universe
)
from rqmojo.core.events import EventBus
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_strategy_universe_init() raises:
    print("Test: StrategyUniverse init")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)
    
    assert_equal(len(universe.get()), 0, "StrategyUniverse should be empty after init")
    print("  PASSED")


def test_strategy_universe_subscribe() raises:
    print("Test: StrategyUniverse subscribe")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)
    
    universe.subscribe("000001.XSHE")
    assert_true(universe.contains("000001.XSHE"), "StrategyUniverse should contain 000001.XSHE")
    assert_equal(len(universe.get()), 1, "StrategyUniverse should have 1 item")
    print("  PASSED")


def test_strategy_universe_unsubscribe() raises:
    print("Test: StrategyUniverse unsubscribe")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)
    
    universe.subscribe("000001.XSHE")
    assert_true(universe.contains("000001.XSHE"), "StrategyUniverse should contain 000001.XSHE")
    
    universe.unsubscribe("000001.XSHE")
    assert_false(universe.contains("000001.XSHE"), "StrategyUniverse should not contain 000001.XSHE after unsubscribe")
    assert_equal(len(universe.get()), 0, "StrategyUniverse should be empty after unsubscribe")
    print("  PASSED")


def test_strategy_universe_update() raises:
    print("Test: StrategyUniverse update")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)
    
    var items = Set[String]()
    items.add("000001.XSHE")
    items.add("000002.XSHE")
    
    universe.update(items)
    
    assert_equal(len(universe.get()), 2, "StrategyUniverse should have 2 items")
    print("  PASSED")


def test_strategy_universe_get() raises:
    print("Test: StrategyUniverse get")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)
    
    universe.subscribe("000001.XSHE")
    universe.subscribe("000002.XSHE")
    
    assert_equal(len(universe.get()), 2, "Result set should have 2 items")
    print("  PASSED")


def test_strategy_universe_get_list() raises:
    print("Test: StrategyUniverse get_list")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)
    
    universe.subscribe("000001.XSHE")
    universe.subscribe("000002.XSHE")
    
    var result = universe.get_list()
    assert_equal(len(result), 2, "Result list should have 2 items")
    print("  PASSED")


def test_strategy_universe_get_state() raises:
    print("Test: StrategyUniverse get_state")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)
    
    universe.subscribe("000001.XSHE")
    
    var state = universe.get_state()
    assert_true(len(state) > 0, "State should not be empty")
    print("  PASSED")


def test_strategy_universe_set_state() raises:
    print("Test: StrategyUniverse set_state")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)
    
    universe.set_state("[\"000002.XSHE\"]")
    assert_true(universe.contains("000002.XSHE"), "StrategyUniverse should contain 000002.XSHE after set_state")
    print("  PASSED")


def test_strategy_universe_clear() raises:
    print("Test: StrategyUniverse clear")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)
    
    universe.subscribe("000001.XSHE")
    universe.subscribe("000002.XSHE")
    
    universe.clear()
    
    assert_equal(len(universe.get()), 0, "StrategyUniverse should be empty after clear")
    print("  PASSED")


def test_universe_change_record() raises:
    print("Test: UniverseChangeRecord")
    var added = Set[String]()
    added.add("000001.XSHE")
    var removed = Set[String]()
    removed.add("000002.XSHE")
    var record = UniverseChangeRecord(added^, removed^)
    
    assert_true(record.has_changes(), "UniverseChangeRecord should have changes")
    assert_equal(len(record.added), 1, "UniverseChangeRecord should have 1 added item")
    assert_equal(len(record.removed), 1, "UniverseChangeRecord should have 1 removed item")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
