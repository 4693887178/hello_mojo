"""
RQAlpha Mojo - Log Capture
Ported from rqalpha/utils/log_capture.py
"""

from std.collections import List
from rqmojo.utils.logger import Level


@fieldwise_init
struct LogRecord(Movable, Copyable):
    var level: Level
    var message: String


@fieldwise_init
struct CaptureHandler(Movable):
    var captured: List[LogRecord]

    def __init__(out self):
        self.captured = List[LogRecord]()

    def emit(mut self, level: Level, message: String):
        self.captured.append(LogRecord(level, message))

    def clear(mut self):
        self.captured = List[LogRecord]()


@fieldwise_init
struct LogCapture(Movable):
    var _capture_handler: CaptureHandler
    var _capturing: Bool

    def __init__(out self):
        self._capture_handler = CaptureHandler()
        self._capturing = False

    def start(mut self):
        self._capturing = True

    def stop(mut self):
        self._capturing = False

    def emit(mut self, level: Level, message: String):
        if self._capturing:
            self._capture_handler.emit(level, message)

    def get_captured(self) -> List[String]:
        var result = List[String]()
        for record in self._capture_handler.captured:
            result.append(record.message)
        return result^

    def clear(mut self):
        self._capture_handler.clear()

    def __enter__(mut self) -> Self:
        self.start()
        return self^

    def __exit__(mut self):
        self.stop()


def create_log_capture() -> LogCapture:
    return LogCapture()
