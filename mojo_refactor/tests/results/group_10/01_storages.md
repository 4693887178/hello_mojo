# Test Results: data/base_data_source/storages.mojo

**Group 10 - File 1**
**Date:** 2026-04-20
**Source:** `rqalpha/data/base_data_source/storages.py` -> `rqmojo/data/base_data_source/storages.mojo`

## Summary

| Suite | Total | Passed | Failed | Skipped |
|-------|-------|--------|--------|---------|
| Mojo (test_storages.mojo) | 21 | **21** | 0 | 0 |
| Python (test_storages.py) | 8 | **8** | 0 | 0 |
| **Total** | **29** | **29** | **0** | **0** |

**Status: ✅ ALL TESTS PASSED**

---

## Mojo Test Details (21 tests)

### FuturesTradingParameters (3 tests)
- `test_futures_trading_params_fields` - All 6 fields: close_commission_ratio, close_commission_today_ratio, commission_type, open_commission_ratio, long_margin_ratio, short_margin_ratio
- `test_futures_trading_params_copyable` - Copy semantics preserve all values
- `test_futures_trading_params_by_volume` - BY_VOLUME commission type works correctly

### FutureInfoStore (9 tests)
- `test_future_info_store_creation` - JSON loading + margin_rate validation
- `test_future_info_store_get_future_info_by_money` - BY_MONEY type: all ratios correct (0.00002/0.00003/0.00004/0.15)
- `test_future_info_store_get_future_info_by_volume` - BY_VOLUME type: open/close = 23.0
- `test_future_info_store_get_tick_size` - Returns 0.2 for both IF and IC instruments
- `test_future_info_store_cache_works` - Second call returns same cached value
- `test_future_info_store_custom_override` - custom_future_info overrides default open_commission_ratio to 999.99
- `test_future_info_store_lookup_by_underlying` - Finds correct instrument by order_book_id
- `test_future_info_store_raises_on_unknown` - Raises on completely unknown instrument
- `test_future_info_store_tick_size_raises_on_unknown` - get_tick_size raises on unknown

### ShareTransformationStore (2 tests)
- `test_share_transformation_store_found` - Returns non-None for known order_book_id
- `test_share_transformation_store_not_found` - Returns None for unknown order_book_id

### Store Creation Tests (7 tests)
- `test_day_bar_store_creation` - DayBarStore instantiates with path
- `test_future_day_bar_store_creation` - FutureDayBarStore extends DayBarStore
- `test_dividend_store_creation` - DividendStore instantiates
- `test_simple_factor_store_creation` - SimpleFactorStore instantiates
- `test_date_set_creation` - DateSet from PythonObject h5 handle
- `test_exchange_trading_calendar_store_creation` - From numpy array input
- `test_file_path_linux_returns_string` - _file_path returns string on Linux

---

## Python Test Details (8 tests)

All 8 Python reference tests passed:
- FuturesTradingParameters NamedTuple field validation
- FutureInfoStore interface existence (get_future_info, get_tick_size)
- All 9 store classes exist
- open_h5 / h5_file functions are callable
- DayBarStore.DEFAULT_DTYPE has correct fields
- FutureDayBarStore.DEFAULT_DTYPE includes open_interest
- ShareTransformationStore returns tuple pattern
- DateSet.contains date conversion behavior

---

## Key Fixes Applied to storages.mojo

| # | Issue | Fix |
|---|-------|-----|
| 1 | `FutureInfoStore.get_tick_size` took `Instrument` param | Changed to `(order_book_id, underlying_symbol): String` for standalone mode |
| 2 | `_to_namedtuple` didn't remove margin_rate/tick_size/order_book_id properly | Fixed key removal sequence matching Python original |
| 3 | `ShareTransformationStore.get_share_transformation` returned raw dict | Changed to return `Optional[PythonObject]` (Python tuple) |
| 4 | `DayBarStore/FutureDayBarStore` missing DEFAULT_DTYPE concept | Added explicit dtype construction via `np.dtype(list_of_tuples)` |
| 5 | `YieldCurveStore.get_yield_curve` missing index/del logic | Added `df.index = pandas.to_datetime(...)` + `df.drop("date", axis=1)` |
| 6 | `DateSet.contains` simplified _to_dt_int logic | Added proper `d > 100000000 ? d // 1000000 : d` conversion |
| 7 | `open_h5` missing error handling | Added try/except with descriptive error message |
| 8 | Optional[PythonObject] type narrowing not supported in Mojo | Used try/except dict access pattern instead of .get() + if-not-None |
| 9 | `np.dtype([...])` variadic args issue | Used list-of-tuples construction via py.list() |
| 10 | `del df["date"]` syntax invalid in Mojo | Replaced with `df.drop("date", axis=1)` |

## Design Differences from Python Original

| Aspect | Python | Mojo | Notes |
|--------|--------|------|-------|
| lru_cache | `@lru_cache(1024/8)` decorator | Manual `Dict[String, T]` cache | Same semantics, explicit management |
| Context manager | `@contextmanager h5_file()` | Explicit `h5_file()` returns object, caller closes | No context manager protocol in Mojo yet |
| Type narrowing | `if x is not None:` narrows type | Does NOT narrow; use try/except or separate paths | Fundamental Mojo type system difference |
| NamedTuple | `FuturesTradingParameters(NamedTuple)` | `@fieldwise_init struct` with Copyable | Struct is more type-safe |
| HDF5 dtype | `[("name", "type"), ...]` literal list | `np.dtype(py_list_of_tuples)` | Variadic args limitation workaround |

## Compilation Verification

```
mojo build rqmojo/data/base_data_source/storages.mojo -> ✅ 0 errors, 2 warnings (unused 'py' variables, harmless)
```
