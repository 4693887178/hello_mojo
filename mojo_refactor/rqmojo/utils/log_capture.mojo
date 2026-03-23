"""
RQAlpha Mojo - Log Capture
Ported from rqalpha/utils/log_capture.py

Mojo-idiomatic redesign:
- LogCapture directly owns a CaptureHandler (no external handler needed)
- replay(target) replays captured records to any target handler
- capture(record) adds a record to the internal buffer

Python version swaps logger.handlers at enter/exit; this Mojo
port drops that illusion and provides a pure capture-replay contract.
"""

from std.collections import List
from std.logger import Level


@fieldwise_init
struct LogRecord(Movable, Copyable, ImplicitlyCopyable, Writable):
    var level: Level
    var message: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("[", String(self.level), "] ", self.message)


struct CaptureHandler(Movable, Copyable):
    var captured: List[LogRecord]

    def __init__(out self):
        self.captured = List[LogRecord]()

    def __init__(out self, *, copy: Self):
        self.captured = copy.captured.copy()

    def emit(mut self, record: LogRecord):
        self.captured.append(record)


struct LogCapture(Movable):
    var _capture_handler: CaptureHandler

    def __init__(out self):
        self._capture_handler = CaptureHandler()

    def __init__(out self, *, copy: Self):
        self._capture_handler = copy._capture_handler.copy()

    def __enter__(mut self) -> ref[self] Self:
        return self

    def __exit__(mut self) -> Bool:
        return False

    def capture(mut self, record: LogRecord):
        self._capture_handler.emit(record)

    def replay(mut self, mut target: CaptureHandler):
        for record in self._capture_handler.captured:
            target.emit(record)

    def replay_and_clear(mut self, mut target: CaptureHandler):
        self.replay(target)
        self._capture_handler.captured.clear()
