# OrderTargetPortfolio Test Results

**Date**: 2026-04-20
**File**: `rqmojo/mod/rqmojo_mod_sys_accounts/api/order_target_portfolio.mojo`
**Test File**: `tests/mojo/unit_tests/test_order_target_portfolio.mojo`

## Summary

| Metric | Value |
|--------|-------|
| Total Tests | 43 |
| Passed | 43 |
| Failed | 0 |
| Skipped | 0 |
| Pass Rate | **100%** |
| Execution Time | ~306.6s |

## Test Categories

### DenialReason (3 tests)
- `test_denial_reason_creation` - PASS
- `test_denial_reason_copy` - PASS
- `test_denial_reason_fields` - PASS

### ExchangeRatePair (4 tests)
- `test_exchange_rate_pair_creation` - PASS
- `test_exchange_rate_pair_get_middle` - PASS
- `test_exchange_rate_pair_copy` - PASS
- `test_exchange_rate_pair_fields` - PASS

### TargetPortfolioItem (3 tests)
- `test_target_item_creation` - PASS
- `test_target_item_copy` - PASS
- `test_target_item_with_denial_reason` - PASS

### AdjustingResult (5 tests)
- `test_adjusting_result_creation` - PASS
- `test_adjusting_result_with_denials` - PASS
- `test_adjusting_result_multiple_denials` - PASS
- `test_adjusting_result_copy` - PASS
- `test_adjusting_result_sell_quantity` - PASS

### _round_order_quantity_for_portfolio (8 tests)
- `test_round_lot_size_1_no_round` - PASS
- `test_round_positive_quantity` - PASS
- `test_round_negative_quantity` - PASS
- `test_round_exact_multiple` - PASS
- `test_round_zero_quantity` - PASS
- `test_round_small_positive` - PASS
- `test_round_small_negative` - PASS
- `test_round_lot_200_positive` - PASS
- `test_round_lot_200_negative` - PASS

### MockAccountForTest / MockPositionForTest (6 tests)
- `test_mock_position_creation` - PASS
- `test_mock_position_short_direction` - PASS
- `test_mock_account_creation` - PASS
- `test_mock_account_get_position_exists` - PASS
- `test_mock_account_get_position_not_found` - PASS
- `test_mock_account_multiple_positions` - PASS

### OrderTargetPortfolio Integration (14 tests)
- `test_order_target_portfolio_basic_buy` - PASS (~305.9s)
- `test_order_target_portfolio_multi_stock` - PASS
- `test_order_target_portfolio_zero_cash` - PASS
- `test_order_target_portfolio_insufficient_cash` - PASS
- `test_order_target_portfolio_smart_basic` - PASS
- `test_order_target_portfolio_smart_safety_factor` - PASS
- `test_order_target_portfolio_round_lot_disabled` - PASS
- `test_order_target_portfolio_empty_weights` - PASS
- `test_order_target_portfolio_single_full_invest` - PASS
- `test_order_target_portfolio_very_small_weight` - PASS
- `test_order_target_portfolio_high_price_stock` - PASS
- `test_order_target_portfolio_result_items_match_weights` - PASS
- `test_order_target_portfolio_quantity_is_int` - PASS

## Implementation Details

### Structs Implemented
1. **DenialReason(Copyable, Movable, Writable)** - Code/message pair for order rejection
2. **ExchangeRatePair(Copyable, Movable, Writable)** - Forex rate with base/target/middle_price
3. **TargetPortfolioItem(Copyable, Movable, Writable)** - Result item with order_book_id/weight/qty/amount/reason
4. **AdjustingResult(Copyable, Movable, Writable)** - Per-stock adjustment result with denial reasons list
5. **OrderTargetPortfolio(Movable)** - Core class with full portfolio adjustment logic
6. **MockAccountForTest / MockPositionForTest** - Test doubles for isolated unit testing

### Key Features
- Full `_calc_adjusting()` pipeline: weight -> amount -> quantity -> closable adjustment
- Suspension check via `instrument.listed_at()` + `data_proxy.is_sufficient()`
- Insufficient cash detection with lot-size-aware affordable quantity
- Not-enough-sellable position check
- Lot size rounding (`round_lot()`) with configurable enable/disable
- Safety factor iteration loop in `__call__()` for smart rebalancing
- Exchange rate support via `ExchangeRatePair` dictionary
- Direction multiplier for LONG(+1)/SHORT(-1) positions

### Compilation Fixes Applied
1. `var` parameter convention for owned-by-value transfer in constructors and API functions
2. DataProxy reference chaining resolved by calling methods inline on `self._env.data_proxy()`
3. Instrument field names corrected: `lot_size` -> `round_lot()`, `listed` -> `listed_at(dt)`
4. Account field access: `total_value()` (field not method), `cash` -> `total_cash`
5. POSITION_DIRECTION.value is String; added `_direction_multiplier()` helper returning Int
6. Added Copyable trait to AdjustingResult for Dict storage
7. Dict value access uses `.copy()` for Copyable types
8. Removed `@property` (not valid in Mojo), renamed to `get_middle()`
9. `create_environment()` requires explicit start_date/end_date DateTime arguments
