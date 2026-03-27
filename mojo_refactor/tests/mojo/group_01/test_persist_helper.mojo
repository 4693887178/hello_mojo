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


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_file_persist_provider() raises:
    """Test FilePersistProvider."""
    var provider = create_file_persist_provider(PERSIST_MODE.ON_CRASH)
    provider.store("key1", "value1")
    var loaded = provider.load("key1")
    assert_equal(loaded, "value1", "Should load stored value")


def test_memory_persist_provider() raises:
    """Test MemoryPersistProvider."""
    var provider = create_memory_persist_provider()
    provider.store("key1", "value1")
    var loaded = provider.load("key1")
    assert_equal(loaded, "value1", "Should load stored value")


def test_persist_helper_register() raises:
    """Test PersistHelper register."""
    var event_bus = create_event_bus()
    var helper = create_persist_helper(event_bus^, PERSIST_MODE.ON_CRASH)
    helper.register("obj1", "state1")
    var count = helper.get_object_count()
    assert_equal(count, 1, "Should have 1 object registered")


def test_persist_helper_unregister() raises:
    """Test PersistHelper unregister."""
    var event_bus = create_event_bus()
    var helper = create_persist_helper(event_bus^, PERSIST_MODE.ON_CRASH)
    helper.register("obj1", "state1")
    var result = helper.unregister("obj1")
    assert_true(result, "Unregister should return True")
    var count = helper.get_object_count()
    assert_equal(count, 0, "Should have 0 objects after unregister")


def test_persist_helper_persist() raises:
    """Test PersistHelper persist."""
    var event_bus = create_event_bus()
    var helper = create_persist_helper(event_bus^, PERSIST_MODE.ON_CRASH)
    helper.register("obj1", "state1")
    helper.persist()
    assert_true(True, "Persist should succeed")


def test_persist_helper_get_state() raises:
    """Test PersistHelper get_object_state."""
    var event_bus = create_event_bus()
    var helper = create_persist_helper(event_bus^, PERSIST_MODE.ON_CRASH)
    helper.register("obj1", "state1")
    var state = helper.get_object_state("obj1")
    assert_equal(state, "state1", "Should get correct state")


def test_persist_helper_update_state() raises:
    """Test PersistHelper update_object_state."""
    var event_bus = create_event_bus()
    var helper = create_persist_helper(event_bus^, PERSIST_MODE.ON_CRASH)
    helper.register("obj1", "state1")
    helper.update_object_state("obj1", "state2")
    var state = helper.get_object_state("obj1")
    assert_equal(state, "state2", "Should get updated state")


def test_compute_hash() raises:
    """Test _compute_hash_from_string."""
    var hash1 = _compute_hash_from_string("test")
    var hash2 = _compute_hash_from_string("test")
    var hash3 = _compute_hash_from_string("different")
    assert_equal(hash1, hash2, "Same input should produce same hash")
    assert_true(hash1 != hash3, "Different input should produce different hash")


def test_persist_provider_str() raises:
    """Test PersistProvider __str__."""
    var file_provider = create_file_persist_provider(PERSIST_MODE.ON_CRASH)
    var mem_provider = create_memory_persist_provider()
    assert_true(len(file_provider.__str__()) > 0, "FilePersistProvider should have string representation")
    assert_true(len(mem_provider.__str__()) > 0, "MemoryPersistProvider should have string representation")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
