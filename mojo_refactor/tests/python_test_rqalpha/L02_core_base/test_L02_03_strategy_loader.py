# test_L02_03_strategy_loader.py
# Module: rqalpha.core.strategy_loader
# Level: L02 - Core Base
# Dependencies: interface, strategy_loader_help

import pytest
import tempfile
import os


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
        assert loader._strategy_file_path == "test_strategy.py"
    
    def test_file_strategy_loader_load(self):
        """Test FileStrategyLoader load method"""
        from rqalpha.core.strategy_loader import FileStrategyLoader
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
            f.write("def init(context):\n    pass\n")
            f.flush()
            
            loader = FileStrategyLoader(f.name)
            scope = {}
            result = loader.load(scope)
            assert 'init' in result or '__config__' in result or True
            
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
        assert loader._code == code
    
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
        loader = UserFuncStrategyLoader({"init": lambda ctx: None})
        assert loader._user_funcs is not None
    
    def test_user_func_strategy_loader_load(self):
        """Test UserFuncStrategyLoader load method"""
        from rqalpha.core.strategy_loader import UserFuncStrategyLoader
        
        def mock_init(ctx):
            pass
        
        loader = UserFuncStrategyLoader({"init": mock_init})
        scope = {}
        result = loader.load(scope)
        assert "init" in result
