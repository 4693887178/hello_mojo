# Test Result: utils/__init__.mojo (RqAttrDict)

## Test Date: 2026-04-19

## Summary

| Metric | Value |
|--------|-------|
| Total Tests | 38 |
| Passed | 38 |
| Failed | 0 |
| Skipped | 0 |
| Warnings | 0 |
| Status | **ALL PASSED** |

## Bugs Fixed

### Bug 1: `update()` - Child → Value replacement not handled
- **Location**: [__init__.mojo:165](rqmojo/utils/__init__.mojo#L165-L177)
- **Problem**: When `other` has a value for key K but `self` has a child at K, the child was not replaced
- **Fix**: Added `_ = self._children.pop(vk)` before setting value to remove stale child

### Bug 2: `update()` - Value → Child replacement not handled  
- **Location**: [__init__.mojo:165](rqmojo/utils/__init__.mojo#L165-L177)
- **Problem**: When `other` has a child for key K but `self` has a value at K, the value was not replaced
- **Fix**: Added `_ = self._values.pop(ck)` before setting child to remove stale value

### Bug 3: `items()` / `convert_to_dict()` missing child keys
- **Location**: [__init__.mojo:193](rqmojo/utils/__init__.mojo#L193-L201)
- **Problem**: Keys that were pure parents (with nested children) were excluded from items() output
- **Fix**: Added `result[ck] = String.write(self._children[ck][])` to include each child key

## Test Coverage (38 tests across 10 categories)

### Construction (7 tests)
- Default init, Int, Float64, String, Bool, NoneType constructors

### getitem/setitem (4 tests)  
- Basic set/get, chain access, missing keys, overwrite semantics

### Iteration & Keys (4 tests)
- keys(), __iter__, child_keys vs value_keys, contains()

### Copy (2 tests)
- Independence verification, data preservation

### Update (6 tests)
- Basic merge, overwrite, nested merge, 3-level deep merge, child→value, value→child replacement

### convert_to_dict / items (5 tests)
- Basic conversion, type handling, nested structure, flattened output, parent key inclusion

### write_to / Writable (3 tests)
- Empty dict, with values, nested children

### Size / Bool (2 tests)
- size() counts top-level only, __bool__() semantics

### Type Conversion (2 tests)
- Float and Bool in items() output

### NullValue & Edge Cases (3 tests)
- Equality, Writable trait, empty iteration

## Architecture Notes

### Python vs Mojo Design Difference

| Aspect | Python (`rqalpha.utils`) | Mojo (`rqmojo.utils`) |
|--------|--------------------------|----------------------|
| Storage | Single `__dict__` dict | Dual: `_children` + `_values` |
| Type safety | Dynamic (any type) | Static (`Variant[NullValue,Int,Float64,String,Bool]`) |
| Chain access | `config.base.date = "x"` | `config["base"]["date"] = RqAttrDict("x")` |
| Nested dicts | Recursive RqAttrDict in values | ArcPointer<RqAttrDict> for children |

### Key Design Decisions
1. **Children vs Values separation**: Child keys map to sub-RqAttrDict nodes (via ArcPointer); Value keys store typed primitives via Variant
2. **`__value__` sentinel**: Wrapping primitive values in RqAttrDict uses internal `__value__` key for uniform getitem interface
3. **Copy-on-read**: `__getitem__` returns copies to prevent accidental mutation of shared state
4. **Flattened items()**: Returns `Dict[String, String]` with dot-notation for nested keys (e.g., `"config.debug"`)
