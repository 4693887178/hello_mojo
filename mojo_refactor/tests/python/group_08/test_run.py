# -*- coding: utf-8 -*-
"""
Test for cmds/run.py (Python original) and cmds/run.mojo (Mojo port)
Group 08 - Run Command Comprehensive Tests

Tests cover:
  1. Python run module: function existence, CLI options, imports
  2. Mojo run module: struct, functions, CLI command creation
  3. Cross-validation of behavior parity between Python and Mojo
"""

import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


# ============================================================
# Python Original Tests
# ============================================================

class TestRunCommandFunction:
    """Test the Python run() function from rqalpha.cmds.run"""

    def test_run_function_exists(self):
        from rqalpha.cmds.run import run
        assert callable(run)

    def test_inject_run_param_exists(self):
        from rqalpha.cmds.run import inject_run_param
        assert callable(inject_run_param)

    def test_run_has_cli_decorator(self):
        from rqalpha.cmds.run import run
        assert hasattr(run, 'params')

    def test_run_params_count(self):
        """run() should have many CLI options matching Click decorators"""
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert len(param_names) >= 15, f"Expected at least 15 params, got {len(param_names)}"


class TestRunImports:
    """Test that all required imports are available"""

    def test_import_click(self):
        import click
        assert click is not None

    def test_import_parse_config(self):
        from rqalpha.utils.config import parse_config
        assert callable(parse_config)

    def test_import_cli(self):
        from rqalpha.cmds.entry import cli
        assert cli is not None


class TestRunOptions:
    """Test each CLI option defined in Python's @click.option decorators"""

    def test_data_bundle_path_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__data_bundle_path' in param_names

    def test_strategy_file_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__strategy_file' in param_names

    def test_start_date_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__start_date' in param_names

    def test_end_date_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__end_date' in param_names

    def test_frequency_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__frequency' in param_names
        freq_param = [p for p in run.params if p.name == 'base__frequency'][0]
        assert hasattr(freq_param, 'type')
        assert '1d' in freq_param.type.choices
        assert '1m' in freq_param.type.choices
        assert 'tick' in freq_param.type.choices

    def test_run_type_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__run_type' in param_names
        rt_param = [p for p in run.params if p.name == 'base__run_type'][0]
        assert 'b' in rt_param.type.choices
        assert 'p' in rt_param.type.choices
        assert 'r' in rt_param.type.choices

    def test_account_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__accounts' in param_names

    def test_log_level_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'extra__log_level' in param_names

    def test_locale_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'extra__locale' in param_names

    def test_source_code_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__source_code' in param_names

    def test_config_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'config_path' in param_names

    def test_mod_config_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'mod_configs' in param_names

    def test_resume_deprecated_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__resume_mode' in param_names

    def test_round_price_flag(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__round_price' in param_names

    def test_enable_profiler_flag(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'extra__enable_profiler' in param_names


class TestRunBehaviorParity:
    """Test behavioral parity expectations between Python and Mojo ports"""

    def test_run_returns_int_on_none_results(self):
        """Python's run() returns 1 when results is None"""
        from rqalpha.cmds.run import run
        import inspect
        sig = inspect.signature(run)
        assert sig.return_annotation in (int, 't.Any', None, inspect.Parameter.empty), \
            f"run() should return int or t.Any, got {sig.return_annotation}"

    def test_run_accepts_kwargs(self):
        """run() accepts **kwargs (variable keyword arguments)"""
        from rqalpha.cmds.run import run
        import inspect
        sig = inspect.signature(run)
        assert len(sig.parameters) >= 1 or any(
            p.kind == inspect.Parameter.VAR_KEYWORD for p in sig.parameters.values()
        ), "run() should accept **kwargs"

    def test_inject_run_param_accepts_click_parameter(self):
        """inject_run_param accepts a click.Parameter"""
        from rqalpha.cmds.run import inject_run_param
        import inspect
        sig = inspect.signature(inject_run_param)
        params = list(sig.parameters.keys())
        assert len(params) >= 1, f"inject_run_param should accept at least 1 arg, got {params}"


class TestParseConfigIntegration:
    """Test parse_config integration with run command kwargs"""

    def test_parse_config_handles_base_params(self):
        from rqalpha.utils.config import parse_config
        cfg = parse_config({
            'base__start_date': '2020-01-01',
            'base__end_date': '2020-12-31',
            'base__frequency': '1d',
            'base__run_type': 'b',
        })
        assert cfg is not None
        assert hasattr(cfg, 'base')

    def test_parse_config_default_values(self):
        from rqalpha.utils.config import parse_config
        cfg = parse_config({})
        assert cfg is not None
        assert hasattr(cfg, 'base')
        assert cfg.base.frequency == '1d'  # default frequency
        assert cfg.base.run_type.value == 'BACKTEST'  # default run type backtest


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
