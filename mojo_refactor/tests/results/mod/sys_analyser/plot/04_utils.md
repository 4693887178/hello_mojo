# Test Results: plot/utils.mojo (Group 07 - File 04)

## Summary

| Test Suite | Total | Passed | Failed | Skipped |
|-----------|-------|--------|--------|---------|
| Mojo (`std.testing`) | 39 | 39 | 0 | 0 |
| Python (`pytest`) | 17 | 17 | 0 | 0 |
| **Total** | **56** | **56** | **0** | **0** |

## Files Modified

### Source Code
- `mojo_refactor/rqmojo/mod/rqmojo_mod_sys_analyser/plot/utils.mojo` — Fixed algorithm bugs, added `raises`, fixed docstrings
- `mojo_refactor/rqmojo/mod/rqmojo_mod_sys_analyser/plot/consts.mojo` — Added `IndexRange.new()` static method, added `List` import

### Test Files
- `mojo_refactor/tests/mojo/group_07/test_plot_utils.mojo` — Comprehensive 39-test suite
- `mojo_refactor/tests/python/group_07/test_plot_utils.py` — Comprehensive 17-test suite

## Issues Fixed in utils.mojo

### 1. max_dd Algorithm Bug (Critical)
- **Problem**: Used `>=` for ratio comparison, causing last-occurrence behavior on ties instead of first-occurrence (numpy `argmax` returns first)
- **Fix**: Changed to strict `>` comparison for both ratio tracking and start_idx finding
- **Impact**: Now matches Python's `np.argmax(np.maximum.accumulate(arr) / arr)` exactly

### 2. Missing IndexRange.new() Factory Method
- **Problem**: Python original has `IndexRange.new(start, end, index)` that extracts dates from index; Mojo version lacked this
- **Fix**: Added `@staticmethod def new(start_idx, end_idx, index) -> IndexRange` to `consts.mojo`
- **Impact**: `max_dd()` and `max_ddd()` now correctly populate date fields via factory method

### 3. weekly_returns Dict/List Ownership
- **Problem**: Mojo's `Dict[String, List[Int]]` value access returns non-copyable reference
- **Fix**: Use `.copy()` for reads and ownership transfer `^` for writes back to Dict
- **Added**: `raises` keyword since Dict operations can raise

### 4. Docstring Warnings
- **Problem**: Multi-line docstrings not ending with period triggered compiler warnings
- **Fix**: All docstrings now end with proper punctuation

## Function Coverage Matrix

| Function | Mojo Tests | Python Tests | Status |
|----------|-----------|-------------|--------|
| `_pad_zero` / `format_date` / `format_datetime` | 3 | — | ✅ |
| `calculate_returns` | 4 | — | ✅ |
| `calculate_max_drawdown` | 4 | — | ✅ |
| `calculate_sharpe_ratio` | 3 | — | ✅ |
| `max_dd` | 6 | 5 | ✅ |
| `max_ddd` | 4 | 3 | ✅ |
| `weekly_returns` | 3 | 2 | ✅ |
| `trading_dates_index` | 5 | 1 | ✅ |
| `IndexRange.new()` | 4 | 1 | ✅ |
| `IndexRange._days()` | 2 | — | ✅ |

## Edge Cases Tested

- Empty arrays/lists → graceful handling (Mojo) or expected error (Python numpy)
- Single element inputs → correct boundary behavior
- All-equal values → first-occurrence semantics verified
- Monotonically increasing/decreasing sequences
- Out-of-bounds indices for IndexRange.new()
- Binary search edge cases (before all, after all, exact match)
- Zero NAV values (division-by-zero protection)
- Same-week date grouping (empty result)

## Execution Commands

```bash
# Mojo tests (39 passed)
cd mojo_refactor && LD_PRELOAD=... PYTHONPATH=... mojo run \
  -I . -I rqmojo/third_party/argmojo/src \
  -I rqmojo/third_party/EmberJson \
  -I rqmojo/third_party/NuMojo \
  -I rqmojo/third_party/mojo-yaml/src \
  -I rqmojo/third_party/morrow.mojo \
  tests/mojo/group_07/test_plot_utils.mojo

# Python tests (17 passed)
cd /home/zhou/hello_mojo/trae_cn_78 && .venv/bin/python \
  -m pytest mojo_refactor/tests/python/group_07/test_plot_utils.py -v
```
