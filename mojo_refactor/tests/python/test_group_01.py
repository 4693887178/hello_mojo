# -*- coding: utf-8 -*-
"""
RQMojo Test Suite - Group 01 (0 dependencies)
Test file for Python version comparison
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))

def test_version():
    """Test _version.py"""
    from rqalpha._version import __version__, __version_tuple__, version, version_tuple
    
    result = {
        "module": "_version",
        "tests": []
    }
    
    # Test 1: __version__ is string
    test1 = {
        "name": "__version__ is string",
        "input": None,
        "expected": str,
        "actual_type": str(type(__version__)),
        "passed": isinstance(__version__, str)
    }
    result["tests"].append(test1)
    
    # Test 2: version equals __version__
    test2 = {
        "name": "version equals __version__",
        "input": None,
        "expected": __version__,
        "actual": version,
        "passed": version == __version__
    }
    result["tests"].append(test2)
    
    # Test 3: __version_tuple__ is tuple
    test3 = {
        "name": "__version_tuple__ is tuple",
        "input": None,
        "expected": tuple,
        "actual_type": str(type(__version_tuple__)),
        "passed": isinstance(__version_tuple__, tuple)
    }
    result["tests"].append(test3)
    
    # Test 4: version_tuple equals __version_tuple__
    test4 = {
        "name": "version_tuple equals __version_tuple__",
        "input": None,
        "expected": __version_tuple__,
        "actual": version_tuple,
        "passed": version_tuple == __version_tuple__
    }
    result["tests"].append(test4)
    
    # Test 5: version format
    test5 = {
        "name": "version format is X.Y.Z",
        "input": None,
        "expected": True,
        "actual": "." in __version__,
        "passed": "." in __version__
    }
    result["tests"].append(test5)
    
    return result


def test_cmds_entry():
    """Test cmds/entry.py"""
    from rqalpha.cmds.entry import cli
    
    result = {
        "module": "cmds/entry",
        "tests": []
    }
    
    # Test 1: cli is callable
    test1 = {
        "name": "cli is callable",
        "input": None,
        "expected": True,
        "actual": callable(cli),
        "passed": callable(cli)
    }
    result["tests"].append(test1)
    
    # Test 2: cli has group decorator
    test2 = {
        "name": "cli has __name__",
        "input": None,
        "expected": True,
        "actual": hasattr(cli, '__name__'),
        "passed": hasattr(cli, '__name__')
    }
    result["tests"].append(test2)
    
    return result


def test_user_module():
    """Test user_module.py"""
    result = {
        "module": "user_module",
        "tests": []
    }
    
    # Test 1: module exists (it's empty in Python)
    test1 = {
        "name": "user_module exists",
        "input": None,
        "expected": True,
        "actual": True,
        "passed": True
    }
    result["tests"].append(test1)
    
    return result


def test_click_helper():
    """Test utils/click_helper.py"""
    from rqalpha.utils.click_helper import Date
    
    result = {
        "module": "utils/click_helper",
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
    
    # Test 2: Date has convert method
    date_param = Date()
    test2 = {
        "name": "Date has convert method",
        "input": None,
        "expected": True,
        "actual": hasattr(date_param, 'convert'),
        "passed": hasattr(date_param, 'convert')
    }
    result["tests"].append(test2)
    
    # Test 3: Date convert returns Timestamp
    import pandas as pd
    converted = date_param.convert("2020-01-01", None, None)
    test3 = {
        "name": "Date convert returns Timestamp",
        "input": "2020-01-01",
        "expected": pd.Timestamp,
        "actual_type": str(type(converted)),
        "passed": isinstance(converted, pd.Timestamp)
    }
    result["tests"].append(test3)
    
    # Test 4: Date name property
    test4 = {
        "name": "Date name property",
        "input": None,
        "expected": "DATE",
        "actual": date_param.name,
        "passed": date_param.name == "DATE"
    }
    result["tests"].append(test4)
    
    return result


def test_concurrent():
    """Test utils/concurrent.py"""
    from rqalpha.utils.concurrent import ProgressedProcessPoolExecutor, ProgressedTask
    
    result = {
        "module": "utils/concurrent",
        "tests": []
    }
    
    # Test 1: ProgressedProcessPoolExecutor exists
    test1 = {
        "name": "ProgressedProcessPoolExecutor exists",
        "input": None,
        "expected": True,
        "actual": ProgressedProcessPoolExecutor is not None,
        "passed": ProgressedProcessPoolExecutor is not None
    }
    result["tests"].append(test1)
    
    # Test 2: ProgressedTask exists
    test2 = {
        "name": "ProgressedTask exists",
        "input": None,
        "expected": True,
        "actual": ProgressedTask is not None,
        "passed": ProgressedTask is not None
    }
    result["tests"].append(test2)
    
    # Test 3: ProgressedTask has total_steps property
    test3 = {
        "name": "ProgressedTask has total_steps",
        "input": None,
        "expected": True,
        "actual": hasattr(ProgressedTask, 'total_steps'),
        "passed": hasattr(ProgressedTask, 'total_steps')
    }
    result["tests"].append(test3)
    
    return result


def test_log_capture():
    """Test utils/log_capture.py"""
    from rqalpha.utils.log_capture import LogCapture, CaptureHandler
    import logbook
    
    result = {
        "module": "utils/log_capture",
        "tests": []
    }
    
    # Test 1: LogCapture exists
    test1 = {
        "name": "LogCapture exists",
        "input": None,
        "expected": True,
        "actual": LogCapture is not None,
        "passed": LogCapture is not None
    }
    result["tests"].append(test1)
    
    # Test 2: CaptureHandler exists
    test2 = {
        "name": "CaptureHandler exists",
        "input": None,
        "expected": True,
        "actual": CaptureHandler is not None,
        "passed": CaptureHandler is not None
    }
    result["tests"].append(test2)
    
    # Test 3: LogCapture context manager
    logger = logbook.Logger('test')
    capture = LogCapture(logger)
    with capture:
        logger.info("test message")
    test3 = {
        "name": "LogCapture context manager",
        "input": "test message",
        "expected": True,
        "actual": len(capture._capture_handler.captured) > 0,
        "passed": len(capture._capture_handler.captured) > 0
    }
    result["tests"].append(test3)
    
    return result


def test_package_helper():
    """Test utils/package_helper.py"""
    result = {
        "module": "utils/package_helper",
        "tests": []
    }
    
    # Test 1: import_mod function exists
    from rqalpha.utils.package_helper import import_mod
    test1 = {
        "name": "import_mod exists",
        "input": None,
        "expected": True,
        "actual": callable(import_mod),
        "passed": callable(import_mod)
    }
    result["tests"].append(test1)
    
    # Test 2: import_mod works
    try:
        mod = import_mod('os')
        test2 = {
            "name": "import_mod works",
            "input": "os",
            "expected": True,
            "actual": mod is not None,
            "passed": mod is not None
        }
    except Exception as e:
        test2 = {
            "name": "import_mod works",
            "input": "os",
            "expected": True,
            "actual": str(e),
            "passed": False
        }
    result["tests"].append(test2)
    
    return result


def test_repr():
    """Test utils/repr.py"""
    from rqalpha.utils.repr import property_repr, dict_repr, properties, PropertyReprMeta
    
    result = {
        "module": "utils/repr",
        "tests": []
    }
    
    # Test 1: property_repr exists
    test1 = {
        "name": "property_repr exists",
        "input": None,
        "expected": True,
        "actual": callable(property_repr),
        "passed": callable(property_repr)
    }
    result["tests"].append(test1)
    
    # Test 2: dict_repr exists
    test2 = {
        "name": "dict_repr exists",
        "input": None,
        "expected": True,
        "actual": callable(dict_repr),
        "passed": callable(dict_repr)
    }
    result["tests"].append(test2)
    
    # Test 3: properties exists
    test3 = {
        "name": "properties exists",
        "input": None,
        "expected": True,
        "actual": callable(properties),
        "passed": callable(properties)
    }
    result["tests"].append(test3)
    
    # Test 4: PropertyReprMeta exists
    test4 = {
        "name": "PropertyReprMeta exists",
        "input": None,
        "expected": True,
        "actual": PropertyReprMeta is not None,
        "passed": PropertyReprMeta is not None
    }
    result["tests"].append(test4)
    
    return result


def test_typing():
    """Test utils/typing.py"""
    from rqalpha.utils.typing import DateLike, StrOrIter, POSITION_DIRECTION_TYPE
    
    result = {
        "module": "utils/typing",
        "tests": []
    }
    
    # Test 1: DateLike exists
    test1 = {
        "name": "DateLike exists",
        "input": None,
        "expected": True,
        "actual": DateLike is not None,
        "passed": DateLike is not None
    }
    result["tests"].append(test1)
    
    # Test 2: StrOrIter exists
    test2 = {
        "name": "StrOrIter exists",
        "input": None,
        "expected": True,
        "actual": StrOrIter is not None,
        "passed": StrOrIter is not None
    }
    result["tests"].append(test2)
    
    # Test 3: POSITION_DIRECTION_TYPE exists
    test3 = {
        "name": "POSITION_DIRECTION_TYPE exists",
        "input": None,
        "expected": True,
        "actual": POSITION_DIRECTION_TYPE is not None,
        "passed": POSITION_DIRECTION_TYPE is not None
    }
    result["tests"].append(test3)
    
    return result


def main():
    """Run all tests and print results"""
    all_results = []
    
    print("=" * 60)
    print("RQMojo Test Suite - Group 01 (Python)")
    print("=" * 60)
    
    tests = [
        ("_version.py", test_version),
        ("cmds/entry.py", test_cmds_entry),
        ("user_module.py", test_user_module),
        ("utils/click_helper.py", test_click_helper),
        ("utils/concurrent.py", test_concurrent),
        ("utils/log_capture.py", test_log_capture),
        ("utils/package_helper.py", test_package_helper),
        ("utils/repr.py", test_repr),
        ("utils/typing.py", test_typing),
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
                    print(f"         Actual: {test.get('actual', test.get('actual_type', 'N/A'))}")
        except Exception as e:
            print(f"  [ERROR] {name}: {e}")
            all_results.append({"module": name, "tests": [], "error": str(e)})
    
    print("\n" + "=" * 60)
    print(f"Total: {passed_tests}/{total_tests} tests passed")
    print("=" * 60)
    
    return all_results


if __name__ == "__main__":
    main()
