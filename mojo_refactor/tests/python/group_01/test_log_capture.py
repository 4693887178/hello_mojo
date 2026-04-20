# -*- coding: utf-8 -*-
"""
RQMojo Test Suite - Group 01
File: utils/log_capture.py (Python test)
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


def test_log_capture():
    """Test utils/log_capture.py"""
    import logbook
    from rqalpha.utils.log_capture import LogCapture, CaptureHandler
    
    result = {
        "module": "utils/log_capture.py",
        "tests": []
    }
    
    # Test 1: CaptureHandler exists
    test1 = {
        "name": "CaptureHandler exists",
        "input": None,
        "expected": True,
        "actual": CaptureHandler is not None,
        "passed": CaptureHandler is not None
    }
    result["tests"].append(test1)
    
    # Test 2: LogCapture exists
    test2 = {
        "name": "LogCapture exists",
        "input": None,
        "expected": True,
        "actual": LogCapture is not None,
        "passed": LogCapture is not None
    }
    result["tests"].append(test2)
    
    # Test 3: CaptureHandler is logbook.Handler subclass
    test3 = {
        "name": "CaptureHandler is logbook.Handler subclass",
        "input": None,
        "expected": True,
        "actual": issubclass(CaptureHandler, logbook.Handler),
        "passed": issubclass(CaptureHandler, logbook.Handler)
    }
    result["tests"].append(test3)
    
    # Test 4: CaptureHandler has captured attribute
    handler = CaptureHandler()
    test4 = {
        "name": "CaptureHandler has captured attribute",
        "input": None,
        "expected": True,
        "actual": hasattr(handler, 'captured'),
        "passed": hasattr(handler, 'captured')
    }
    result["tests"].append(test4)
    
    # Test 5: CaptureHandler captured is empty initially
    test5 = {
        "name": "CaptureHandler captured is empty initially",
        "input": None,
        "expected": 0,
        "actual": len(handler.captured),
        "passed": len(handler.captured) == 0
    }
    result["tests"].append(test5)
    
    # Test 6: CaptureHandler emit method
    handler.emit("test_record")
    test6 = {
        "name": "CaptureHandler emit method works",
        "input": "test_record",
        "expected": 1,
        "actual": len(handler.captured),
        "passed": len(handler.captured) == 1
    }
    result["tests"].append(test6)
    
    # Test 7: LogCapture context manager
    logger = logbook.Logger('test')
    capture = LogCapture(logger)
    with capture:
        logger.info("test message")
    test7 = {
        "name": "LogCapture context manager works",
        "input": "test message",
        "expected": True,
        "actual": len(capture._capture_handler.captured) > 0,
        "passed": len(capture._capture_handler.captured) > 0
    }
    result["tests"].append(test7)
    
    # Test 8: LogCapture has replay method
    test8 = {
        "name": "LogCapture has replay method",
        "input": None,
        "expected": True,
        "actual": hasattr(LogCapture, 'replay'),
        "passed": hasattr(LogCapture, 'replay')
    }
    result["tests"].append(test8)
    
    return result


def main():
    """Run all tests and print results"""
    print("=" * 60)
    print("Test: utils/log_capture.py (Python)")
    print("=" * 60)
    
    all_results = []
    
    tests = [
        ("utils/log_capture.py", test_log_capture),
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
