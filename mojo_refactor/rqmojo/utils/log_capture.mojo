"""
RQAlpha Mojo - Log Capture
Ported from rqalpha/utils/log_capture.py

Pure Mojo implementation matching Python original behavior.
Uses ArcPointer for shared mutable state (mimics Python reference semantics).

Design: ArcPointer provides true shared references, eliminating the need
for _active flags, data copy-back in __exit__, and conditional reads.
This matches Python's behavior where self._logger = logger stores a reference.
"""

from std.collections import List
from std.logger import Level
from std.memory import ArcPointer


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


struct RQLogger(Movable, Copyable, Writable):
    """Logger with a swappable handler list (ArcPointer-based).
    
    Handlers are stored as ArcPointers so multiple references can share
    the same underlying handler - essential for LogCapture's intercept pattern.
    """
    var name: String
    var _handlers: List[ArcPointer[CaptureHandler]]

    def __init__(out self, name: String = ""):
        self.name = name
        self._handlers = List[ArcPointer[CaptureHandler]]()

    def __init__(out self, *, copy: Self):
        self.name = copy.name
        self._handlers = copy._handlers.copy()

    def get_handlers(self) -> List[ArcPointer[CaptureHandler]]:
        return self._handlers.copy()

    def clear_handlers(mut self):
        self._handlers.clear()

    def add_handler(mut self, var handler: CaptureHandler):
        self._handlers.append(ArcPointer(handler^))

    def add_handler_arc(mut self, arc: ArcPointer[CaptureHandler]):
        self._handlers.append(arc)

    def handle(mut self, record: LogRecord):
        var i = 0
        while i < len(self._handlers):
            self._handlers[i][].emit(record)
            i += 1

    def write_to(self, mut writer: Some[Writer]):
        writer.write("RQLogger(", self.name, ", handlers=", len(self._handlers), ")")


struct LogCapture(Movable, Copyable):
    """Context manager that intercepts log output from an RQLogger.
    
    Uses ArcPointer[CaptureHandler] so the installed handler and
    capture_handler() accessor share the same underlying data -
    no _active flag or data shuffling needed.
    
    Matches Python LogCapture exactly:
      1. __enter__: saves current handlers, installs CaptureHandler via ArcPointer
      2. (block executes - all log goes to shared CaptureHandler)
      3. __exit__: restores original handlers
      4. replay(): dispatches captured records back to logger
    """
    var _logger: RQLogger
    var _capture_handler: ArcPointer[CaptureHandler]
    var _saved_handlers: List[ArcPointer[CaptureHandler]]

    def __init__(out self, var logger: RQLogger):
        self._logger = logger^
        self._capture_handler = ArcPointer(CaptureHandler())
        self._saved_handlers = List[ArcPointer[CaptureHandler]]()

    def __init__(out self, *, copy: Self):
        self._logger = copy._logger.copy()
        self._capture_handler = copy._capture_handler.copy()
        self._saved_handlers = copy._saved_handlers.copy()

    def __enter__(mut self) -> ref[self] Self:
        self._saved_handlers = self._logger.get_handlers()
        self._logger.clear_handlers()
        self._logger.add_handler_arc(self._capture_handler.copy())
        return self

    def __exit__(mut self) -> Bool:
        self._logger.clear_handlers()
        var i = 0
        while i < len(self._saved_handlers):
            self._logger.add_handler_arc(self._saved_handlers[i].copy())
            i += 1
        self._saved_handlers = List[ArcPointer[CaptureHandler]]()
        return False

    def handle(mut self, record: LogRecord):
        self._logger.handle(record)

    def add_handler(mut self, var handler: CaptureHandler):
        self._logger.add_handler(handler^)

    def replay(mut self):
        """Replay all captured records to the logger's current handlers."""
        var records = self._capture_handler[].captured.copy()
        var i = 0
        while i < len(records):
            self._logger.handle(records[i])
            i += 1

    def capture_handler(ref self) -> CaptureHandler:
        return self._capture_handler[].copy()


def create_log_capture(var logger: RQLogger) -> LogCapture:
    return LogCapture(logger^)
