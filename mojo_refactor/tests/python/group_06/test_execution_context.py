# -*- coding: utf-8 -*-
"""
Test for core/execution_context.py
Group 06 - File 08
"""

import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestContextStack:
    """Test ContextStack class"""
    
    def test_context_stack_exists(self):
        """Test ContextStack class exists"""
        from rqalpha.core.execution_context import ContextStack
        assert ContextStack is not None
    
    def test_context_stack_push_pop(self):
        """Test ContextStack push and pop"""
        from rqalpha.core.execution_context import ContextStack
        from rqalpha.const import EXECUTION_PHASE
        
        stack = ContextStack()
        stack.push(EXECUTION_PHASE.ON_BAR)
        assert stack.top == EXECUTION_PHASE.ON_BAR
        result = stack.pop()
        assert result == EXECUTION_PHASE.ON_BAR
    
    def test_context_stack_top(self):
        """Test ContextStack top property"""
        from rqalpha.core.execution_context import ContextStack
        from rqalpha.const import EXECUTION_PHASE
        
        stack = ContextStack()
        stack.push(EXECUTION_PHASE.ON_INIT)
        stack.push(EXECUTION_PHASE.BEFORE_TRADING)
        assert stack.top == EXECUTION_PHASE.BEFORE_TRADING


class TestExecutionContext:
    """Test ExecutionContext class"""
    
    def test_execution_context_exists(self):
        """Test ExecutionContext class exists"""
        from rqalpha.core.execution_context import ExecutionContext
        assert ExecutionContext is not None
    
    def test_execution_context_init(self):
        """Test ExecutionContext initialization"""
        from rqalpha.core.execution_context import ExecutionContext
        from rqalpha.const import EXECUTION_PHASE
        
        ctx = ExecutionContext(EXECUTION_PHASE.ON_BAR)
        assert ctx.phase == EXECUTION_PHASE.ON_BAR
    
    def test_execution_context_context_manager(self):
        """Test ExecutionContext as context manager"""
        from rqalpha.core.execution_context import ExecutionContext
        from rqalpha.const import EXECUTION_PHASE
        
        ctx = ExecutionContext(EXECUTION_PHASE.ON_BAR)
        with ctx:
            assert ExecutionContext.stack.top.phase == EXECUTION_PHASE.ON_BAR
    
    def test_enforce_phase_decorator(self):
        """Test enforce_phase decorator"""
        from rqalpha.core.execution_context import ExecutionContext
        from rqalpha.const import EXECUTION_PHASE
        
        @ExecutionContext.enforce_phase(EXECUTION_PHASE.ON_BAR)
        def test_func():
            return "success"
        
        with ExecutionContext(EXECUTION_PHASE.ON_BAR):
            result = test_func()
            assert result == "success"
    
    def test_phase_classmethod(self):
        """Test phase classmethod"""
        from rqalpha.core.execution_context import ExecutionContext
        from rqalpha.const import EXECUTION_PHASE
        
        with ExecutionContext(EXECUTION_PHASE.BEFORE_TRADING):
            assert ExecutionContext.phase() == EXECUTION_PHASE.BEFORE_TRADING


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
