"""
Test for data/base_data_source/storage_interface.mojo
Group 08 - File 3
"""

from std.collections import List, Dict
from rqmojo.data.base_data_source.storage_interface import DataArray, create_data_array


def test_data_array_struct() -> Bool:
    print("Test: DataArray struct exists")
    var da = create_data_array()
    if not da.is_empty():
        raise "New DataArray should be empty"
    print("  PASSED")
    return True


def test_data_array_add_int_column() -> Bool:
    print("Test: DataArray add_int_column")
    var da = create_data_array()
    var data = List[Int]()
    data.append(1)
    data.append(2)
    data.append(3)
    da.add_int_column("id", data^)
    
    if da.row_count() != 3:
        raise "Row count should be 3"
    
    var val = da.get_int("id", 0)
    if val == None or val.value() != 1:
        raise "First value should be 1"
    print("  PASSED")
    return True


def test_data_array_add_float_column() -> Bool:
    print("Test: DataArray add_float_column")
    var da = create_data_array()
    var data = List[Float64]()
    data.append(1.5)
    data.append(2.5)
    data.append(3.5)
    da.add_float_column("price", data^)
    
    if da.row_count() != 3:
        raise "Row count should be 3"
    
    var val = da.get_float("price", 1)
    if val == None or val.value() != 2.5:
        raise "Second value should be 2.5"
    print("  PASSED")
    return True


def test_data_array_column_index() -> Bool:
    print("Test: DataArray column_index")
    var da = create_data_array()
    var data = List[Int]()
    data.append(1)
    da.add_int_column("col1", data^)
    
    var idx = da.column_index("col1")
    if idx == None or idx.value() != 0:
        raise "col1 index should be 0"
    
    var missing = da.column_index("missing")
    if missing != None:
        raise "Missing column should return None"
    print("  PASSED")
    return True


def test_data_array_slice() -> Bool:
    print("Test: DataArray slice")
    var da = create_data_array()
    var data = List[Int]()
    for i in range(10):
        data.append(i)
    da.add_int_column("id", data^)
    
    var sliced = da.slice(2, 5)
    if sliced.row_count() != 3:
        raise "Sliced row count should be 3"
    
    var val = sliced.get_int("id", 0)
    if val == None or val.value() != 2:
        raise "First sliced value should be 2"
    print("  PASSED")
    return True


def test_data_array_multiple_columns() -> Bool:
    print("Test: DataArray multiple columns")
    var da = create_data_array()
    
    var ids = List[Int]()
    ids.append(1)
    ids.append(2)
    
    var prices = List[Float64]()
    prices.append(10.5)
    prices.append(20.5)
    
    da.add_int_column("id", ids^)
    da.add_float_column("price", prices^)
    
    if len(da.field_names) != 2:
        raise "Should have 2 field names"
    
    if da.row_count() != 2:
        raise "Row count should be 2"
    print("  PASSED")
    return True


def main() -> None:
    print("=== Group 08 File 3: Storage Interface Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    if test_data_array_struct():
        passed += 1
    else:
        failed += 1
    
    if test_data_array_add_int_column():
        passed += 1
    else:
        failed += 1
    
    if test_data_array_add_float_column():
        passed += 1
    else:
        failed += 1
    
    if test_data_array_column_index():
        passed += 1
    else:
        failed += 1
    
    if test_data_array_slice():
        passed += 1
    else:
        failed += 1
    
    if test_data_array_multiple_columns():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
