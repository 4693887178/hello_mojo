# -*- coding: utf-8 -*-
"""
RQMojo Test Suite - Group 01
File: utils/click_helper.py (Python test)
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


def test_click_helper():
    """Test utils/click_helper.py"""
    from rqalpha.utils.click_helper import Date
    import pandas as pd
    
    result = {
        "module": "utils/click_helper.py",
        "tests": []
    }
    
    # Test 1: Date class exists
    test1 = {
        "name": "Date class exists",
        "input": None,
        "expected": True,
        "actual": Date is not None,
        "passed": Date is not None
    }
    result["tests"].append(test1)
    
    # Test 2: Date is a click.ParamType
    import click
    test2 = {
        "name": "Date is click.ParamType",
        "input": None,
        "expected": True,
        "actual": issubclass(Date, click.ParamType),
        "passed": issubclass(Date, click.ParamType)
    }
    result["tests"].append(test2)
    
    # Test 3: Date has convert method
    date_param = Date()
    test3 = {
        "name": "Date has convert method",
        "input": None,
        "expected": True,
        "actual": hasattr(date_param, 'convert'),
        "passed": hasattr(date_param, 'convert')
    }
    result["tests"].append(test3)
    
    # Test 4: Date convert returns Timestamp
    converted = date_param.convert("2020-01-01", None, None)
    test4 = {
        "name": "Date convert returns Timestamp",
        "input": "2020-01-01",
        "expected": pd.Timestamp,
        "actual_type": str(type(converted)),
        "passed": isinstance(converted, pd.Timestamp)
    }
    result["tests"].append(test4)
    
    # Test 5: Date name property
    test5 = {
        "name": "Date name property returns 'DATE'",
        "input": None,
        "expected": "DATE",
        "actual": date_param.name,
        "passed": date_param.name == "DATE"
    }
    result["tests"].append(test5)
    
    # Test 6: Date with timezone
    date_with_tz = Date(tz="UTC")
    test6 = {
        "name": "Date accepts tz parameter",
        "input": "UTC",
        "expected": "UTC",
        "actual": date_with_tz.tz,
        "passed": date_with_tz.tz == "UTC"
    }
    result["tests"].append(test6)
    
    # Test 7: Date convert with different format
    converted2 = date_param.convert("2021-12-31", None, None)
    test7 = {
        "name": "Date convert with different date",
        "input": "2021-12-31",
        "expected": True,
        "actual": isinstance(converted2, pd.Timestamp),
        "passed": isinstance(converted2, pd.Timestamp)
    }
    result["tests"].append(test7)
    
    return result


def main():
    """Run all tests and print results"""
    print("=" * 60)
    print("Test: utils/click_helper.py (Python)")
    print("=" * 60)
    
    all_results = []
    
    tests = [
        ("utils/click_helper.py", test_click_helper),
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
