"""
RQAlpha Mojo - Log Capture
Ported from rqalpha/utils/log_capture.py
"""

from collections import List
from logger import Level


@fieldwise_init
struct LogRecord(Movable, Copyable):
    var level: Level
    var message: String


@fieldwise_init
struct CaptureHandler(Movable):
    var captured: List[LogRecord]

    fn __init__(out self):
        self.captured = List[LogRecord]()

    fn emit(mut self, level: Level, message: String):
        self.captured.append(LogRecord(level, message))

    fn clear(mut self):
        self.captured = List[LogRecord]()


@fieldwise_init
struct LogCapture(Movable):
    var _capture_handler: CaptureHandler
    var _capturing: Bool

    fn __init__(out self):
        self._capture_handler = CaptureHandler()
        self._capturing = False

    fn start(mut self):
        self._capturing = True

    fn stop(mut self):
        self._capturing = False

    fn emit(mut self, level: Level, message: String):
        if self._capturing:
            self._capture_handler.emit(level, message)

    fn get_captured(self) -> List[String]:
        var result = List[String]()
        for record in self._capture_handler.captured:
            result.append(record.message)
        return result^

    fn clear(mut self):
        self._capture_handler.clear()

    fn __enter__(mut self) -> Self:
        self.start()
        return self^

    fn __exit__(mut self):
        self.stop()


fn create_log_capture() -> LogCapture:
    return LogCapture()
