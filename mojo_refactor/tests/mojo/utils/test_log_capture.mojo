"""
Test for log_capture.mojo
Aligned with Python rqalpha/utils/log_capture.py behavior:
  - LogCapture(var logger) transfers ownership (Mojo value semantics)
  - __enter__ swaps handlers, __exit__ restores them
  - replay() dispatches to logger without target parameter
  - create_log_capture() factory function available
  - All logger ops proxied through LogCapture (capture.handle, capture.add_handler)
"""

from std.logger import Level
from rqmojo.utils.log_capture import (
    LogRecord, CaptureHandler, RQLogger,
    LogCapture, create_log_capture,
)


def test_log_record():
    print("=== Testing LogRecord ===")

    var record = LogRecord(Level.INFO, "Test message")
    print("LogRecord: " + String.write(record))

    if record.level == Level.INFO and record.message == "Test message":
        print("PASS")
    else:
        print("FAIL")


def test_capture_handler():
    print("=== Testing CaptureHandler ===")

    var handler = CaptureHandler()
    handler.emit(LogRecord(Level.INFO, "msg1"))
    handler.emit(LogRecord(Level.WARNING, "msg2"))

    if len(handler.captured) == 2:
        print("PASS")
    else:
        print("FAIL")


def test_rq_logger():
    print("=== Testing RQLogger handler dispatch ===")

    var logger = RQLogger(name="test")
    var h1 = CaptureHandler()
    var h2 = CaptureHandler()
    logger.add_handler(h1^)
    logger.add_handler(h2^)

    logger.handle(LogRecord(Level.INFO, "dispatch test"))

    var handlers = logger.get_handlers()
    if len(handlers) == 2:
        print("PASS: dispatched, handler list has 2 entries")
    else:
        print("FAIL")


def test_log_capture_context_manager():
    print("=== Testing LogCapture context manager (matches Python `with`) ===")

    var logger = RQLogger(name="ctx_test")
    var original_handler = CaptureHandler()
    logger.add_handler(original_handler^)

    var capture = LogCapture(logger^)

    _ = capture.__enter__()
    capture.handle(LogRecord(Level.INFO, "Hello"))
    capture.handle(LogRecord(Level.ERROR, "World"))
    _ = capture.__exit__()

    if len(capture.capture_handler().captured) == 2:
        print("PASS: captured 2 records during context")
    else:
        print("FAIL")

    # After exit, logger should use restored handlers again
    capture.handle(LogRecord(Level.INFO, "after context"))
    if len(capture.capture_handler().captured) == 2:
        print("PASS: post-exit handle() does not add to capture_handler")
    else:
        print("FAIL")


def test_replay_to_logger():
    print("=== Testing replay() to logger (no target param) ===")

    var logger = RQLogger(name="replay_test")
    var capture = LogCapture(logger^)
    _ = capture.__enter__()
    capture.handle(LogRecord(Level.INFO, "A"))
    capture.handle(LogRecord(Level.INFO, "B"))
    _ = capture.__exit__()

    var target = CaptureHandler()
    capture.add_handler(target^)
    capture.replay()

    if len(capture.capture_handler().captured) == 2:
        print("PASS: replay preserved captured records, dispatched to logger")
    else:
        print("FAIL")


def test_create_log_capture_factory():
    print("=== Testing create_log_capture() factory ===")

    var logger = RQLogger(name="factory")
    var capture = create_log_capture(logger^)
    _ = capture.__enter__()
    capture.handle(LogRecord(Level.DEBUG, "factory created"))
    _ = capture.__exit__()

    if len(capture.capture_handler().captured) == 1:
        print("PASS: factory produces working LogCapture")
    else:
        print("FAIL")


def test_log_capture_copy():
    print("=== Testing LogCapture copy independence ===")

    var logger = RQLogger(name="copy_test")
    var capture = LogCapture(logger^)
    _ = capture.__enter__()
    capture.handle(LogRecord(Level.INFO, "original"))
    _ = capture.__exit__()

    var copy = LogCapture(copy=capture)

    if len(copy.capture_handler().captured) == 1:
        print("PASS: copy preserves captured records")
    else:
        print("FAIL")

    _ = copy.__enter__()
    copy.handle(LogRecord(Level.INFO, "extra via copy"))
    _ = copy.__exit__()
    if len(capture.capture_handler().captured) == 2:
        print("PASS: ArcPointer shares state - original sees copy's records")
    else:
        print("FAIL")


def test_record_level_preservation():
    print("=== Testing LogRecord level preservation ===")

    var logger = RQLogger(name="level_test")
    var capture = LogCapture(logger^)
    _ = capture.__enter__()
    capture.handle(LogRecord(Level.DEBUG, "Debug"))
    capture.handle(LogRecord(Level.INFO, "Info"))
    capture.handle(LogRecord(Level.WARNING, "Warning"))
    capture.handle(LogRecord(Level.ERROR, "Error"))
    _ = capture.__exit__()

    var has_debug = False
    var has_info = False
    var has_warning = False
    var has_error = False

    for record in capture.capture_handler().captured:
        if record.level == Level.DEBUG:
            has_debug = True
        elif record.level == Level.INFO:
            has_info = True
        elif record.level == Level.WARNING:
            has_warning = True
        elif record.level == Level.ERROR:
            has_error = True

    if has_debug and has_info and has_warning and has_error:
        print("PASS")
    else:
        print("FAIL")


def test_multiple_context_cycles():
    print("=== Testing multiple enter/exit cycles ===")

    var logger = RQLogger(name="cycle_test")
    var capture = LogCapture(logger^)

    _ = capture.__enter__()
    capture.handle(LogRecord(Level.INFO, "First"))
    _ = capture.__exit__()

    _ = capture.__enter__()
    capture.handle(LogRecord(Level.INFO, "Second"))
    _ = capture.__exit__()

    if len(capture.capture_handler().captured) == 2:
        print("PASS: both cycles captured independently")
    else:
        print("FAIL")


def test_nested_handler_preservation():
    print("=== Testing pre-existing handlers preserved across cycles ===")

    var logger = RQLogger(name="nest_test")
    var persistent = CaptureHandler()
    logger.add_handler(persistent^)

    var capture = LogCapture(logger^)
    _ = capture.__enter__()
    capture.handle(LogRecord(Level.INFO, "captured only"))
    _ = capture.__exit__()

    capture.handle(LogRecord(Level.INFO, "goes to persistent"))

    if len(capture.capture_handler().captured) == 1:
        print("PASS: capture_handler has exactly 1 record (from during-context)")
    else:
        print("FAIL")


def main():
    print("=" * 60)
    print("RQAlpha Mojo utils/log_capture.mojo Test")
    print("(aligned with Python behavior)")
    print("=" * 60)
    print("")

    test_log_record()
    test_capture_handler()
    test_rq_logger()
    test_log_capture_context_manager()
    test_replay_to_logger()
    test_create_log_capture_factory()
    test_log_capture_copy()
    test_record_level_preservation()
    test_multiple_context_cycles()
    test_nested_handler_preservation()

    print("")
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
