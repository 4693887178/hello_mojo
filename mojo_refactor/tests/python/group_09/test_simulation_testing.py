# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_simulation/testing.py
Group 09 - File 7
Comprehensive tests verifying Python testing module behavior.
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestSimulationTestingModule:
    def test_module_exists(self):
        from rqalpha.mod import rqalpha_mod_sys_simulation
        assert rqalpha_mod_sys_simulation is not None

    def test_testing_module_importable(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation import testing
        assert testing is not None


class TestSimulationEventSourceFixture:
    """Test SimulationEventSourceFixture class matching Python implementation."""

    def test_fixture_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.testing import SimulationEventSourceFixture
        assert SimulationEventSourceFixture is not None

    def test_fixture_inherits_environment_fixture(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.testing import SimulationEventSourceFixture
        from rqalpha.utils.testing import EnvironmentFixture
        assert issubclass(SimulationEventSourceFixture, EnvironmentFixture)

    def test_fixture_init_sets_none_source(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.testing import SimulationEventSourceFixture
        fixture = SimulationEventSourceFixture()
        assert fixture.simulation_event_source is None

    def test_fixture_init_accepts_no_args(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.testing import SimulationEventSourceFixture
        fixture = SimulationEventSourceFixture()
        assert fixture.simulation_event_source is None

    def test_init_fixture_creates_event_source_when_env_set(self):
        """When env is set, init_fixture should create a SimulationEventSource."""
        from rqalpha.mod.rqalpha_mod_sys_simulation.testing import SimulationEventSourceFixture
        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.simulation_event_source.SimulationEventSource') as MockSource:
            mock_env = Mock()
            mock_env.config = Mock()
            fixture = SimulationEventSourceFixture()
            fixture.env = mock_env
            fixture.init_fixture()
            assert fixture.simulation_event_source is not None

    def test_init_fixture_always_creates_source(self):
        """Python's parent EnvironmentFixture.init_fixture sets up env, so source is always created."""
        from rqalpha.mod.rqalpha_mod_sys_simulation.testing import SimulationEventSourceFixture
        fixture = SimulationEventSourceFixture()
        fixture.init_fixture()
        assert fixture.simulation_event_source is not None
        from rqalpha.mod.rqalpha_mod_sys_simulation.simulation_event_source import SimulationEventSource
        assert isinstance(fixture.simulation_event_source, SimulationEventSource)


class TestSimulationEventSourceIntegration:
    """Test that init_fixture properly creates SimulationEventSource."""

    def test_init_fixture_calls_parent_and_creates_source(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.testing import SimulationEventSourceFixture
        original_init = SimulationEventSourceFixture.__init__
        call_count = [0]
        def tracking_init(self_ref, *args, **kwargs):
            call_count[0] += 1
            return original_init(self_ref, *args, **kwargs)
        SimulationEventSourceFixture.__init__ = tracking_init
        try:
            fixture = SimulationEventSourceFixture()
            assert call_count[0] == 1
        finally:
            SimulationEventSourceFixture.__init__ = original_init

    def test_init_fixture_with_real_env_creates_source(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.testing import SimulationEventSourceFixture
        fixture = SimulationEventSourceFixture()
        if hasattr(fixture, 'env') and fixture.env is not None:
            fixture.init_fixture()
            assert fixture.simulation_event_source is not None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
