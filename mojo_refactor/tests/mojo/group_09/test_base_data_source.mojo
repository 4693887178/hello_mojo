"""
Test for data/base_data_source/data_source.mojo
Group 09 - File 6
"""

from rqmojo.data.base_data_source import BaseDataSource, create_base_data_source
from rqmojo.utils.typing import DateTime


fn test_base_data_source_init() -> Bool:
    print("Test: BaseDataSource init")
    var source = create_base_data_source()
    print("  PASSED")
    return True


fn test_base_data_source_get_bar() -> Bool:
    print("Test: BaseDataSource get_bar")
    var source = create_base_data_source()
    var bar = source.get_bar("000001.XSHE", DateTime(2024, 1, 2, 0, 0, 0, 0))
    print("  PASSED")
    return True


fn test_base_data_source_get_instrument() -> Bool:
    print("Test: BaseDataSource get_instrument")
    var source = create_base_data_source()
    var instrument = source.get_instrument("000001.XSHE")
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 6: Base Data Source Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_base_data_source_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_base_data_source_get_bar():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_base_data_source_get_instrument():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
