"""
Test for rqalpha/mod/rqalpha_mod_sys_simulation/__init__.py
"""


class TestSimulationInit:
    """Test simulation module initialization"""

    def test_config_exists(self):
        """Test __config__ dictionary exists and has correct keys"""
        from rqalpha.mod.rqalpha_mod_sys_simulation import __config__
        
        assert isinstance(__config__, dict)
        assert "signal" in __config__
        assert "matching_type" in __config__
        assert "price_limit" in __config__
        assert "liquidity_limit" in __config__
        assert "volume_limit" in __config__
        assert "volume_percent" in __config__
        assert "slippage_model" in __config__
        assert "slippage" in __config__
        assert "inactive_limit" in __config__
        assert "management_fee" in __config__

    def test_config_default_values(self):
        """Test __config__ default values"""
        from rqalpha.mod.rqalpha_mod_sys_simulation import __config__
        
        assert __config__["signal"] is False
        assert __config__["matching_type"] is None
        assert __config__["price_limit"] is True
        assert __config__["liquidity_limit"] is False
        assert __config__["volume_limit"] is True
        assert __config__["volume_percent"] == 0.25
        assert __config__["slippage_model"] == "PriceRatioSlippage"
        assert __config__["slippage"] == 0
        assert __config__["inactive_limit"] is True
        assert __config__["management_fee"] == []

    def test_cli_prefix_exists(self):
        """Test cli_prefix constant exists"""
        from rqalpha.mod.rqalpha_mod_sys_simulation import cli_prefix
        
        assert cli_prefix == "mod__sys_simulation__"

    def test_load_mod_function_exists(self):
        """Test load_mod function exists"""
        from rqalpha.mod.rqalpha_mod_sys_simulation import load_mod
        
        assert callable(load_mod)

    def test_load_mod_returns_simulation_mod(self):
        """Test load_mod returns SimulationMod instance"""
        from rqalpha.mod.rqalpha_mod_sys_simulation import load_mod
        
        mod = load_mod()
        assert mod is not None
        assert hasattr(mod, 'start_up')
        assert hasattr(mod, 'tear_down')

    def test_mod_name(self):
        """Test module name"""
        from rqalpha.mod.rqalpha_mod_sys_simulation import load_mod
        
        mod = load_mod()
        assert mod.__class__.__name__ == "SimulationMod"


class TestSimulationConfig:
    """Test simulation configuration"""

    def test_signal_config(self):
        """Test signal configuration"""
        from rqalpha.mod.rqalpha_mod_sys_simulation import __config__
        
        assert __config__["signal"] is False

    def test_matching_type_config(self):
        """Test matching type configuration"""
        from rqalpha.mod.rqalpha_mod_sys_simulation import __config__
        
        assert __config__["matching_type"] is None

    def test_slippage_config(self):
        """Test slippage configuration"""
        from rqalpha.mod.rqalpha_mod_sys_simulation import __config__
        
        assert __config__["slippage_model"] == "PriceRatioSlippage"
        assert __config__["slippage"] == 0

    def test_volume_limit_config(self):
        """Test volume limit configuration"""
        from rqalpha.mod.rqalpha_mod_sys_simulation import __config__
        
        assert __config__["volume_limit"] is True
        assert __config__["volume_percent"] == 0.25


class TestCLIOptions:
    """Test CLI options registration"""

    def test_cli_options_registered(self):
        """Test CLI options are registered"""
        from rqalpha import cli
        
        run_cmd = cli.commands.get('run')
        assert run_cmd is not None
        
        param_names = [p.name for p in run_cmd.params]
        
        assert 'signal' in param_names or 'mod__sys_simulation__signal' in param_names
