"""
RQAlpha Mojo - Execution Context
Ported from rqalpha/core/execution_context.py
"""

from std.collections import List, Dict
from rqmojo.const import EXECUTION_PHASE
from rqmojo.utils.typing import DateTime, DateTimeDate


@fieldwise_init
struct ContextStack(Movable):
    var stack: List[EXECUTION_PHASE]

    def push(mut self, phase: EXECUTION_PHASE):
        self.stack.append(phase)

    def pop(mut self) -> EXECUTION_PHASE:
        if len(self.stack) == 0:
            return EXECUTION_PHASE.GLOBAL
        return self.stack.pop()

    def top(self) -> EXECUTION_PHASE:
        if len(self.stack) == 0:
            return EXECUTION_PHASE.GLOBAL
        return self.stack[len(self.stack) - 1]

    def is_empty(self) -> Bool:
        return len(self.stack) == 0

    def size(self) -> Int:
        return len(self.stack)

    def clear(mut self):
        self.stack = List[EXECUTION_PHASE]()


@fieldwise_init
struct ExecutionContext(Movable, Writable):
    var phase: EXECUTION_PHASE
    var current_datetime: DateTime
    var stack_depth: Int

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ExecutionContext(", self.phase.name, ")")

    def set_datetime(mut self, dt: DateTime):
        self.current_datetime = dt

    def get_phase(self) -> EXECUTION_PHASE:
        return self.phase

    def get_datetime(self) -> DateTime:
        return self.current_datetime

    def is_on_bar(self) -> Bool:
        return self.phase == EXECUTION_PHASE.ON_BAR

    def is_on_tick(self) -> Bool:
        return self.phase == EXECUTION_PHASE.ON_TICK

    def is_before_trading(self) -> Bool:
        return self.phase == EXECUTION_PHASE.BEFORE_TRADING

    def is_after_trading(self) -> Bool:
        return self.phase == EXECUTION_PHASE.AFTER_TRADING

    def is_on_init(self) -> Bool:
        return self.phase == EXECUTION_PHASE.ON_INIT

    def is_global(self) -> Bool:
        return self.phase == EXECUTION_PHASE.GLOBAL


def create_execution_context(phase: EXECUTION_PHASE) -> ExecutionContext:
    return ExecutionContext(
        phase=phase,
        current_datetime=DateTime(2024, 1, 1, 0, 0, 0, 0),
        stack_depth=0
    )


def create_bar_execution_context(dt: DateTime) -> ExecutionContext:
    return ExecutionContext(
        phase=EXECUTION_PHASE.ON_BAR,
        current_datetime=DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.microsecond),
        stack_depth=0
    )


def create_tick_execution_context(dt: DateTime) -> ExecutionContext:
    return ExecutionContext(
        phase=EXECUTION_PHASE.ON_TICK,
        current_datetime=DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.microsecond),
        stack_depth=0
    )
