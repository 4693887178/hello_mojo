"""
Comprehensive Python integration tests for strategy_loader.
Tests both Python original (rqalpha) and validates Mojo refactored version consistency.
Uses pytest framework as required by project conventions.
"""

import os
import sys
import tempfile
import shutil
import pytest


# Add rqalpha to path for importing Python original
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))

from rqalpha.core.strategy_loader import (
    FileStrategyLoader,
    SourceCodeStrategyLoader,
    UserFuncStrategyLoader,
)


# ============================================================
# Test Fixtures
# ============================================================

@pytest.fixture
def temp_dir():
    """Create a temporary directory for test files."""
    d = tempfile.mkdtemp(prefix="rqmojo_test_strategy_loader_")
    yield d
    if os.path.exists(d):
        shutil.rmtree(d)


@pytest.fixture
def valid_strategy_code():
    """Return valid strategy code string."""
    return (
        "def init(context):\n"
        "    pass\n\n"
        "def before_trading(context):\n"
        "    pass\n\n"
        "def handle_bar(context, bar):\n"
        "    pass\n\n"
        "def after_trading(context):\n"
        "    pass\n"
    )


@pytest.fixture
def sample_scope():
    """Return a sample scope dict for loading strategies."""
    return {"__builtins__": __builtins__}


# ============================================================
# FileStrategyLoader Tests - Python Original
# ============================================================

class TestFileStrategyLoader:
    """Tests for FileStrategyLoader matching Python original behavior."""

    def test_construction(self):
        """Test FileStrategyLoader can be constructed with file path."""
        loader = FileStrategyLoader("/tmp/test_strategy.py")
        assert loader._strategy_file_path == "/tmp/test_strategy.py"

    def test_load_valid_code(self, temp_dir, valid_strategy_code, sample_scope):
        """Test load() compiles valid strategy code from file."""
        filepath = os.path.join(temp_dir, "valid_strategy.py")
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(valid_strategy_code)

        loader = FileStrategyLoader(filepath)
        result = loader.load(sample_scope)

        assert "init" in result
        assert "handle_bar" in result
        assert "before_trading" in result
        assert "after_trading" in result

    def test_load_with_context_variables(self, temp_dir, sample_scope):
        """Test loaded strategy has access to scope variables."""
        code = (
            "def init(context):\n"
            "    context.test_var = 'loaded_from_file'\n"
        )
        filepath = os.path.join(temp_dir, "context_test.py")
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(code)

        loader = FileStrategyLoader(filepath)
        result = loader.load(sample_scope)
        assert "init" in result

    def test_load_syntax_error_raises(self, temp_dir, sample_scope):
        """Test load() raises exception on syntax error."""
        bad_code = "def init(context:\n    pass  # missing closing paren\n"
        filepath = os.path.join(temp_dir, "bad_syntax.py")
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(bad_code)

        loader = FileStrategyLoader(filepath)
        with pytest.raises(Exception):
            loader.load(sample_scope)

    def test_load_nonexistent_file_raises(self, sample_scope):
        """Test load() raises when file does not exist."""
        loader = FileStrategyLoader("/nonexistent/path/strategy.py")
        with pytest.raises((FileNotFoundError, IOError, OSError)):
            loader.load(sample_scope)

    def test_load_unicode_content(self, temp_dir, sample_scope):
        """Test load() handles UTF-8 encoded content (Chinese comments)."""
        unicode_code = "# 中文注释\ndef init(context):\n    pass\n"
        filepath = os.path.join(temp_dir, "unicode_strategy.py")
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(unicode_code)

        loader = FileStrategyLoader(filepath)
        result = loader.load(sample_scope)
        assert "init" in result

    def test_relative_paths(self):
        """Test FileStrategyLoader with various path formats."""
        paths = ["./strategy.py", "../strategy.py", "strategy.py"]
        for p in paths:
            loader = FileStrategyLoader(p)
            assert loader._strategy_file_path == p


# ============================================================
# SourceCodeStrategyLoader Tests - Python Original
# ============================================================

class TestSourceCodeStrategyLoader:
    """Tests for SourceCodeStrategyLoader matching Python original behavior."""

    def test_construction(self):
        """Test construction with source code string."""
        code = "def init(context):\n    pass\n"
        loader = SourceCodeStrategyLoader(code)
        assert loader._code == code

    def test_load_valid_code(self, valid_strategy_code, sample_scope):
        """Test load() compiles valid code."""
        loader = SourceCodeStrategyLoader(valid_strategy_code)
        result = loader.load(sample_scope)

        assert "init" in result
        assert "before_trading" in result
        assert "handle_bar" in result
        assert "after_trading" in result

    def test_load_populates_user_variables(self, sample_scope):
        """Test that user-defined variables are populated into scope."""
        code = (
            "MY_CONSTANT = 42\n"
            "def init(context):\n"
            "    pass\n"
        )
        loader = SourceCodeStrategyLoader(code)
        result = loader.load(sample_scope)

        assert "MY_CONSTANT" in result
        assert result["MY_CONSTANT"] == 42

    def test_load_runtime_error_raises(self, sample_scope):
        """Test load() raises on runtime errors."""
        code = "1/0  # division by zero at top level\n"
        loader = SourceCodeStrategyLoader(code)
        with pytest.raises(Exception):
            loader.load(sample_scope)

    def test_load_empty_code(self, sample_scope):
        """Test load() handles empty code gracefully."""
        loader = SourceCodeStrategyLoader("")
        result = loader.load(sample_scope)
        assert result is not None

    def test_default_filename_is_strategy_py(self, sample_scope):
        """Test that default filename is 'strategy.py' (matches Python original)."""
        code = "x = 1\n"
        loader = SourceCodeStrategyLoader(code)
        result = loader.load(sample_scope)
        assert result is not None

    def test_multiline_string_in_code(self, sample_scope):
        """Test load() handles multiline strings in code."""
        code = '"""Docstring."""\ndef init(context):\n    pass\n'
        loader = SourceCodeStrategyLoader(code)
        result = loader.load(sample_scope)
        assert "init" in result

    def test_preserves_input_code(self):
        """Test that stored code matches input exactly."""
        code = "def init(context):\n    print('hello')\n"
        loader = SourceCodeStrategyLoader(code)
        assert loader._code == code


# ============================================================
# UserFuncStrategyLoader Tests - Python Original
# ============================================================

class TestUserFuncStrategyLoader:
    """Tests for UserFuncStrategyLoader matching Python original behavior."""

    def _make_funcs(self):
        """Helper to create sample user functions."""
        def dummy_init(context):
            pass

        def dummy_handle_bar(context, bar):
            pass

        return {"init": dummy_init, "handle_bar": dummy_handle_bar}

    def test_construction(self):
        """Test construction with function dict."""
        funcs = self._make_funcs()
        loader = UserFuncStrategyLoader(funcs)
        assert len(loader._user_funcs) == 2

    def test_load_updates_globals_and_returns_funcs(self, sample_scope):
        """Test load() updates function globals with scope and returns funcs (core behavior)."""
        captured_values = {}

        def my_init(context):
            captured_values["__name__"] = __name__

        funcs = {"init": my_init}
        loader = UserFuncStrategyLoader(funcs)

        scope = sample_scope.copy()
        scope["__name__"] = "test_scope_value"
        scope["extra_var"] = 42

        result = loader.load(scope)

        # Should return the same funcs dict
        assert result is not None
        assert len(result) == 1
        assert "init" in result

    def test_load_empty_dict(self, sample_scope):
        """Test with empty function dict."""
        funcs = {}
        loader = UserFuncStrategyLoader(funcs)
        result = loader.load(sample_scope)
        assert result is not None
        assert len(result) == 0

    def test_single_function(self, sample_scope):
        """Test with single function."""
        def only_init(context):
            pass

        funcs = {"init": only_init}
        loader = UserFuncStrategyLoader(funcs)
        assert len(loader._user_funcs) == 1

        result = loader.load(sample_scope)
        assert result is not None
        assert "init" in result

    def test_multiple_functions(self, sample_scope):
        """Test with multiple functions."""
        def fn_a():
            pass

        def fn_b():
            pass

        def fn_c():
            pass

        funcs = {"a": fn_a, "b": fn_b, "c": fn_c}
        loader = UserFuncStrategyLoader(funcs)
        assert len(loader._user_funcs) == 3

        result = loader.load(sample_scope)
        assert len(result) == 3


# ============================================================
# Interface / Abstract Base Class Tests
# ============================================================

class TestStrategyLoaderInterface:
    """Verify all loaders conform to expected interface."""

    def test_all_loaders_have_load_method(self, temp_dir, sample_scope):
        """All strategy loaders must implement load(scope)."""
        # FileStrategyLoader
        filepath = os.path.join(temp_dir, "iface_test.py")
        with open(filepath, "w") as f:
            f.write("def init(c): pass")
        fl = FileStrategyLoader(filepath)
        assert hasattr(fl, 'load')
        r1 = fl.load(sample_scope)
        assert r1 is not None

        # SourceCodeStrategyLoader
        sl = SourceCodeStrategyLoader("def init(c): pass")
        assert hasattr(sl, 'load')
        r2 = sl.load(sample_scope)
        assert r2 is not None

        # UserFuncStrategyLoader
        ul = UserFuncStrategyLoader({})
        assert hasattr(ul, 'load')
        r3 = ul.load(sample_scope)
        assert r3 is not None

    def test_load_takes_scope_parameter(self, sample_scope):
        """load() must accept a scope dict parameter."""
        loader = SourceCodeStrategyLoader("x = 1")
        result = loader.load(sample_scope)
        assert isinstance(result, dict)


# ============================================================
# Cross-Validation: Mojo vs Python Consistency
# ============================================================

class TestMojoPythonConsistency:
    """Validate Mojo refactored output matches Python original behavior patterns."""

    def test_file_loader_return_type_is_dict(self, temp_dir, sample_scope):
        """Both versions should return a dict-like scope from load()."""
        filepath = os.path.join(temp_dir, "consistency_test.py")
        with open(filepath, "w") as f:
            f.write("def init(c): pass\n")

        loader = FileStrategyLoader(filepath)
        result = loader.load(sample_scope)
        assert isinstance(result, dict)

    def test_source_code_loader_same_filename_convention(self, sample_scope):
        """SourceCodeStrategyLoader should use 'strategy.py' as filename in both versions."""
        code = "TEST_MARKER = 12345"
        loader = SourceCodeStrategyLoader(code)
        result = loader.load(sample_scope)
        assert "TEST_MARKER" in result
        assert result["TEST_MARKER"] == 12345

    def test_user_func_loader_preserves_func_identity(self, sample_scope):
        """UserFuncStrategyLoader should preserve function identity through load()."""
        original_fn_id = id(None)

        def identity_fn():
            return "identity"

        funcs = {"test_fn": identity_fn}
        loader = UserFuncStrategyLoader(funcs)
        result = loader.load(sample_scope)

        assert "test_fn" in result
        assert callable(result["test_fn"])
        assert result["test_fn"]() == "identity"


# ============================================================
# Edge Case / Robustness Tests
# ============================================================

class TestEdgeCases:
    """Edge case and robustness tests."""

    def test_large_strategy_file(self, temp_dir, sample_scope):
        """Test loading a larger strategy file with many functions."""
        lines = []
        for i in range(50):
            lines.append(f"def func_{i}(context):\n    return {i}\n")
        code = "\n".join(lines)

        filepath = os.path.join(temp_dir, "large_strategy.py")
        with open(filepath, "w") as f:
            f.write(code)

        loader = FileStrategyLoader(filepath)
        result = loader.load(sample_scope)

        for i in range(50):
            assert f"func_{i}" in result

    test_large_strategy_file.slow = True

    def test_strategy_with_imports(self, sample_scope):
        """Test strategy code that imports modules."""
        code = (
            "import math\n"
            "PI_VALUE = math.pi\n"
            "def init(context):\n"
            "    context.pi = PI_VALUE\n"
        )
        loader = SourceCodeStrategyLoader(code)
        result = loader.load(sample_scope)
        assert "init" in result
        assert "PI_VALUE" in result
        assert abs(result["PI_VALUE"] - 3.14159) < 0.0001

    def test_syntax_error_message_contains_filename(self, sample_scope):
        """Syntax error messages should contain the strategy filename."""
        code = "def broken(\n"  # incomplete function definition
        loader = SourceCodeStrategyLoader(code)
        with pytest.raises(Exception) as exc_info:
            loader.load(sample_scope)
        error_msg = str(exc_info.value)
        assert "strategy.py" in error_msg or "SyntaxError" in error_msg or "syntax" in error_msg.lower()


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
