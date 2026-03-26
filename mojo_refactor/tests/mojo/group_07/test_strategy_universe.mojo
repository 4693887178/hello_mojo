"""
Test for core/strategy_universe.mojo
Group 07 - File 01
"""

 
from std.collections import Set, List
from rqmojo.core.strategy_universe import (
    StrategyUniverse, UniverseChangeRecord,
    create_strategy_universe, universe_from_list
)
from rqmojo.core.events import EventBus
from rqmojo.utils.typing import DateTime


 

fn test_strategy_universe_init() raises -> Bool:
    print("Test: StrategyUniverse init")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus)
    
    if not universe.is_empty():
        raise "StrategyUniverse should be empty after init"
    if universe.size() != 0:
        raise "StrategyUniverse size should be 0 after init"
    print("  PASSED")
    return True


 

fn test_strategy_universe_subscribe() raises -> Bool:
    print("Test: StrategyUniverse subscribe")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus)
    
    universe.subscribe("000001.XSHE")
    if not universe.contains("000001.XSHE"):
        raise "StrategyUniverse should contain 000001.XSHE"
    if universe.size() != 1:
        raise "StrategyUniverse size should be 1"
    print("  PASSED")
    return True


 

fn test_strategy_universe_unsubscribe() raises -> Bool:
    print("Test: StrategyUniverse unsubscribe")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus)
    
    universe.subscribe("000001.XSHE")
    if not universe.contains("000001.XSHE"):
        raise "StrategyUniverse should contain 000001.XSHE"
    
    universe.unsubscribe("000001.XSHE")
    if universe.contains("000001.XSHE"):
        raise "StrategyUniverse should not contain 000001.XSHE after unsubscribe"
    if not universe.is_empty():
        raise "StrategyUniverse should be empty after unsubscribe"
    print("  PASSED")
    return True


 

fn test_strategy_universe_update_from_list() raises -> Bool:
    print("Test: StrategyUniverse update_from_list")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus)
    
    var items = List[String]()
    items.append("000001.XSHE")
    items.append("000002.XSHE")
    
    universe.update_from_list(items)
    
    if universe.size() != 2:
        raise "StrategyUniverse size should be 2"
    print("  PASSED")
    return True


 

fn test_strategy_universe_get() raises -> Bool:
    print("Test: StrategyUniverse get")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus)
    
    universe.subscribe("000001.XSHE")
    universe.subscribe("000002.XSHE")
    
    var result = universe.get()
    if len(result) != 2:
        raise "Result set should have 2 items"
    print("  PASSED")
    return True


 

fn test_strategy_universe_get_list() raises -> Bool:
    print("Test: StrategyUniverse get_list")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus)
    
    universe.subscribe("000001.XSHE")
    universe.subscribe("000002.XSHE")
    
    var result = universe.get_list()
    if len(result) != 2:
        raise "Result list should have 2 items"
    print("  PASSED")
    return True


 

fn test_strategy_universe_get_state() raises -> Bool:
    print("Test: StrategyUniverse get_state")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus)
    
    universe.subscribe("000001.XSHE")
    
    var state = universe.get_state()
    print("  PASSED")
    return True


 

fn test_strategy_universe_set_state() raises -> Bool:
    print("Test: StrategyUniverse set_state")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus)
    
    universe.set_state(Set[String]())
    universe.subscribe("000002.XSHE")
    
    if not universe.contains("000002.XSHE"):
        raise "StrategyUniverse should contain 000002.XSHE after set_state"
    print("  PASSED")
    return True


 

fn test_strategy_universe_clear() raises -> Bool:
    print("Test: StrategyUniverse clear")
    var event_bus = EventBus()
    var universe = create_strategy_universe(event_bus)
    
    universe.subscribe("000001.XSHE")
    universe.subscribe("000002.XSHE")
    
    universe.clear()
    
    if not universe.is_empty():
        raise "StrategyUniverse should be empty after clear"
    print("  PASSED")
    return True


 

fn test_universe_from_list() raises -> Bool:
    print("Test: universe_from_list")
    var event_bus = EventBus()
    var items = List[String]()
    items.append("000001.XSHE")
    items.append("000002.XSHE")
    
    var universe = universe_from_list(event_bus, items)
    
    if universe.size() != 2:
        raise "Universe size should be 2"
    print("  PASSED")
    return True


 

fn test_universe_change_record() raises -> Bool:
    print("Test: UniverseChangeRecord")
    var record = UniverseChangeRecord()
    
    record.add("000001.XSHE")
    record.remove("000002.XSHE")
    
    if not record.has_changes():
        raise "UniverseChangeRecord should have changes"
    if len(record.added) != 1:
        raise "UniverseChangeRecord should have 1 added item"
    if len(record.removed) != 1:
        raise "UniverseChangeRecord should have 1 removed item"
    print("  PASSED")
    return True


 

def main() raises:
    print("=== Group 07 File 01: StrategyUniverse Tests ===")
    print("")
    
    var passed = 0
    var failed = 0
    
    try:
        if test_strategy_universe_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_strategy_universe_subscribe():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_strategy_universe_unsubscribe():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_strategy_universe_update_from_list():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_strategy_universe_get():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_strategy_universe_get_list():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_strategy_universe_get_state():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_strategy_universe_set_state():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_strategy_universe_clear():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_universe_from_list():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_universe_change_record():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
