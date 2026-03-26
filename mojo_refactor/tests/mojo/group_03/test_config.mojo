"""
RQAlpha Mojo - Config Module Test
Tests for utils/config.mojo
"""

from std.collections import Dict
from rqmojo.utils.config import (
    parse_run_type, parse_persist_mode,
    default_config, default_base_config, default_extra_config,
    create_config, create_config_from_args, parse_config,
    BaseConfig, ExtraConfig, ModConfig, RQAlphaConfig
)
from rqmojo.const import RUN_TYPE, PERSIST_MODE
from rqmojo.utils.typing import DateTime


def test_parse_run_type() raises:
    """Test that parse_run_type returns correct values."""
    var rt1 = parse_run_type("b")
    assert rt1 == RUN_TYPE.BACKTEST, "parse_run_type('b') should return BACKTEST"
    
    var rt2 = parse_run_type("p")
    assert rt2 == RUN_TYPE.PAPER_TRADING, "parse_run_type('p') should return PAPER_TRADING"
    
    var rt3 = parse_run_type("r")
    assert rt3 == RUN_TYPE.LIVE_TRADING, "parse_run_type('r') should return LIVE_TRADING"
    
    print("  parse_run_type test passed!")


def test_parse_persist_mode() raises:
    """Test that parse_persist_mode returns correct values."""
    var pm1 = parse_persist_mode("real_time")
    assert pm1 == PERSIST_MODE.REAL_TIME, "parse_persist_mode('real_time') should return REAL_TIME"
    
    var pm2 = parse_persist_mode("on_crash")
    assert pm2 == PERSIST_MODE.ON_CRASH, "parse_persist_mode('on_crash') should return ON_CRASH"
    
    var pm3 = parse_persist_mode("on_normal_exit")
    assert pm3 == PERSIST_MODE.ON_NORMAL_EXIT, "parse_persist_mode('on_normal_exit') should return ON_NORMAL_EXIT"
    
    print("  parse_persist_mode test passed!")


def test_default_config() raises:
    """Test that default_config returns a valid config."""
    var config = default_config()
    assert config.base.frequency == "1d", "Default frequency should be '1d'"
    assert config.base.run_type == RUN_TYPE.BACKTEST, "Default run_type should be BACKTEST"
    print("  default_config test passed!")


def test_create_config_from_args() raises:
    """Test that create_config_from_args creates a valid config."""
    var config = create_config_from_args(2020, 1, 1, 2020, 12, 31, "1d", "b")
    assert config.base.frequency == "1d", "Frequency should be '1d'"
    assert config.base.run_type == RUN_TYPE.BACKTEST, "Run type should be BACKTEST"
    print("  create_config_from_args test passed!")


def main() raises:
    print("============================================================")
    print("Testing utils/config.mojo")
    print("============================================================")
    
    test_parse_run_type()
    test_parse_persist_mode()
    test_default_config()
    test_create_config_from_args()
    
    print("============================================================")
    print("All utils/config.mojo tests passed!")
    print("============================================================")
