from std.io import print
from std.collections import Dict
from rqmojo.utils.persist_helper import create_persist_helper, create_event_bus, _compute_hash_from_string, create_file_persist_provider, create_memory_persist_provider
from rqmojo.const import PERSIST_MODE
from rqmojo.core.events import Event, EventValue


fn main() raises:
    # 测试哈希函数
    print("Testing hash function...")
    var s1 = "test string"
    var s2 = "test string"
    var s3 = "different string"
    
    var hash1 = _compute_hash_from_string(s1)
    var hash2 = _compute_hash_from_string(s2)
    var hash3 = _compute_hash_from_string(s3)
    
    if hash1 != hash2:
        print("FAIL: 相同字符串应该产生相同的哈希值")
        return
    if hash1 == hash3:
        print("FAIL: 不同字符串应该产生不同的哈希值")
        return
    if len(hash1) != 16:
        print("FAIL: 哈希值长度应该为16")
        return
    print("PASS: 哈希函数测试通过")
    
    # 测试 PersistHelper 基本功能
    print("\nTesting PersistHelper basic functionality...")
    var event_bus = create_event_bus()
    var helper = create_persist_helper(event_bus^, PERSIST_MODE.ON_CRASH)
    
    # 测试注册
    helper.register("test_key", "test_value")
    if helper.get_object_count() != 1:
        print("FAIL: 注册后对象数量应该为1")
        return
    if helper.get_object_state("test_key") != "test_value":
        print("FAIL: 获取对象状态应该正确")
        return
    
    # 测试重复注册
    var raised = False
    try:
        helper.register("test_key", "new_value")
    except:
        raised = True
    if not raised:
        print("FAIL: 重复注册应该抛出异常")
        return
    
    # 测试更新对象状态
    helper.update_object_state("test_key", "updated_value")
    if helper.get_object_state("test_key") != "updated_value":
        print("FAIL: 更新对象状态应该正确")
        return
    
    # 测试持久化
    helper.persist()
    
    # 测试恢复
    var event = Event(
        event_type="DO_RESTORE",
        attributes=Dict[String, EventValue]()
    )
    var restore_result = helper.restore(event)
    if len(restore_result) != 1:
        print("FAIL: 恢复结果应该包含1个对象")
        return
    if not restore_result["test_key"]:
        print("FAIL: 恢复应该成功")
        return
    
    # 测试注销
    var unregistered = helper.unregister("test_key")
    if not unregistered:
        print("FAIL: 注销应该成功")
        return
    if helper.get_object_count() != 0:
        print("FAIL: 注销后对象数量应该为0")
        return
    print("PASS: PersistHelper 基本功能测试通过")
    
    # 测试空键处理
    print("\nTesting empty key handling...")
    var event_bus2 = create_event_bus()
    var helper2 = create_persist_helper(event_bus2^, PERSIST_MODE.ON_CRASH)
    
    # 测试空键注册
    var raised2 = False
    try:
        helper2.register("", "test_value")
    except:
        raised2 = True
    if not raised2:
        print("FAIL: 空键注册应该抛出异常")
        return
    
    # 测试空键注销
    var unregistered2 = helper2.unregister("")
    if unregistered2:
        print("FAIL: 空键注销应该返回False")
        return
    print("PASS: 空键处理测试通过")
    
    # 测试实时模式
    print("\nTesting real-time mode...")
    var event_bus3 = create_event_bus()
    var helper3 = create_persist_helper(event_bus3^, PERSIST_MODE.REAL_TIME)
    
    # 测试注册
    helper3.register("test_key", "test_value")
    
    # 测试事件处理
    var event3 = Event(
        event_type="POST_BAR",
        attributes=Dict[String, EventValue]()
    )
    var result = helper3.on_event(event3)
    if result:
        print("FAIL: 事件处理应该返回False")
        return
    print("PASS: 实时模式测试通过")
    
    # 测试持久化提供者
    print("\nTesting persist providers...")
    
    # 测试 FilePersistProvider
    var file_provider = create_file_persist_provider()
    file_provider.store("key1", "value1")
    if file_provider.load("key1") != "value1":
        print("FAIL: FilePersistProvider 存储和加载应该正确")
        return
    if file_provider.load("non_existent") != "":
        print("FAIL: 加载不存在的键应该返回空字符串")
        return
    
    # 测试 MemoryPersistProvider
    var memory_provider = create_memory_persist_provider()
    memory_provider.store("key1", "value1")
    if memory_provider.load("key1") != "value1":
        print("FAIL: MemoryPersistProvider 存储和加载应该正确")
        return
    if memory_provider.load("non_existent") != "":
        print("FAIL: 加载不存在的键应该返回空字符串")
        return
    print("PASS: 持久化提供者测试通过")
    
    print("\nAll tests passed!")



