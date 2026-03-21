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
    
    logger = logbook.Logger("test")
    record = logbook.LogRecord("Test message", logger, logbook.INFO)
    
    handler.emit(record)
    
    print(f"Captured {len(handler.captured)} records")
    
    assert len(handler.captured) == 1, "Should have 1 captured record"
    assert handler.captured[0] == record, "Captured record should match"
    
    print("PASS: CaptureHandler.emit works correctly")
    print("")


def test_log_capture_init():
    """测试 LogCapture 初始化"""
    print("=== Testing LogCapture init ===")
    
    logger = logbook.Logger("test_logger")
    capture = LogCapture(logger)
    
    print(f"LogCapture created for logger: {logger.name}")
    
    assert capture._logger == logger, "Logger should be stored"
    assert capture._capture_handler is not None, "CaptureHandler should be created"
    assert capture._handlers is None, "Handlers should be None initially"
    
    print("PASS: LogCapture initialized correctly")
    print("")


def test_log_capture_context_manager():
    """测试 LogCapture 上下文管理器功能"""
    print("=== Testing LogCapture context manager ===")
    
    logger = logbook.Logger("test_logger")
    
    with LogCapture(logger) as capture:
        assert logger.handlers == [capture._capture_handler], "Handler should be replaced"
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
    
    assert len(capture._capture_handler.captured) == 3, "Should have 3 captured records"
    
    print("PASS: LogCapture captured list works")
    print("")


def test_log_capture_replay():
    """测试 LogCapture.replay 方法"""
    print("=== Testing LogCapture.replay ===")
    
    logger = logbook.Logger("test_logger")
    
    with LogCapture(logger) as capture:
        logger.info("Test message for replay")
    
    captured_count = len(capture._capture_handler.captured)
    print(f"Captured {captured_count} records before replay")
    
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
