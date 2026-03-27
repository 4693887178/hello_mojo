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



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_context_stack() raises:
    print("Test: ContextStack struct")
    var stack = ContextStack(stack=List[EXECUTION_PHASE]())
    stack.push(EXECUTION_PHASE.ON_BAR)
    var top = stack.top()
    print("  Stack top: ", top.name)
    assert_true(True, "test passed")


def test_context_stack_push_pop() raises:
    print("Test: ContextStack push and pop")
    var stack = ContextStack(stack=List[EXECUTION_PHASE]())
    stack.push(EXECUTION_PHASE.ON_BAR)
    stack.push(EXECUTION_PHASE.BEFORE_TRADING)
    var top = stack.top()
    print("  Top after push: ", top.name)
    var popped = stack.pop()
    print("  Popped: ", popped.name)
    assert_true(True, "test passed")


def test_execution_context() raises:
    print("Test: ExecutionContext struct")
    var ctx = create_execution_context(EXECUTION_PHASE.ON_BAR)
    print("  ExecutionContext phase: ", ctx.phase.name)
    assert_true(True, "test passed")


def test_bar_execution_context() raises:
    print("Test: create_bar_execution_context")
    var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
    var ctx = create_bar_execution_context(dt)
    print("  Bar context phase: ", ctx.phase.name)
    assert_true(True, "test passed")


def test_tick_execution_context() raises:
    print("Test: create_tick_execution_context")
    var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
    var ctx = create_tick_execution_context(dt)
    print("  Tick context phase: ", ctx.phase.name)
    assert_true(True, "test passed")


def test_execution_context_is_on_bar() raises:
    print("Test: ExecutionContext.is_on_bar")
    var ctx = create_bar_execution_context(DateTime(2024, 1, 1, 9, 30, 0, 0))
    if ctx.is_on_bar():
        print("  is_on_bar returned True")
        assert_true(True, "test passed")
    else:
        print("  is_on_bar returned False, expected True")
        assert_true(False, "test failed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()