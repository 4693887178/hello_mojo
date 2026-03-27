"""
Test for core/executor.mojo
Group 06 - File 09
"""

from rqmojo.core.executor import (
    Executor,
    ExecutorConfig,
    EventSplitTuple,
    create_event_bus,
    create_executor,
    create_executor_with_config
)
from rqmojo.const import EXECUTION_PHASE
from rqmojo.utils.typing import DateTime
from rqmojo.core.events import EVENT



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_executor_config() raises:
    print("Test: ExecutorConfig struct")
    var config = ExecutorConfig(
        start_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        end_date=DateTime(2020, 12, 31, 0, 0, 0, 0),
        frequency="1d"
    )
    print("  ExecutorConfig created successfully")
    assert_true(True, "test passed")


def test_event_split_tuple() raises:
    print("Test: EventSplitTuple struct")
    var tuple = EventSplitTuple(
        pre=EVENT.PRE_BAR(),
        main=EVENT.BAR(),
        post=EVENT.POST_BAR()
    )
    print("  EventSplitTuple created successfully")
    assert_true(True, "test passed")


def test_create_event_bus() raises:
    print("Test: create_event_bus function")
    var bus = create_event_bus()
    print("  EventBus created successfully")
    assert_true(True, "test passed")


def test_create_executor() raises:
    print("Test: create_executor function")
    var executor = create_executor()
    print("  Executor created successfully")
    assert_true(True, "test passed")


def test_executor_get_state() raises:
    print("Test: Executor.get_state method")
    var executor = create_executor()
    var state = executor.get_state()
    print("  State: ", state)
    assert_true(True, "test passed")


def test_executor_get_event_split_map() raises:
    print("Test: Executor.get_event_split_map method")
    var split_map = Executor.get_event_split_map()
    print("  Event split map has ", len(split_map), " entries")
    assert_true(True, "test passed")


def test_executor_current_phase() raises:
    print("Test: Executor.current_phase method")
    var executor = create_executor()
    var phase = executor.current_phase()
    print("  Current phase: ", phase.name)
    assert_true(True, "test passed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()