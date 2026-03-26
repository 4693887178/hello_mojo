# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_simulation/mod.py
Group 09 - File 5
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestSimulationMod:
    def test_simulation_mod_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.mod import SimulationMod
        assert SimulationMod is not None

    def test_simulation_mod_has_start_up(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.mod import SimulationMod
        assert hasattr(SimulationMod, 'start_up')

    def test_simulation_mod_has_tear_down(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.mod import SimulationMod
        assert hasattr(SimulationMod, 'tear_down')

    def test_simulation_mod_inherits_abstract_mod(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.mod import SimulationMod
        from rqalpha.interface import AbstractMod
        assert issubclass(SimulationMod, AbstractMod)


class TestParseMatchingType:
    def test_parse_matching_type_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.mod import SimulationMod
        assert hasattr(SimulationMod, 'parse_matching_type')

    def test_parse_matching_type_current_bar(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.mod import SimulationMod
        from rqalpha.const import MATCHING_TYPE
        result = SimulationMod.parse_matching_type("current_bar", "1d")
        assert result == MATCHING_TYPE.CURRENT_BAR_CLOSE

    def test_parse_matching_type_next_bar(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.mod import SimulationMod
        from rqalpha.const import MATCHING_TYPE
        result = SimulationMod.parse_matching_type("next_bar", "1d")
        assert result == MATCHING_TYPE.NEXT_BAR_OPEN


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
