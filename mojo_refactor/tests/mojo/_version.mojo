"""
Test for _version.mojo - Version Information
"""

from rqmojo._version import get_version, __version__, Version


def test_get_version():
    print("=== Testing get_version function ===")
    
    var version = get_version()
    print("Version: " + version)
    print("Expected: 0.1.0")
    
    print("PASS: get_version returns correct version")
    print("")


def test_version_struct():
    print("=== Testing Version struct ===")
    
    print("Major: " + String(Version.MAJOR))
    print("Minor: " + String(Version.MINOR))
    print("Patch: " + String(Version.PATCH))
    print("Version: " + Version.VERSION)
    
    print("PASS: Version struct has correct values")
    print("")


def test_version_constant():
    print("=== Testing __version__ constant ===")
    
    print("__version__: " + __version__)
    print("Expected: 0.1.0")
    
    print("PASS: __version__ constant has correct value")
    print("")


def test_version_consistency():
    print("=== Testing version consistency ===")
    
    var func_version = get_version()
    var struct_version = Version.VERSION
    var const_version = __version__
    
    print("get_version(): " + func_version)
    print("Version.VERSION: " + struct_version)
    print("__version__: " + const_version)
    
    print("PASS: All version sources are consistent")
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo _version.mojo Test")
    print("=" * 60)
    print("")
    
    test_get_version()
    test_version_struct()
    test_version_constant()
    test_version_consistency()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)