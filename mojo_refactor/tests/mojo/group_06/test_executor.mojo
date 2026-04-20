"""
Comprehensive Test for core/executor.mojo
Covers all public methods and behavioral parity with Python original.
"""

from std.memory import ArcPointer
from std.testing import assert_equal, assert_true, assert_false, TestSuite

from rqmojo.core.executor import (
    Executor,
    ExecutorConfig,
    EventSplitTuple,
    DateProxyInterface,
    default_date_proxy_fn,
    copy_event_with_type,
    create_event_bus,
    create_executor,
    create_executor_with_config,
)
from rqmojo.const import EXECUTION_PHASE
from rqmojo.core.events import EVENT, Event, EventBus, create_generic_listener


def make_bar_event(calendar_dt: Int, trading_dt: Int) -> Event:
    var e = Event(EVENT.BAR.name)
    e.attributes["calendar_dt"] = calendar_dt
    e.attributes["trading_dt"] = trading_dt
    return e^


def make_tick_event(trading_dt: Int) -> Event:
    var e = Event(EVENT.TICK.name)
    e.attributes["trading_dt"] = trading_dt
    return e^


def make_open_auction_event(calendar_dt: Int, trading_dt: Int) -> Event:
    var e = Event(EVENT.OPEN_AUCTION.name)
    e.attributes["calendar_dt"] = calendar_dt
    e.attributes["trading_dt"] = trading_dt
    return e^


def test_executor_config_creation() raises:
    var config = ExecutorConfig(
        start_date=20200101,
        end_date=20201231,
        frequency="1d",
        is_hold=False
    )
    assert_equal(config.start_date, 20200101)
    assert_equal(config.end_date, 20201231)
    assert_equal(config.frequency, "1d")
    assert_equal(config.is_hold, False)


def test_executor_config_is_hold_true() raises:
    var config = ExecutorConfig(
        start_date=20200101,
        end_date=20201231,
        frequency="1d",
        is_hold=True
    )
    assert_true(config.is_hold)


def test_event_split_tuple_creation() raises:
    var tup = EventSplitTuple(
        pre=EVENT.PRE_BAR,
        main=EVENT.BAR,
        post=EVENT.POST_BAR
    )
    assert_equal(tup.pre.name, "PRE_BAR")
    assert_equal(tup.main.name, "BAR")
    assert_equal(tup.post.name, "POST_BAR")


def test_create_executor() raises:
    var executor = create_executor()
    assert_equal(executor._current_phase_name, "GLOBAL")
    assert_equal(executor._last_before_trading_date, 0)
    assert_equal(executor._config.is_hold, False)


def test_create_executor_with_config() raises:
    var config = ExecutorConfig(
        start_date=20190101,
        end_date=20191231,
        frequency="1h",
        is_hold=True
    )
    var executor = create_executor_with_config(config)
    assert_equal(executor._config.start_date, 20190101)
    assert_equal(executor._config.end_date, 20191231)
    assert_equal(executor._config.frequency, "1h")
    assert_true(executor._config.is_hold)


def test_get_state_initial() raises:
    var executor = create_executor()
    var state = executor.get_state()
    assert_true(state.find("null") != -1, "Initial state should contain null")


def test_get_state_with_date() raises:
    var executor = create_executor()
    executor._last_before_trading_date = 20200515
    var state = executor.get_state()
    assert_true(state.find("2020-5-15") != -1 or state.find("2020-05-15") != -1,
                "State should contain date 2020-05-15 or 2020-5-15")


def test_set_state_null() raises:
    var executor = create_executor()
    executor.set_state('{"last_before_trading": null}')
    assert_equal(executor._last_before_trading_date, 0)


def test_set_state_valid_date() raises:
    var executor = create_executor()
    executor.set_state('{"last_before_trading": "2020-03-15"}')
    assert_equal(executor._last_before_trading_date, 20200315)


def test_set_state_empty_string() raises:
    var executor = create_executor()
    executor.set_state("")
    assert_equal(executor._last_before_trading_date, 0)


def test_set_state_invalid_json() raises:
    var executor = create_executor()
    executor.set_state("not json at all")
    assert_equal(executor._last_before_trading_date, 0)


def test_current_phase() raises:
    var executor = create_executor()
    var phase = executor.current_phase()
    assert_equal(phase.name, "GLOBAL")


def test_set_phase() raises:
    var executor = create_executor()
    executor.set_phase(EXECUTION_PHASE.ON_BAR)
    assert_equal(executor._current_phase_name, "ON_BAR")


def test_get_event_split_map_all_keys() raises:
    var split_map = Executor.get_event_split_map()
    assert_equal(len(split_map), 6)
    assert_true(split_map.__contains__("BEFORE_TRADING"))
    assert_true(split_map.__contains__("BAR"))
    assert_true(split_map.__contains__("TICK"))
    assert_true(split_map.__contains__("AFTER_TRADING"))
    assert_true(split_map.__contains__("SETTLEMENT"))
    assert_true(split_map.__contains__("OPEN_AUCTION"))


def test_get_event_split_map_bar_values() raises:
    var split_map = Executor.get_event_split_map()
    var bar_tuple = split_map["BAR"].copy()
    assert_equal(bar_tuple.pre.name, "PRE_BAR")
    assert_equal(bar_tuple.main.name, "BAR")
    assert_equal(bar_tuple.post.name, "POST_BAR")


def test_get_event_split_map_settlement_values() raises:
    var split_map = Executor.get_event_split_map()
    var settle_tuple = split_map["SETTLEMENT"].copy()
    assert_equal(settle_tuple.pre.name, "PRE_SETTLEMENT")
    assert_equal(settle_tuple.main.name, "SETTLEMENT")
    assert_equal(settle_tuple.post.name, "POST_SETTLEMENT")


def test_copy_event_with_type_preserves_attributes() raises:
    var source = Event("ORIGINAL")
    source.attributes["key1"] = "value1"
    source.attributes["key2"] = 42
    source.attributes["key3"] = 3.14
    source.attributes["key4"] = True
    var copied = copy_event_with_type(source, "COPIED")
    assert_equal(copied.event_type, "COPIED")
    assert_equal(copied.attributes["key1"], "value1")
    assert_equal(copied.attributes["key2"], 42)
    assert_equal(copied.attributes["key3"], 3.14)
    assert_equal(copied.attributes["key4"], True)


def test_run_single_bar_event() raises:
    var bus = EventBus()
    var counter = ArcPointer(0)
    var _ = bus.add_listener("BAR", create_generic_listener("bar_test", counter))
    var config = ExecutorConfig(
        start_date=20200102, end_date=20200102, frequency="1d", is_hold=False
    )
    var executor = Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=0,
        _event_bus=bus^,
        _config=config^,
        _calendar_dt=0,
        _trading_dt=0,
        _date_proxy=DateProxyInterface(default_date_proxy_fn)
    )
    var events = List[Event]()
    events.append(make_bar_event(20200102, 20200102))
    executor.run(events)
    assert_true(counter[] > 0, "Should have published BAR event")


def test_run_bar_splits_into_three() raises:
    var bus = EventBus()
    var counter = ArcPointer(0)
    var _ = bus.add_listener("PRE_BAR", create_generic_listener("pre", counter))
    var _ = bus.add_listener("BAR", create_generic_listener("bar", counter))
    var _ = bus.add_listener("POST_BAR", create_generic_listener("post", counter))
    var config = ExecutorConfig(
        start_date=20200102, end_date=20200102, frequency="1d", is_hold=False
    )
    var executor = Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=0,
        _event_bus=bus^,
        _config=config^,
        _calendar_dt=0,
        _trading_dt=0,
        _date_proxy=DateProxyInterface(default_date_proxy_fn)
    )
    var events = List[Event]()
    events.append(make_bar_event(20200102, 20200102))
    executor.run(events)
    assert_equal(counter[], 3, "BAR should split into PRE_BAR + BAR + POST_BAR")


def test_run_same_day_skips_before_trading() raises:
    var bus = EventBus()
    var before_counter = ArcPointer(0)
    var _ = bus.add_listener("BEFORE_TRADING", create_generic_listener("before", before_counter))
    var config = ExecutorConfig(
        start_date=20200102, end_date=20200104, frequency="1d", is_hold=False
    )
    var executor = Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=20200102,
        _event_bus=bus^,
        _config=config^,
        _calendar_dt=0,
        _trading_dt=0,
        _date_proxy=DateProxyInterface(default_date_proxy_fn)
    )
    var events = List[Event]()
    events.append(make_bar_event(20200102, 20200102))
    executor.run(events)
    assert_equal(before_counter[], 0, "Same day should NOT publish BEFORE_TRADING again")


def test_run_is_hold_mode() raises:
    var bus = EventBus()
    var before_counter = ArcPointer(0)
    var settlement_counter = ArcPointer(0)
    var _ = bus.add_listener("BEFORE_TRADING", create_generic_listener("before", before_counter))
    var _ = bus.add_listener("SETTLEMENT", create_generic_listener("settlement", settlement_counter))
    var config = ExecutorConfig(
        start_date=20200102, end_date=20200104, frequency="1d", is_hold=True
    )
    var executor = Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=0,
        _event_bus=bus^,
        _config=config^,
        _calendar_dt=0,
        _trading_dt=0,
        _date_proxy=DateProxyInterface(default_date_proxy_fn)
    )
    var events = List[Event]()
    events.append(make_bar_event(20200102, 20200102))
    events.append(make_bar_event(20200103, 20200103))
    executor.run(events)
    assert_equal(before_counter[], 0, "is_hold=True should skip all BEFORE_TRADING")
    assert_equal(settlement_counter[], 0, "is_hold=True should skip SETTLEMENT")


def test_run_settlement_on_last_day() raises:
    var bus = EventBus()
    var settlement_counter = ArcPointer(0)
    var _ = bus.add_listener("SETTLEMENT", create_generic_listener("settle", settlement_counter))
    var config = ExecutorConfig(
        start_date=20200102, end_date=20200102, frequency="1d", is_hold=False
    )
    var executor = Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=0,
        _event_bus=bus^,
        _config=config^,
        _calendar_dt=0,
        _trading_dt=0,
        _date_proxy=DateProxyInterface(default_date_proxy_fn)
    )
    var events = List[Event]()
    events.append(make_bar_event(20200102, 20200102))
    executor.run(events)
    assert_true(settlement_counter[] > 0, "Should publish SETTLEMENT when trading_dt == end_date")


def test_run_no_settlement_when_not_last_day() raises:
    var bus = EventBus()
    var settlement_counter = ArcPointer(0)
    var _ = bus.add_listener("SETTLEMENT", create_generic_listener("settle2", settlement_counter))
    var config = ExecutorConfig(
        start_date=20200102, end_date=20200105, frequency="1d", is_hold=False
    )
    var executor = Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=0,
        _event_bus=bus^,
        _config=config^,
        _calendar_dt=0,
        _trading_dt=0,
        _date_proxy=DateProxyInterface(default_date_proxy_fn)
    )
    var events = List[Event]()
    events.append(make_bar_event(20200102, 20200102))
    executor.run(events)
    assert_equal(settlement_counter[], 0, "Should NOT publish SETTLEMENT when not last day")


def test_run_tick_event_handling() raises:
    var bus = EventBus()
    var tick_counter = ArcPointer(0)
    var _ = bus.add_listener("TICK", create_generic_listener("tick", tick_counter))
    var config = ExecutorConfig(
        start_date=20200102, end_date=20200102, frequency="1d", is_hold=False
    )
    var executor = Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=0,
        _event_bus=bus^,
        _config=config^,
        _calendar_dt=0,
        _trading_dt=0,
        _date_proxy=DateProxyInterface(default_date_proxy_fn)
    )
    var events = List[Event]()
    events.append(make_tick_event(20200102))
    executor.run(events)
    assert_true(tick_counter[] > 0, "TICK event should be processed and published")


def test_run_open_auction_splits() raises:
    var bus = EventBus()
    var counter = ArcPointer(0)
    var _ = bus.add_listener("OPEN_AUCTION", create_generic_listener("oa", counter))
    var config = ExecutorConfig(
        start_date=20200102, end_date=20200102, frequency="1d", is_hold=False
    )
    var executor = Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=0,
        _event_bus=bus^,
        _config=config^,
        _calendar_dt=0,
        _trading_dt=0,
        _date_proxy=DateProxyInterface(default_date_proxy_fn)
    )
    var events = List[Event]()
    events.append(make_open_auction_event(20200102, 20200102))
    executor.run(events)
    assert_true(counter[] > 0, "OPEN_AUCTION should be processed")


def test_run_after_trading_published() raises:
    var bus = EventBus()
    var after_counter = ArcPointer(0)
    var _ = bus.add_listener("AFTER_TRADING", create_generic_listener("after", after_counter))
    var config = ExecutorConfig(
        start_date=20200102, end_date=20200102, frequency="1d", is_hold=False
    )
    var executor = Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=0,
        _event_bus=bus^,
        _config=config^,
        _calendar_dt=0,
        _trading_dt=0,
        _date_proxy=DateProxyInterface(default_date_proxy_fn)
    )
    var events = List[Event]()
    var after_evt = Event(EVENT.AFTER_TRADING.name)
    after_evt.attributes["trading_dt"] = 20200102
    events.append(after_evt^)
    executor.run(events)
    assert_true(after_counter[] > 0, "AFTER_TRADING should be published")


def test_run_unknown_event_passthrough() raises:
    var bus = EventBus()
    var user_counter = ArcPointer(0)
    var _ = bus.add_listener("USER", create_generic_listener("user", user_counter))
    var config = ExecutorConfig(
        start_date=20200102, end_date=20200102, frequency="1d", is_hold=False
    )
    var executor = Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=0,
        _event_bus=bus^,
        _config=config^,
        _calendar_dt=0,
        _trading_dt=0,
        _date_proxy=DateProxyInterface(default_date_proxy_fn)
    )
    var events = List[Event]()
    var user_evt = Event(EVENT.USER.name)
    events.append(user_evt^)
    executor.run(events)
    assert_true(user_counter[] > 0, "Unknown event type should be passed through to bus")


def test_ensure_before_trading_updates_last_date() raises:
    var bus = EventBus()
    var config = ExecutorConfig(
        start_date=20200106, end_date=20200106, frequency="1d", is_hold=False
    )
    var executor = Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=0,
        _event_bus=bus^,
        _config=config^,
        _calendar_dt=0,
        _trading_dt=0,
        _date_proxy=DateProxyInterface(default_date_proxy_fn)
    )
    var evt = make_bar_event(20200106, 20200106)
    var events = List[Event]()
    events.append(evt^)
    executor.run(events)
    assert_equal(executor._last_before_trading_date, 20200106,
                 "_last_before_trading_date should be updated to event date")


def test_get_calendar_dt_and_trading_dt() raises:
    var executor = create_executor()
    assert_equal(executor.get_calendar_dt(), 0)
    assert_equal(executor.get_trading_dt(), 0)
    executor._calendar_dt = 20200601
    executor._trading_dt = 20200602
    assert_equal(executor.get_calendar_dt(), 20200601)
    assert_equal(executor.get_trading_dt(), 20200602)


def test_get_last_before_trading_date() raises:
    var executor = create_executor()
    assert_equal(executor.get_last_before_trading_date(), 0)
    executor._last_before_trading_date = 20200715
    assert_equal(executor.get_last_before_trading_date(), 20200715)


def test_multiple_days_produces_settlements() raises:
    var bus = EventBus()
    var settlement_counter = ArcPointer(0)
    var _ = bus.add_listener("SETTLEMENT", create_generic_listener("settle_multi", settlement_counter))
    var config = ExecutorConfig(
        start_date=20200102, end_date=20200104, frequency="1d", is_hold=False
    )
    var executor = Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=0,
        _event_bus=bus^,
        _config=config^,
        _calendar_dt=0,
        _trading_dt=0,
        _date_proxy=DateProxyInterface(default_date_proxy_fn)
    )
    var events = List[Event]()
    events.append(make_bar_event(20200102, 20200102))
    events.append(make_bar_event(20200103, 20200103))
    events.append(make_bar_event(20200104, 20200104))
    executor.run(events)
    assert_true(settlement_counter[] >= 2,
                "Multiple days should produce SETTLEMENT between days + final")


def test_default_date_proxy_fn() raises:
    assert_equal(default_date_proxy_fn(20200105), 20200104)


def test_date_proxy_interface() raises:
    var dpi = DateProxyInterface(default_date_proxy_fn)
    assert_equal(dpi._fn_get_previous_trading_date(20200301), 20200300)


def test_event_split_map_open_auction_values() raises:
    var split_map = Executor.get_event_split_map()
    var oa_tuple = split_map["OPEN_AUCTION"].copy()
    assert_equal(oa_tuple.pre.name, "PRE_OPEN_AUCTION")
    assert_equal(oa_tuple.main.name, "OPEN_AUCTION")
    assert_equal(oa_tuple.post.name, "POST_OPEN_AUCTION")


def test_event_split_map_tick_values() raises:
    var split_map = Executor.get_event_split_map()
    var tick_tuple = split_map["TICK"].copy()
    assert_equal(tick_tuple.pre.name, "PRE_TICK")
    assert_equal(tick_tuple.main.name, "TICK")
    assert_equal(tick_tuple.post.name, "POST_TICK")


def test_event_split_map_after_trading_values() raises:
    var split_map = Executor.get_event_split_map()
    var at_tuple = split_map["AFTER_TRADING"].copy()
    assert_equal(at_tuple.pre.name, "PRE_AFTER_TRADING")
    assert_equal(at_tuple.main.name, "AFTER_TRADING")
    assert_equal(at_tuple.post.name, "POST_AFTER_TRADING")


def test_event_split_map_before_trading_values() raises:
    var split_map = Executor.get_event_split_map()
    var bt_tuple = split_map["BEFORE_TRADING"].copy()
    assert_equal(bt_tuple.pre.name, "PRE_BEFORE_TRADING")
    assert_equal(bt_tuple.main.name, "BEFORE_TRADING")
    assert_equal(bt_tuple.post.name, "POST_BEFORE_TRADING")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
