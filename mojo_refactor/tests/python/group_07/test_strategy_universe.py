# -*- coding: utf-8 -*-
"""
Test for core/strategy_universe.py
Group 07 - File 01
"""

import pytest
import json
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestStrategyUniverseStructure:
    def test_class_exists(self):
        from rqalpha.core.strategy_universe import StrategyUniverse
        assert StrategyUniverse is not None

    def test_class_methods(self):
        from rqalpha.core.strategy_universe import StrategyUniverse
        methods = [m for m in dir(StrategyUniverse) if not m.startswith('_') or m in ['__init__', 'get_state', 'set_state']]
        expected_methods = ['__init__', 'get_state', 'set_state', 'update', 'get', '_clear_de_listed']
        for method in expected_methods:
            assert method in dir(StrategyUniverse), f"Missing method: {method}"


class TestStrategyUniverseInit:
    def test_init(self):
        with patch('rqalpha.core.strategy_universe.Environment') as MockEnv:
            mock_env = Mock()
            mock_event_bus = Mock()
            mock_env.get_instance.return_value.event_bus = mock_event_bus
            MockEnv.get_instance.return_value = mock_env
            
            from rqalpha.core.strategy_universe import StrategyUniverse
            universe = StrategyUniverse()
            
            assert universe._set == set()


class TestStrategyUniverseUpdate:
    def test_update_with_string_list(self):
        with patch('rqalpha.core.strategy_universe.Environment') as MockEnv:
            mock_env = Mock()
            mock_event_bus = Mock()
            mock_env.get_instance.return_value.event_bus = mock_event_bus
            MockEnv.get_instance.return_value = mock_env
            
            from rqalpha.core.strategy_universe import StrategyUniverse
            universe = StrategyUniverse()
            
            universe.update(['000001.XSHE', '000002.XSHE'])
            
            assert '000001.XSHE' in universe._set
            assert '000002.XSHE' in universe._set

    def test_update_with_single_string(self):
        with patch('rqalpha.core.strategy_universe.Environment') as MockEnv:
            mock_env = Mock()
            mock_event_bus = Mock()
            mock_env.get_instance.return_value.event_bus = mock_event_bus
            MockEnv.get_instance.return_value = mock_env
            
            from rqalpha.core.strategy_universe import StrategyUniverse
            universe = StrategyUniverse()
            
            universe.update('000001.XSHE')
            
            assert '000001.XSHE' in universe._set


class TestStrategyUniverseGet:
    def test_get_returns_copy(self):
        with patch('rqalpha.core.strategy_universe.Environment') as MockEnv:
            mock_env = Mock()
            mock_event_bus = Mock()
            mock_env.get_instance.return_value.event_bus = mock_event_bus
            MockEnv.get_instance.return_value = mock_env
            
            from rqalpha.core.strategy_universe import StrategyUniverse
            universe = StrategyUniverse()
            
            universe.update(['000001.XSHE'])
            result = universe.get()
            
            assert isinstance(result, set)
            assert '000001.XSHE' in result


class TestStrategyUniverseState:
    def test_get_state(self):
        with patch('rqalpha.core.strategy_universe.Environment') as MockEnv:
            mock_env = Mock()
            mock_event_bus = Mock()
            mock_env.get_instance.return_value.event_bus = mock_event_bus
            MockEnv.get_instance.return_value = mock_env
            
            from rqalpha.core.strategy_universe import StrategyUniverse
            universe = StrategyUniverse()
            
            universe.update(['000001.XSHE', '000002.XSHE'])
            state = universe.get_state()
            
            assert isinstance(state, bytes)
            state_list = json.loads(state.decode('utf-8'))
            assert '000001.XSHE' in state_list
            assert '000002.XSHE' in state_list

    def test_set_state(self):
        with patch('rqalpha.core.strategy_universe.Environment') as MockEnv:
            mock_env = Mock()
            mock_event_bus = Mock()
            mock_env.get_instance.return_value.event_bus = mock_event_bus
            MockEnv.get_instance.return_value = mock_env
            
            from rqalpha.core.strategy_universe import StrategyUniverse
            universe = StrategyUniverse()
            
            state = json.dumps(['000001.XSHE', '000002.XSHE']).encode('utf-8')
            universe.set_state(state)
            
            result = universe.get()
            assert '000001.XSHE' in result
            assert '000002.XSHE' in result


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
