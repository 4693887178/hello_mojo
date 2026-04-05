from std.python import Python, PythonObject
from rqmojo.data.base_data_source.adjust import adjust_bars, get_price_fields, get_fields_require_adjustment, _is_price_field

# Test basic functions
def test_basic_functions():
    print("Testing basic functions...")
    
    # Test get_price_fields
    var price_fields = get_price_fields()
    print("Price fields count:", len(price_fields))
    
    # Test get_fields_require_adjustment
    var adjustment_fields = get_fields_require_adjustment()
    print("Adjustment fields count:", len(adjustment_fields))
    
    # Test _is_price_field
    print("Is 'open' a price field?", _is_price_field("open"))
    print("Is 'volume' a price field?", _is_price_field("volume"))
    
    print("Basic functions test passed!")

# Test adjust_bars with simple data
def test_adjust_bars() raises:
    print("\nTesting adjust_bars function...")
    
    # Create test data using Python
    var np = Python.import_module("numpy")
    
    # Create sample bars
    var dates = np.array([1609459200, 1609545600, 1609632000, 1609718400, 1609804800])  # 2021-01-01 to 2021-01-05
    var open_prices = np.array([100.0, 101.0, 102.0, 103.0, 104.0])
    var close_prices = np.array([101.0, 102.0, 103.0, 104.0, 105.0])
    var volume = np.array([1000, 2000, 3000, 4000, 5000])
    
    var dtype = [("datetime", "i8"), ("open", "f8"), ("close", "f8"), ("volume", "i