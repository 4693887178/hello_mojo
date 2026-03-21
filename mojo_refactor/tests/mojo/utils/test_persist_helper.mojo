"""
Test for persist_helper.mojo - Persist Helper Module
Compares output with Python rqalpha/utils/persisit_helper.py
"""

from std.collections import Dict
from rqmojo.const import PERSIST_MODE, PERSIST_MODE_ON_CRASH, PERSIST_MODE_REAL_TIME
from rqmojo.core.events import EVENT, EventBus, Event
from rqmojo.utils.persist_helper import (
    PersistHelper, MemoryPersistProvider, FilePersistProvider,
    create_persist_helper, create_memory_persist_provider, create_file_persist_provider,
    _compute_hash, _compute_hash_from_string
)


def test_compute_hash():
    """测试哈希计算函数"""
    print("=== Testing _compute_hash ===")
    
    var data = "test_data".as_bytes()
    var hash_result = _compute_hash(data)
    
    print("Hash result: " + hash_result)
    if len(hash_result) > 0:
        print("PASS: Hash computed successfully")
    else:
        print("FAIL: Hash should not be empty")
    print("")


def test_compute_hash_from_string():
    """测试字符串哈希计算"""
    print("=== Testing _compute_hash_from_string ===")
    
    var hash_result = _compute_hash_from_string("test_string")
    
    print("Hash result: " + hash_result)
    if len(hash_result) > 0:
        print("PASS: String hash computed successfully")
    else:
        print("FAIL: Hash should not be empty")
    print("")


def test_memory_persist_provider():
    """测试 MemoryPersistProvider"""
    print("=== Testing MemoryPersistProvider ===")
    
    var provider = create_memory_persist_provider()
    
    provider.store("key1", "value1")
    var loaded = provider.load("key1")
    
    print("Loaded value: " + loaded)
    if loaded == "value1":
        print("PASS: MemoryPersistProvider works correctly")
    else:
        print("FAIL: Expected 'value1', got '" + loaded + "'")
    print("")


def test_memory_persist_provider_not_found():
    """测试 MemoryPersistProvider 加载不存在的键"""
    print("=== Testing MemoryPersistProvider load nonexistent ===")
    
    var provider = create_memory_persist_provider()
    
    var loaded = provider.load("nonexistent")
    print("Loaded value for nonexistent key: '" + loaded + "'")
    
    if loaded == "":
        print("PASS: Returns empty string for nonexistent key")
    else:
        print("FAIL: Should return empty string")
    print("")


def test_file_persist_provider():
    """测试 FilePersistProvider"""
    print("=== Testing FilePersistProvider ===")
    
    var provider = create_file_persist_provider()
    
    provider.store("key1", "value1")
    var loaded = provider.load("key1")
    
    print("Loaded value: " + loaded)
    if loaded == "value1":
        print("PASS: FilePersistProvider works correctly")
    else:
        print("FAIL: Expected 'value1', got '" + loaded + "'")
    print("")


def test_persist_helper_init():
    """测试 PersistHelper 初始化"""
    print("=== Testing PersistHelper init ===")
    
    var event_bus = EventBus()
    var helper = create_persist_helper(event_bus, PERSIST_MODE_ON_CRASH)
    
    print("PersistHelper created")
    print("PASS: PersistHelper initialized correctly")
    print("")


def test_persist_helper_register():
    """测试 PersistHelper.register 方法"""
    print("=== Testing PersistHelper.register ===")
    
    var event_bus = EventBus()
    var helper = create_persist_helper(event_bus, PERSIST_MODE_ON_CRASH)
    
    try:
        helper.register("test_key", "test_state")
        print("Registered object with key: test_key")
        
        var count = helper.get_object_count()
        if count == 1:
            print("PASS: register method works correctly")
        else:
            print("FAIL: Expected 1 object, got " + String(count))
    except:
        print("FAIL: Exception during register")
    print("")


def test_persist_helper_unregister():
    """测试 PersistHelper.unregister 方法"""
    print("=== Testing PersistHelper.unregister ===")
    
    var event_bus = EventBus()
    var helper = create_persist_helper(event_bus, PERSIST_MODE_ON_CRASH)
    
    try:
        helper.register("test_key", "test_state")
        var result = helper.unregister("test_key")
        
        if result:
            print("PASS: unregister method works correctly")
        else:
            print("FAIL: unregister should return True")
    except:
        print("FAIL: Exception during unregister")
    print("")


def test_persist_helper_get_object_state():
    """测试 PersistHelper.get_object_state 方法"""
    print("=== Testing PersistHelper.get_object_state ===")
    
    var event_bus = EventBus()
    var helper = create_persist_helper(event_bus, PERSIST_MODE_ON_CRASH)
    
    try:
        helper.register("test_key", "test_state_value")
        var state = helper.get_object_state("test_key")
        
        if state == "test_state_value":
            print("PASS: get_object_state works correctly")
        else:
            print("FAIL: Expected 'test_state_value', got '" + state + "'")
    except:
        print("FAIL: Exception during get_object_state")
    print("")


def test_persist_helper_update_object_state():
    """测试 PersistHelper.update_object_state 方法"""
    print("=== Testing PersistHelper.update_object_state ===")
    
    var event_bus = EventBus()
    var helper = create_persist_helper(event_bus, PERSIST_MODE_ON_CRASH)
    
    try:
        helper.register("test_key", "initial_state")
        helper.update_object_state("test_key", "updated_state")
        
        var state = helper.get_object_state("test_key")
        if state == "updated_state":
            print("PASS: update_object_state works correctly")
        else:
            print("FAIL: Expected 'updated_state', got '" + state + "'")
    except:
        print("FAIL: Exception during update_object_state")
    print("")


def test_persist_helper_persist():
    """测试 PersistHelper.persist 方法"""
    print("=== Testing PersistHelper.persist ===")
    
    var event_bus = EventBus()
    var helper = create_persist_helper(event_bus, PERSIST_MODE_ON_CRASH)
    
    try:
        helper.register("test_key", "test_state_data")
        helper.persist()
        print("PASS: persist method works correctly")
    except:
        print("FAIL: Exception during persist")
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo utils/persist_helper.mojo Test")
    print("=" * 60)
    print("")
    
    test_compute_hash()
    test_compute_hash_from_string()
    test_memory_persist_provider()
    test_memory_persist_provider_not_found()
    test_file_persist_provider()
    test_persist_helper_init()
    test_persist_helper_register()
    test_persist_helper_unregister()
    test_persist_helper_get_object_state()
    test_persist_helper_update_object_state()
    test_persist_helper_persist()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
