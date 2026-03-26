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


def test_executor_config() -> Bool:
    print("Test: ExecutorConfig struct")
    var config = ExecutorConfig(
        start_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        end_date=DateTime(2020, 12, 31, 0, 0, 0, 0),
        frequency="1d"
    )
    print("  ExecutorConfig created successfully")
    return True


def test_event_split_tuple() -> Bool:
    print("Test: EventSplitTuple struct")
    var tuple = EventSplitTuple(
        pre=EVENT.PRE_BAR(),
        main=EVENT.BAR(),
        post=EVENT.POST_BAR()
    )
    print("  EventSplitTuple created successfully")
    return True


def test_create_event_bus() -> Bool:
    print("Test: create_event_bus function")
    var bus = create_event_bus()
    print("  EventBus created successfully")
    return True


def test_create_executor() -> Bool:
    print("Test: create_executor function")
    var executor = create_executor()
    print("  Executor created successfully")
    return True


def test_executor_get_state() -> Bool:
    print("Test: Executor.get_state method")
    var executor = create_executor()
    var state = executor.get_state()
    print("  State: ", state)
    return True


def test_executor_get_event_split_map() -> Bool:
    print("Test: Executor.get_event_split_map method")
    var split_map = Executor.get_event_split_map()
    print("  Event split map has ", len(split_map), " entries")
    return True


def test_executor_current_phase() -> Bool:
    print("Test: Executor.current_phase method")
    var executor = create_executor()
    var phase = executor.current_phase()
    print("  Current phase: ", phase.name)
    return True


def main() -> None:
    print("=== Group 06 File 09: Executor Tests ===")
    print("")
    
    var passed = 0
    var failed = 0
    
    if test_executor_config():
        passed += 1
    else:
        failed += 1
    
    if test_event_split_tuple():
        passed += 1
    else:
        failed += 1
    
    if test_create_event_bus():
        passed += 1
    else:
        failed += 1
    
    if test_create_executor():
        passed += 1
    else:
        failed += 1
    
    if test_executor_get_state():
        passed += 1
    else:
        failed += 1
    
    if test_executor_get_event_split_map():
        passed += 1
    else:
        failed += 1
    
    if test_executor_current_phase():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
