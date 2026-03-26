# -*- coding: utf-8 -*-
"""
Test for core/executor.py
Group 06 - File 09
"""

import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestExecutor:
    """Test Executor class"""
    
    def test_executor_exists(self):
        """Test Executor class exists"""
        from rqalpha.core.executor import Executor
        assert Executor is not None
    
    def test_executor_init(self):
        """Test Executor initialization"""
        from rqalpha.core.executor import Executor
        from unittest.mock import MagicMock
        
        env = MagicMock()
        executor = Executor(env)
        assert executor is not None
    
    def test_executor_get_state(self):
        """Test Executor get_state method"""
        from rqalpha.core.executor import Executor
        from unittest.mock import MagicMock
        
        env = MagicMock()
        executor = Executor(env)
        state = executor.get_state()
        assert state is not None
        assert isinstance(state, bytes)
    
    def test_executor_set_state(self):
        """Test Executor set_state method"""
        from rqalpha.core.executor import Executor
        from unittest.mock import MagicMock
        
        env = MagicMock()
        executor = Executor(env)
        state = b'{"last_before_trading": null}'
        executor.set_state(state)
    
    def test_event_split_map_exists(self):
        """Test EVENT_SPLIT_MAP exists"""
        from rqalpha.core.executor import Executor
        assert hasattr(Executor, 'EVENT_SPLIT_MAP')
        assert Executor.EVENT_SPLIT_MAP is not None


class TestExecutorEventHandling:
    """Test Executor event handling"""
    
    def test_run_method_exists(self):
        """Test run method exists"""
        from rqalpha.core.executor import Executor
        assert hasattr(Executor, 'run')
    
    def test_ensure_before_trading_exists(self):
        """Test _ensure_before_trading method exists"""
        from rqalpha.core.executor import Executor
        assert hasattr(Executor, '_ensure_before_trading')
    
    def test_split_and_publish_exists(self):
        """Test _split_and_publish method exists"""
        from rqalpha.core.executor import Executor
        assert hasattr(Executor, '_split_and_publish')


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
