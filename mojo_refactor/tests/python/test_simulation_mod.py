"""
Integration tests for SimulationMod
"""

import pytest
from rqmojo.mod.rqmojo_mod_sys_simulation.mod import SimulationMod
from rqmojo.const import MATCHING_TYPE, RUN_TYPE


class MockEnv:
    def __init__(self):
        class Config:
            class Base:
                run_type = RUN_TYPE.BACKTEST
                frequency = "1d"
                margin_multiplier = 1.0
        self.config = Config()
        self.config.base = Config.Base()
        
        class EventBus:
            def add_listener(self, event, callback):
                pass
        self.event_bus = EventBus()
        
        class Portfolio:
            def __init__(self):
                class Account:
                    def set_management_fee_rate(self, rate):
                        self.fee_rate = rate
                self.accounts = {
                    "STOCK": Account(),
                    "FUTURE": Account()
                }
        self.portfolio = Portfolio()
        
        self._broker = None
        self._event_source = None
        self._validators = []
    
    def set_broker(self, broker):
        self._broker = broker
    
    def set_event_source(self, event_source):
        self._event_source = event_source
    
    def add_frontend_validator(self, validator):
        self._validators.append(validator)


class MockModConfig:
    def __init__(self):
        self.matching_type = None
        self.signal = False
        self.management_fee = [
            ("stock", "0.001"),
            ("future", "0.002")
        ]


def test_simulation_mod_start_up():
    """Test SimulationMod start_up method"""
    env = MockEnv()
    mod_config = MockModConfig()
    
    mod = SimulationMod()
    mod.start_up(env, mod_config)
    
    # Check that matching type was set correctly
    assert mod_config.matching_type == MATCHING_TYPE.CURRENT_BAR_CLOSE
    
    # Check that broker was set
    assert env._broker is not None
    
    # Check that event source was set
    assert env._event_source is not None
    
    # Check that validator was added
    assert len(env._validators) == 1


def test_simulation_mod_live_trading():
    """Test SimulationMod with live trading"""
    env = MockEnv()
    env.config.base.run_type = RUN_TYPE.LIVE_TRADING
    mod_config = MockModConfig()
    
    mod = SimulationMod()
    mod.start_up(env, mod_config)
    
    # Check that no broker was set for live trading
    assert env._broker is None


def test_simulation_mod_invalid_margin_multiplier():
    """Test SimulationMod with invalid margin multiplier"""
    env = MockEnv()
    env.config.base.margin_multiplier = 0.0
    mod_config = MockModConfig()
    
    mod = SimulationMod()
    with pytest.raises(Exception):
        mod.start_up(env, mod_config)


def test_simulation_mod_invalid_matching_type():
    """Test SimulationMod with invalid matching type"""
    env = MockEnv()
    mod_config = MockModConfig()
    mod_config.matching_type = "invalid"
    
    mod = SimulationMod()
    with pytest.raises(Exception):
        mod.start_up(env, mod_config)


def test_register_management_fee_calculator():
    """Test register_management_fee_calculator method"""
    env = MockEnv()
    mod_config = MockModConfig()
    
    mod = SimulationMod()
    mod.start_up(env, mod_config)
    
    # Call the method directly
    mod.register_management_fee_calculator(None)
    
    # Check that fee rates were set
    assert env.portfolio.accounts["STOCK"].fee_rate == 0.001
    assert env.portfolio.accounts["FUTURE"].fee_rate == 0.002


def test_register_management_fee_calculator_invalid_account():
    """Test register_management_fee_calculator with invalid account"""
    env = MockEnv()
    mod_config = MockModConfig()
    mod_config.management_fee = [("INVALID", "0.001")]
    
    mod = SimulationMod()
    mod.start_up(env, mod_config)
    
    # Call the method directly
    with pytest.raises(Exception):
        mod.register_management_fee_calculator(None)
