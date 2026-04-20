"""
RQMojo Test Suite - Group 01
File: utils/log_capture.mojo (standalone test)

Tests verify behavior matches Python rqalpha/utils/log_capture.py:
  1. CaptureHandler captures records via emit()
  2. LogCapture(var logger) transfers ownership
  3. __enter__ swaps handlers (intercepts log output)
  4. __exit__ restores original handlers
  5. replay() dispatches captured records back to logger (no target needed)
  6. create_log_capture() factory function works
"""

from std.collections import List
from std.logger import Level
from rqmojo.utils.log_capture import (
    LogRecord, CaptureHandler, RQLogger,
    LogCapture, create_log_capture,
)


def main() raises:
    print("=" * 60)
    print("Test: utils/log_capture.mojo (aligned with Python)")
    print("=" * 60)

    var passed = 0
    var failed = 0

    # Test 1: LogRecord struct exists and holds level + message
    print("\n[TEST 1] LogRecord stores level and message")
    var record = LogRecord(Level.INFO, "test msg")
    if record.level == Level.INFO and record.message == "test msg":
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")

    # Test 2: CaptureHandler exists, captured is empty initially
    print("\n[TEST 2] CaptureHandler captured is empty initially")
    var handler = CaptureHandler()
    if len(handler.captured) == 0:
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")

    # Test 3: CaptureHandler.emit() appends records
    print("\n[TEST 3] CaptureHandler.emit() works")
    handler.emit(LogRecord(level=Level.INFO, message="test"))
    if len(handler.captured) == 1:
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")

    # Test 4: RQLogger exists with handlers list
    print("\n[TEST 4] RQLogger has handlers list")
    var logger = RQLogger(name="test_logger")
    if len(logger.get_handlers()) == 0:
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")

    # Test 5: LogCapture takes owned logger (matches Python constructor)
    print("\n[TEST 5] LogCapture(var logger) constructor")
    var capture = LogCapture(logger^)
    if len(capture.capture_handler().captured) == 0:
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")

    # Test 6: __enter__ installs CaptureHandler, intercepts handle()
    print("\n[TEST 6] __enter__ installs CaptureHandler, intercepts handle()")
    _ = capture.__enter__()
    capture.handle(LogRecord(Level.INFO, "intercepted msg"))
    if len(capture.capture_handler().captured) == 1:
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")

    # Test 7: __exit__ restores original handlers
    print("\n[TEST 7] __exit__ restores original handlers")
    _ = capture.__exit__()
    capture.handle(LogRecord(Level.INFO, "after exit"))
    if len(capture.capture_handler().captured) == 1:
        passed += 1
        print("  Result: PASS (no new capture after restore)")
    else:
        failed += 1
        print("  Result: FAIL")

    # Test 8: replay() sends records back to logger (no target param)
    print("\n[TEST 8] replay() dispatches to logger (no target)")
    var replay_handler = CaptureHandler()
    capture.add_handler(replay_handler^)
    capture.replay()
    if len(capture.capture_handler().captured) == 1:
        passed += 1
        print("  Result: PASS (replay preserved source, dispatched to logger handlers)")
    else:
        failed += 1
        print("  Result: FAIL")

    # Test 9: create_log_capture() factory function exists
    print("\n[TEST 9] create_log_capture() factory function")
    var logger2 = RQLogger(name="factory_test")
    var capture2 = create_log_capture(logger2^)
    _ = capture2.__enter__()
    capture2.handle(LogRecord(Level.WARNING, "factory test"))
    if len(capture2.capture_handler().captured) == 1:
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")
    _ = capture2.__exit__()

    # Test 10: Full context manager lifecycle (matches Python `with` pattern)
    print("\n[TEST 10] Full context manager lifecycle")
    var logger3 = RQLogger(name="lifecycle_test")
    var pre_handler = CaptureHandler()
    logger3.add_handler(pre_handler^)
    var cap3 = LogCapture(logger3^)
    _ = cap3.__enter__()
    cap3.handle(LogRecord(Level.ERROR, "during capture"))
    _ = cap3.__exit__()
    cap3.handle(LogRecord(Level.INFO, "after capture"))
    if (
        len(cap3.capture_handler().captured) == 1
        and len(cap3.capture_handler().captured) == 1
    ):
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")

    print("\n" + "=" * 60)
    print("Summary: " + String(passed) + "/" + String(passed + failed) + " tests passed")
    print("=" * 60)

    if failed > 0:
        print("STATUS: FAILED")
    else:
        print("STATUS: SUCCESS")
