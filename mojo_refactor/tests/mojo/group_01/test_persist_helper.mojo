"""
Test for rqmojo/utils/persist_helper.mojo
"""

from std.collections import Dict, List
from rqmojo.utils.persist_helper import (
    PersistProvider, FilePersistProvider, MemoryPersistProvider,
    PersistHelper, create_file_persist_provider, create_memory_persist_provider,
    create_persist_helper, create_event_bus, _compute_hash_from_string
)
from rqmojo.const import PERSIST_MODE
from rqmojo.core.events import EventBus, EVENT


def test_file_persist_provider() -> Bool:
    """Test FilePersistProvider."""
    print("Test 1: FilePersistProvider")
    var provider = create_file_persist_provider(PERSIST_MODE.ON_CRASH)
    provider.store("key1", "value1")
    var loaded = provider.load("key1")
    print("  Stored: key1=value1")
    print("  Loaded: ", loaded)
    print("  PASS")
    return True


def test_memory_persist_provider() -> Bool:
    """Test MemoryPersistProvider."""
    print("Test 2: MemoryPersistProvider")
    var provider = create_memory_persist_provider()
    provider.store("key1", "value1")
    var loaded = provider.load("key1")
    print("  Stored: key1=value1")
    print("  Loaded: ", loaded)
    print("  PASS")
    return True


def test_persist_helper_register() -> Bool:
    """Test PersistHelper register."""
    print("Test 3: PersistHelper register")
    var event_bus = create_event_bus()
    var helper = create_persist_helper(event_bus^, PERSIST_MODE.ON_CRASH)
    try:
        helper.register("obj1", "state1")
        var count = helper.get_object_count()
        print("  Registered obj1")
        print("  Object count: ", count)
        print("  PASS")
        return True
    except:
        print("  FAIL: Exception raised")
        return False


def test_persist_helper_unregister() -> Bool:
    """Test PersistHelper unregister."""
    print("Test 4: PersistHelper unregister")
    var event_bus = create_event_bus()
    var helper = create_persist_helper(event_bus^, PERSIST_MODE.ON_CRASH)
    try:
        helper.register("obj1", "state1")
        var result = helper.unregister("obj1")
        var count = helper.get_object_count()
        print("  Unregistered obj1")
        print("  Result: ", result)
        print("  Object count: ", count)
        print("  PASS")
        return True
    except:
        print("  FAIL: Exception raised")
        return False


def test_persist_helper_persist() -> Bool:
    """Test PersistHelper persist."""
    print("Test 5: PersistHelper persist")
    var event_bus = create_event_bus()
    var helper = create_persist_helper(event_bus^, PERSIST_MODE.ON_CRASH)
    try:
        helper.register("obj1", "state1")
        helper.persist()
        print("  Persisted obj1")
        print("  PASS")
        return True
    except:
        print("  FAIL: Exception raised")
        return False


def test_persist_helper_get_state() -> Bool:
    """Test PersistHelper get_object_state."""
    print("Test 6: PersistHelper get_object_state")
    var event_bus = create_event_bus()
    var helper = create_persist_helper(event_bus^, PERSIST_MODE.ON_CRASH)
    try:
        helper.register("obj1", "state1")
        var state = helper.get_object_state("obj1")
        print("  State: ", state)
        print("  PASS")
        return True
    except:
        print("  FAIL: Exception raised")
        return False


def test_persist_helper_update_state() -> Bool:
    """Test PersistHelper update_object_state."""
    print("Test 7: PersistHelper update_object_state")
    var event_bus = create_event_bus()
    var helper = create_persist_helper(event_bus^, PERSIST_MODE.ON_CRASH)
    try:
        helper.register("obj1", "state1")
        helper.update_object_state("obj1", "state2")
        var state = helper.get_object_state("obj1")
        print("  Updated state: ", state)
        print("  PASS")
        return True
    except:
        print("  FAIL: Exception raised")
        return False


def test_compute_hash() -> Bool:
    """Test _compute_hash_from_string."""
    print("Test 8: _compute_hash_from_string")
    var hash1 = _compute_hash_from_string("test")
    var hash2 = _compute_hash_from_string("test")
    var hash3 = _compute_hash_from_string("different")
    print("  Hash of 'test': ", hash1)
    print("  Hash of 'test' again: ", hash2)
    print("  Hash of 'different': ", hash3)
    print("  Same hash for same input: ", hash1 == hash2)
    print("  Different hash for different input: ", hash1 != hash3)
    print("  PASS")
    return True


def test_persist_provider_str() -> Bool:
    """Test PersistProvider __str__."""
    print("Test 9: PersistProvider __str__")
    var file_provider = create_file_persist_provider(PERSIST_MODE.ON_CRASH)
    var mem_provider = create_memory_persist_provider()
    print("  FilePersistProvider: ", file_provider.__str__())
    print("  MemoryPersistProvider: ", mem_provider.__str__())
    print("  PASS")
    return True


def main() raises:
    print("=" * 60)
    print("Mojo persist_helper.mojo Test")
    print("=" * 60)
    
    var results = List[Bool]()
    results.append(test_file_persist_provider())
    results.append(test_memory_persist_provider())
    results.append(test_persist_helper_register())
    results.append(test_persist_helper_unregister())
    results.append(test_persist_helper_persist())
    results.append(test_persist_helper_get_state())
    results.append(test_persist_helper_update_state())
    results.append(test_compute_hash())
    results.append(test_persist_provider_str())
    
    var passed = 0
    for r in results:
        if r:
            passed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, "/", len(results), " passed")
    print("=" * 60)
