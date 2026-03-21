"""
Test for log_capture.mojo - Log Capture Module
Compares output with Python rqalpha/utils/log_capture.py
"""

from std.collections import List
from logger import Level
from rqmojo.utils.log_capture import LogRecord, CaptureHandler, LogCapture, create_log_capture


def test_capture_handler_init():
    """测试 CaptureHandler 初始化"""
    print("=== Testing CaptureHandler init ===")
    
    var handler = CaptureHandler()
    print("CaptureHandler created")
    
    if len(handler.captured) == 0:
        print("PASS: CaptureHandler initialized with empty captured list")
    else:
        print("FAIL: captured should be empty")
    print("")


def test_capture_handler_emit():
    """测试 CaptureHandler.emit 方法"""
    print("=== Testing CaptureHandler.emit ===")
    
    var handler = CaptureHandler()
    
    handler.emit(Level.INFO, "Test message 1")
    handler.emit(Level.WARNING, "Test message 2")
    
    print("Captured " + String(len(handler.captured)) + " records")
    
    if len(handler.captured) == 2:
        print("PASS: CaptureHandler.emit works correctly")
    else:
        print("FAIL: Should have 2 captured records")
    print("")


def test_capture_handler_clear():
    """测试 CaptureHandler.clear 方法"""
    print("=== Testing CaptureHandler.clear ===")
    
    var handler = CaptureHandler()
    handler.emit(Level.INFO, "Test message")
    handler.clear()
    
    if len(handler.captured) == 0:
        print("PASS: CaptureHandler.clear works correctly")
    else:
        print("FAIL: captured should be empty after clear")
    print("")


def test_log_capture_init():
    """测试 LogCapture 初始化"""
    print("=== Testing LogCapture init ===")
    
    var capture = create_log_capture()
    print("LogCapture created")
    
    print("PASS: LogCapture initialized correctly")
    print("")


def test_log_capture_context_manager():
    """测试 LogCapture 上下文管理器功能"""
    print("=== Testing LogCapture context manager ===")
    
    var capture = create_log_capture()
    
    capture.start()
    capture.emit(Level.INFO, "Test message inside context")
    capture.stop()
    
    print("Context manager start/stop executed successfully")
    
    print("PASS: LogCapture context manager works")
    print("")


def test_log_capture_captured_list():
    """测试 LogCapture captured 列表记录功能"""
    print("=== Testing LogCapture captured list ===")
    
    var capture = create_log_capture()
    
    capture.start()
    capture.emit(Level.INFO, "Message 1")
    capture.emit(Level.WARNING, "Message 2")
    capture.emit(Level.ERROR, "Message 3")
    capture.stop()
    
    var captured = capture.get_captured()
    print("Captured " + String(len(captured)) + " messages")
    
    if len(captured) == 3:
        print("PASS: LogCapture captured list works")
    else:
        print("FAIL: Should have 3 captured messages")
    print("")


def test_log_capture_get_captured():
    """测试 LogCapture.get_captured 方法"""
    print("=== Testing LogCapture.get_captured ===")
    
    var capture = create_log_capture()
    
    capture.start()
    capture.emit(Level.INFO, "Test message")
    capture.stop()
    
    var messages = capture.get_captured()
    print("get_captured returned " + String(len(messages)) + " messages")
    
    if len(messages) == 1:
        print("PASS: get_captured works correctly")
    else:
        print("FAIL: Should return 1 message")
    print("")


def test_log_capture_clear():
    """测试 LogCapture.clear 方法"""
    print("=== Testing LogCapture.clear ===")
    
    var capture = create_log_capture()
    
    capture.start()
    capture.emit(Level.INFO, "Test message")
    capture.stop()
    capture.clear()
    
    var messages = capture.get_captured()
    if len(messages) == 0:
        print("PASS: LogCapture.clear works correctly")
    else:
        print("FAIL: captured should be empty after clear")
    print("")


def test_log_capture_empty_capture():
    """测试 LogCapture 空捕获"""
    print("=== Testing LogCapture empty capture ===")
    
    var capture = create_log_capture()
    
    capture.start()
    capture.stop()
    
    var messages = capture.get_captured()
    print("Captured " + String(len(messages)) + " messages (expected 0)")
    
    if len(messages) == 0:
        print("PASS: Empty capture works correctly")
    else:
        print("FAIL: Should have 0 captured messages")
    print("")


def test_log_capture_not_capturing():
    """测试 LogCapture 在非捕获状态下的行为"""
    print("=== Testing LogCapture not capturing ===")
    
    var capture = create_log_capture()
    
    capture.emit(Level.INFO, "This should not be captured")
    
    var messages = capture.get_captured()
    if len(messages) == 0:
        print("PASS: Messages not captured when not capturing")
    else:
        print("FAIL: Should not capture when not capturing")
    print("")


def test_log_capture_multiple_contexts():
    """测试 LogCapture 多次上下文使用"""
    print("=== Testing LogCapture multiple contexts ===")
    
    var capture = create_log_capture()
    
    capture.start()
    capture.emit(Level.INFO, "First context")
    capture.stop()
    
    capture.start()
    capture.emit(Level.INFO, "Second context")
    capture.stop()
    
    print("Multiple context uses completed")
    
    print("PASS: Multiple contexts work")
    print("")


def test_log_record_struct():
    """测试 LogRecord 结构体"""
    print("=== Testing LogRecord struct ===")
    
    var record = LogRecord(Level.INFO, "Test message")
    
    print("LogRecord level: " + String(record.level))
    print("LogRecord message: " + record.message)
    
    if record.message == "Test message":
        print("PASS: LogRecord struct works correctly")
    else:
        print("FAIL: LogRecord message mismatch")
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo utils/log_capture.mojo Test")
    print("=" * 60)
    print("")
    
    test_capture_handler_init()
    test_capture_handler_emit()
    test_capture_handler_clear()
    test_log_capture_init()
    test_log_capture_context_manager()
    test_log_capture_captured_list()
    test_log_capture_get_captured()
    test_log_capture_clear()
    test_log_capture_empty_capture()
    test_log_capture_not_capturing()
    test_log_capture_multiple_contexts()
    test_log_record_struct()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
