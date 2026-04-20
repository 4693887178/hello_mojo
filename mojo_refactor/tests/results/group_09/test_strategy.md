# Test Results: strategy.mojo / strategy.py

**Date**: 2026-04-19
**File**: `rqmojo/core/strategy.mojo` (Mojo) / `rqalpha/core/strategy.py` (Python)
**Group**: 09 - File 9

## Summary

| Test Suite | Total | Passed | Failed | Skipped |
|-----------|-------|--------|--------|---------|
| Mojo (test_strategy.mojo) | 29 | 29 | 0 | 0 |
| Python (test_strategy.py) | 31 | 31 | 0 | 0 |
| **Total** | **60** | **60** | **0** | **0** |

**Status**: ✅ ALL TESTS PASSED

## Mojo Tests (29 passed)

### Strategy Trait & BaseStrategy
- `test_strategy_trait_exists` - Trait definition verified
- `test_base_strategy_init` - Default creation works
- `test_base_strategy_with_custom_name` - Custom name assignment
- `test_base_strategy_default_name` - Default name is "BaseStrategy"
- `test_base_strategy_str_representation` - String output contains name
- `test_base_strategy_empty_universe` - Initial universe is empty set
- `test_base_strategy_user_context_returns_context` - user_context() returns valid context

### StrategyCallbacks
- `test_callback_creation_defaults` - All 6 flags default to False
- `test_callback_write_to` - write_to contains all field names

### Registration Methods
- `test_register_init` - Sets has_init=True
- `test_register_before_trading` - Sets has_before_trading=True
- `test_register_handle_bar` - Sets has_handle_bar=True
- `test_register_handle_tick` - Sets has_handle_tick=True
- `test_register_after_trading` - Sets has_after_trading=True
- `test_register_open_auction` - Sets has_open_auction=True
- `test_register_all_callbacks` - All 6 flags True when all registered

### Call Methods (no-op defaults)
- `test_call_init_noop`
- `test_call_before_trading_noop`
- `test_call_handle_bar_noop`
- `test_call_handle_tick_noop`
- `test_call_after_trading_noop`
- `test_call_open_auction_noop`

### Universe Management
- `test_update_universe` - Replaces current universe with new set

### Event Handler Wrapping
- `test_wrap_user_event_handler` - Returns "wrapped_" prefixed name

### StrategyEventWrapper
- `test_event_wrapper_creation` - Empty registered_events on creation
- `test_event_wrapper_str` - String representation valid
- `test_event_wrapper_register_no_events` - No callbacks = no events
- `test_event_wrapper_register_before_trading` - Registers 1 event
- `test_event_wrapper_register_all_events` - Registers 5 events

## Python Tests (31 passed)

### Class Structure (9 tests)
- `test_strategy_class_exists` through `test_strategy_has_user_context_property`

### __init__ Behavior (8 tests)
- User context storage, empty universe, scope extraction for all 6 handlers, None for missing

### Event Registration (7 tests)
- Registers BEFORE_TRADING/BAR/TICK/AFTER_TRADING/OPEN_AUCTION when handler present
- No registration when handler missing

### User Context (1 test)
- Property returns stored _user_context

### run_when_strategy_not_hold Decorator (2 tests)
- Executes when is_hold=False, skips when is_hold=True

### wrap_user_event_handler (2 tests)
- Returns callable, calls original with user_context as first arg

### init() Lifecycle Method (3 tests)
- Calls user init if defined, publishes POST_USER_INIT event, safe when no user init

## Key Differences Between Python and Mojo

| Feature | Python | Mojo |
|---------|--------|------|
| Dynamic scope dict | Extracts functions from dict at runtime | Static callback flags (StrategyCallbacks) |
| @run_when_strategy_not_hold decorator | Function decorator wrapping | Standalone function taking fn + env |
| wrap_user_event_handler | Returns closure injecting user_context | Returns "wrapped_" prefixed string name |
| Event registration | Directly on EventBus in __init__ | Via StrategyEventWrapper.register_events() |
| user_context | Stored reference from constructor | Factory-created via create_environment/create_strategy_context |
| Config access | config.extra.is_hold | config().is_hold (method call) |
