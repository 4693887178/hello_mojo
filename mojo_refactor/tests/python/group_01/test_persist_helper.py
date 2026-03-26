#!/usr/bin/env python3
"""
Test for checking if persist_helper.py exists in Python rqalpha
"""

import sys
import os

# Add the Python package path
sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')


def test_persist_helper_not_exist():
    """Test that persist_helper.py does not exist in Python rqalpha"""
    print("Test 1: Check if persist_helper.py exists in Python")
    
    try:
        from rqalpha.utils import persist_helper
        print("  FAIL: File exists but should not")
        return False
    except ImportError:
        print("  File does not exist in Python rqalpha (expected)")
        print("  PASS")
        return True


def test_related_files():
    """Test related persistence files in Python"""
    print("Test 2: Check related persistence functionality")
    
    # Check if there's any persistence-related code
    import rqalpha
    print(f"  rqalpha version: {rqalpha.__version__}")
    
    # List utils directory
    import os
    utils_path = '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages/rqalpha/utils'
    files = [f for f in os.listdir(utils_path) if f.endswith('.py')]
    persist_files = [f for f in files if 'persist' in f.lower()]
    print(f"  Persist-related files: {persist_files}")
    print("  PASS")
    return True


def main():
    print("=" * 60)
    print("Python persist_helper.py Test")
    print("=" * 60)
    
    results = []
    results.append(test_persist_helper_not_exist())
    results.append(test_related_files())
    
    print()
    print("=" * 60)
    print(f"Results: {sum(results)}/{len(results)} passed")
    print("=" * 60)
    
    return sum(results) == len(results)


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
