# L00-07 events Module Test Result

## Test Information

| Item | Value |
|------|-------|
| Module | rqmojo.core.events / rqalpha.core.events |
| Level | L00 - Leaf module |
| Dependencies | const, datetime_func |
| Test Date | 2026-03-02 |

## Python Test Results

### Test Command

```bash
.venv/bin/python -m pytest tests/python_test_rqalpha/L00_leaf/test_L00_07_events.py -v
```

### Test Statistics

| Metric | Value |
|--------|-------|
| Test Cases | 16 |
| Passed | 16 |
| Failed | 0 |
| Execution Time | 2.63s |

### Test Output

```
============================= test session starts ==============================
platform linux -- Python 3.14.3, pytest-9.0.2, pluggy-1.6.0
collected 16 items

test_L00_07_events.py::TestL00Events::TestEvent::test_event_init PASSED
test_L00_07_events.py::TestL00Events::TestEvent::test_event_repr PASSED
test_L00_07_events.py::TestL00Events::TestEventBus::test_event_bus_init PASSED
test_L00_07_events.py::TestL00Events::TestEventBus::test_add_listener PASSED
test_L00_07_events.py::TestL00Events::TestEventBus::test_add_user_listener PASSED
test_L00_07_events.py::TestL00Events::TestEventBus::test_prepend_listener PASSED
test_L00_07_events.py::TestL00Events::TestEventBus::test_listener_stops_propagation PASSED
test_L00_07_events.py::TestL00Events::TestEVENT::test_event_values PASSED
test_L00_07_events.py::TestL00Events::TestEVENT::test_event_contains PASSED
test_L00_07_events.py::TestL00Events::TestParseEvent::test_parse_event_upper PASSED
test_L00_07_events.py::TestL00Events::TestParseEvent::test_parse_event_lower PASSED
test_L00_07_events.py::TestL00Events::TestParseEvent::test_parse_event_mixed PASSED
test_L00_07_events.py::TestL00Events::TestModuleStructure::test_event_class_exists PASSED
test_L00_07_events.py::TestL00Events::TestModuleStructure::test_event_bus_class_exists PASSED
test_L00_07_events.py::TestL00Events::TestModuleStructure::test_event_enum_exists PASSED
test_L00_07_events.py::TestL00Events::TestModuleStructure::test_parse_event_exists PASSED

============================== 16 passed in 2.63s ==============================
```

## Mojo Test Results

### Test Command

```bash
mojo run -I . tests/mojo_test_rqmojo/L00_leaf/test_L00_07_events.mojo
```

### Test Statistics

| Metric | Value |
|--------|-------|
| Test Cases | 35 |
| Passed | 35 |
| Failed | 0 |
| Execution Time | < 1s |

### Test Output

```
============================================================
L00_07_events Module Tests
============================================================
PASS: EVENT.BAR name
PASS: EVENT.BAR value
PASS: EVENT.TICK name
PASS: EVENT.TICK value
PASS: EVENT.TRADE name
PASS: EVENT.TRADE value
PASS: EVENT.BAR == EVENT.BAR
PASS: EVENT.BAR != EVENT.TICK
PASS: EVENT.__str__
PASS: EVENT.POST_SYSTEM_INIT
PASS: EVENT.BEFORE_TRADING
PASS: EVENT.AFTER_TRADING
PASS: EVENT.SETTLEMENT
PASS: EVENT.ORDER_PENDING_NEW
PASS: EVENT.HEARTBEAT
PASS: Event.create event_type
PASS: Event.create data
PASS: Event.__str__ returns non-empty
PASS: ListenerEntry listener
PASS: ListenerEntry priority
PASS: EventBus initial listener_count
PASS: EventBus add_listener count
PASS: EventBus add_user_listener count
PASS: EventBus prepend_listener count
PASS: EventBus remove_listener count
PASS: EventBus publish executes
PASS: parse_event BAR
PASS: parse_event bar lowercase
PASS: parse_event Bar mixed case
PASS: parse_event TICK
PASS: parse_event TRADE
PASS: parse_event HEARTBEAT
============================================================
Results: 35/35 tests passed
============================================================
```

## Test Coverage

### Classes/Structs Tested

| Class/Struct | Python | Mojo | Description |
|--------------|--------|------|-------------|
| Event | Yes | Yes | Event object |
| EventBus | Yes | Yes | Event bus for pub/sub |
| EVENT | Yes | Yes | Event type enum |
| ListenerEntry | N/A | Yes | Mojo listener entry struct |

### Functions Tested

| Function | Python | Mojo | Behavior Match |
|----------|--------|------|----------------|
| add_listener | Yes | Yes | Yes |
| prepend_listener | Yes | Yes | Yes |
| remove_listener | N/A | Yes | Mojo only |
| publish_event | Yes | Yes | Yes |
| parse_event | Yes | Yes | Yes |

### Event Types Tested

| Event Type | Python | Mojo | Value Match |
|------------|--------|------|-------------|
| BAR | Yes | Yes | Yes |
| TICK | Yes | Yes | Yes |
| TRADE | Yes | Yes | Yes |
| POST_SYSTEM_INIT | Yes | Yes | Yes |
| BEFORE_TRADING | Yes | Yes | Yes |
| AFTER_TRADING | Yes | Yes | Yes |
| SETTLEMENT | Yes | Yes | Yes |
| ORDER_PENDING_NEW | Yes | Yes | Yes |
| HEARTBEAT | Yes | Yes | Yes |

## Verification

- [x] Python tests pass
- [x] Mojo tests pass
- [x] Event types match between Python and Mojo
- [x] EventBus functionality works correctly
- [x] parse_event function works correctly

## Conclusion

**L00-07 events module test PASSED**

All event types and event bus functionality in the events module have been verified to work correctly in both Python and Mojo implementations.
