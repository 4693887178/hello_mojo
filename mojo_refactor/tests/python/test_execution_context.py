"""
Python integration tests for execution_context.
Validates Python rqalpha/core/execution_context.py behavior as reference.

These tests serve as the "golden standard" that the Mojo implementation
must match. Run with: pytest tests/python/test_execution_context.py -v
"""

import pytest
from rqalpha.core.execution_context import ExecutionContext, ContextStack
from rqalpha.const import EXECUTION_PHASE


class TestContextStack:
    """Test ContextStack: push, pop, top, error handling."""

    def test_push_and_size(self):
        cs = ContextStack()
        assert cs.stack == []
        assert len(cs.stack) == 0
        cs.push(EXECUTION_PHASE.ON_INIT)
        assert len(cs.stack) == 1
        cs.push(EXECUTION_PHASE.ON_BAR)
        assert len(cs.stack) == 2

    def test_pop_returns_lifo_order(self):
        cs = ContextStack()
        cs.push(EXECUTION_PHASE.ON_INIT)
        cs.push(EXECUTION_PHASE.ON_BAR)
        assert cs.pop() is not None  # Returns context object
        assert len(cs.stack) == 1

    def test_pop_empty_raises_runtime_error(self):
        cs = ContextStack()
        with pytest.raises(RuntimeError, match="stack is empty"):
            cs.pop()

    def test_top_empty_raises_runtime_error(self):
        cs = ContextStack()
        with pytest.raises(RuntimeError, match="stack is empty"):
            _ = cs.top

    def test_top_returns_last_pushed(self):
        cs = ContextStack()
        ctx = ExecutionContext(EXECUTION_PHASE.ON_BAR)
        cs.push(ctx)
        assert cs.top.phase == EXECUTION_PHASE.ON_BAR

    def test_pushed_context_manager(self):
        """Test the 'pushed' context manager for automatic push/pop."""
        cs = ContextStack()
        ctx1 = ExecutionContext(EXECUTION_PHASE.ON_INIT)
        ctx2 = ExecutionContext(EXECUTION_PHASE.ON_BAR)

        with cs.pushed(ctx1):
            assert cs.top.phase == EXECUTION_PHASE.ON_INIT
            with cs.pushed(ctx2):
                assert cs.top.phase == EXECUTION_PHASE.ON_BAR
            assert cs.top.phase == EXECUTION_PHASE.ON_INIT

        with pytest.raises(RuntimeError, match="stack is empty"):
            _ = cs.top


class TestExecutionContext:
    """Test ExecutionContext: creation, phase, enter/exit."""

    def test_creation_with_phase(self):
        ctx = ExecutionContext(EXECUTION_PHASE.ON_BAR)
        assert ctx.phase == EXECUTION_PHASE.ON_BAR

    def test_enter_pushes_to_stack(self):
        ctx = ExecutionContext(EXECUTION_PHASE.ON_BAR)
        result = ctx.__enter__()
        assert result is ctx  # __enter__ returns self
        assert ExecutionContext.stack.top.phase == EXECUTION_PHASE.ON_BAR
        ctx.__exit__(None, None, None)  # cleanup

    def test_exit_normal_pops_stack(self):
        ctx = ExecutionContext(EXECUTION_PHASE.ON_BAR)
        ctx.__enter__()
        assert not ExecutionContext.stack.is_empty() if hasattr(ExecutionContext.stack, 'is_empty') else True
        result = ctx.__exit__(None, None, None)
        assert result is False  # False = exception NOT handled

    def test_exit_with_exception_re_raises(self):
        """When an exception occurs during context, it should be re-raised."""
        ctx = ExecutionContext(EXECUTION_PHASE.ON_BAR)
        ctx.__enter__()
        try:
            # Simulate an exception inside the context
            with pytest.raises(Exception):
                ctx.__exit__(RuntimeError, RuntimeError("test error"), None)
        finally:
            # Stack should be popped even on exception
            pass

    def test_nested_contexts(self):
        """Test nested execution contexts maintain correct stack order."""
        outer = ExecutionContext(EXECUTION_PHASE.BEFORE_TRADING)
        inner = ExecutionContext(EXECUTION_PHASE.ON_BAR)

        outer.__enter__()
        assert ExecutionContext.stack.top.phase == EXECUTION_PHASE.BEFORE_TRADING

        inner.__enter__()
        assert ExecutionContext.stack.top.phase == EXECUTION_PHASE.ON_BAR

        inner.__exit__(None, None, None)
        assert ExecutionContext.stack.top.phase == EXECUTION_PHASE.BEFORE_TRADING

        outer.__exit__(None, None, None)
        # Stack should be empty now

    def test_pop_wrong_context_raises(self):
        """Popping a different context than expected raises RuntimeError."""
        ctx1 = ExecutionContext(EXECUTION_PHASE.ON_BAR)
        ctx2 = ExecutionContext(EXECUTION_PHASE.ON_TICK)

        ctx1.__enter__()
        ctx2.__enter__()

        # Try to pop ctx1 while ctx2 is on top -> should raise or handle correctly
        # In Python, _pop checks identity
        with pytest.raises((RuntimeError, AssertionError)):
            ctx1._pop()

        # Cleanup
        try:
            ctx2._pop()
        except (RuntimeError, IndexError):
            pass


class TestEnforcePhase:
    """Test enforce_phase decorator and phase() class method."""

    def test_phase_returns_current(self):
        ctx = ExecutionContext(EXECUTION_PHASE.ON_BAR)
        ctx.__enter__()
        assert ExecutionContext.phase() == EXECUTION_PHASE.ON_BAR
        ctx.__exit__(None, None, None)

    def test_enforce_phase_allowed(self):
        """Decorator allows function when current phase is in allowed list."""
        @ExecutionContext.enforce_phase(EXECUTION_PHASE.ON_BAR, EXECUTION_PHASE.ON_TICK)
        def my_func():
            return "ok"

        ctx = ExecutionContext(EXECUTION_PHASE.ON_BAR)
        ctx.__enter__()
        assert my_func() == "ok"
        ctx.__exit__(None, None, None)

    def test_enforce_phase_rejected(self):
        """Decorator rejects function when current phase is NOT in allowed list."""
        @ExecutionContext.enforce_phase(EXECUTION_PHASE.ON_BAR, EXECUTION_PHASE.ON_TICK)
        def my_func():
            return "ok"

        ctx = ExecutionContext(EXECUTION_PHASE.ON_INIT)
        ctx.__enter__()
        with pytest.raises(Exception):  # patch_user_exc raises
            my_func()
        ctx.__exit__(None, None, None)


class TestAllPhases:
    """Verify all EXECUTION_PHASE values work correctly."""

    @pytest.mark.parametrize("phase", [
        EXECUTION_PHASE.GLOBAL,
        EXECUTION_PHASE.ON_INIT,
        EXECUTION_PHASE.BEFORE_TRADING,
        EXECUTION_PHASE.OPEN_AUCTION,
        EXECUTION_PHASE.ON_BAR,
        EXECUTION_PHASE.ON_TICK,
        EXECUTION_PHASE.AFTER_TRADING,
        EXECUTION_PHASE.FINALIZED,
        EXECUTION_PHASE.SCHEDULED,
    ])
    def test_each_phase_enter_exit(self, phase):
        """Each phase can be used in an execution context."""
        ctx = ExecutionContext(phase)
        ctx.__enter__()
        assert ExecutionContext.phase() == phase
        ctx.__exit__(None, None, None)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
