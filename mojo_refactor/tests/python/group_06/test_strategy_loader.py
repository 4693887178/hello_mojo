# -*- coding: utf-8 -*-
"""
Test for core/strategy_loader.py
Group 06 - File 10
"""

import pytest
import sys
import os
import tempfile

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestFileStrategyLoader:
    """Test FileStrategyLoader class"""
    
    def test_file_strategy_loader_exists(self):
        """Test FileStrategyLoader class exists"""
        from rqalpha.core.strategy_loader import FileStrategyLoader
        assert FileStrategyLoader is not None
    
    def test_file_strategy_loader_init(self):
        """Test FileStrategyLoader initialization"""
        from rqalpha.core.strategy_loader import FileStrategyLoader
        
        loader = FileStrategyLoader("test_strategy.py")
        assert loader is not None
    
    def test_file_strategy_loader_load(self):
        """Test FileStrategyLoader load method"""
        from rqalpha.core.strategy_loader import FileStrategyLoader
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
            f.write("def init(context):\n    pass\n")
            f.flush()
            
            loader = FileStrategyLoader(f.name)
            scope = {}
            result = loader.load(scope)
            assert result is not None
            
            os.unlink(f.name)


class TestSourceCodeStrategyLoader:
    """Test SourceCodeStrategyLoader class"""
    
    def test_source_code_strategy_loader_exists(self):
        """Test SourceCodeStrategyLoader class exists"""
        from rqalpha.core.strategy_loader import SourceCodeStrategyLoader
        assert SourceCodeStrategyLoader is not None
    
    def test_source_code_strategy_loader_init(self):
        """Test SourceCodeStrategyLoader initialization"""
        from rqalpha.core.strategy_loader import SourceCodeStrategyLoader
        
        code = "def init(context):\n    pass\n"
        loader = SourceCodeStrategyLoader(code)
        assert loader is not None
    
    def test_source_code_strategy_loader_load(self):
        """Test SourceCodeStrategyLoader load method"""
        from rqalpha.core.strategy_loader import SourceCodeStrategyLoader
        
        code = "def init(context):\n    pass\n"
        loader = SourceCodeStrategyLoader(code)
        scope = {}
        result = loader.load(scope)
        assert result is not None


class TestUserFuncStrategyLoader:
    """Test UserFuncStrategyLoader class"""
    
    def test_user_func_strategy_loader_exists(self):
        """Test UserFuncStrategyLoader class exists"""
        from rqalpha.core.strategy_loader import UserFuncStrategyLoader
        assert UserFuncStrategyLoader is not None
    
    def test_user_func_strategy_loader_init(self):
        """Test UserFuncStrategyLoader initialization"""
        from rqalpha.core.strategy_loader import UserFuncStrategyLoader
        
        def init(context):
            pass
        
        loader = UserFuncStrategyLoader({"init": init})
        assert loader is not None
    
    def test_user_func_strategy_loader_load(self):
        """Test UserFuncStrategyLoader load method"""
        from rqalpha.core.strategy_loader import UserFuncStrategyLoader
        
        def init(context):
            pass
        
        def handle_bar(context, bar_dict):
            pass
        
        user_funcs = {"init": init, "handle_bar": handle_bar}
        loader = UserFuncStrategyLoader(user_funcs)
        scope = {}
        result = loader.load(scope)
        assert result is not None


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
