# Test Results: Mojo sys_transaction_cost (deciders.mojo)

**Date**: 2026-04-18  
**File**: `rqmojo/mod/rqmojo_mod_sys_transaction_cost/deciders.mojo`  
**Test File**: `tests/mojo/group_05/test_transaction_cost_deciders.mojo`

## Summary

| Metric | Value |
|--------|-------|
| Total Tests | **27** |
| Passed | **27** |
| Failed | 0 |
| Skipped | 0 |
| Warnings | **0** |

## Test Results by Category

### StockTransactionCostDecider (16 tests)
- Default init values (commission_rate=0.0008, min_commission=5.0, tax_rate=0.0005)
- Custom init with all parameters
- order_id=0: no tracking, max(cost, min)
- order_id=0 small trade: clamped to min
- First large trade on order: full cost returned
- Second trade after large first: remaining=0, full cost
- First small trade: collect min early
- Second after min collected: returns 0
- BUY side tax = 0
- SELL side tax > 0
- Non-BUY side tax calculation
- update_tax_rate before PIT → 0.001
- update_tax_rate after PIT → 0.0005
- calc() returns TransactionCost with correct fields
- commission_multiplier scales correctly
- Different orders track independently

### FutureTransactionCostDecider (5 tests)
- Default init (multiplier=1.0, hedge_type=0)
- BY_MONEY OPEN position calculation
- BY_MONEY CLOSE with partial today close
- BY_VOLUME OPEN by lot count
- multiplier scales commission

### BondTransactionCostDecider (3 tests)
- Default init
- Simple price * quantity * multiplier
- Custom multiplier

### Factory Functions (3 tests)
- create_stock_decider()
- create_future_decider()
- create_bond_decider()

## Fixes Applied vs Previous Version

| # | Issue | Fix |
|---|-------|-----|
| 1 | Missing `commission_rate` field (was using only multiplier) | Added `commission_rate=0.0008`, proper rate*multiplier formula |
| 2 | No per-order commission tracking (`commission_map`) | Added `Dict[Int, Float64]` with full algorithm |
| 3 | Simplified _calc_commission (just clamp) | Implemented full 4-branch algorithm matching Python original |
| 4 | No PIT tax support / `update_tax_rate()` | Added `update_tax_rate(before_pit_change_date)` method |
| 5 | Tax only checked SELL, not BUY properly | Fixed: BUY→0, all others calculate tax |
| 6 | Futures: simple price*qty, no BY_MONEY/BY_VOLUME | Added full BY_MONEY and BY_VOLUME modes with ratio params |
| 7 | @fieldwise_init + explicit __init__ conflict | Removed redundant decorators, used correct pattern |
| 8 | SIDE.UNKNOWN doesn't exist in Mojo const | Changed to SIDE.FINANCING for non-BUY test |
