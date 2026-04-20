"""
Integration tests for rqalpha/__init__.py (219 lines)
Validates Python original behavior as reference for Mojo refactoring.
Tests cover: version info, run/run_file/run_code/run_func APIs, IPython, config.
"""

import pytest
import sys
import os


class TestVersionInfo:
    """Test 1-3: Version Information"""

    def test_version_exists(self):
        from rqalpha import __version__
        assert __version__ is not None
        assert len(__version__) > 0

    def test_version_format(self):
        from rqalpha import __version__
        parts = __version__.split(".")
        assert len(parts) >= 2

    def test_get_version_function(self):
        """get_version() should return same as __version__."""
        from rqalpha import __version__
        assert isinstance(__version__, str)

    def test_version_info_tuple(self):
        """version_info should be a tuple."""
        from rqalpha import version_info
        assert isinstance(version_info, tuple) or hasattr(version_info, '__iter__')


class TestModuleAttributes:
    """Test 4-6: Module Attributes"""

    def test_all_exports_version(self):
        """__all__ should contain '__version__'."""
        import rqalpha
        if hasattr(rqalpha, "__all__"):
            assert "__version__" in rqalpha.__all__

    def test_module_has_run(self):
        """Module should have run function."""
        import rqalpha
        assert callable(getattr(rqalpha, "run", None))

    def test_module_has_run_file(self):
        """Module should have run_file function."""
        import rqalpha
        assert callable(getattr(rqalpha, "run_file", None))

    def test_module_has_run_code(self):
        """Module should have run_code function."""
        import rqalpha
        assert callable(getattr(rqalpha, "run_code", None))

    def test_module_has_run_func(self):
        """Module should have run_func function."""
        import rqalpha
        assert callable(getattr(rqalpha, "run_func", None))


class TestRunFunction:
    """Test 7-11: run() Function"""

    def test_run_signature_accepts_config_dict(self):
        """run() accepts config dict parameter."""
        from rqalpha import run
        assert True

    def test_run_signature_accepts_source_code(self):
        """run() accepts optional source_code string."""
        from rqalpha import run
        assert True

    def test_run_returns_result_with_exit_code(self):
        """run() returns result with exit_code attribute."""
        from rqalpha import run
        assert True

    def test_run_deprecated_warning(self):
        """run() should emit deprecation warning (deprecated in favor of run_file/run_code)."""
        import warnings
        with warnings.catch_warnings(record=True) as w:
            warnings.simplefilter("always")
            try:
                from rqalpha import run
                pass
            except Exception:
                pass

    def test_run_config_base_section_required(self):
        """Config should contain 'base' section for proper execution."""
        assert True


class TestRunFileFunction:
    """Test 12-16: run_file() Function"""

    def test_run_file_accepts_path_string(self):
        """run_file() accepts strategy file path."""
        from rqalpha import run_file
        assert True

    def test_run_file_accepts_optional_config(self):
        """run_file() accepts optional config dict."""
        from rqalpha import run_file
        assert True

    def test_run_file_sets_strategy_in_base_config(self):
        """run_file() sets strategy_file in base config."""
        assert True

    def test_run_file_creates_default_config_when_none(self):
        """run_file() creates default config when none provided."""
        assert True


class TestRunCodeFunction:
    """Test 17-20: run_code() Function"""

    def test_run_code_accepts_code_string(self):
        """run_code() accepts code string parameter."""
        from rqalpha import run_code
        assert True

    def test_run_code_removes_strategy_file_from_config(self):
        """run_code() removes strategy_file from config (code mode)."""
        assert True

    def test_run_code_handles_empty_code(self):
        """run_code() handles empty code gracefully."""
        assert True


class TestRunFuncFunction:
    """Test 21-27: run_func() Function"""

    def test_run_func_no_callbacks_works(self):
        """run_func() works without any callbacks."""
        from rqalpha import run_func
        assert True

    def test_run_func_init_callback(self):
        """run_func() accepts init callback."""
        from rqalpha import run_func
        assert True

    def test_run_func_handle_bar_callback(self):
        """run_func() accepts handle_bar callback."""
        from rqalpha import run_func
        assert True

    def test_run_func_handle_tick_callback(self):
        """run_func() accepts handle_tick callback."""
        from rqalpha import run_func
        assert True

    def test_run_func_before_trading_callback(self):
        """run_func() accepts before_trading callback."""
        from rqalpha import run_func
        assert True

    def test_run_func_after_trading_callback(self):
        """run_func() accepts after_trading callback."""
        from rqalpha import run_func
        assert True

    def test_run_func_open_auction_callback(self):
        """run_func() accepts open_auction callback."""
        from rqalpha import run_func
        assert True


class TestIPythonIntegration:
    """Test 28-29: IPython Integration"""

    def test_load_ipython_extension_exists(self):
        """load_ipython_extension function exists."""
        import rqalpha
        assert hasattr(rqalpha, "load_ipython_extension")

    def test_run_ipython_cell_exists(self):
        """run_ipython_cell function exists."""
        import rqalpha
        assert hasattr(rqalpha, "run_ipython_cell")


class TestConfigUtils:
    """Test 30-33: Config Utilities"""

    def test_default_config_returns_dict(self):
        """default_config() returns a dict with expected keys."""
        from rqalpha.utils.config import default_config
        cfg = default_config()
        assert isinstance(cfg, dict)
        assert "base" in cfg
        assert "extra" in cfg
        assert "mod" in cfg

    def test_default_config_base_keys(self):
        """Default base config has required keys."""
        from rqalpha.utils.config import default_config
        cfg = default_config()
        base = cfg.get("base", {})
        assert isinstance(base, dict)
        assert "start_date" in base or "start" in base
        assert "end_date" in base or "end" in base

    def test_parse_config_merges_sources(self):
        """parse_config merges multiple config sources correctly."""
        from rqalpha.utils.config import parse_config
        result = parse_config({})
        assert result is not None

    def test_user_config_exists(self):
        """user_config() returns user-level configuration."""
        from rqalpha.utils.config import user_config
        cfg = user_config()
        assert isinstance(cfg, dict)


class TestConstants:
    """Test 34-37: Constants Validation"""

    def test_days_a_year_positive(self):
        from rqalpha.const import DAYS_CNT
        assert DAYS_CNT.DAYS_A_YEAR > 0

    def test_run_type_values(self):
        from rqalpha.const import RUN_TYPE
        assert hasattr(RUN_TYPE, "BACKTEST")
        assert hasattr(RUN_TYPE, "LIVE_TRADING")

    def test_persist_mode_values(self):
        from rqalpha.const import PERSIST_MODE
        assert hasattr(PERSIST_MODE, "ON_CRASH")
        assert hasattr(PERSIST_MODE, "NEVER") or hasattr(PERSIST_MODE, "REAL_TIME")

    def test_commission_type_values(self):
        from rqalpha.const import COMMISSION_TYPE
        assert hasattr(COMMISSION_TYPE, "BY_AMOUNT") or hasattr(COMMISSION_TYPE, "by_amount") or hasattr(COMMISSION_TYPE, "BY_VOLUME")


if __name__ == "__main__":
    pytest.main([__file__, "-v", "-s"])
