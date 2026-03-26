"""
Test for data/storage_interface.mojo
Group 08 - File 7
"""

from rqmojo.data.storage_interface import StorageInterface, DataStore, create_data_store
from rqmojo.utils.typing import DateTime
from std.collections import List, Dict


fn test_data_store_init() -> Bool:
    print("Test: DataStore init")
    var store = create_data_store()
    print("  PASSED")
    return True


fn test_data_store_store() -> Bool:
    print("Test: DataStore store")
    var store = create_data_store()
    store.store("test_key", "test_value")
    print("  PASSED")
    return True


fn test_data_store_load() -> Bool:
    print("Test: DataStore load")
    var store = create_data_store()
    store.store("test_key", "test_value")
    var value = store.load("test_key")
    print("  PASSED")
    return True


fn test_data_store_keys() -> Bool:
    print("Test: DataStore keys")
    var store = create_data_store()
    store.store("test_key1", "test_value1")
    store.store("test_key2", "test_value2")
    var keys = store.keys()
    if len(keys) != 2:
        return False
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 08 File 7: Storage Interface Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_data_store_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_data_store_store():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_data_store_load():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_data_store_keys():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
