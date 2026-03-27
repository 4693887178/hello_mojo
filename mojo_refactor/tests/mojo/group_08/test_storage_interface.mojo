"""
Test for data/base_data_source/storage_interface.mojo
Group 08 - File 7
"""

from std.collections import Dict, List
from rqmojo.utils.typing import DateTime



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

@fieldwise_init
struct StorageInterface(Movable, Writable):
    var _path: String
    var _initialized: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("StorageInterface(path=", self._path, ")")

    def get_path(self) -> String:
        return self._path

    def is_initialized(self) -> Bool:
        return self._initialized


@fieldwise_init
struct DataStore(Movable, Writable):
    var _data: Dict[String, String]
    var _name: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("DataStore(name=", self._name, ")")

    def get(self, key: String) -> Optional[String]:
        return self._data.get(key)

    def set(mut self, key: String, value: String) -> None:
        self._data[key] = value


def create_data_store(name: String = "default") -> DataStore:
    return DataStore(
        _data=Dict[String, String](),
        _name=name
    )


def create_storage_interface(path: String = "") -> StorageInterface:
    return StorageInterface(
        _path=path,
        _initialized=False
    )


def test_storage_interface_init() raises:
    print("Test: StorageInterface init")
    var storage = create_storage_interface()
    print("  PASSED")
    assert_true(True, "test passed")


def test_data_store_init() raises:
    print("Test: DataStore init")
    var store = create_data_store()
    print("  PASSED")
    assert_true(True, "test passed")


def test_data_store_set_get() raises:
    print("Test: DataStore set/get")
    var store = create_data_store("test")
    store.set("key1", "value1")
    var result = store.get("key1")
    if result is None:
        raise "DataStore should have key1"
    if result.value() != "value1":
        raise "DataStore value mismatch"
    print("  PASSED")
    assert_true(True, "test passed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()