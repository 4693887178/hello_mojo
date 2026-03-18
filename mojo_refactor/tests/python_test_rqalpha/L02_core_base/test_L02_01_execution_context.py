# test_L02_01_execution_context.py
# Module: rqalpha.core.execution_context
# Level: L02 - Core Base
# Dependencies: const, exception, i18n

import pytest


class TestContextStack:
    """Test ContextStack class"""
    
    def test_context_stack_init(self):
        """Test ContextStack initialization"""
        from rqalpha.core.execution_context import ContextStack
        stack = ContextStack()
        assert stack.stack == []
    
    def test_context_stack_push(self):
        """Test ContextStack push"""
        from rqalpha.core.execution_context import ContextStack
        stack = ContextStack()
        stack.push("item1")
        assert len(stack.stack) == 1
    
    def test_context_stack_pop(self):
        """Test ContextStack pop"""
        from rqalpha.core.execution_context import ContextStack
        stack = ContextStack()
        stack.push("item1")
        result = stack.pop()
        assert result == "item1"
        assert len(stack.stack) == 0
    
    def test_context_stack_top(self):
        """Test ContextStack top"""
        from rqalpha.core.execution_context import ContextStack
        stack = ContextStack()
        stack.push("item1")
        stack.push("item2")
        assert stack.top == "item2"
    
    def test_context_stack_pop_empty(self):
        """Test ContextStack pop from empty stack"""
        from rqalpha.core.execution_context import ContextStack
        stack = ContextStack()
        with pytest.raises(RuntimeError):
            stack.pop()
    
    def test_context_stack_top_empty(self):
        """Test ContextStack top from empty stack"""
        from rqalpha.core.execution_context import ContextStack
        stack = ContextStack()
        with pytest.raises(RuntimeError):
            _ = stack.top


class TestExecutionContext:
    """Test ExecutionContext class"""
    
    def test_execution_context_init(self):
        """Test ExecutionContext initialization"""
        from rqalpha.core.execution_context import ExecutionContext
        from rqalpha.const import EXECUTION_PHASE
        ctx = ExecutionContext(EXECUTION_PHASE.ON_BAR)
        assert ctx.phase == EXECUTION_PHASE.ON_BAR
    
    def test_execution_context_enter_exit(self):
        """Test ExecutionContext context manager"""
        from rqalpha.core.execution_context import ExecutionContext
        from rqalpha.const import EXECUTION_PHASE
        ctx = ExecutionContext(EXECUTION_PHASE.ON_BAR)
        with ctx:
            assert ExecutionContext.stack.top == ctx
    
    def test_execution_context_phase(self):
        """Test ExecutionContext phase method"""
        from rqalpha.core.execution_context import ExecutionContext
        from rqalpha.const import EXECUTION_PHASE
        ctx = ExecutionContext(EXECUTION_PHASE.ON_TICK)
        assert ctx.phase == EXECUTION_PHASE.ON_TICK


class TestEnforcePhase:
    """Test enforce_phase decorator"""
    
    def test_enforce_phase_valid(self):
        """Test enforce_phase with valid phase"""
        from rqalpha.core.execution_context import ExecutionContext
        from rqalpha.const import EXECUTION_PHASE
        
        @ExecutionContext.enforce_phase(EXECUTION_PHASE.ON_BAR)
        def test_func():
            return "success"
        
        with ExecutionContext(EXECUTION_PHASE.ON_BAR):
            result = test_func()
            assert result == "success"
    
    def test_enforce_phase_invalid(self):
        """Test enforce_phase with invalid phase"""
        from rqalpha.core.execution_context import ExecutionContext
        from rqalpha.const import EXECUTION_PHASE
        
        @ExecutionContext.enforce_phase(EXECUTION_PHASE.ON_BAR)
        def test_func():
            return "success"
        
        with ExecutionContext(EXECUTION_PHASE.ON_TICK):
            with pytest.raises(RuntimeError):
                test_func()


class TestPhaseMethod:
    """Test phase class method"""
    
    def test_phase_method(self):
        """Test phase class method"""
        from rqalpha.core.execution_context import ExecutionContext
        from rqalpha.const import EXECUTION_PHASE
        with ExecutionContext(EXECUTION_PHASE.BEFORE_TRADING):
            assert ExecutionContext.phase() == EXECUTION_PHASE.BEFORE_TRADING
