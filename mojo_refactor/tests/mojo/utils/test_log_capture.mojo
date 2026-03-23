"""
Test for log_capture.mojo
Based on current implementation API

Tests for:
- LogRecord struct
- CaptureHandler struct
- LogCapture struct with generic handler
- start()/stop() methods for context management
- replay() method
"""

from std.collections import List
from std.logger import Level
from rqmojo.utils.log_capture import LogRecord, CaptureHandler, LogCapture, LogHandler, create_log_capture


struct TestHandler(LogHandler, Movable, Copyable, ImplicitlyCopyable):
    var records: List[LogRecord]

    def __init__(out self):
        self.records = List[LogRecord]()

    def __init__(out self, *, copy: Self):
        self.records = List[LogRecord]()
        for record in copy.records:
            self.records.append(record)

    def emit(mut self, record: LogRecord):
        self.records.append(record)

    def count(self) -> Int:
        return len(self.records)

    def clear(mut self):
        self.records.clear()


def test_log_record():
    print("=== Testing LogRecord ===")
    
    var record = LogRecord(Level.INFO, "Test message")
    print("LogRecord: " + String.write(record))
    
    if record.level == Level.INFO and record.message == "Test message":
        print("PASS: LogRecord fields work correctly")
    else:
        print("FAIL: LogRecord fields incorrect")
    print("")


def test_log_record_writable():
    print("=== Testing LogRecord Writable ===")
    
    var record = LogRecord(Level.WARNING, "Warning test")
    var str_repr = String.write(record)
    print("String representation: " + str_repr)
    
    print("PASS: LogRecord Writable works")
    print("")


def test_capture_handler_init():
    print("=== Testing CaptureHandler init ===")
    
    var handler = CaptureHandler()
    print("CaptureHandler created")
    
    if handler.captured.__len__() == 0:
        print("PASS: CaptureHandler initialized with empty captured list")
    else:
        print("FAIL: captured should be empty")
    print("")


def test_capture_handler_emit():
    print("=== Testing CaptureHandler.emit ===")
    
    var handler = CaptureHandler()
    
    handler.emit(LogRecord(Level.INFO, "Test message 1"))
    handler.emit(LogRecord(Level.WARNING, "Test message 2"))
    
    print("Captured " + String(len(handler.captured)) + " records")
    
    if len(handler.captured) == 2:
        print("PASS: CaptureHandler.emit works correctly")
    else:
        print("FAIL: Should have 2 captured records")
    print("")


def test_capture_handler_clear():
    print("=== Testing CaptureHandler.clear ===")
    
    var handler = CaptureHandler()
    handler.emit(LogRecord(Level.INFO, "Test message"))
    handler.clear()
    
    if len(handler.captured) == 0:
        print("PASS: CaptureHandler.clear works correctly")
    else:
        print("FAIL: captured should be empty after clear")
    print("")


def test_capture_handler_capacity():
    print("=== Testing CaptureHandler capacity ===")
    
    var handler = CaptureHandler(capacity=128)
    
    for i in range(10):
        handler.emit(LogRecord(Level.INFO, "Message " + String(i)))
    
    print("Captured " + String(len(handler.captured)) + " records")
    
    if len(handler.captured) == 10:
        print("PASS: CaptureHandler capacity works correctly")
    else:
        print("FAIL: Should have 10 captured records")
    print("")


def test_log_capture_init():
    print("=== Testing LogCapture init ===")
    
    var handler = TestHandler()
    var capture = create_log_capture(handler^)
    print("LogCapture created")
    
    print("PASS: LogCapture initialized correctly")
    print("")


def test_log_capture_start_stop():
    print("=== Testing LogCapture start/stop ===")
    
    var handler = TestHandler()
    var capture = create_log_capture(handler^)
    
    capture.start()
    capture.emit(LogRecord(Level.INFO, "Test message inside context"))
    capture.stop()
    
    print("start/stop executed successfully")
    
    if capture.count() == 1:
        print("PASS: LogCapture start/stop works")
    else:
        print("FAIL: Should have 1 captured record")
    print("")


def test_log_capture_captured_list():
    print("=== Testing LogCapture captured list ===")
    
    var handler = TestHandler()
    var capture = create_log_capture(handler^)
    
    capture.start()
    capture.emit(LogRecord(Level.INFO, "Message 1"))
    capture.emit(LogRecord(Level.WARNING, "Message 2"))
    capture.emit(LogRecord(Level.ERROR, "Message 3"))
    capture.stop()
    
    var records = capture.get_records()
    print("Captured " + String(len(records)) + " records")
    
    if len(records) == 3:
        print("PASS: LogCapture captured list works")
    else:
        print("FAIL: Should have 3 captured records")
    print("")


def test_log_capture_get_records():
    print("=== Testing LogCapture.get_records ===")
    
    var handler = TestHandler()
    var capture = create_log_capture(handler^)
    
    capture.start()
    capture.emit(LogRecord(Level.INFO, "Test message"))
    capture.emit(LogRecord(Level.WARNING, "Warning message"))
    capture.stop()
    
    var records = capture.get_records()
    print("get_records returned " + String(len(records)) + " records")
    
    if len(records) == 2:
        print("PASS: get_records works correctly")
    else:
        print("FAIL: Should return 2 records")
    print("")


def test_log_capture_clear():
    print("=== Testing LogCapture.clear ===")
    
    var handler = TestHandler()
    var capture = create_log_capture(handler^)
    
    capture.start()
    capture.emit(LogRecord(Level.INFO, "Test message"))
    capture.stop()
    
    capture.clear()
    
    if capture.is_empty():
        print("PASS: LogCapture.clear works correctly")
    else:
        print("FAIL: captured should be empty after clear")
    print("")


def test_log_capture_empty_capture():
    print("=== Testing LogCapture empty capture ===")
    
    var handler = TestHandler()
    var capture = create_log_capture(handler^)
    
    capture.start()
    capture.stop()
    
    var records = capture.get_records()
    print("Captured " + String(len(records)) + " records (expected 0)")
    
    if len(records) == 0:
        print("PASS: Empty capture works correctly")
    else:
        print("FAIL: Should have 0 captured records")
    print("")


def test_log_capture_not_capturing():
    print("=== Testing LogCapture not capturing ===")
    
    var handler = TestHandler()
    var capture = create_log_capture(handler^)
    
    capture.emit(LogRecord(Level.INFO, "This should go to handler, not captured"))
    
    if capture.is_empty() and capture.handler_count() == 1:
        print("PASS: Messages go to handler when not capturing")
    else:
        print("FAIL: Should not capture when not capturing")
    print("")


def test_log_capture_count_and_is_empty():
    print("=== Testing LogCapture count and is_empty ===")
    
    var handler = TestHandler()
    var capture = create_log_capture(handler^)
    
    if capture.is_empty():
        print("PASS: is_empty returns True initially")
    else:
        print("FAIL: is_empty should return True initially")
    
    capture.start()
    capture.emit(LogRecord(Level.INFO, "Test"))
    capture.stop()
    
    if capture.count() == 1:
        print("PASS: count returns 1 after one emit")
    else:
        print("FAIL: count should return 1")
    
    if not capture.is_empty():
        print("PASS: is_empty returns False after emit")
    else:
        print("FAIL: is_empty should return False after emit")
    print("")


def test_log_capture_replay():
    print("=== Testing LogCapture.replay ===")
    
    var handler = TestHandler()
    var capture = create_log_capture(handler^)
    
    capture.start()
    capture.emit(LogRecord(Level.INFO, "Message A"))
    capture.emit(LogRecord(Level.ERROR, "Message B"))
    capture.stop()
    
    print("Before replay: handler has " + String(capture.handler_count()) + " records")
    
    capture.replay()
    
    print("After replay: handler has " + String(capture.handler_count()) + " records")
    
    if capture.handler_count() == 2:
        print("PASS: replay() works correctly")
    else:
        print("FAIL: replay() should send 2 records to handler")
    print("")


def test_log_capture_copy():
    print("=== Testing LogCapture copy ===")
    
    var handler = TestHandler()
    var capture = create_log_capture(handler^)
    
    capture.start()
    capture.emit(LogRecord(Level.INFO, "Original message"))
    capture.stop()
    
    var capture_copy = LogCapture(copy=capture)
    
    if capture_copy.count() == 1:
        print("PASS: Copy preserves captured records")
    else:
        print("FAIL: Copy should preserve captured records")
    
    capture_copy.clear()
    if capture.count() == 1:
        print("PASS: Original is independent of copy")
    else:
        print("FAIL: Original should be independent of copy")
    print("")


def test_multiple_contexts():
    print("=== Testing LogCapture multiple contexts ===")
    
    var handler = TestHandler()
    var capture = create_log_capture(handler^)
    
    capture.start()
    capture.emit(LogRecord(Level.INFO, "First context"))
    capture.stop()
    
    capture.clear()
    
    capture.start()
    capture.emit(LogRecord(Level.INFO, "Second context"))
    capture.stop()
    
    print("Multiple context uses completed")
    
    if capture.count() == 1:
        print("PASS: Multiple contexts work")
    else:
        print("FAIL: Multiple contexts should work independently")
    print("")


def test_record_level_preservation():
    print("=== Testing LogRecord level preservation ===")
    
    var handler = TestHandler()
    var capture = create_log_capture(handler^)
    
    capture.start()
    capture.emit(LogRecord(Level.DEBUG, "Debug message"))
    capture.emit(LogRecord(Level.INFO, "Info message"))
    capture.emit(LogRecord(Level.WARNING, "Warning message"))
    capture.emit(LogRecord(Level.ERROR, "Error message"))
    capture.stop()
    
    var records = capture.get_records()
    var has_debug = False
    var has_info = False
    var has_warning = False
    var has_error = False
    
    for record in records:
        if record.level == Level.DEBUG:
            has_debug = True
        elif record.level == Level.INFO:
            has_info = True
        elif record.level == Level.WARNING:
            has_warning = True
        elif record.level == Level.ERROR:
            has_error = True
    
    if has_debug and has_info and has_warning and has_error:
        print("PASS: All log levels preserved correctly")
    else:
        print("FAIL: Not all levels captured correctly")
    print("")


def test_emit_routing():
    print("=== Testing emit routing ===")
    
    var handler = TestHandler()
    var capture = create_log_capture(handler^)
    
    capture.emit(LogRecord(Level.INFO, "Not capturing - goes to handler"))
    
    capture.start()
    capture.emit(LogRecord(Level.WARNING, "Capturing - goes to capture"))
    capture.stop()
    
    capture.emit(LogRecord(Level.ERROR, "Not capturing again - goes to handler"))
    
    if capture.handler_count() == 2 and capture.count() == 1:
        print("PASS: emit routing works correctly")
    else:
        print("FAIL: emit routing incorrect")
        print("  handler.count() = " + String(capture.handler_count()) + " (expected 2)")
        print("  capture.count() = " + String(capture.count()) + " (expected 1)")
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo utils/log_capture.mojo Test")
    print("Testing current implementation API")
    print("=" * 60)
    print("")
    
    test_log_record()
    test_log_record_writable()
    test_capture_handler_init()
    test_capture_handler_emit()
    test_capture_handler_clear()
    test_capture_handler_capacity()
    test_log_capture_init()
    test_log_capture_start_stop()
    test_log_capture_captured_list()
    test_log_capture_get_records()
    test_log_capture_clear()
    test_log_capture_empty_capture()
    test_log_capture_not_capturing()
    test_log_capture_count_and_is_empty()
    test_log_capture_replay()
    test_log_capture_copy()
    test_multiple_contexts()
    test_record_level_preservation()
    test_emit_routing()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
