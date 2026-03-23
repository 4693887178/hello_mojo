"""
RQAlpha Mojo - Log Capture
Ported from rqalpha/utils/log_capture.py

Core semantics (matching Python):
1. LogCapture intercepts logs by wrapping the handler chain
2. __enter__ starts capturing (logs go to capture handler only)
3. __exit__ stops capturing and optionally replays to original handler
4. replay() sends captured records to original handler

Design:
- Simplified from original over-engineered version
- Uses trait-based handler abstraction
- Clear separation: capture -> replay -> restore
"""

from std.collections import List
from std.logger import Level


comptime DEFAULT_CAPACITY = 64


@fieldwise_init
struct LogRecord(Movable, Copyable, ImplicitlyCopyable, Writable):
    var level: Level
    var message: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("[", String(self.level), "] ", self.message)


trait LogHandler(Movable, Copyable, ImplicitlyCopyable):
    def emit(mut self, record: LogRecord): ...
    def count(self) -> Int: ...


struct CaptureHandler(LogHandler, Movable, Copyable, ImplicitlyCopyable):
    var captured: List[LogRecord]

    def __init__(out self, capacity: Int = DEFAULT_CAPACITY):
        self.captured = List[LogRecord]()
        self.captured.reserve(capacity)

    def __init__(out self, *, copy: Self):
        self.captured = List[LogRecord]()
        self.captured.reserve(len(copy.captured))
        for record in copy.captured:
            self.captured.append(record)

    def emit(mut self, record: LogRecord):
        self.captured.append(record)

    def clear(mut self):
        self.captured.clear()

    def count(self) -> Int:
        return len(self.captured)


struct LogCapture[H: LogHandler](Movable):
    var _logger_handler: Self.H
    var _capture_handler: CaptureHandler
    var _is_capturing: Bool

    def __init__(out self, var logger_handler: Self.H, capacity: Int = DEFAULT_CAPACITY):
        self._logger_handler = logger_handler^
        self._capture_handler = CaptureHandler(capacity)
        self._is_capturing = False

    def __init__(out self, *, copy: Self):
        self._logger_handler = copy._logger_handler
        self._capture_handler = CaptureHandler(copy=copy._capture_handler)
        self._is_capturing = copy._is_capturing

    def emit(mut self, record: LogRecord):
        if self._is_capturing:
            self._capture_handler.emit(record)
        else:
            self._logger_handler.emit(record)

    def get_records(self) -> List[LogRecord]:
        var result = List[LogRecord]()
        result.reserve(len(self._capture_handler.captured))
        for record in self._capture_handler.captured:
            result.append(record)
        return result^

    def clear(mut self):
        self._capture_handler.clear()

    def count(self) -> Int:
        return len(self._capture_handler.captured)

    def is_empty(self) -> Bool:
        return len(self._capture_handler.captured) == 0

    def replay(mut self):
        for record in self._capture_handler.captured:
            self._logger_handler.emit(record)

    def start(mut self):
        self._is_capturing = True

    def stop(mut self):
        self._is_capturing = False

    def handler_count(self) -> Int:
        return self._logger_handler.count()

    def __enter__(mut self) -> ref[self] Self:
        self._is_capturing = True
        return self

    def __exit__(mut self) -> Bool:
        self._is_capturing = False
        return False


def create_log_capture[H: LogHandler](var handler: H, capacity: Int = DEFAULT_CAPACITY) -> LogCapture[H]:
    return LogCapture[H](handler^, capacity)
