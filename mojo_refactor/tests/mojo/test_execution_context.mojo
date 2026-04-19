"""
Comprehensive tests for rqmojo/core/execution_context.mojo
Tests mirror Python's rqalpha/core/execution_context.py behavior.

Coverage:
  1. ContextStack: push, pop, top, is_empty, size, clear
  2. ContextStack error handling: pop/top on empty stack raises Error
  3. ExecutionContext: creation, phase access, is_* helpers
  4. ExecutionContext._push / _pop: stack management
  5. ExecutionContext.enter / exit: context manager protocol
  6. ExecutionContext.exit with exception: re-raise as RQUserError
  7. get_current_phase: class-method equivalent
  8. check_phase: phase enforcement logic
  9. Factory functions: create_*_context
  10. Nested context push/pop correctness
"""

from std.testing import assert_equal, assert_true, assert_false, assert_raises
from rqmojo.const import EXECUTION_PHASE
from rqmojo.core.execution_context import (
    ContextStack,
    ExecutionContext,
    get_current_phase,
    check_phase,
    create_execution_context,
    create_bar_execution_context,
    create_tick_execution_context,
    create_before_trading_context,
    create_after_trading_context,
    create_init_context,
)
from rqmojo.utils.exception import RQUserError


def test_context_stack_push_and_size() raises:
    print("  [test] ContextStack push and size")
    var cs = ContextStack()
    assert_equal(cs.size(), 0)
    assert_true(cs.is_empty())
    cs.push(EXECUTION_PHASE.ON_INIT)
    assert_equal(cs.size(), 1)
    assert_false(cs.is_empty())
    cs.push(EXECUTION_PHASE.ON_BAR)
    assert_equal(cs.size(), 2)
    cs.push(EXECUTION_PHASE.AFTER_TRADING)
    assert_equal(cs.size(), 3)


def test_context_stack_pop() raises:
    print("  [test] ContextStack pop")
    var cs = ContextStack()
    cs.push(EXECUTION_PHASE.GLOBAL)
    cs.push(EXECUTION_PHASE.ON_INIT)
    var popped = cs.pop()
    assert_equal(popped, EXECUTION_PHASE.ON_INIT)
    assert_equal(cs.size(), 1)
    popped = cs.pop()
    assert_equal(popped, EXECUTION_PHASE.GLOBAL)
    assert_equal(cs.size(), 0)


def test_context_stack_top() raises:
    print("  [test] ContextStack top")
    var cs = ContextStack()
    cs.push(EXECUTION_PHASE.BEFORE_TRADING)
    cs.push(EXECUTION_PHASE.ON_BAR)
    assert_equal(cs.top(), EXECUTION_PHASE.ON_BAR)
    _ = cs.pop()
    assert_equal(cs.top(), EXECUTION_PHASE.BEFORE_TRADING)


def test_context_stack_pop_empty_raises() raises:
    print("  [test] ContextStack pop empty raises")
    var cs = ContextStack()
    with assert_raises():
        _ = cs.pop()


def test_context_stack_top_empty_raises() raises:
    print("  [test] ContextStack top empty raises")
    var cs = ContextStack()
    with assert_raises():
        _ = cs.top()


def test_context_stack_clear() raises:
    print("  [test] ContextStack clear")
    var cs = ContextStack()
    cs.push(EXECUTION_PHASE.ON_BAR)
    cs.push(EXECUTION_PHASE.ON_TICK)
    assert_equal(cs.size(), 2)
    cs.clear()
    assert_equal(cs.size(), 0)
    assert_true(cs.is_empty())


def test_context_stack_lifo_order() raises:
    print("  [test] ContextStack LIFO order")
    var cs = ContextStack()
    cs.push(EXECUTION_PHASE.ON_INIT)
    cs.push(EXECUTION_PHASE.BEFORE_TRADING)
    cs.push(EXECUTION_PHASE.OPEN_AUCTION)
    cs.push(EXECUTION_PHASE.ON_BAR)
    assert_equal(cs.pop(), EXECUTION_PHASE.ON_BAR)
    assert_equal(cs.pop(), EXECUTION_PHASE.OPEN_AUCTION)
    assert_equal(cs.pop(), EXECUTION_PHASE.BEFORE_TRADING)
    assert_equal(cs.pop(), EXECUTION_PHASE.ON_INIT)


def test_execution_context_creation() raises:
    print("  [test] ExecutionContext creation")
    var ctx = create_execution_context(EXECUTION_PHASE.ON_BAR)
    assert_equal(ctx.get_phase(), EXECUTION_PHASE.ON_BAR)
    assert_true(ctx.is_on_bar())
    assert_false(ctx.is_on_tick())
    assert_false(ctx.is_before_trading())
    assert_false(ctx.is_after_trading())
    assert_false(ctx.is_on_init())
    assert_false(ctx.is_global())


def test_execution_context_all_phases() raises:
    print("  [test] ExecutionContext all phases")
    var phases_list = [
        EXECUTION_PHASE.GLOBAL,
        EXECUTION_PHASE.ON_INIT,
        EXECUTION_PHASE.BEFORE_TRADING,
        EXECUTION_PHASE.OPEN_AUCTION,
        EXECUTION_PHASE.ON_BAR,
        EXECUTION_PHASE.ON_TICK,
        EXECUTION_PHASE.AFTER_TRADING,
        EXECUTION_PHASE.FINALIZED,
        EXECUTION_PHASE.SCHEDULED,
    ]
    for phase in phases_list:
        var ctx = ExecutionContext(phase=phase)
        assert_equal(ctx.get_phase(), phase)


def test_execution_context_is_helpers() raises:
    print("  [test] ExecutionContext is_* helpers")
    var init_ctx = create_init_context()
    assert_true(init_ctx.is_on_init())
    assert_false(init_ctx.is_on_bar())

    var bar_ctx = create_bar_execution_context()
    assert_true(bar_ctx.is_on_bar())
    assert_false(bar_ctx.is_on_init())

    var tick_ctx = create_tick_execution_context()
    assert_true(tick_ctx.is_on_tick())
    assert_false(tick_ctx.is_on_bar())

    var before_ctx = create_before_trading_context()
    assert_true(before_ctx.is_before_trading())
    assert_false(before_ctx.is_on_tick())

    var after_ctx = create_after_trading_context()
    assert_true(after_ctx.is_after_trading())
    assert_false(after_ctx.is_before_trading())


def test_execution_context_push_and_pop() raises:
    print("  [test] ExecutionContext push/pop via stack")
    var cs = ContextStack()
    var ctx = ExecutionContext(phase=EXECUTION_PHASE.ON_BAR)
    ctx._push(cs)
    assert_equal(cs.size(), 1)
    assert_equal(cs.top(), EXECUTION_PHASE.ON_BAR)
    ctx._pop(cs)
    assert_equal(cs.size(), 0)


def test_enter_exit_normal_flow() raises:
    print("  [test] enter/exit normal flow (no exception)")
    var cs = ContextStack()
    var ctx = ExecutionContext(phase=EXECUTION_PHASE.ON_BAR)
    ctx.enter(cs)
    assert_equal(cs.top(), EXECUTION_PHASE.ON_BAR)
    var result = ctx.exit(cs, None, None, None)
    assert_equal(result, False)
    assert_true(cs.is_empty())


def test_enter_exit_with_exception() raises:
    print("  [test] enter/exit with exception re-raises as RQUserError")
    var cs = ContextStack()
    var ctx = ExecutionContext(phase=EXECUTION_PHASE.ON_BAR)
    ctx.enter(cs)
    assert_equal(cs.size(), 1)
    var caught = False
    try:
        _ = ctx.exit(
            cs,
            Optional[String]("ValueError"),
            Optional[String]("test error message"),
            Optional[String](None),
        )
    except e:
        caught = True
        var err_str = String(e)
        assert_true(
            err_str == "Error in execution context"
            or err_str == "test error message",
            "Exception message should contain error info",
        )
    assert_true(caught, "Should have caught RQUserError")
    assert_true(cs.is_empty(), "Stack should be empty after exception exit")


def test_nested_contexts() raises:
    print("  [test] Nested contexts push/pop correctly")
    var cs = ContextStack()
    var outer = ExecutionContext(phase=EXECUTION_PHASE.BEFORE_TRADING)
    var inner = ExecutionContext(phase=EXECUTION_PHASE.ON_BAR)
    outer.enter(cs)
    assert_equal(cs.top(), EXECUTION_PHASE.BEFORE_TRADING)
    inner.enter(cs)
    assert_equal(cs.top(), EXECUTION_PHASE.ON_BAR)
    assert_equal(cs.size(), 2)
    _ = inner.exit(cs, None, None, None)
    assert_equal(cs.top(), EXECUTION_PHASE.BEFORE_TRADING)
    _ = outer.exit(cs, None, None, None)
    assert_true(cs.is_empty())


def test_get_current_phase() raises:
    print("  [test] get_current_phase returns stack top")
    var cs = ContextStack()
    cs.push(EXECUTION_PHASE.ON_TICK)
    assert_equal(get_current_phase(cs), EXECUTION_PHASE.ON_TICK)
    cs.push(EXECUTION_PHASE.SCHEDULED)
    assert_equal(get_current_phase(cs), EXECUTION_PHASE.SCHEDULED)


def test_check_phase_allowed() raises:
    print("  [test] check_phase passes when current phase is allowed")
    var cs = ContextStack()
    cs.push(EXECUTION_PHASE.ON_BAR)
    check_phase(cs, "order_target", [EXECUTION_PHASE.ON_BAR, EXECUTION_PHASE.ON_TICK])


def test_check_phase_rejected() raises:
    print("  [test] check_phase raises when current phase not allowed")
    var cs = ContextStack()
    cs.push(EXECUTION_PHASE.ON_INIT)
    var caught = False
    try:
        check_phase(cs, "order_target", [EXECUTION_PHASE.ON_BAR, EXECUTION_PHASE.ON_TICK])
    except e:
        caught = True
        var err_str = String(e)
        assert_true(
            len(err_str) > 0,
            "Error message should not be empty",
        )
    assert_true(caught, "Should have raised RQUserError")


def test_check_phase_single_allowed() raises:
    print("  [test] check_phase with single allowed phase")
    var cs = ContextStack()
    cs.push(EXECUTION_PHASE.ON_BAR)
    check_phase(cs, "some_func", [EXECUTION_PHASE.ON_BAR])


def test_factory_functions() raises:
    print("  [test] Factory functions create correct phases")
    assert_equal(create_init_context().get_phase(), EXECUTION_PHASE.ON_INIT)
    assert_equal(create_before_trading_context().get_phase(), EXECUTION_PHASE.BEFORE_TRADING)
    assert_equal(create_bar_execution_context().get_phase(), EXECUTION_PHASE.ON_BAR)
    assert_equal(create_tick_execution_context().get_phase(), EXECUTION_PHASE.ON_TICK)
    assert_equal(create_after_trading_context().get_phase(), EXECUTION_PHASE.AFTER_TRADING)


def test_full_lifecycle() raises:
    print("  [test] Full lifecycle: INIT -> BEFORE -> BAR -> AFTER")
    var cs = ContextStack()

    var init_ctx = create_init_context()
    init_ctx.enter(cs)
    assert_equal(get_current_phase(cs), EXECUTION_PHASE.ON_INIT)
    _ = init_ctx.exit(cs, None, None, None)

    var before_ctx = create_before_trading_context()
    before_ctx.enter(cs)
    assert_equal(get_current_phase(cs), EXECUTION_PHASE.BEFORE_TRADING)

    var bar_ctx = create_bar_execution_context()
    bar_ctx.enter(cs)
    assert_equal(get_current_phase(cs), EXECUTION_PHASE.ON_BAR)
    check_phase(cs, "schedule", [EXECUTION_PHASE.ON_BAR])
    _ = bar_ctx.exit(cs, None, None, None)

    var after_ctx = create_after_trading_context()
    after_ctx.enter(cs)
    assert_equal(get_current_phase(cs), EXECUTION_PHASE.AFTER_TRADING)
    _ = after_ctx.exit(cs, None, None, None)
    _ = before_ctx.exit(cs, None, None, None)
    assert_true(cs.is_empty())


def test_writable_output() raises:
    print("  [test] Writable output for debugging")
    var cs = ContextStack()
    cs.push(EXECUTION_PHASE.ON_BAR)
    var cs_str = String.write(cs)
    assert_true(len(cs_str) > 0)

    var ctx = ExecutionContext(phase=EXECUTION_PHASE.ON_TICK)
    var ctx_str = String.write(ctx)
    assert_true(len(ctx_str) > 0)


def main() raises:
    print("=" * 60)
    print("Running Execution Context Tests")
    print("=" * 60)

    test_context_stack_push_and_size()
    test_context_stack_pop()
    test_context_stack_top()
    test_context_stack_pop_empty_raises()
    test_context_stack_top_empty_raises()
    test_context_stack_clear()
    test_context_stack_lifo_order()

    test_execution_context_creation()
    test_execution_context_all_phases()
    test_execution_context_is_helpers()
    test_execution_context_push_and_pop()
    test_enter_exit_normal_flow()
    test_enter_exit_with_exception()
    test_nested_contexts()

    test_get_current_phase()
    test_check_phase_allowed()
    test_check_phase_rejected()
    test_check_phase_single_allowed()

    test_factory_functions()
    test_full_lifecycle()
    test_writable_output()

    print("=" * 60)
    print("All 22 Execution Context tests passed!")
    print("=" * 60)
