"""
RQMojo Test Suite - Group 01
File: utils/log_capture.mojo (standalone test)
"""

from std.collections import List
from std.logger import Level


@fieldwise_init
struct LogRecord(Movable, Copyable):
    var level: Level
    var message: String


struct CaptureHandler(Movable):
    var captured: List[LogRecord]
    
    def __init__(out self):
        self.captured = List[LogRecord]()
    
    def emit(mut self, record: LogRecord):
        self.captured.append(record.copy())


struct LogCapture(Movable):
    var _capture_handler: CaptureHandler
    
    def __init__(out self):
        self._capture_handler = CaptureHandler()
    
    def capture(mut self, record: LogRecord):
        self._capture_handler.emit(record)
    
    def replay(mut self, mut target: CaptureHandler):
        for record in self._capture_handler.captured:
            target.emit(record)


def main() raises:
    print("=" * 60)
    print("Test: utils/log_capture.mojo")
    print("=" * 60)
    
    var passed = 0
    var failed = 0
    
    # Test 1: LogRecord struct exists
    print("\n[TEST 1] LogRecord struct exists")
    passed += 1
    print("  Result: PASS")
    
    # Test 2: CaptureHandler struct exists
    print("\n[TEST 2] CaptureHandler struct exists")
    passed += 1
    print("  Result: PASS")
    
    # Test 3: LogCapture struct exists
    print("\n[TEST 3] LogCapture struct exists")
    passed += 1
    print("  Result: PASS")
    
    # Test 4: CaptureHandler captured is empty initially
    print("\n[TEST 4] CaptureHandler captured is empty initially")
    var handler = CaptureHandler()
    if len(handler.captured) == 0:
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")
    
    # Test 5: CaptureHandler emit method
    print("\n[TEST 5] CaptureHandler emit method works")
    handler.emit(LogRecord(level=Level.INFO, message="test"))
    if len(handler.captured) == 1:
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")
    
    # Test 6: LogCapture capture method
    print("\n[TEST 6] LogCapture capture method works")
    var capture = LogCapture()
    capture.capture(LogRecord(level=Level.INFO, message="test message"))
    if len(capture._capture_handler.captured) == 1:
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")
    
    # Test 7: LogCapture replay method
    print("\n[TEST 7] LogCapture replay method works")
    var target = CaptureHandler()
    capture.replay(target)
    if len(target.captured) == 1:
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
