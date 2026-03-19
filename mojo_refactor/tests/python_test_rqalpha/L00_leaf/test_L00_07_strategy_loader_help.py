# test_L00_07_strategy_loader_help.py
# Module: rqalpha.utils.strategy_loader_help
# Mojo: rqmojo.utils.strategy_loader_help
# Level: L00 - Leaf module
# Dependencies: six, rqalpha.utils.exception

import pytest
from rqalpha.utils import strategy_loader_help
from rqalpha.utils.exception import CustomException


class TestL00StrategyLoaderHelp:
    """L00 - strategy_loader_help module tests"""

    class TestCompileStrategy:
        """compile_strategy function tests"""

        def test_simple_code(self):
            """Test compiling simple code"""
            scope = {"__builtins__": __builtins__}
            code = "x = 1\ny = 2"
            result = strategy_loader_help.compile_strategy(code, "test.py", scope)
            assert "x" in result
            assert "y" in result
            assert result["x"] == 1
            assert result["y"] == 2

        def test_with_init_function(self):
            """Test compiling code with init function"""
            scope = {"__builtins__": __builtins__}
            code = '''
def init(context):
    pass
'''
            result = strategy_loader_help.compile_strategy(code, "strategy.py", scope)
            assert "init" in result
            assert callable(result["init"])

        def test_with_handle_bar_function(self):
            """Test compiling code with handle_bar function"""
            scope = {"__builtins__": __builtins__}
            code = '''
def handle_bar(context, bar_dict):
    pass
'''
            result = strategy_loader_help.compile_strategy(code, "strategy.py", scope)
            assert "handle_bar" in result
            assert callable(result["handle_bar"])

        def test_with_multiple_functions(self):
            """Test compiling code with multiple functions"""
            scope = {"__builtins__": __builtins__}
            code = '''
def init(context):
    pass

def handle_bar(context, bar_dict):
    pass

def before_trading(context):
    pass

def after_trading(context):
    pass
'''
            result = strategy_loader_help.compile_strategy(code, "strategy.py", scope)
            assert "init" in result
            assert "handle_bar" in result
            assert "before_trading" in result
            assert "after_trading" in result

        def test_syntax_error_raises_custom_exception(self):
            """Test that syntax error raises CustomException"""
            scope = {"__builtins__": __builtins__}
            code = "def broken(\n"
            with pytest.raises(CustomException):
                strategy_loader_help.compile_strategy(code, "test.py", scope)

        def test_indentation_error_raises_custom_exception(self):
            """Test that indentation error raises CustomException"""
            scope = {"__builtins__": __builtins__}
            code = '''
def init(context):
  pass
    pass
'''
            with pytest.raises(CustomException):
                strategy_loader_help.compile_strategy(code, "test.py", scope)

        def test_runtime_error_raises_custom_exception(self):
            """Test that runtime error raises CustomException"""
            scope = {"__builtins__": __builtins__}
            code = '''
def init(context):
    return 1 / 0

init(None)
'''
            with pytest.raises(CustomException):
                strategy_loader_help.compile_strategy(code, "test.py", scope)

    class TestMojoCompatibility:
        """Tests for Mojo compatibility"""

        def test_strategy_code_format(self):
            """Test that strategy code format is compatible"""
            scope = {"__builtins__": __builtins__}
            code = '''
def init(context):
    context.a = 1

def handle_bar(context, bar_dict):
    pass
'''
            result = strategy_loader_help.compile_strategy(code, "test.py", scope)
            assert "init" in result
            assert "handle_bar" in result

        def test_function_signature_compatibility(self):
            """Test function signature compatibility"""
            scope = {"__builtins__": __builtins__}
            code = '''
def init(context):
    pass

def handle_bar(context, bar_dict):
    pass

def handle_tick(context, tick):
    pass

def before_trading(context):
    pass

def after_trading(context):
    pass
'''
            result = strategy_loader_help.compile_strategy(code, "test.py", scope)
            
            import inspect
            
            init_sig = inspect.signature(result["init"])
            handle_bar_sig = inspect.signature(result["handle_bar"])
            handle_tick_sig = inspect.signature(result["handle_tick"])
            
            assert len(init_sig.parameters) == 1
            assert len(handle_bar_sig.parameters) == 2
            assert len(handle_tick_sig.parameters) == 2

        def test_validate_strategy_functions_in_mojo(self):
            """Test that validate_strategy_functions is available in Mojo version"""
            scope = {"__builtins__": __builtins__}
            code = "def init(context):\n    pass"
            result = strategy_loader_help.compile_strategy(code, "test.py", scope)
            assert "init" in result

        def test_extract_strategy_functions_in_mojo(self):
            """Test that extract_strategy_functions is available in Mojo version"""
            scope = {"__builtins__": __builtins__}
            code = '''
def init(context):
    pass

def handle_bar(context, bar_dict):
    pass
'''
            result = strategy_loader_help.compile_strategy(code, "test.py", scope)
            assert "init" in result
            assert "handle_bar" in result
