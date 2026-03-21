# -*- coding: utf-8 -*-
"""
Test for rqalpha/utils/persisit_helper.py - Persist Helper Module
Compares output with Mojo rqmojo/utils/persist_helper.mojo
"""

from collections import OrderedDict
from unittest.mock import Mock, MagicMock
from rqalpha.const import PERSIST_MODE
from rqalpha.core.events import EVENT, EventBus
from rqalpha.utils.persisit_helper import PersistHelper


class MockPersistProvider:
    """Mock persist provider for testing"""
    
    def __init__(self):
        self._storage = {}
        self._should_resume = False
        self._should_run_init = True
    
    def store(self, key, value):
        self._storage[key] = value
    
    def load(self, key):
        return self._storage.get(key, None)
    
    def should_resume(self):
        return self._should_resume
    
    def should_run_init(self):
        return self._should_run_init


def test_persist_helper_init_on_crash():
    """测试 PersistHelper 初始化 (ON_CRASH 模式)"""
    print("=== Testing PersistHelper init (ON_CRASH mode) ===")
    
    provider = MockPersistProvider()
    event_bus = EventBus()
    
    helper = PersistHelper(provider, event_bus, PERSIST_MODE.ON_CRASH)
    
    print(f"PersistHelper created with mode: {helper._persist_mode}")
    
    assert helper._persist_mode == PERSIST_MODE.ON_CRASH
    assert len(helper._objects) == 0
    
    print("PASS: PersistHelper initialized correctly (ON_CRASH)")
    print("")


def test_persist_helper_init_real_time():
    """测试 PersistHelper 初始化 (REAL_TIME 模式)"""
    print("=== Testing PersistHelper init (REAL_TIME mode) ===")
    
    provider = MockPersistProvider()
    event_bus = EventBus()
    
    helper = PersistHelper(provider, event_bus, PERSIST_MODE.REAL_TIME)
    
    print(f"PersistHelper created with mode: {helper._persist_mode}")
    
    assert helper._persist_mode == PERSIST_MODE.REAL_TIME
    
    print("PASS: PersistHelper initialized correctly (REAL_TIME)")
    print("")


def test_persist_helper_register():
    """测试 PersistHelper.register 方法"""
    print("=== Testing PersistHelper.register ===")
    
    provider = MockPersistProvider()
    event_bus = EventBus()
    helper = PersistHelper(provider, event_bus, PERSIST_MODE.ON_CRASH)
    
    mock_obj = Mock()
    mock_obj.get_state = Mock(return_value=b"test_state")
    
    helper.register("test_key", mock_obj)
    
    print(f"Registered object with key: test_key")
    assert "test_key" in helper._objects
    
    print("PASS: register method works correctly")
    print("")


def test_persist_helper_register_duplicate():
    """测试 PersistHelper.register 重复键"""
    print("=== Testing PersistHelper.register duplicate key ===")
    
    provider = MockPersistProvider()
    event_bus = EventBus()
    helper = PersistHelper(provider, event_bus, PERSIST_MODE.ON_CRASH)
    
    mock_obj = Mock()
    mock_obj.get_state = Mock(return_value=b"test_state")
    
    helper.register("test_key", mock_obj)
    
    try:
        helper.register("test_key", mock_obj)
        print("FAIL: Should have raised RuntimeError for duplicate key")
    except RuntimeError as e:
        print(f"PASS: Correctly raised RuntimeError: {e}")
    print("")


def test_persist_helper_unregister():
    """测试 PersistHelper.unregister 方法"""
    print("=== Testing PersistHelper.unregister ===")
    
    provider = MockPersistProvider()
    event_bus = EventBus()
    helper = PersistHelper(provider, event_bus, PERSIST_MODE.ON_CRASH)
    
    mock_obj = Mock()
    mock_obj.get_state = Mock(return_value=b"test_state")
    
    helper.register("test_key", mock_obj)
    result = helper.unregister("test_key")
    
    print(f"Unregister result: {result}")
    assert result == True
    assert "test_key" not in helper._objects
    
    print("PASS: unregister method works correctly")
    print("")


def test_persist_helper_unregister_nonexistent():
    """测试 PersistHelper.unregister 不存在的键"""
    print("=== Testing PersistHelper.unregister nonexistent key ===")
    
    provider = MockPersistProvider()
    event_bus = EventBus()
    helper = PersistHelper(provider, event_bus, PERSIST_MODE.ON_CRASH)
    
    result = helper.unregister("nonexistent_key")
    
    print(f"Unregister result: {result}")
    assert result == False
    
    print("PASS: unregister nonexistent key returns False")
    print("")


def test_persist_helper_persist():
    """测试 PersistHelper.persist 方法"""
    print("=== Testing PersistHelper.persist ===")
    
    provider = MockPersistProvider()
    event_bus = EventBus()
    helper = PersistHelper(provider, event_bus, PERSIST_MODE.ON_CRASH)
    
    mock_obj = Mock()
    mock_obj.get_state = Mock(return_value=b"test_state_data")
    
    helper.register("test_key", mock_obj)
    helper.persist()
    
    stored = provider.load("test_key")
    print(f"Stored data: {stored}")
    
    assert stored == b"test_state_data"
    
    print("PASS: persist method works correctly")
    print("")


def test_persist_helper_persist_empty_state():
    """测试 PersistHelper.persist 空状态"""
    print("=== Testing PersistHelper.persist empty state ===")
    
    provider = MockPersistProvider()
    event_bus = EventBus()
    helper = PersistHelper(provider, event_bus, PERSIST_MODE.ON_CRASH)
    
    mock_obj = Mock()
    mock_obj.get_state = Mock(return_value=None)
    
    helper.register("test_key", mock_obj)
    helper.persist()
    
    stored = provider.load("test_key")
    print(f"Stored data: {stored}")
    
    assert stored is None
    
    print("PASS: persist empty state handled correctly")
    print("")


def test_persist_helper_restore():
    """测试 PersistHelper.restore 方法"""
    print("=== Testing PersistHelper.restore ===")
    
    provider = MockPersistProvider()
    provider.store("test_key", b"restored_state")
    
    event_bus = EventBus()
    helper = PersistHelper(provider, event_bus, PERSIST_MODE.ON_CRASH)
    
    mock_obj = Mock()
    mock_obj.get_state = Mock(return_value=b"test_state")
    mock_obj.set_state = Mock()
    
    helper.register("test_key", mock_obj)
    
    event = Mock()
    event.key = None
    
    result = helper.restore(event)
    
    print(f"Restore result: {result}")
    mock_obj.set_state.assert_called_once()
    
    print("PASS: restore method works correctly")
    print("")


if __name__ == "__main__":
    print("=" * 60)
    print("RQAlpha Python utils/persisit_helper.py Test")
    print("=" * 60)
    print("")
    
    test_persist_helper_init_on_crash()
    test_persist_helper_init_real_time()
    test_persist_helper_register()
    test_persist_helper_register_duplicate()
    test_persist_helper_unregister()
    test_persist_helper_unregister_nonexistent()
    test_persist_helper_persist()
    test_persist_helper_persist_empty_state()
    test_persist_helper_restore()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
