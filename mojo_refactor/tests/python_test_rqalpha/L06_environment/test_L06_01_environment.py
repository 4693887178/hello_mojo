# test_L06_01_environment.py
# Module: rqalpha.environment
# Level: L06 - Environment Layer
# Dependencies: core, const, interface, data, portfolio

import pytest


class TestEnvironment:
    """Test Environment class"""
    
    def test_environment_exists(self):
        """Test Environment exists"""
        from rqalpha.environment import Environment
        assert Environment is not None
    
    def test_environment_get_instance_raises(self):
        """Test Environment.get_instance raises when not initialized"""
        from rqalpha.environment import Environment
        from rqalpha.utils.exception import EnvironmentNotInitialized
        
        Environment._env = None
        with pytest.raises(EnvironmentNotInitialized):
            Environment.get_instance()


class TestEnvironmentMethods:
    """Test Environment methods - requires config"""
    
    @pytest.mark.skip(reason="Requires config initialization")
    def test_environment_creation(self):
        pass
    
    @pytest.mark.skip(reason="Requires config initialization")
    def test_set_data_proxy(self):
        pass


class TestGlobalVars:
    """Test GlobalVars class"""
    
    def test_global_vars_exists(self):
        """Test GlobalVars exists"""
        from rqalpha.core.global_var import GlobalVars
        assert GlobalVars is not None
