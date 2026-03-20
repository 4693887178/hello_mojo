"""
RQAlpha Mojo - Execution Context
Ported from rqalpha/core/execution_context.py
"""

from collections import List, Dict
from rqmojo.const import EXECUTION_PHASE, EXECUTION_PHASE_GLOBAL, EXECUTION_PHASE_ON_BAR, EXECUTION_PHASE_ON_TICK, EXECUTION_PHASE_BEFORE_TRADING, EXECUTION_PHASE_AFTER_TRADING, EXECUTION_PHASE_ON_INIT, EXECUTION_PHASE_GLOBAL, EXECUTION_PHASE_ON_BAR, EXECUTION_PHASE_ON_TICK, EXECUTION_PHASE_BEFORE_TRADING, EXECUTION_PHASE_AFTER_TRADING, EXECUTION_PHASE_ON_INIT
from rqmojo.utils.datetime_func import DateTime, Date


@fieldwise_init
struct ContextStack(Movable):
    var stack: List[EXECUTION_PHASE]

    fn push(mut self, phase: EXECUTION_PHASE):
        self.stack.append(phase)

    fn pop(mut self) -> EXECUTION_PHASE:
        if len(self.stack) == 0:
            return EXECUTION_PHASE_GLOBAL
        return self.stack.pop()

    fn top(self) -> EXECUTION_PHASE:
        if len(self.stack) == 0:
            return EXECUTION_PHASE_GLOBAL
        return self.stack[len(self.stack) - 1]

    fn is_empty(self) -> Bool:
        return len(self.stack) == 0

    fn size(self) -> Int:
        return len(self.stack)

    fn clear(mut self):
        self.stack = List[EXECUTION_PHASE]()


@fieldwise_init
struct ExecutionContext(Movable, Stringable, ImplicitlyCopyable):
    var phase: EXECUTION_PHASE
    var current_datetime: DateTime
    var stack_depth: Int

    fn __str__(self) -> String:
        return "ExecutionContext(" + self.phase.name + ")"

    fn set_datetime(mut self, dt: DateTime):
        self.current_datetime = dt

    fn get_phase(self) -> EXECUTION_PHASE:
        return self.phase

    fn get_datetime(self) -> DateTime:
        return self.current_datetime

    fn is_on_bar(self) -> Bool:
        return self.phase == EXECUTION_PHASE_ON_BAR

    fn is_on_tick(self) -> Bool:
        return self.phase == EXECUTION_PHASE_ON_TICK

    fn is_before_trading(self) -> Bool:
        return self.phase == EXECUTION_PHASE_BEFORE_TRADING

    fn is_after_trading(self) -> Bool:
        return self.phase == EXECUTION_PHASE_AFTER_TRADING

    fn is_on_init(self) -> Bool:
        return self.phase == EXECUTION_PHASE_ON_INIT

    fn is_global(self) -> Bool:
        return self.phase == EXECUTION_PHASE_GLOBAL


fn create_execution_context(phase: EXECUTION_PHASE) -> ExecutionContext:
    return ExecutionContext(
        phase=phase,
        current_datetime=DateTime(2024, 1, 1, 0, 0, 0, 0),
        stack_depth=0
    )


fn create_bar_execution_context(dt: DateTime) -> ExecutionContext:
    return ExecutionContext(
        phase=EXECUTION_PHASE_ON_BAR,
        current_datetime=dt,
        stack_depth=0
    )


fn create_tick_execution_context(dt: DateTime) -> ExecutionContext:
    return ExecutionContext(
        phase=EXECUTION_PHASE_ON_TICK,
        current_datetime=dt,
        stack_depth=0
    )
