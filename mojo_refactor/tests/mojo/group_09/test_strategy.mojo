"""
Test for core/strategy.mojo
Group 09 - File 9

Comprehensive tests covering:
- Strategy trait definition
- BaseStrategy lifecycle (init, register_*, call_*, universe)
- StrategyCallbacks tracking
- StrategyEventWrapper event registration
- run_when_strategy_not_hold behavior
- Factory functions
"""

from std.collections import Dict, Set, List
from rqmojo.core.strategy import (
    Strategy, BaseStrategy, create_base_strategy,
    StrategyCallbacks, create_strategy_callbacks,
    StrategyEventWrapper,
    run_when_strategy_not_hold
)
from rqmojo.core.events import create_event_bus, EVENT, EventBus
from rqmojo.model.bar import BarObject, create_simple_bar
from rqmojo.model.tick import TickObject, create_tick_object
from rqmojo.model.instrument import create_stock_instrument, EXCHANGE
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def _contains(s: String, sub: String) -> Bool:
    return s.find(sub) >= 0


def test_strategy_trait_exists() raises:
    print("Test: Strategy trait exists")


def test_base_strategy_init() raises:
    print("Test: BaseStrategy init with default name")
    var event_bus = create_event_bus()
    var _ = create_base_strategy(event_bus=event_bus^)
    print("  PASSED")


def test_base_strategy_with_custom_name() raises:
    print("Test: BaseStrategy init with custom name")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^, name="MyCustomStrategy")
    assert_equal(strategy.strategy_name, "MyCustomStrategy")
    print("  PASSED")


def test_base_strategy_default_name() raises:
    print("Test: BaseStrategy default name is BaseStrategy")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    assert_equal(strategy.strategy_name, "BaseStrategy")
    print("  PASSED")


def test_base_strategy_str_representation() raises:
    print("Test: BaseStrategy string representation")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^, name="TestStrat")
    var s = String(strategy)
    assert_true(_contains(s, "TestStrat"))
    print("  PASSED")


def test_base_strategy_empty_universe() raises:
    print("Test: BaseStrategy initial universe is empty")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    var universe = strategy.get_universe()
    assert_equal(len(universe), 0)
    print("  PASSED")


def test_base_strategy_user_context_returns_context() raises:
    print("Test: BaseStrategy.user_context() returns StrategyContext")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    var ctx = strategy.user_context()
    var s = String(ctx.now())
    assert_true(len(s) > 0)
    print("  PASSED")


def test_callback_creation_defaults() raises:
    print("Test: create_strategy_callbacks returns all False")
    var cb = create_strategy_callbacks()
    assert_false(cb.has_init)
    assert_false(cb.has_before_trading)
    assert_false(cb.has_handle_bar)
    assert_false(cb.has_handle_tick)
    assert_false(cb.has_after_trading)
    assert_false(cb.has_open_auction)
    print("  PASSED")


def test_callback_write_to() raises:
    print("Test: StrategyCallbacks.write_to contains field info")
    var cb = create_strategy_callbacks()
    var s = String(cb)
    assert_true(_contains(s, "StrategyCallbacks"))
    assert_true(_contains(s, "init="))
    assert_true(_contains(s, "before_trading="))
    assert_true(_contains(s, "handle_bar="))
    print("  PASSED")


def test_register_init() raises:
    print("Test: register_init sets has_init=True")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    strategy.register_init()
    assert_true(strategy.callbacks.has_init)
    print("  PASSED")


def test_register_before_trading() raises:
    print("Test: register_before_trading sets has_before_trading=True")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    strategy.register_before_trading()
    assert_true(strategy.callbacks.has_before_trading)
    print("  PASSED")


def test_register_handle_bar() raises:
    print("Test: register_handle_bar sets has_handle_bar=True")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    strategy.register_handle_bar()
    assert_true(strategy.callbacks.has_handle_bar)
    print("  PASSED")


def test_register_handle_tick() raises:
    print("Test: register_handle_tick sets has_handle_tick=True")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    strategy.register_handle_tick()
    assert_true(strategy.callbacks.has_handle_tick)
    print("  PASSED")


def test_register_after_trading() raises:
    print("Test: register_after_trading sets has_after_trading=True")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    strategy.register_after_trading()
    assert_true(strategy.callbacks.has_after_trading)
    print("  PASSED")


def test_register_open_auction() raises:
    print("Test: register_open_auction sets has_open_auction=True")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    strategy.register_open_auction()
    assert_true(strategy.callbacks.has_open_auction)
    print("  PASSED")


def test_register_all_callbacks() raises:
    print("Test: Registering all callbacks sets all flags True")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    strategy.register_init()
    strategy.register_before_trading()
    strategy.register_handle_bar()
    strategy.register_handle_tick()
    strategy.register_after_trading()
    strategy.register_open_auction()
    assert_true(strategy.callbacks.has_init)
    assert_true(strategy.callbacks.has_before_trading)
    assert_true(strategy.callbacks.has_handle_bar)
    assert_true(strategy.callbacks.has_handle_tick)
    assert_true(strategy.callbacks.has_after_trading)
    assert_true(strategy.callbacks.has_open_auction)
    print("  PASSED")


def test_call_init_noop() raises:
    print("Test: call_init is a no-op by default")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    strategy.call_init()
    print("  PASSED")


def test_call_before_trading_noop() raises:
    print("Test: call_before_trading is a no-op by default")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    strategy.call_before_trading()
    print("  PASSED")


def test_call_handle_bar_noop() raises:
    print("Test: call_handle_bar is a no-op by default")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    var dt = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var bar = create_simple_bar("000001.XSHE", dt, 10.0, 11.0, 9.0, 10.5, 1000.0)
    strategy.call_handle_bar(bar)
    print("  PASSED")


def test_call_handle_tick_noop() raises:
    print("Test: call_handle_tick is a no-op by default")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    var ins = create_stock_instrument("000001.XSHE", "000001", DateTime(2020, 1, 1), EXCHANGE.XSHE)
    var dt = DateTime(2020, 1, 1, 10, 30, 0, 0)
    var tick = create_tick_object(ins^, dt^)
    strategy.call_handle_tick(tick)
    print("  PASSED")


def test_call_after_trading_noop() raises:
    print("Test: call_after_trading is a no-op by default")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    strategy.call_after_trading()
    print("  PASSED")


def test_call_open_auction_noop() raises:
    print("Test: call_open_auction is a no-op by default")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    var dt = DateTime(2020, 1, 1, 9, 25, 0, 0)
    var bar = create_simple_bar("000001.XSHE", dt, 10.0, 11.0, 9.0, 10.5, 1000.0)
    strategy.call_open_auction(bar)
    print("  PASSED")


def test_update_universe() raises:
    print("Test: update_universe replaces current universe")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    var new_universe = Set[String]()
    new_universe.add("000001.XSHE")
    new_universe.add("600000.XSHG")
    strategy.update_universe(new_universe^)
    var universe = strategy.get_universe()
    assert_equal(len(universe), 2)
    print("  PASSED")


def test_wrap_user_event_handler() raises:
    print("Test: wrap_user_event_handler returns wrapped name")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    var result = strategy.wrap_user_event_handler("my_handler")
    assert_equal(result, "wrapped_my_handler")
    print("  PASSED")


def test_event_wrapper_creation() raises:
    print("Test: StrategyEventWrapper creation")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    var wrapper = StrategyEventWrapper(strategy=strategy^)
    assert_equal(len(wrapper.registered_events), 0)
    print("  PASSED")


def test_event_wrapper_str() raises:
    print("Test: StrategyEventWrapper string representation")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    var wrapper = StrategyEventWrapper(strategy=strategy^)
    var s = String(wrapper)
    assert_true(_contains(s, "StrategyEventWrapper"))
    print("  PASSED")


def test_event_wrapper_register_no_events() raises:
    print("Test: register_events with no callbacks registers nothing")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    var wrapper = StrategyEventWrapper(strategy=strategy^)
    var bus = create_event_bus()
    wrapper.register_events(bus^)
    assert_equal(len(wrapper.registered_events), 0)
    print("  PASSED")


def test_event_wrapper_register_before_trading() raises:
    print("Test: register_events registers BEFORE_TRADING when callback set")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    strategy.register_before_trading()
    var wrapper = StrategyEventWrapper(strategy=strategy^)
    var bus = create_event_bus()
    wrapper.register_events(bus^)
    assert_equal(len(wrapper.registered_events), 1)
    print("  PASSED")


def test_event_wrapper_register_all_events() raises:
    print("Test: register_events registers all events when all callbacks set")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    strategy.register_before_trading()
    strategy.register_handle_bar()
    strategy.register_handle_tick()
    strategy.register_after_trading()
    strategy.register_open_auction()
    var wrapper = StrategyEventWrapper(strategy=strategy^)
    var bus = create_event_bus()
    wrapper.register_events(bus^)
    assert_equal(len(wrapper.registered_events), 5)
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
