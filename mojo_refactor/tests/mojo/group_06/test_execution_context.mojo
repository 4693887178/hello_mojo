"""
Test for core/execution_context.mojo
Group 06 - File 08
"""

from rqmojo.core.execution_context import (
    ContextStack,
    ExecutionContext,
    create_execution_context,
    create_bar_execution_context,
    create_tick_execution_context
)
from rqmojo.const import EXECUTION_PHASE
from rqmojo.utils.typing import DateTime


def test_context_stack() -> Bool:
    print("Test: ContextStack struct")
    var stack = ContextStack(stack=List[EXECUTION_PHASE]())
    stack.push(EXECUTION_PHASE.ON_BAR)
    var top = stack.top()
    print("  Stack top: ", top.name)
    return True


def test_context_stack_push_pop() -> Bool:
    print("Test: ContextStack push and pop")
    var stack = ContextStack(stack=List[EXECUTION_PHASE]())
    stack.push(EXECUTION_PHASE.ON_BAR)
    stack.push(EXECUTION_PHASE.BEFORE_TRADING)
    var top = stack.top()
    print("  Top after push: ", top.name)
    var popped = stack.pop()
    print("  Popped: ", popped.name)
    return True


def test_execution_context() -> Bool:
    print("Test: ExecutionContext struct")
    var ctx = create_execution_context(EXECUTION_PHASE.ON_BAR)
    print("  ExecutionContext phase: ", ctx.phase.name)
    return True


def test_bar_execution_context() -> Bool:
    print("Test: create_bar_execution_context")
    var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
    var ctx = create_bar_execution_context(dt)
    print("  Bar context phase: ", ctx.phase.name)
    return True


def test_tick_execution_context() -> Bool:
    print("Test: create_tick_execution_context")
    var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
    var ctx = create_tick_execution_context(dt)
    print("  Tick context phase: ", ctx.phase.name)
    return True


def test_execution_context_is_on_bar() -> Bool:
    print("Test: ExecutionContext.is_on_bar")
    var ctx = create_bar_execution_context(DateTime(2024, 1, 1, 9, 30, 0, 0))
    if ctx.is_on_bar():
        print("  is_on_bar returned True")
        return True
    else:
        print("  is_on_bar returned False, expected True")
        return False


def main() -> None:
    print("=== Group 06 File 08: Execution Context Tests ===")
    print("")
    
    var passed = 0
    var failed = 0
    
    if test_context_stack():
        passed += 1
    else:
        failed += 1
    
    if test_context_stack_push_pop():
        passed += 1
    else:
        failed += 1
    
    if test_execution_context():
        passed += 1
    else:
        failed += 1
    
    if test_bar_execution_context():
        passed += 1
    else:
        failed += 1
    
    if test_tick_execution_context():
        passed += 1
    else:
        failed += 1
    
    if test_execution_context_is_on_bar():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
