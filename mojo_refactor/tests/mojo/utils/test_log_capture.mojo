"""
Test for log_capture.mojo
Mojo-idiomatic version: LogCapture owns its CaptureHandler internally.
"""

from std.logger import Level
from rqmojo.utils.log_capture import LogRecord, CaptureHandler, LogCapture


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


def test_log_capture_simple():
    print("=== Testing LogCapture simple capture + replay ===")

    var capture = LogCapture()
    _ = capture.__enter__()
    capture.capture(LogRecord(Level.INFO, "Hello"))
    capture.capture(LogRecord(Level.ERROR, "World"))
    _ = capture.__exit__()

    if len(capture._capture_handler.captured) == 2:
        print("PASS: captured 2 records")
    else:
        print("FAIL")

    # Replay to a target handler
    var target = CaptureHandler()
    capture.replay(target)

    if len(target.captured) == 2:
        print("PASS: replayed 2 records to target")
    else:
        print("FAIL")


def test_log_capture_replay_and_clear():
    print("=== Testing replay_and_clear ===")

    var capture = LogCapture()
    capture.capture(LogRecord(Level.INFO, "A"))
    capture.capture(LogRecord(Level.INFO, "B"))

    var target = CaptureHandler()
    capture.replay_and_clear(target)

    if len(capture._capture_handler.captured) == 0 and len(target.captured) == 2:
        print("PASS: cleared after replay")
    else:
        print("FAIL")


def test_log_capture_no_external_handler():
    print("=== Testing LogCapture needs no external handler ===")

    var capture = LogCapture()
    capture.capture(LogRecord(Level.DEBUG, "no handler needed"))

    if len(capture._capture_handler.captured) == 1:
        print("PASS: works without external handler")
    else:
        print("FAIL")


def test_log_capture_copy():
    print("=== Testing LogCapture copy ===")

    var capture = LogCapture()
    capture.capture(LogRecord(Level.INFO, "original"))

    var copy = LogCapture(copy=capture)

    if len(copy._capture_handler.captured) == 1:
        print("PASS: copy preserves records")
    else:
        print("FAIL")

    copy.capture(LogRecord(Level.INFO, "extra"))
    if len(capture._capture_handler.captured) == 1:
        print("PASS: original independent of copy")
    else:
        print("FAIL")


def test_replay_to_multiple_targets():
    print("=== Testing replay to multiple targets ===")

    var capture = LogCapture()
    capture.capture(LogRecord(Level.INFO, "broadcast"))
    capture.capture(LogRecord(Level.WARNING, "alert"))

    var target1 = CaptureHandler()
    var target2 = CaptureHandler()
    capture.replay(target1)
    capture.replay(target2)

    if len(target1.captured) == 2 and len(target2.captured) == 2:
        print("PASS: replayed to 2 targets independently")
    else:
        print("FAIL")


def test_record_level_preservation():
    print("=== Testing LogRecord level preservation ===")

    var capture = LogCapture()
    capture.capture(LogRecord(Level.DEBUG, "Debug"))
    capture.capture(LogRecord(Level.INFO, "Info"))
    capture.capture(LogRecord(Level.WARNING, "Warning"))
    capture.capture(LogRecord(Level.ERROR, "Error"))

    var has_debug = False
    var has_info = False
    var has_warning = False
    var has_error = False

    for record in capture._capture_handler.captured:
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


def test_multiple_contexts():
    print("=== Testing multiple contexts ===")

    var capture = LogCapture()

    _ = capture.__enter__()
    capture.capture(LogRecord(Level.INFO, "First"))
    _ = capture.__exit__()

    capture._capture_handler.captured.clear()

    _ = capture.__enter__()
    capture.capture(LogRecord(Level.INFO, "Second"))
    _ = capture.__exit__()

    if len(capture._capture_handler.captured) == 1:
        print("PASS")
    else:
        print("FAIL")


def main():
    print("=" * 60)
    print("RQAlpha Mojo utils/log_capture.mojo Test")
    print("=" * 60)
    print("")

    test_log_record()
    test_capture_handler()
    test_log_capture_simple()
    test_log_capture_replay_and_clear()
    test_log_capture_no_external_handler()
    test_log_capture_copy()
    test_replay_to_multiple_targets()
    test_record_level_preservation()
    test_multiple_contexts()

    print("")
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
