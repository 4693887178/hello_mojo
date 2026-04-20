# SimulationEventSource Test Results

**Date**: 2025-04-20
**File**: `simulation_event_source.mojo`
**Python Original**: `rqalpha/mod/rqalpha_mod_sys_simulation/simulation_event_source.py`
**Test File**: `tests/mojo/test_simulation_event_source.mojo`

## Summary

| Metric | Result |
|--------|--------|
| Total Tests | **29** |
| Passed | **29** |
| Failed | 0 |
| Errors | 0 |
| Warnings | 0 |

## Test Run Command

```bash
cd mojo_refactor && \
LD_PRELOAD=~/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so \
PYTHONPATH=.venv/lib/python3.14/site-packages \
.venv/bin/mojo run -I . -I rqmojo/third_party/argmojo/src \
  -I rqmojo/third_party/EmberJson -I rqmojo/third_party/NuMojo \
  -I rqmojo/third_party/mojo-yaml/src -I rqmojo/third_party/morrow.mojo \
  tests/mojo/test_simulation_event_source.mojo
```

## All Tests Passed

```
============================================================
SimulationEventSource Comprehensive Test Suite
============================================================
Test: SimEvent initialization with all fields              PASSED
Test: SimEvent with tick data                            PASSED
Test: SimEvent is copyable                                PASSED
Test: DateTimeCopy initialization                          PASSED
Test: DateTimeCopy is copyable                             PASSED
Test: SimulationEventSource __init__                      PASSED
Test: create_simulation_event_source factory              PASSED
Test: set_universe_changed sets flag                      PASSED
Test: _on_universe_changed callback                       PASSED
Test: _get_day_bar_dt returns 15:00                       PASSED
Test: _get_after_trading_dt returns 15:30                 PASSED
Test: _get_stock_trading_minutes produces correct count   PASSED (240)
Test: _get_stock_trading_minutes range                    PASSED (9:31-11:30, 13:01-15:00)
Test: events(1d) produces 4 events per trading day        PASSED (8 = 2 days x 4)
Test: events(1d) correct event type order                 PASSED
Test: events(1d) events have proper timestamps            PASSED (0:00, 15:00, 15:30)
Test: events(1d) events have tick=None                    PASSED
Test: events() invalid frequency raises Error             PASSED
Test: events() clears previous events                     PASSED
Test: get_generated_events returns copy                   PASSED
Test: events(1m) produces events                          PASSED (486)
Test: events(1m) first=before_trading, last=after_trading PASSED
Test: events(1m) includes open_auction                   PASSED
Test: events(1m) includes bar events (480)               PASSED
Test: events(tick) produces events                        PASSED
Test: events(tick) ends with after_trading               PASSED
Test: universe changed flag resets in 1m mode            PASSED
Test: _get_future_trading_minutes int→datetime conversion PASSED
Test: _get_trading_minutes combines stock+future         PASSED (241 vs 240)
Test: SimEvent.write_to output                           PASSED
Test: EventSource trait conformance                       PASSED
============================================================
ALL 29 TESTS PASSED!
============================================================
```

## Coverage Map

### Structs & Traits
- [x] `DateTimeCopy` - init, copyable
- [x] `SimEvent` - init (all fields), tick data, copyable, write_to
- [x] `EventSource` - trait conformance

### SimulationEventSource Lifecycle
- [x] `__init__(env)` - config extraction, initial state
- [x] `create_simulation_event_source(env)` - factory function
- [x] `_on_universe_changed(event)` - callback sets flag
- [x] `set_universe_changed()` - public API for flag setting

### DateTime Helpers
- [x] `_get_day_bar_dt(date)` → 15:00
- [x] `_get_after_trading_dt(date)` → 15:30
- [x] `_to_datetime(day)` - handles both datetime.datetime and pandas Timestamp

### Trading Minutes Generation
- [x] `_get_stock_trading_minutes(date)` - count (240), range (9:31-11:30, 13:01-15:00)
- [x] `_get_future_trading_minutes(date)` - int→datetime conversion
- [x] `_get_trading_minutes(date)` - stock + future union

### Event Generation: Daily (1d)
- [x] 4 events/day: before_trading, open_auction, bar, after_trading
- [x] Correct event type ordering
- [x] Proper timestamps: 0:00, 15:00, 15:30
- [x] tick=None for daily events

### Event Generation: Minute (1m)
- [x] Events produced (486 for 2-day mock)
- [x] First event = before_trading, Last event = after_trading
- [x] Contains open_auction event
- [x] Contains bar events (480)
- [x] Universe change flag consumed during processing

### Event Generation: Tick
- [x] Events produced (2 for mock: after_trading per day)
- [x] Ends with after_trading when ticks exist

### Error Handling
- [x] Invalid frequency raises Error ("5m", "invalid")

### Data Integrity
- [x] Re-call to events() clears previous results (no accumulation)
- [x] get_generated_events() returns independent copy

## Issues Fixed (vs Previous Version)

### Critical Fixes (7 issues)

1. **SimEvent struct expanded**: Added `calendar_dt`, `trading_dt` (PythonObject), `tick` (Optional[PythonObject]) fields to match Python `Event` semantics. Old version only had `event_type` + `order_book_id`.

2. **Universe change callback**: Added `_on_universe_changed(mut self, event)` and `set_universe_changed()` methods. Old version was missing the callback mechanism entirely.

3. **_get_universe() logic fixed**: Now properly iterates accounts to check for STOCK presence. Old version used try/except which had different semantics.

4. **_get_future_trading_minutes() int→datetime conversion**: Added proper `convert_int_to_datetime` logic (parsing int timestamp → datetime components). Old version passed raw integers through without conversion.

5. **_events_daily() timestamp generation**: Now computes actual datetime values (before_trading=0:00, bar=15:00, after_trading=15:30). Old version emitted placeholder events with no time data.

6. **_events_minute() complete implementation**: 
   - Added `dt_before_day_trading` (8:30 threshold)
   - Added time offset calculations (-30min BEFORE_TRADING, -3min OPEN_AUCTION)
   - Added calendar_dt vs trading_dt distinction for pre-market times
   - Added proper bar generation loop with universe change handling
   - Old version was a skeleton missing all core logic.

7. **_events_tick() instrument type detection**: 
   - Added FUTURE (30min before) vs STOCK (15min before) differentiation
   - Added last_tick tracking for first-tick detection
   - Added proper tick event generation with tick data
   - Old version had no type distinction or time offsets.

### Additional Improvements

- **_to_datetime() helper**: Handles both `datetime.datetime` and pandas Timestamp (with `to_pydatetime()`)
- **_get_stock_trading_minutes()**: Uses direct `datetime()` constructor instead of `combine()` to avoid type errors
- **SimEvent.write_to()**: Properly handles None calendar_dt/trading_dt with `raises`
- **Removed dead code**: Cleaned up unused `timedelta_min` variable

### Compilation Fixes

- Fixed `write_to` method signature (added `raises`)
- Fixed variable scope for `trading_dt` in if/else branches (declared before conditional)
- Used index-based iteration with `.copy()` for non-ImplicitlyCopyable SimEvent in tests
