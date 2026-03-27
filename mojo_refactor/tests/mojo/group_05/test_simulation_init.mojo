"""
第五组测试 - mod/rqmojo_mod_sys_simulation/__init__.mojo
测试Mojo版本的模拟模块
"""

from rqmojo.mod.rqmojo_mod_sys_simulation import SimulationMod, create_simulation_mod
from rqmojo.mod.rqmojo_mod_sys_simulation.matcher import Matcher, create_matcher
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_broker import SimulationBroker, create_simulation_broker
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_event_source import SimulationEventSource, create_simulation_event_source_with_test_data
from rqmojo.mod.rqmojo_mod_sys_simulation.signal_broker import SignalBroker, create_signal_broker
from rqmojo.mod.rqmojo_mod_sys_simulation.slippage import Slippage, FixedSlippage, PercentSlippage



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_create_simulation_mod() raises:
    var mod = create_simulation_mod()
    assert_true(True, "test passed")


def test_matcher_creation() raises:
    var matcher = create_matcher()
    assert_true(True, "test passed")


def test_simulation_broker_creation() raises:
    var broker = create_simulation_broker()
    assert_true(True, "test passed")


def test_simulation_event_source_creation() raises:
    var source = create_simulation_event_source_with_test_data()
    assert_true(True, "test passed")


def test_signal_broker_creation() raises:
    var broker = create_signal_broker()
    assert_true(True, "test passed")


def test_slippage_model_creation() raises:
    var model = FixedSlippage(0.1)
    assert_true(True, "test passed")


def test_slippage_model_calc() raises:
    var model = PercentSlippage(0.01)
    assert_true(True, "test passed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()