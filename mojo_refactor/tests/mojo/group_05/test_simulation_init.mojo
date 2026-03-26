"""
第五组测试 - mod/rqmojo_mod_sys_simulation/__init__.mojo
测试Mojo版本的模拟模块
"""

from rqmojo.mod.rqmojo_mod_sys_simulation import SimulationMod, create_simulation_mod
from rqmojo.mod.rqmojo_mod_sys_simulation.matcher import Matcher, create_matcher
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_broker import SimulationBroker, create_simulation_broker
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_event_source import SimulationEventSource, create_simulation_event_source_with_test_data
from rqmojo.mod.rqmojo_mod_sys_simulation.signal_broker import SignalBroker, create_signal_broker
from rqmojo.mod.rqmojo_mod_sys_simulation.slippage import SlippageModel, create_slippage_model


def test_create_simulation_mod() -> Bool:
    var mod = create_simulation_mod()
    return True


def test_matcher_creation() -> Bool:
    var matcher = create_matcher()
    return True


def test_simulation_broker_creation() -> Bool:
    var broker = create_simulation_broker()
    return True


def test_simulation_event_source_creation() -> Bool:
    var source = create_simulation_event_source_with_test_data()
    return True


def test_signal_broker_creation() -> Bool:
    var broker = create_signal_broker()
    return True


def test_slippage_model_creation() -> Bool:
    var model = create_slippage_model()
    return True


def test_slippage_model_calc() -> Bool:
    var model = create_slippage_model()
    var slippage = model.calc(10.0, 100)
    return slippage >= 0


def main():
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Testing: mod/rqmojo_mod_sys_simulation/__init__.mojo")
    print("=" * 60)
    
    if test_create_simulation_mod():
        print("PASS: test_create_simulation_mod")
        passed += 1
    else:
        print("FAIL: test_create_simulation_mod")
        failed += 1
    
    if test_matcher_creation():
        print("PASS: test_matcher_creation")
        passed += 1
    else:
        print("FAIL: test_matcher_creation")
        failed += 1
    
    if test_simulation_broker_creation():
        print("PASS: test_simulation_broker_creation")
        passed += 1
    else:
        print("FAIL: test_simulation_broker_creation")
        failed += 1
    
    if test_simulation_event_source_creation():
        print("PASS: test_simulation_event_source_creation")
        passed += 1
    else:
        print("FAIL: test_simulation_event_source_creation")
        failed += 1
    
    if test_signal_broker_creation():
        print("PASS: test_signal_broker_creation")
        passed += 1
    else:
        print("FAIL: test_signal_broker_creation")
        failed += 1
    
    if test_slippage_model_creation():
        print("PASS: test_slippage_model_creation")
        passed += 1
    else:
        print("FAIL: test_slippage_model_creation")
        failed += 1
    
    if test_slippage_model_calc():
        print("PASS: test_slippage_model_calc")
        passed += 1
    else:
        print("FAIL: test_slippage_model_calc")
        failed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, " passed, ", failed, " failed")
    print("=" * 60)
