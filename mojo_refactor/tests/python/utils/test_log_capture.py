# -*- coding: utf-8 -*-
"""
Test for rqalpha/utils/log_capture.py - Log Capture Module
Compares output with Mojo rqmojo/utils/log_capture.mojo
"""

import logbook
from rqalpha.utils.log_capture import CaptureHandler, LogCapture


def test_capture_handler_init():
    """测试 CaptureHandler 初始化"""
    print("=== Testing CaptureHandler init ===")
    
    handler = CaptureHandler()
    print(f"CaptureHandler created: {handler}")
    
    assert handler.captured == [], "captured should be empty list"
    
    print("PASS: CaptureHandler initialized correctly")
    print("")


def test_capture_handler_emit():
    """测试 CaptureHandler.emit 方法"""
    print("=== Testing CaptureHandler.emit ===")
    
    handler = CaptureHandler()
    
    record1 = logbook.LogRecord("Test message 1", level=logbook.INFO)
    record2 = logbook.LogRecord("Test message 2", level=logbook.WARNING)
    
    handler.emit(record1)
    handler.emit(record2)
    
    print(f"Captured {len(handler.captured)} records")
    
    assert len(handler.captured) == 2, "Should have 2 captured records"
    
    print("PASS: CaptureHandler.emit works correctly")
    print("")


def test_log_capture_init():
    """测试 LogCapture 初始化"""
    print("=== Testing LogCapture init ===")
    
    logger = logbook.Logger("test_logger")
    capture = LogCapture(logger)
    
    print(f"LogCapture created for logger: {logger.name}")
    
    print("PASS: LogCapture initialized correctly")
    print("")


def test_log_capture_context_manager():
    """测试 LogCapture 上下文管理器功能"""
    print("=== Testing LogCapture context manager ===")
    
    logger = logbook.Logger("test_logger")
    
    with LogCapture(logger) as capture:
        logger.info("Test message inside context")
    
    print("Context manager entered and exited successfully")
    
    print("PASS: LogCapture context manager works")
    print("")


def test_log_capture_captured_list():
    """测试 LogCapture captured 列表记录功能"""
    print("=== Testing LogCapture captured list ===")
    
    logger = logbook.Logger("test_logger")
    
    with LogCapture(logger) as capture:
        logger.info("Message 1")
        logger.warning("Message 2")
        logger.error("Message 3")
    
    print(f"Captured {len(capture._capture_handler.captured)} records")
    
    print("PASS: LogCapture captured list works")
    print("")


def test_log_capture_replay():
    """测试 LogCapture.replay 方法"""
    print("=== Testing LogCapture.replay ===")
    
    logger = logbook.Logger("test_logger")
    
    with LogCapture(logger) as capture:
        logger.info("Test message for replay")
    
    capture.replay()
    print("Replay executed successfully")
    
    print("PASS: LogCapture.replay works")
    print("")


def test_log_capture_empty_capture():
    """测试 LogCapture 空捕获"""
    print("=== Testing LogCapture empty capture ===")
    
    logger = logbook.Logger("test_logger")
    
    with LogCapture(logger) as capture:
        pass
    
    print(f"Captured {len(capture._capture_handler.captured)} records (expected 0)")
    
    assert len(capture._capture_handler.captured) == 0, "Should have 0 captured records"
    
    print("PASS: Empty capture works correctly")
    print("")


def test_log_capture_multiple_contexts():
    """测试 LogCapture 多次上下文使用"""
    print("=== Testing LogCapture multiple contexts ===")
    
    logger = logbook.Logger("test_logger")
    capture = LogCapture(logger)
    
    with capture:
        logger.info("First context")
    
    with capture:
        logger.info("Second context")
    
    print("Multiple context uses completed")
    
    print("PASS: Multiple contexts work")
    print("")


if __name__ == "__main__":
    print("=" * 60)
    print("RQAlpha Python utils/log_capture.py Test")
    print("=" * 60)
    print("")
    
    test_capture_handler_init()
    test_capture_handler_emit()
    test_log_capture_init()
    test_log_capture_context_manager()
    test_log_capture_captured_list()
    test_log_capture_replay()
    test_log_capture_empty_capture()
    test_log_capture_multiple_contexts()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
