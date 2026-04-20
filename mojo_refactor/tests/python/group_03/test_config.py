# -*- coding: utf-8 -*-
"""
Test for rqalpha/utils/config.py
Tests for configuration parsing functions
"""

import pytest


class TestParseRunType:
    """Tests for parse_run_type function"""

    def test_parse_run_type_backtest(self):
        """Test that parse_run_type returns BACKTEST for 'b'"""
        from rqalpha.utils.config import parse_run_type
        from rqalpha.const import RUN_TYPE
        assert parse_run_type("b") == RUN_TYPE.BACKTEST

    def test_parse_run_type_paper_trading(self):
        """Test that parse_run_type returns PAPER_TRADING for 'p'"""
        from rqalpha.utils.config import parse_run_type
        from rqalpha.const import RUN_TYPE
        assert parse_run_type("p") == RUN_TYPE.PAPER_TRADING

    def test_parse_run_type_live_trading(self):
        """Test that parse_run_type returns LIVE_TRADING for 'r'"""
        from rqalpha.utils.config import parse_run_type
        from rqalpha.const import RUN_TYPE
        assert parse_run_type("r") == RUN_TYPE.LIVE_TRADING


class TestParsePersistMode:
    """Tests for parse_persist_mode function"""

    def test_parse_persist_mode_real_time(self):
        """Test that parse_persist_mode returns REAL_TIME for 'real_time'"""
        from rqalpha.utils.config import parse_persist_mode
        from rqalpha.const import PERSIST_MODE
        assert parse_persist_mode("real_time") == PERSIST_MODE.REAL_TIME

    def test_parse_persist_mode_on_crash(self):
        """Test that parse_persist_mode returns ON_CRASH for 'on_crash'"""
        from rqalpha.utils.config import parse_persist_mode
        from rqalpha.const import PERSIST_MODE
        assert parse_persist_mode("on_crash") == PERSIST_MODE.ON_CRASH

    def test_parse_persist_mode_on_normal_exit(self):
        """Test that parse_persist_mode returns ON_NORMAL_EXIT for 'on_normal_exit'"""
        from rqalpha.utils.config import parse_persist_mode
        from rqalpha.const import PERSIST_MODE
        assert parse_persist_mode("on_normal_exit") == PERSIST_MODE.ON_NORMAL_EXIT


class TestDefaultConfig:
    """Tests for default_config function"""

    def test_default_config_exists(self):
        """Test that default_config function exists"""
        from rqalpha.utils.config import default_config
        assert callable(default_config)

    def test_default_config_returns_dict(self):
        """Test that default_config returns a dictionary"""
        from rqalpha.utils.config import default_config
        config = default_config()
        assert isinstance(config, dict)

    def test_default_config_has_base(self):
        """Test that default_config has 'base' key"""
        from rqalpha.utils.config import default_config
        config = default_config()
        assert "base" in config
