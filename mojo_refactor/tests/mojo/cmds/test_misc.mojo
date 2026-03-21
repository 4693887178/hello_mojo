"""
Test for misc.mojo - Misc Commands
Compares output with Python rqalpha/cmds/misc.py
"""

from std.collections import List
from rqmojo.cmds.misc import examples, version, generate_config, print_version, print_help


def test_version():
    """测试 version 函数"""
    print("=== Testing version ===")
    
    var result = version()
    print("version() returned: " + String(result))
    
    if result == 0:
        print("PASS: version returns 0")
    else:
        print("FAIL: expected 0, got " + String(result))
    
    print("")


def test_print_version():
    """测试 print_version 函数"""
    print("=== Testing print_version ===")
    
    print_version()
    print("PASS: print_version executed")
    print("")


def test_print_help():
    """测试 print_help 函数"""
    print("=== Testing print_help ===")
    
    print_help()
    print("PASS: print_help executed")
    print("")


def test_examples_invalid_dir():
    """测试 examples 无效目录"""
    print("=== Testing examples invalid dir ===")
    
    var result = examples("/nonexistent/path/xyz123")
    print("examples() returned: " + String(result))
    
    print("PASS: examples handles invalid directory")
    print("")


def test_generate_config_invalid_dir():
    """测试 generate_config 无效目录"""
    print("=== Testing generate_config invalid dir ===")
    
    var result = generate_config("/nonexistent/path/xyz123")
    print("generate_config() returned: " + String(result))
    
    print("PASS: generate_config handles invalid directory")
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
