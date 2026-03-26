# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_simulation/signal_broker.py
Group 09 - File 6
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestSignalBroker:
    def test_signal_broker_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        assert SignalBroker is not None

    def test_signal_broker_has_submit_order(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        assert hasattr(SignalBroker, 'submit_order')

    def test_signal_broker_has_cancel_order(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        assert hasattr(SignalBroker, 'cancel_order')

    def test_signal_broker_has_get_open_orders(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        assert hasattr(SignalBroker, 'get_open_orders')

    def test_signal_broker_inherits_abstract_broker(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        from rqalpha.interface import AbstractBroker
        assert issubclass(SignalBroker, AbstractBroker)


class TestSignalBrokerMethods:
    def test_signal_broker_is_abstract_broker(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        from rqalpha.interface import AbstractBroker
        assert issubclass(SignalBroker, AbstractBroker)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
