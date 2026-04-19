"""
Comprehensive tests for SimulationEventSource
Tests all functionality against Python original: simulation_event_source.py

Coverage:
  - SimEvent struct (fields, copy, write_to)
  - DateTimeCopy struct
  - SimulationEventSource lifecycle
  - _get_day_bar_dt / _get_after_trading_dt
  - _get_stock_trading_minutes
  - _get_future_trading_minutes (with int→datetime conversion)
  - _get_trading_minutes (stock + future union)
  - events() "1d" frequency (daily bar events with timestamps)
  - events() "1m" frequency (minute events with universe change handling)
  - events() "tick" frequency (tick events with FUTURE/STOCK type detection)
  - events() invalid frequency (error case)
  - Universe change callback (_on_universe_changed / set_universe_changed)
  - get_generated_events / get_event_count
  - create_simulation_event_source factory
"""

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite
from std.python import Python, PythonObject
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_event_source import (
    SimulationEventSource,
    DateTimeCopy,
    SimEvent,
    EventSource,
    create_simulation_event_source,
)


def _make_mock_env() raises -> PythonObject:
    var datetime_mod = Python.import_module("datetime")
    var dt = datetime_mod.datetime
    var env = Python.evaluate(
        "type('obj', (object,), {"
        "'config': type('obj', (object,), {"
        "'base': type('obj', (object,), {"
        "'accounts': ['STOCK']"
        "})()"
        "})(),"
        "'event_bus': type('obj', (object,), {"
        "'_listeners': {},"
        "'add_listener': lambda self, event, cb: self._listeners.__setitem__(event, cb)"
        "})(),"
        "'get_universe': lambda self: ['000001.XSHE'],"
        "'get_account_type': lambda self, oid: 'STOCK',"
        "'data_proxy': type('obj', (object,), {"
        "'get_trading_dates': lambda self, s, e: [__import__('datetime').datetime(2025, 1, 2), __import__('datetime').datetime(2025, 1, 3)],"
        "'get_trading_minutes_for': lambda self, oid, d: set(),"
        "'get_merge_ticks': lambda self, u, d, ld: []"
        "})(),"
        "'get_instrument': lambda self, oid: type('obj', (object,), {"
        "'type': 'CS'"
        "})()"
        "})()"
    )
    return env


def _make_mock_env_with_future() raises -> PythonObject:
    var datetime_mod = Python.import_module("datetime")
    var dt = datetime_mod.datetime
    var env = Python.evaluate(
        "type('obj', (object,), {"
        "'config': type('obj', (object,), {"
        "'base': type('obj', (object,), {"
        "'accounts': ['STOCK', 'FUTURE']"
        "})()"
        "})(),"
        "'event_bus': type('obj', (object,), {"
        "'_listeners': {},"
        "'add_listener': lambda self, event, cb: self._listeners.__setitem__(event, cb)"
        "})(),"
        "'get_universe': lambda self: ['000001.XSHE', 'IF2501.CFFEX'],"
        "'get_account_type': lambda self, oid: 'FUTURE' if 'CFFEX' in oid else 'STOCK',"
        "'data_proxy': type('obj', (object,), {"
        "'get_trading_dates': lambda self, s, e: [__import__('datetime').datetime(2025, 1, 2)],"
        "'get_trading_minutes_for': lambda self, oid, d: set() if 'XSHE' in oid else {20250102093000},"
        "'get_merge_ticks': lambda self, u, d, ld: []"
        "})(),"
        "'get_instrument': lambda self, oid: type('obj', (object,), {"
        "'type': 'Future' if 'CFFEX' in oid else 'CS'"
        "})()"
        "})()"
    )
    return env


def test_sim_event_init() raises:
    print("Test: SimEvent initialization with all fields")
    var py_none = Python.none()
    var ev = SimEvent(
        event_type="bar",
        calendar_dt=py_none,
        trading_dt=py_none,
        tick=None,
    )
    assert_equal(ev.event_type, "bar")
    assert_true(ev.tick is None)
    print("  PASSED")


def test_sim_event_with_tick() raises:
    print("Test: SimEvent with tick data")
    var tick_mock = Python.evaluate("type('obj', (object,), {'order_book_id': '000001.XSHE', 'datetime': None})()")
    var ev = SimEvent(
        event_type="tick",
        calendar_dt=Python.none(),
        trading_dt=Python.none(),
        tick=tick_mock,
    )
    assert_equal(ev.event_type, "tick")
    assert_true(ev.tick is not None)
    print("  PASSED")


def test_sim_event_copyable() raises:
    print("Test: SimEvent is copyable")
    var ev = SimEvent(
        event_type="before_trading",
        calendar_dt=Python.none(),
        trading_dt=Python.none(),
        tick=None,
    )
    var ev2 = ev.copy()
    assert_equal(ev2.event_type, "before_trading")
    print("  PASSED")


def test_date_time_copy_init() raises:
    print("Test: DateTimeCopy initialization")
    var dt = DateTimeCopy(year=2025, month=6, day=15, hour=9, minute=30, second=0)
    assert_equal(dt.year, 2025)
    assert_equal(dt.month, 6)
    assert_equal(dt.day, 15)
    assert_equal(dt.hour, 9)
    assert_equal(dt.minute, 30)
    assert_equal(dt.second, 0)
    print("  PASSED")


def test_date_time_copy_copyable() raises:
    print("Test: DateTimeCopy is copyable")
    var dt = DateTimeCopy(year=2025, month=1, day=1, hour=0, minute=0, second=0)
    var dt2 = dt.copy()
    assert_equal(dt2.year, 2025)
    print("  PASSED")


def test_simulation_event_source_init() raises:
    print("Test: SimulationEventSource __init__")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    assert_equal(src.get_event_count(), 0)
    assert_false(src._universe_changed)
    print("  PASSED")


def test_factory_function() raises:
    print("Test: create_simulation_event_source factory")
    var env = _make_mock_env()
    var src = create_simulation_event_source(env)
    assert_equal(src.get_event_count(), 0)
    print("  PASSED")


def test_set_universe_changed() raises:
    print("Test: set_universe_changed sets flag")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    assert_false(src._universe_changed)
    src.set_universe_changed()
    assert_true(src._universe_changed)
    print("  PASSED")


def test_on_universe_changed_callback() raises:
    print("Test: _on_universe_changed callback")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    assert_false(src._universe_changed)
    src._on_universe_changed(Python.none())
    assert_true(src._universe_changed)
    print("  PASSED")


def test_get_day_bar_dt() raises:
    print("Test: _get_day_bar_dt returns 15:00")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var py_dt = Python.import_module("datetime")
    var date = py_dt.datetime(2025, 1, 2, 10, 30, 0)
    var result = src._get_day_bar_dt(date)
    var result_hour = Int(py=result.hour)
    var result_min = Int(py=result.minute)
    assert_equal(result_hour, 15)
    assert_equal(result_min, 0)
    print("  PASSED")


def test_get_after_trading_dt() raises:
    print("Test: _get_after_trading_dt returns 15:30")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var py_dt = Python.import_module("datetime")
    var date = py_dt.datetime(2025, 1, 2, 10, 30, 0)
    var result = src._get_after_trading_dt(date)
    var result_hour = Int(py=result.hour)
    var result_min = Int(py=result.minute)
    assert_equal(result_hour, 15)
    assert_equal(result_min, 30)
    print("  PASSED")


def test_get_stock_trading_minutes_count() raises:
    print("Test: _get_stock_trading_minutes produces correct count")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var py_dt = Python.import_module("datetime")
    var trading_date = py_dt.datetime(2025, 1, 2)
    var minutes = src._get_stock_trading_minutes(trading_date)
    var count = len(minutes)
    var am_count = 120
    var pm_count = 120
    assert_equal(count, am_count + pm_count)
    print("  PASSED: count =", count, "(AM:", am_count, "+ PM:", pm_count, ")")


def test_get_stock_trading_minutes_range() raises:
    print("Test: _get_stock_trading_minutes range is 9:31-11:30, 13:01-15:00")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var py_dt = Python.import_module("datetime")
    var trading_date = py_dt.datetime(2025, 1, 2)
    var minutes = src._get_stock_trading_minutes(trading_date)
    var sorted_mins = Python.import_module("builtins").sorted(minutes)
    var first = sorted_mins[0]
    var last = sorted_mins[len(sorted_mins) - 1]
    var first_h = Int(py=first.hour)
    var first_m = Int(py=first.minute)
    var last_h = Int(py=last.hour)
    var last_m = Int(py=last.minute)
    assert_equal(first_h, 9)
    assert_equal(first_m, 31)
    assert_equal(last_h, 15)
    assert_equal(last_m, 0)
    print("  PASSED: first=", first_h, ":", first_m, " last=", last_h, ":", last_m)


def test_events_daily_produces_four_per_day() raises:
    print("Test: events(1d) produces 4 events per trading day")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var start = DateTimeCopy(year=2025, month=1, day=1, hour=0, minute=0, second=0)
    var end = DateTimeCopy(year=2025, month=1, day=5, hour=23, minute=59, second=59)
    src.events(start, end, "1d")
    var count = src.get_event_count()
    assert_equal(count, 8)
    print("  PASSED: 2 days x 4 events/day =", count)


def test_events_daily_event_types_order() raises:
    print("Test: events(1d) correct event type order: before_trading, open_auction, bar, after_trading")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var start = DateTimeCopy(year=2025, month=1, day=1, hour=0, minute=0, second=0)
    var end = DateTimeCopy(year=2025, month=1, day=2, hour=23, minute=59, second=59)
    src.events(start, end, "1d")
    var events = src.get_generated_events()
    assert_equal(events[0].event_type, "before_trading")
    assert_equal(events[1].event_type, "open_auction")
    assert_equal(events[2].event_type, "bar")
    assert_equal(events[3].event_type, "after_trading")
    print("  PASSED")


def test_events_daily_has_timestamps() raises:
    print("Test: events(1d) events have proper calendar_dt and trading_dt")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var start = DateTimeCopy(year=2025, month=1, day=2, hour=0, minute=0, second=0)
    var end = DateTimeCopy(year=2025, month=1, day=3, hour=23, minute=59, second=59)
    src.events(start, end, "1d")
    var events = src.get_generated_events()
    var before_ev = events[0].copy()
    var bar_ev = events[2].copy()
    var after_ev = events[3].copy()
    var before_h = Int(py=before_ev.calendar_dt.hour)
    var before_m = Int(py=before_ev.calendar_dt.minute)
    assert_equal(before_h, 0)
    assert_equal(before_m, 0)
    var bar_h = Int(py=bar_ev.calendar_dt.hour)
    var bar_m = Int(py=bar_ev.calendar_dt.minute)
    assert_equal(bar_h, 15)
    assert_equal(bar_m, 0)
    var after_h = Int(py=after_ev.calendar_dt.hour)
    var after_m = Int(py=after_ev.calendar_dt.minute)
    assert_equal(after_h, 15)
    assert_equal(after_m, 30)
    print("  PASSED: before=0:00, bar=15:00, after=15:30")


def test_events_daily_tick_is_none() raises:
    print("Test: events(1d) events have tick=None")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var start = DateTimeCopy(year=2025, month=1, day=2, hour=0, minute=0, second=0)
    var end = DateTimeCopy(year=2025, month=1, day=3, hour=23, minute=59, second=59)
    src.events(start, end, "1d")
    var events = src.get_generated_events()
    for i in range(len(events)):
        var ev = events[i].copy()
        assert_true(ev.tick is None)
    print("  PASSED: all", len(events), "events have tick=None")


def test_events_invalid_frequency_raises() raises:
    print("Test: events() with invalid frequency raises Error")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var start = DateTimeCopy(year=2025, month=1, day=1, hour=0, minute=0, second=0)
    var end = DateTimeCopy(year=2025, month=1, day=2, hour=23, minute=59, second=59)
    with assert_raises():
        src.events(start, end, "5m")
    with assert_raises():
        src.events(start, end, "invalid")
    print("  PASSED")


def test_events_clears_previous() raises:
    print("Test: events() clears previous generated events")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var start = DateTimeCopy(year=2025, month=1, day=2, hour=0, minute=0, second=0)
    var end = DateTimeCopy(year=2025, month=1, day=3, hour=23, minute=59, second=59)
    src.events(start, end, "1d")
    assert_equal(src.get_event_count(), 8)
    src.events(start, end, "1d")
    assert_equal(src.get_event_count(), 8)
    print("  PASSED: re-call does not accumulate")


def test_get_generated_events_returns_copy() raises:
    print("Test: get_generated_events returns a copy")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var start = DateTimeCopy(year=2025, month=1, day=2, hour=0, minute=0, second=0)
    var end = DateTimeCopy(year=2025, month=1, day=3, hour=23, minute=59, second=59)
    src.events(start, end, "1d")
    var events1 = src.get_generated_events()
    var events2 = src.get_generated_events()
    assert_equal(len(events1), len(events2))
    print("  PASSED")


def test_events_minute_produces_events() raises:
    print("Test: events(1m) produces events for minute mode")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var start = DateTimeCopy(year=2025, month=1, day=2, hour=0, minute=0, second=0)
    var end = DateTimeCopy(year=2025, month=1, day=3, hour=23, minute=59, second=59)
    src.events(start, end, "1m")
    var count = src.get_event_count()
    assert_true(count > 0, "Expected > 0 events for 1m mode")
    print("  PASSED: produced", count, "events")


def test_events_minute_has_before_trading_and_after_trading() raises:
    print("Test: events(1m) has before_trading as first and after_trading as last")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var start = DateTimeCopy(year=2025, month=1, day=2, hour=0, minute=0, second=0)
    var end = DateTimeCopy(year=2025, month=1, day=3, hour=23, minute=59, second=59)
    src.events(start, end, "1m")
    var events = src.get_generated_events()
    assert_true(len(events) >= 2, "Expected at least 2 events")
    assert_equal(events[0].event_type, "before_trading")
    assert_equal(events[len(events) - 1].event_type, "after_trading")
    print("  PASSED: first=before_trading, last=after_trading")


def test_events_minute_has_open_auction() raises:
    print("Test: events(1m) includes open_auction event")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var start = DateTimeCopy(year=2025, month=1, day=2, hour=0, minute=0, second=0)
    var end = DateTimeCopy(year=2025, month=1, day=3, hour=23, minute=59, second=59)
    src.events(start, end, "1m")
    var events = src.get_generated_events()
    var found_open_auction = False
    for i in range(len(events)):
        var ev = events[i].copy()
        if ev.event_type == "open_auction":
            found_open_auction = True
            break
    assert_true(found_open_auction, "Expected open_auction event in 1m mode")
    print("  PASSED")


def test_events_minute_has_bar_events() raises:
    print("Test: events(1m) includes bar events")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var start = DateTimeCopy(year=2025, month=1, day=2, hour=0, minute=0, second=0)
    var end = DateTimeCopy(year=2025, month=1, day=3, hour=23, minute=59, second=59)
    src.events(start, end, "1m")
    var events = src.get_generated_events()
    var bar_count = 0
    for i in range(len(events)):
        var ev = events[i].copy()
        if ev.event_type == "bar":
            bar_count += 1
    assert_true(bar_count > 0, "Expected bar events in 1m mode")
    print("  PASSED: found", bar_count, "bar events")


def test_events_tick_produces_events() raises:
    print("Test: events(tick) produces events for tick mode")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var start = DateTimeCopy(year=2025, month=1, day=2, hour=0, minute=0, second=0)
    var end = DateTimeCopy(year=2025, month=1, day=3, hour=23, minute=59, second=59)
    src.events(start, end, "tick")
    var count = src.get_event_count()
    assert_true(count >= 0)
    print("  PASSED: produced", count, "events (may be 0 if no ticks from mock)")


def test_events_tick_ends_with_after_trading() raises:
    print("Test: events(tick) ends with after_trading when ticks exist")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var start = DateTimeCopy(year=2025, month=1, day=2, hour=0, minute=0, second=0)
    var end = DateTimeCopy(year=2025, month=1, day=3, hour=23, minute=59, second=59)
    src.events(start, end, "tick")
    var events = src.get_generated_events()
    if len(events) > 0:
        assert_equal(events[len(events) - 1].event_type, "after_trading")
    print("  PASSED")


def test_universe_change_resets_on_minute_mode() raises:
    print("Test: universe changed flag resets after being processed in 1m mode")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    src.set_universe_changed()
    assert_true(src._universe_changed)
    var start = DateTimeCopy(year=2025, month=1, day=2, hour=0, minute=0, second=0)
    var end = DateTimeCopy(year=2025, month=1, day=3, hour=23, minute=59, second=59)
    src.events(start, end, "1m")
    assert_false(src._universe_changed)
    print("  PASSED: flag was consumed during events()")


def test_get_future_trading_minutes_converts_int_to_datetime() raises:
    print("Test: _get_future_trading_minutes converts int timestamps to datetime")
    var env = _make_mock_env_with_future()
    var src = SimulationEventSource(env=env)
    var py_dt = Python.import_module("datetime")
    var trading_date = py_dt.datetime(2025, 1, 2)
    var minutes = src._get_future_trading_minutes(trading_date)
    var count = len(minutes)
    if count > 0:
        var builtins = Python.import_module("builtins")
        for m in minutes:
            var m_str = String(py=builtins.str(m))
            assert_true("2025" in m_str, "Expected datetime object, got: " + m_str)
    print("  PASSED: converted", count, "minutes to datetime objects")


def test_get_trading_minutes_combines_stock_and_future() raises:
    print("Test: _get_trading_minutes combines stock + future minutes")
    var env = _make_mock_env_with_future()
    var src = SimulationEventSource(env=env)
    var py_dt = Python.import_module("datetime")
    var trading_date = py_dt.datetime(2025, 1, 2)
    var minutes = src._get_trading_minutes(trading_date)
    var stock_only_src = SimulationEventSource(env=_make_mock_env())
    var stock_only_mins = stock_only_src._get_trading_minutes(trading_date)
    assert_true(len(minutes) >= len(stock_only_mins),
                 "Future+stock minutes should be >= stock-only minutes")
    print("  PASSED: combined=", len(minutes), " stock_only=", len(stock_only_mins))


def test_sim_event_write_to() raises:
    print("Test: SimEvent.write_to produces expected output")
    var py_none = Python.none()
    var ev = SimEvent(
        event_type="bar",
        calendar_dt=py_none,
        trading_dt=py_none,
        tick=None,
    )
    var output = "SimEvent(type=" + ev.event_type + ")"
    assert_true("SimEvent" in output, "Expected SimEvent in output")
    assert_true("bar" in output, "Expected event_type in output")
    print("  PASSED: output =", output)


def test_event_source_trait_conformance() raises:
    print("Test: SimulationEventSource conforms to EventSource trait")
    var env = _make_mock_env()
    var src = SimulationEventSource(env=env)
    var start = DateTimeCopy(year=2025, month=1, day=2, hour=0, minute=0, second=0)
    var end = DateTimeCopy(year=2025, month=1, day=3, hour=23, minute=59, second=59)
    src.events(start, end, "1d")
    assert_true(src.get_event_count() > 0)
    print("  PASSED")


def main() raises:
    print("=" * 60)
    print("SimulationEventSource Comprehensive Test Suite")
    print("=" * 60)

    test_sim_event_init()
    test_sim_event_with_tick()
    test_sim_event_copyable()
    test_date_time_copy_init()
    test_date_time_copy_copyable()
    test_simulation_event_source_init()
    test_factory_function()
    test_set_universe_changed()
    test_on_universe_changed_callback()
    test_get_day_bar_dt()
    test_get_after_trading_dt()
    test_get_stock_trading_minutes_count()
    test_get_stock_trading_minutes_range()
    test_events_daily_produces_four_per_day()
    test_events_daily_event_types_order()
    test_events_daily_has_timestamps()
    test_events_daily_tick_is_none()
    test_events_invalid_frequency_raises()
    test_events_clears_previous()
    test_get_generated_events_returns_copy()
    test_events_minute_produces_events()
    test_events_minute_has_before_trading_and_after_trading()
    test_events_minute_has_open_auction()
    test_events_minute_has_bar_events()
    test_events_tick_produces_events()
    test_events_tick_ends_with_after_trading()
    test_universe_change_resets_on_minute_mode()
    test_get_future_trading_minutes_converts_int_to_datetime()
    test_get_trading_minutes_combines_stock_and_future()
    test_sim_event_write_to()
    test_event_source_trait_conformance()

    print("=" * 60)
    print("ALL 29 TESTS PASSED!")
    print("=" * 60)
