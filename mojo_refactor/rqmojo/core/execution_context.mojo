"""
RQAlpha Mojo - Execution Context
Ported from rqalpha/core/execution_context.py

Design (vs Python original):
  Python: class + @contextmanager + decorator + class-level shared stack
  Mojo:  struct + explicit enter/exit + function-based phase enforcement
         ContextStack owns its List; pass by reference for sharing
"""

from std.collections import List
from rqmojo.const import EXECUTION_PHASE
from rqmojo.utils.exception import RQUserError


@fieldwise_init
struct ContextStack(Copyable, Movable, Writable):
    """Execution context stack storing EXECUTION_PHASE values.

    Python original stores ExecutionContext objects on the stack.
    Mojo adaptation: stores phases since ExecutionContext is a value type.
    """
    var stack: List[EXECUTION_PHASE]

    def __init__(out self):
        self.stack = List[EXECUTION_PHASE]()

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ContextStack(size=", len(self.stack), ")")

    def push(mut self, phase: EXECUTION_PHASE):
        self.stack.append(phase)

    def pop(mut self) raises -> EXECUTION_PHASE:
        if len(self.stack) == 0:
            raise Error("stack is empty")
        return self.stack.pop()

    def top(self) raises -> EXECUTION_PHASE:
        if len(self.stack) == 0:
            raise Error("stack is empty")
        return self.stack[len(self.stack) - 1]

    def is_empty(self) -> Bool:
        return len(self.stack) == 0

    def size(self) -> Int:
        return len(self.stack)

    def clear(mut self):
        self.stack = List[EXECUTION_PHASE]()


@fieldwise_init
struct ExecutionContext(Movable, Writable):
    """Execution context manager for tracking current execution phase.

    Mirrors Python's ExecutionContext (__enter__/__exit__ protocol).
    In Mojo, call enter()/exit() explicitly.
    """
    var phase: EXECUTION_PHASE

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ExecutionContext(phase=", self.phase.name, ")")

    def _push(mut self, mut cs: ContextStack):
        cs.push(self.phase)

    def _pop(mut self, mut cs: ContextStack) raises:
        var popped = cs.pop()
        if popped != self.phase:
            raise Error(
                "Popped wrong context: expected "
                + self.phase.name
                + " got "
                + popped.name,
            )

    def enter(mut self, mut cs: ContextStack):
        self._push(cs)

    def exit(
        mut self,
        mut cs: ContextStack,
        exc_type: Optional[String],
        exc_val: Optional[String],
        exc_tb: Optional[String],
    ) raises -> Bool:
        if exc_type == None:
            self._pop(cs)
            return False
        self._pop(cs)
        var msg = "Error in execution context"
        if exc_val != None:
            msg = exc_val[]
        raise RQUserError.create(msg)

    def get_phase(self) -> EXECUTION_PHASE:
        return self.phase

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


def get_current_phase(cs: ContextStack) raises -> EXECUTION_PHASE:
    """Return the current execution phase from the given stack.

    Equivalent to Python's ExecutionContext.phase().
    """
    return cs.top()


def check_phase(
    cs: ContextStack,
    func_name: String,
    allowed_phases: List[EXECUTION_PHASE],
) raises:
    """Check that the current phase is in the allowed list.

    Equivalent to Python's ExecutionContext.enforce_phase() decorator logic.
    Raises RQUserError if phase is not allowed.
    """
    var current = cs.top()
    for i in range(len(allowed_phases)):
        if current == allowed_phases[i]:
            return
    raise RQUserError.create(
        "You cannot call "
        + func_name
        + " when executing "
        + current.value,
    )


def create_execution_context(phase: EXECUTION_PHASE) -> ExecutionContext:
    return ExecutionContext(phase=phase)


def create_bar_execution_context() -> ExecutionContext:
    return ExecutionContext(phase=EXECUTION_PHASE.ON_BAR)


def create_tick_execution_context() -> ExecutionContext:
    return ExecutionContext(phase=EXECUTION_PHASE.ON_TICK)


def create_before_trading_context() -> ExecutionContext:
    return ExecutionContext(phase=EXECUTION_PHASE.BEFORE_TRADING)


def create_after_trading_context() -> ExecutionContext:
    return ExecutionContext(phase=EXECUTION_PHASE.AFTER_TRADING)


def create_init_context() -> ExecutionContext:
    return ExecutionContext(phase=EXECUTION_PHASE.ON_INIT)
