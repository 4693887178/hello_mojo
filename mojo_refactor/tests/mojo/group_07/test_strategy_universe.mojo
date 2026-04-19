"""
Test for core/strategy_universe.mojo
Comprehensive tests aligned with Python rqalpha/core/strategy_universe.py.
Group 07 - File 01.
"""

from std.collections import Set, List
from std.testing import assert_equal, assert_true, assert_false, TestSuite
from rqmojo.core.strategy_universe import (
    StrategyUniverse, create_strategy_universe,
    _bubble_sort
)
from rqmojo.core.events import EventBus, EVENT, Event


def test_init_empty_set() raises:
    """Test that universe is empty after init."""
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)
    var result = universe.get()
    assert_equal(len(result), 0, "Universe should be empty after init")
    print("  PASSED: init_empty_set")


def test_update_with_list() raises:
    """Test update with list of order_book_ids."""
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)

    var items = List[String]()
    items.append("000001.XSHE")
    items.append("000002.XSHE")
    universe.update(items)

    var result = universe.get()
    assert_equal(len(result), 2, "Should have 2 items after update")
    assert_true("000001.XSHE" in result, "Should contain 000001.XSHE")
    assert_true("000002.XSHE" in result, "Should contain 000002.XSHE")
    print("  PASSED: update_with_list")


def test_update_single() raises:
    """Test update_single with a single order_book_id."""
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)

    universe.update_single("000001.XSHE")

    var result = universe.get()
    assert_equal(len(result), 1, "Should have 1 item after update_single")
    assert_true("000001.XSHE" in result, "Should contain 000001.XSHE")
    print("  PASSED: update_single")


def test_get_returns_copy() raises:
    """Test that get returns a copy of the set."""
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)

    var items = List[String]()
    items.append("000001.XSHE")
    universe.update(items)

    var result1 = universe.get()
    var result2 = universe.get()

    assert_equal(len(result1), len(result2), "Both copies should have same size")
    assert_true("000001.XSHE" in result1, "First copy should contain item")
    assert_true("000001.XSHE" in result2, "Second copy should contain item")
    print("  PASSED: get_returns_copy")


def test_update_same_content_no_change() raises:
    """Test that updating with same content does not change the set."""
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)

    var items = List[String]()
    items.append("000001.XSHE")
    items.append("000002.XSHE")
    universe.update(items)

    var size_before = len(universe.get())
    universe.update(items)
    var size_after = len(universe.get())

    assert_equal(size_before, size_after, "Same content update should not change size")
    print("  PASSED: update_same_content_no_change")


def test_update_different_content_changes() raises:
    """Test that updating with different content changes the set."""
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)

    var items1 = List[String]()
    items1.append("000001.XSHE")
    universe.update(items1)

    var items2 = List[String]()
    items2.append("000001.XSHE")
    items2.append("000002.XSHE")
    universe.update(items2)

    var result = universe.get()
    assert_equal(len(result), 2, "Should have 2 items after second update")
    print("  PASSED: update_different_content_changes")


def test_get_state_json_format() raises:
    """Test get_state returns sorted JSON array string."""
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)

    var items = List[String]()
    items.append("000002.XSHE")
    items.append("000001.XSHE")
    universe.update(items)

    var state = universe.get_state()

    assert_true(len(state) > 0, "State should not be empty")
    assert_true(state.startswith("["), "State should start with [")
    assert_true(state.endswith("]"), "State should end with ]")
    assert_true(state.find("000001.XSHE") != -1, "State should contain 000001.XSHE")
    assert_true(state.find("000002.XSHE") != -1, "State should contain 000002.XSHE")

    var idx1 = state.find("000001.XSHE")
    var idx2 = state.find("000002.XSHE")
    assert_true(idx1 < idx2, "Items should be sorted (000001 before 000002)")
    print("  PASSED: get_state_json_format")


def test_get_state_empty() raises:
    """Test get_state on empty universe returns '[]'."""
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)

    var state = universe.get_state()
    assert_equal(state, "[]", "Empty state should be '[]'")
    print("  PASSED: get_state_empty")


def test_set_state_from_json() raises:
    """Test set_state parses JSON array and updates universe."""
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)

    universe.set_state("[\"000001.XSHE\", \"000002.XSHE\"]")

    var result = universe.get()
    assert_equal(len(result), 2, "Should have 2 items after set_state")
    assert_true("000001.XSHE" in result, "Should contain 000001.XSHE")
    assert_true("000002.XSHE" in result, "Should contain 000002.XSHE")
    print("  PASSED: set_state_from_json")


def test_set_state_single_item() raises:
    """Test set_state with a single item."""
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)

    universe.set_state("[\"000001.XSHE\"]")

    var result = universe.get()
    assert_equal(len(result), 1, "Should have 1 item")
    assert_true("000001.XSHE" in result, "Should contain 000001.XSHE")
    print("  PASSED: set_state_single_item")


def test_set_state_empty_array() raises:
    """Test set_state with empty array clears universe."""
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)

    var items = List[String]()
    items.append("000001.XSHE")
    universe.update(items)

    universe.set_state("[]")

    var result = universe.get()
    assert_equal(len(result), 0, "Should be empty after set_state with []")
    print("  PASSED: set_state_empty_array")


def test_get_state_set_state_roundtrip() raises:
    """Test that state roundtrips correctly through get_state and set_state."""
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)

    var items = List[String]()
    items.append("000003.XSHE")
    items.append("000001.XSHE")
    items.append("000002.XSHE")
    universe.update(items)

    var state = universe.get_state()

    var event_bus2 = EventBus()
    var universe2 = create_strategy_universe(event_bus2^)
    universe2.set_state(state)

    var result = universe2.get()
    assert_equal(len(result), 3, "Roundtrip should preserve count")
    assert_true("000001.XSHE" in result, "Roundtrip should preserve 000001.XSHE")
    assert_true("000002.XSHE" in result, "Roundtrip should preserve 000002.XSHE")
    assert_true("000003.XSHE" in result, "Roundtrip should preserve 000003.XSHE")
    print("  PASSED: get_state_set_state_roundtrip")


def test_update_replaces_content() raises:
    """Test that update replaces entire universe set."""
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)

    var items1 = List[String]()
    items1.append("000001.XSHE")
    items1.append("000002.XSHE")
    universe.update(items1)

    var items2 = List[String]()
    items2.append("000003.XSHE")
    items2.append("000004.XSHE")
    universe.update(items2)

    var result = universe.get()
    assert_equal(len(result), 2, "Should have 2 items after replacement")
    assert_false("000001.XSHE" in result, "Old item 000001.XSHE should be removed")
    assert_false("000002.XSHE" in result, "Old item 000002.XSHE should be removed")
    assert_true("000003.XSHE" in result, "New item 000003.XSHE should exist")
    assert_true("000004.XSHE" in result, "New item 000004.XSHE should exist")
    print("  PASSED: update_replaces_content")


def test_update_idempotent() raises:
    """Test that updating with same list multiple times is safe."""
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)

    var items = List[String]()
    items.append("000001.XSHE")
    items.append("000002.XSHE")

    universe.update(items)
    universe.update(items)
    universe.update(items)

    var result = universe.get()
    assert_equal(len(result), 2, "Idempotent updates should not duplicate items")
    print("  PASSED: update_idempotent")


def test_write_to() raises:
    """Test write_to output format."""
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus^)

    var items = List[String]()
    items.append("000001.XSHE")
    universe.update(items)

    var s = String.write(universe)
    assert_true(s.find("StrategyUniverse") != -1, "write_to should contain StrategyUniverse")
    assert_true(s.find("count=1") != -1 or s.find("count= 1") != -1, "write_to should show count")
    print("  PASSED: write_to")


def test_bubble_sort() raises:
    """Test the bubble sort helper function."""
    var items = List[String]()
    items.append("zebra")
    items.append("apple")
    items.append("monkey")
    items.append("banana")
    _bubble_sort(items)

    assert_equal(items[0], "apple", "First item should be apple")
    assert_equal(items[1], "banana", "Second item should be banana")
    assert_equal(items[2], "monkey", "Third item should be monkey")
    assert_equal(items[3], "zebra", "Fourth item should be zebra")
    print("  PASSED: bubble_sort")


def test_bubble_sort_empty() raises:
    """Test bubble sort with empty list."""
    var items = List[String]()
    _bubble_sort(items)
    assert_equal(len(items), 0, "Empty list should remain empty")
    print("  PASSED: bubble_sort_empty")


def test_bubble_sort_single() raises:
    """Test bubble sort with single element."""
    var items = List[String]()
    items.append("solo")
    _bubble_sort(items)
    assert_equal(len(items), 1, "Single element list should remain unchanged")
    assert_equal(items[0], "solo", "Single element should be solo")
    print("  PASSED: bubble_sort_single")


def test_bubble_sort_sorted() raises:
    """Test bubble sort with already sorted list."""
    var items = List[String]()
    items.append("a")
    items.append("b")
    items.append("c")
    _bubble_sort(items)
    assert_equal(items[0], "a", "First should be a")
    assert_equal(items[1], "b", "Second should be b")
    assert_equal(items[2], "c", "Third should be c")
    print("  PASSED: bubble_sort_sorted")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
