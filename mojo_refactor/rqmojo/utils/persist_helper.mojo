"""
RQAlpha Mojo - Persistence Provider and Helper
Ported from rqalpha/utils/persisit_helper.py
Reference: rqcpp/utils/persisit_helper.cpp

完全按照 Python/C++ 实现:
- PersistHelper: 核心持久化辅助类
- 支持事件监听器注册 (REAL_TIME 模式)
- 使用 DJB2 哈希替代 MD5

注意: Mojo 不支持 lambda 捕获，事件监听器需要通过 on_event 方法手动调用
"""

from collections import Dict, List
from rqmojo.const import PERSIST_MODE
from rqmojo.core.events import EVENT, EventBus, Event, EventValue
from rqmojo.utils.rq_logger import system_log


fn _compute_hash(data: Span[Byte]) -> String:
    var hash_val: UInt64 = 5381
    for i in range(len(data)):
        hash_val = ((hash_val << 5) + hash_val) + UInt64(data[i])
    var result = String()
    var h = hash_val
    for _ in range(16):
        var nibble = h and 0xF
        if nibble < 10:
            result = result + String(Int(nibble) + 48)
        else:
            result = result + String(Int(nibble) - 10 + 97)
        h = h >> 4
    return result


fn _compute_hash_from_string(s: String) -> String:
    var bytes = s.as_bytes()
    return _compute_hash(bytes)


@fieldwise_init
struct FilePersistProvider(Movable):
    var _storage: Dict[String, String]
    var _mode: PERSIST_MODE
    var _should_resume_flag: Bool
    var _should_run_init_flag: Bool

    fn __str__(self) -> String:
        return "FilePersistProvider(mode=" + self._mode.value + ")"

    fn store(mut self, key: String, value: String) -> None:
        self._storage[key] = value

    fn load(self, key: String) -> String:
        try:
            return self._storage[key]
        except:
            return ""

    fn should_resume(self) -> Bool:
        return self._should_resume_flag

    fn should_run_init(self) -> Bool:
        return self._should_run_init_flag


fn create_file_persist_provider(mode: PERSIST_MODE = PERSIST_MODE.ON_CRASH) -> FilePersistProvider:
    return FilePersistProvider(
        _storage=Dict[String, String](),
        _mode=mode,
        _should_resume_flag=False,
        _should_run_init_flag=True
    )


@fieldwise_init
struct MemoryPersistProvider(Movable):
    var _storage: Dict[String, String]
    var _should_resume_flag: Bool
    var _should_run_init_flag: Bool

    fn __str__(self) -> String:
        return "MemoryPersistProvider()"

    fn store(mut self, key: String, value: String) -> None:
        self._storage[key] = value

    fn load(self, key: String) -> String:
        try:
            return self._storage[key]
        except:
            return ""

    fn should_resume(self) -> Bool:
        return self._should_resume_flag

    fn should_run_init(self) -> Bool:
        return self._should_run_init_flag


fn create_memory_persist_provider() -> MemoryPersistProvider:
    return MemoryPersistProvider(
        _storage=Dict[String, String](),
        _should_resume_flag=False,
        _should_run_init_flag=True
    )


@fieldwise_init
struct PersistHelper(Movable):
    var _objects: Dict[String, String]
    var _last_state: Dict[String, String]
    var _persist_provider: MemoryPersistProvider
    var _event_bus: EventBus
    var _persist_mode: PERSIST_MODE
    var _listeners_registered: Bool

    fn __init__(
        out self,
        var event_bus: EventBus,
        persist_mode: PERSIST_MODE
    ):
        self._objects = Dict[String, String]()
        self._last_state = Dict[String, String]()
        self._persist_provider = create_memory_persist_provider()
        self._event_bus = event_bus^
        self._persist_mode = persist_mode
        self._listeners_registered = False

    fn __str__(self) -> String:
        return "PersistHelper(mode=" + self._persist_mode.value + ", objects=" + String(len(self._objects)) + ")"

    fn _has_object(self, key: String) -> Bool:
        try:
            _ = self._objects[key]
            return True
        except:
            return False

    fn _register_event_listeners(mut self) raises -> None:
        if self._listeners_registered:
            return
        if self._persist_mode == PERSIST_MODE.REAL_TIME:
            self._listeners_registered = True

    fn on_event(mut self, event_type: String, event: Event) -> Bool:
        if self._persist_mode != PERSIST_MODE.REAL_TIME:
            return False
        if event_type == EVENT.POST_BEFORE_TRADING().value:
            self.persist()
            return False
        if event_type == EVENT.POST_AFTER_TRADING().value:
            self.persist()
            return False
        if event_type == EVENT.POST_BAR().value:
            self.persist()
            return False
        if event_type == EVENT.DO_PERSIST().value:
            self.persist()
            return False
        if event_type == EVENT.POST_SETTLEMENT().value:
            self.persist()
            return False
        if event_type == EVENT.DO_RESTORE().value:
            _ = self.restore(event)
            return False
        return False

    fn persist(mut self) -> None:
        var keys_list = List[String]()
        for key in self._objects.keys():
            keys_list.append(key)
        for key in keys_list:
            try:
                var state = self._objects[key]
                self._persist_object(key, state)
            except:
                system_log().exception("PersistHelper.persist fail")

    fn _persist_object(mut self, key: String, state: String) -> None:
        if state == "":
            return
        var md5 = _compute_hash_from_string(state)
        var last_match = False
        try:
            var last = self._last_state[key]
            if last == md5:
                last_match = True
        except:
            pass
        if last_match:
            return
        self._persist_provider.store(key, state)
        self._last_state[key] = md5

    fn register(mut self, key: String, state: String) raises -> None:
        if self._has_object(key):
            raise Error("duplicated persist key found: " + key)
        self._objects[key] = state

    fn unregister(mut self, key: String) -> Bool:
        if self._has_object(key):
            try:
                _ = self._objects.pop(key)
            except:
                pass
            return True
        return False

    fn restore(mut self, event: Event) -> Dict[String, Bool]:
        var event_key = event.attributes.get("key", EventValue(""))
        if event_key.isa[String]():
            var key_str = event_key[String]
            if len(key_str) > 0:
                if self._has_object(key_str):
                    var result = Dict[String, Bool]()
                    result[key_str] = self._restore_obj(key_str)
                    return result^

        var result = Dict[String, Bool]()
        var keys_list = List[String]()
        for key in self._objects.keys():
            keys_list.append(key)
        for key in keys_list:
            result[key] = self._restore_obj(key)
        return result^

    fn _restore_obj(mut self, key: String) -> Bool:
        var state = self._persist_provider.load(key)
        system_log().debug("restore " + key + " with state = " + state)
        if state == "":
            return False
        try:
            self._objects[key] = state
        except:
            system_log().exception("restore failed: key=" + key)
        return True

    fn get_object_count(self) -> Int:
        return len(self._objects)

    fn get_object_state(self, key: String) -> String:
        try:
            return self._objects[key]
        except:
            return ""

    fn update_object_state(mut self, key: String, state: String) -> None:
        if self._has_object(key):
            self._objects[key] = state


fn create_persist_helper(
    var event_bus: EventBus,
    persist_mode: PERSIST_MODE = PERSIST_MODE.ON_CRASH
) -> PersistHelper:
    return PersistHelper(
        event_bus=event_bus^,
        persist_mode=persist_mode
    )
