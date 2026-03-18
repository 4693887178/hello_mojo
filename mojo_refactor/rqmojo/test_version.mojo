"""
Test for _version.mojo
Testing version information module.
"""

from rqmojo._version import Version, get_version


fn test_version_constants() raises:
    """Test version constants."""
    print("Testing version constants...")
    
    # Test major version
    if Version.MAJOR != 0:
        raise Error("MAJOR version should be 0")
    
    # Test minor version
    if Version.MINOR != 1:
        raise Error("MINOR version should be 1")
    
    # Test patch version
    if Version.PATCH != 0:
        raise Error("PATCH version should be 0")
    
    # Test version string
    if Version.VERSION != "0.1.0":
        raise Error("VERSION string should be '0.1.0'")
    
    print("  ✓ Version constants test passed")


fn test_get_version_function() raises:
    """Test get_version function."""
    print("Testing get_version function...")
    
    var version = get_version()
    if version != "0.1.0":
        raise Error("get_version() should return '0.1.0'")
    
    print("  ✓ get_version function test passed")


fn test_version_format() raises:
    """Test version format."""
    print("Testing version format...")
    
    var version = get_version()
    
    # Verify version format follows semantic versioning
    var parts = version.split(".")
    if len(parts) != 3:
        raise Error("Version should have 3 parts")
    
    # Verify each part is a number
    try:
        var major = Int(parts[0])
        var minor = Int(parts[1])
        var patch = Int(parts[2])
        
        if major != Version.MAJOR:
            raise Error("Major version mismatch")
        if minor != Version.MINOR:
            raise Error("Minor version mismatch")
        if patch != Version.PATCH:
            raise Error("Patch version mismatch")
    except:
        raise Error("Version parts should be integers")
    
    print("  ✓ Version format test passed")


fn main() raises:
    print("========================================")
    print("Running tests for _version.mojo")
    print("========================================")
    print()
    
    test_version_constants()
    test_get_version_function()
    test_version_format()
    
    print()
    print("========================================")
    print("✓ All tests passed!")
    print("========================================")
