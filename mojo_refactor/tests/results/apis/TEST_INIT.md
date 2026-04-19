# Test Result: apis/__init__.mojo

## Test Date: 2026-04-19

## Summary

| Metric | Value |
|--------|-------|
| Total Tests | 23 (13 legacy + 10 new) |
| Passed | 23 |
| Failed | 0 |
| Skipped | 0 |
| Warnings | 0 (in test code) |
| Status | **ALL PASSED** |

## Files Modified (8 files, 15+ bugs fixed)

### Core Bug Fixes

| File | Bug | Fix |
|------|-----|-----|
| **broker.mojo** | `submit_order` had extra `account` param (trait mismatch) | Store account internally via `set_account()`, match Broker trait signature |
| **broker.mojo** | `cancel_order` took `Int` instead of `Order` | Changed to accept Order, look up by order_id internally |
| **broker.mojo** | `get_open_orders` missing optional filter param | Added `order_book_id: Optional[String] = None` |
| **broker.mojo** | Dict.values() returns refs, can't append non-copyable | Added `.copy()` for each order in iteration |
| **broker.mojo** | `if let acc = ...` invalid Mojo syntax | Changed to `if self._account is not None:` + `.value().copy()` for aliasing safety |
| **broker.mojo** | `order.price` unknown overload | Changed to `order.price()` method call |
| **event_source.mojo** | `events()` missing 3 required params from EventSource trait | Added `(start_date, end_date, frequency)` params |
| **account.mojo** | `trade.price` field doesn't exist on Trade struct | → `trade.last_price` (2 occurrences) |
| **account.mojo** | `trade.position_direction` doesn't exist | → `trade.position_direction_val` (2 occurrences) |
| **position.mojo** | `trade.price` used in 5 places for trade amount calc | → `trade.last_price` (5 occurrences) |
| **environment.mojo** | `submit_order(order, account)` with 2 args vs broker's new signature | Split into `set_account(account)` + `submit_order(order)` |
| **environment.mojo** | `return order` on non-ImplicitlyCopyable type | → `return order.copy()` |
| **environment.mojo** | `EVENT.ORDER_CREATION_REJECT()` called as function | EVENT is comptime value, not callable → removed `()` |
| **environment.mojo** | Internal `Portfolio` shadowed real one from portfolio_manager | Renamed to `EnvPortfolio` + updated all references |
| **environment.mojo** | Missing `raises` propagation chain | `can_submit_order`→`submit_order`→`order_target_portfolio` all got `raises` |
| **order_target_portfolio.mojo** | `orders.append(result)` where result is `Optional[Order]` | Added `if result is not None: orders.append(result.value().copy())` |
| **portfolio_manager.mojo** (top-level) | Missing `get_position` method needed by api_base | Added stub delegating to `create_position()` |
| **api_base.mojo** | Imported Portfolio from wrong module (shadowed) | Changed to import from top-level `portfolio_manager` |

### Architecture Fixes

| Issue | Impact | Resolution |
|-------|--------|------------|
| **Triple Portfolio name collision**: environment's internal `Portfolio`, top-level `portfolio_manager.Portfolio`, and `portfolio/portfolio_manager.Portfolio` all shared the same name | Type confusion, compiler resolved to wrong type | Renamed environment's version to `EnvPortfolio`; unified api_base import path |
| **Broker trait conformance broken**: SimulationBroker didn't implement Broker trait correctly | Could not use polymorphically through interface | Fixed all 3 method signatures + copy semantics |
| **EventSource trait conformance broken**: Missing params prevented polymorphic usage | Same as above | Added required params to events() |

## New Test Coverage (10 tests)

| Category | Tests | Coverage |
|----------|-------|----------|
| Import verification | 1 | All API functions importable |
| Broker trait | 4 | submit_order, cancel_order, get_open_orders(with filter), set_account |
| EventSource trait | 2 | creation, events() with params, start/stop lifecycle |
| Environment | 1 | EnvPortfolio renamed, create_env_portfolio works |
| Trade fields | 1 | last_price and position_direction_val correct names |
| Portfolio consistency | 1 | Top-level Portfolio has get_position |
| Integration | 1 | order_target_portfolio end-to-end with raises |

## Python vs Mojo Import Comparison

| Source | Imports | Notes |
|--------|---------|-------|
| Python `rqalpha/apis/__init__.py` | api_abstract, api_base, api_rqdatac, api_stock (×2 duplicate) | 3 core + 1 mod |
| Mojo `rqmojo/apis/__init__.mojo` | names, api_base, api_abstract, api_rqdatac, api_stock, api_future, order_target_portfolio | 3 core + 3 mod + 1 names |
| **Delta** | +names, +api_future, +order_target_portfolio | Intentional additions per dependency analysis doc; duplicate line fixed |

## Legacy Tests (13 tests - group_10/test_apis_init.mojo)

All pass: cancel_order, order_shares, order_value, order_percent, order_target_value, order_target_percent, get_position, get_portfolio, get_trading_dates, get_previous_trading_date, get_next_trading_date, get_price, history
