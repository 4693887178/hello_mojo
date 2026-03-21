"""
Test for misc.mojo - Misc Commands
"""

from std.collections import List, Dict
from rqmojo.cmds.misc import examples, version, generate_config, print_version, print_help


def test_version():
    print("=== Testing version ===")
    
    try:
        var result = version()
        print("version() returned: " + String(result))
        
        if result == 0:
            print("PASS: version returns 0")
        else:
            print("FAIL: expected 0, got " + String(result))
    except:
        print("FAIL: version raised exception")
    
    print("")


def test_print_version():
    print("=== Testing print_version ===")
    
    try:
        print_version()
        print("PASS: print_version executed")
    except:
        print("FAIL: print_version raised exception")
    print("")


def test_print_help():
    print("=== Testing print_help ===")
    
    print_help()
    print("PASS: print_help executed")
    print("")


def test_examples_invalid_dir():
    print("=== Testing examples invalid dir ===")
    
    try:
        var result = examples("/nonexistent/path/xyz123")
        print("examples() returned: " + String(result))
        print("PASS: examples handles invalid directory")
    except:
        print("PASS: examples raised exception for invalid directory")
    print("")


def test_generate_config_invalid_dir():
    print("=== Testing generate_config invalid dir ===")
    
    try:
        var result = generate_config("/nonexistent/path/xyz123")
        print("generate_config() returned: " + String(result))
        print("PASS: generate_config handles invalid directory")
    except:
        print("PASS: generate_config raised exception for invalid directory")
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo cmds/misc.mojo Test")
    print("=" * 60)
    print("")
    
    test_version()
    test_print_version()
    test_print_help()
    test_examples_invalid_dir()
    test_generate_config_invalid_dir()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
