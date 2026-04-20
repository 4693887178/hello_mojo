# -*- coding: utf-8 -*-
"""
RQMojo Test Suite - Group 01
File: user_module.py (Python test)
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


def test_user_module():
    """Test user_module.py"""
    import rqalpha.user_module as user_module
    
    result = {
        "module": "user_module.py",
        "tests": []
    }
    
    # Test 1: module exists
    test1 = {
        "name": "user_module module exists",
        "input": None,
        "expected": True,
        "actual": user_module is not None,
        "passed": user_module is not None
    }
    result["tests"].append(test1)
    
    # Test 2: module has __file__
    test2 = {
        "name": "user_module has __file__",
        "input": None,
        "expected": True,
        "actual": hasattr(user_module, '__file__'),
        "passed": hasattr(user_module, '__file__')
    }
    result["tests"].append(test2)
    
    # Test 3: module has no public exports (empty file)
    public_items = [name for name in dir(user_module) if not name.startswith('_')]
    test3 = {
        "name": "user_module has no public exports",
        "input": None,
        "expected": 0,
        "actual": len(public_items),
        "passed": len(public_items) == 0
    }
    result["tests"].append(test3)
    
    return result


def main():
    """Run all tests and print results"""
    print("=" * 60)
    print("Test: user_module.py (Python)")
    print("=" * 60)
    
    all_results = []
    
    tests = [
        ("user_module.py", test_user_module),
    ]
    
    total_tests = 0
    passed_tests = 0
    
    for name, test_func in tests:
        print(f"\n--- Testing {name} ---")
        try:
            result = test_func()
            all_results.append(result)
            
            for test in result["tests"]:
                total_tests += 1
                status = "PASS" if test["passed"] else "FAIL"
                if test["passed"]:
                    passed_tests += 1
                print(f"  [{status}] {test['name']}")
                if not test["passed"]:
                    print(f"         Expected: {test.get('expected', 'N/A')}")
                    print(f"         Actual: {test.get('actual', 'N/A')}")
        except Exception as e:
            print(f"  [ERROR] {name}: {e}")
            all_results.append({"module": name, "tests": [], "error": str(e)})
    
    print("\n" + "=" * 60)
    print(f"Total: {passed_tests}/{total_tests} tests passed")
    print("=" * 60)
    
    return all_results


if __name__ == "__main__":
    main()
