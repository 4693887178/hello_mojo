from rqmojo.utils.package_helper import import_mod

fn main() raises:
    # Test importing a standard Python module
    var math_mod = import_mod("math")
    print("Successfully imported math module")
    
    # Test importing a non-existent module to test error handling
    try:
        var non_existent = import_mod("non_existent_module_12345")
    except:
        print("Successfully caught error for non-existent module")
    
    print("All tests passed!")
