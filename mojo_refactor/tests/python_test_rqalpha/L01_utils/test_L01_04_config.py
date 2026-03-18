# test_L01_04_config.py
# Module: rqalpha.utils.config
# Level: L01 - Utils module
# Dependencies: const, i18n, logger

import pytest
import os


class TestConfigPaths:
    """Test config path functions"""
    
    def test_rqalpha_path(self):
        """Test rqalpha_path constant"""
        from rqalpha.utils.config import rqalpha_path
        assert rqalpha_path == "~/.rqalpha"
    
    def test_default_config_path(self):
        """Test default_config_path exists"""
        from rqalpha.utils.config import default_config_path
        assert default_config_path is not None
    
    def test_default_mod_config_path(self):
        """Test default_mod_config_path exists"""
        from rqalpha.utils.config import default_mod_config_path
        assert default_mod_config_path is not None


class TestLoadFunctions:
    """Test load functions"""
    
    def test_load_yaml_exists(self):
        """Test load_yaml function exists"""
        from rqalpha.utils.config import load_yaml
        assert callable(load_yaml)
    
    def test_load_json_exists(self):
        """Test load_json function exists"""
        from rqalpha.utils.config import load_json
        assert callable(load_json)


class TestDefaultConfig:
    """Test default config functions"""
    
    def test_default_config_exists(self):
        """Test default_config function exists"""
        from rqalpha.utils.config import default_config
        assert callable(default_config)
    
    def test_default_config_returns_dict(self):
        """Test default_config returns dict"""
        from rqalpha.utils.config import default_config
        config = default_config()
        assert isinstance(config, dict)
        assert 'base' in config
    
    def test_default_config_base_keys(self):
        """Test default_config base keys"""
        from rqalpha.utils.config import default_config
        config = default_config()
        assert 'start_date' in config['base']
        assert 'end_date' in config['base']
        assert 'frequency' in config['base']


class TestParseRunType:
    """Test parse_run_type function"""
    
    def test_parse_run_type_backtest(self):
        """Test parse_run_type backtest"""
        from rqalpha.utils.config import parse_run_type
        from rqalpha.const import RUN_TYPE
        result = parse_run_type("b")
        assert result == RUN_TYPE.BACKTEST
    
    def test_parse_run_type_paper_trading(self):
        """Test parse_run_type paper trading"""
        from rqalpha.utils.config import parse_run_type
        from rqalpha.const import RUN_TYPE
        result = parse_run_type("p")
        assert result == RUN_TYPE.PAPER_TRADING
    
    def test_parse_run_type_live_trading(self):
        """Test parse_run_type live trading"""
        from rqalpha.utils.config import parse_run_type
        from rqalpha.const import RUN_TYPE
        result = parse_run_type("r")
        assert result == RUN_TYPE.LIVE_TRADING


class TestParsePersistMode:
    """Test parse_persist_mode function"""
    
    def test_parse_persist_mode_real_time(self):
        """Test parse_persist_mode real_time"""
        from rqalpha.utils.config import parse_persist_mode
        from rqalpha.const import PERSIST_MODE
        result = parse_persist_mode("real_time")
        assert result == PERSIST_MODE.REAL_TIME
    
    def test_parse_persist_mode_on_crash(self):
        """Test parse_persist_mode on_crash"""
        from rqalpha.utils.config import parse_persist_mode
        from rqalpha.const import PERSIST_MODE
        result = parse_persist_mode("on_crash")
        assert result == PERSIST_MODE.ON_CRASH
    
    def test_parse_persist_mode_on_normal_exit(self):
        """Test parse_persist_mode on_normal_exit"""
        from rqalpha.utils.config import parse_persist_mode
        from rqalpha.const import PERSIST_MODE
        result = parse_persist_mode("on_normal_exit")
        assert result == PERSIST_MODE.ON_NORMAL_EXIT


class TestParseAccounts:
    """Test parse_accounts function"""
    
    def test_parse_accounts_empty(self):
        """Test parse_accounts with empty dict"""
        from rqalpha.utils.config import parse_accounts
        result = parse_accounts({})
        assert result == {}
    
    def test_parse_accounts_stock(self):
        """Test parse_accounts with stock account"""
        from rqalpha.utils.config import parse_accounts
        result = parse_accounts({"stock": 100000})
        assert "STOCK" in result
        assert result["STOCK"] == 100000.0
    
    def test_parse_accounts_future(self):
        """Test parse_accounts with future account"""
        from rqalpha.utils.config import parse_accounts
        result = parse_accounts({"future": 500000})
        assert "FUTURE" in result
        assert result["FUTURE"] == 500000.0


class TestParseInitPositions:
    """Test parse_init_positions function"""
    
    def test_parse_init_positions_empty(self):
        """Test parse_init_positions with empty string"""
        from rqalpha.utils.config import parse_init_positions
        result = parse_init_positions("")
        assert result == []
    
    def test_parse_init_positions_none(self):
        """Test parse_init_positions with None"""
        from rqalpha.utils.config import parse_init_positions
        result = parse_init_positions(None)
        assert result == []
    
    def test_parse_init_positions_single(self):
        """Test parse_init_positions with single position"""
        from rqalpha.utils.config import parse_init_positions
        result = parse_init_positions("000001.XSHE:1000")
        assert len(result) == 1
        assert result[0][0] == "000001.XSHE"
        assert result[0][1] == 1000.0
