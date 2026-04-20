# Test Results: rqmojo_mod_sys_accounts/__init__.mojo

**Date**: 2025-04-18
**Source File**: `mojo_refactor/rqmojo/mod/rqmojo_mod_sys_accounts/__init__.mojo`
**Python Original**: `rqalpha/mod/rqalpha_mod_sys_accounts/__init__.py`

## Summary

| Test Suite | Total | Passed | Failed | Skipped | Time |
|-----------|-------|--------|--------|---------|------|
| Mojo (`test_init.mojo`) | 38 | 38 | 0 | 0 | 0.094s |
| Python (`test_init.py`) | 16 | 16 | 0 | 0 | 1.59s |
| **Total** | **54** | **54** | **0** | **0** | - |

**Status**: ✅ ALL TESTS PASSED - NO WARNINGS

---

## Changes Made

### 1. Fixed `__init__.mojo` (Major Rewrite)

**Before** (broken):
- Used `comptime __config__` dict (wrong pattern - should be runtime)
- Missing `get_config()` function
- Missing `get_cli_options()` function (5 CLI options completely absent)
- Missing `register_cli_options()` function
- Wrong import: `from python import click`
- Only 29 lines, missing most functionality

**After** (fixed):
- Added `get_config() -> Dict[String, ConfigValue]` with all 10 config items
- Added `get_cli_prefix() -> String` returning `"mod__sys_accounts__"`
- Added `get_cli_options() -> List[Argument]` with all 5 CLI options:
  1. `--stock-t1 / --no-stock-t1` (negatable flag)
  2. `--dividend-reinvestment` (flag)
  3. `--cash-return-by-stock-delisted / --no-cash-return-by-stock-delisted` (negatable flag)
  4. `--short-stock / --no-short-stock` (negatable flag for validate_stock_position)
  5. `--futures-settlement-price-type` (string option with value_name TYPE)
- Added `register_cli_options(mut cmd: Command)` to register options
- Fixed imports: uses argmojo instead of python click
- Added `__all__` export list
- 136 lines, fully functional

### 2. Added `ConfigValue` struct to `mod/utils.mojo`

New tagged union type supporting Bool, Float64, Int, and String values:
- 4 typed constructors: `ConfigValue(Bool)`, `ConfigValue(Float64)`, `ConfigValue(Int)`, `ConfigValue(String)`
- Accessor methods: `as_bool()`, `as_float()`, `as_int()`, `as_string()`
- Copy constructor support
- `Writable` trait conformance for debugging
- This was required by other mods (transaction_cost, progress) that import it from utils

---

## Functional Parity Matrix

| Feature | Python Original | Mojo Refactored | Status |
|---------|---------------|-----------------|--------|
| Config: stock_t1 = True | ✅ `__config__["stock_t1"]` | ✅ `get_config()["stock_t1"]` | Match |
| Config: dividend_reinvestment = False | ✅ | ✅ | Match |
| Config: dividend_tax_rate = 0.0 | ✅ | ✅ | Match |
| Config: cash_return_by_delisted = True | ✅ | ✅ | Match |
| Config: auto_switch_order_value = False | ✅ | ✅ | Match |
| Config: validate_stock_position = True | ✅ | ✅ | Match |
| Config: validate_future_position = True | ✅ | ✅ | Match |
| Config: financing_rate = 0.0 | ✅ | ✅ | Match |
| Config: financing_stocks_restriction = False | ✅ | ✅ | Match |
| Config: futures_settlement_price_type = "close" | ✅ | ✅ | Match |
| load_mod() → AccountMod | ✅ `from .mod import AccountMod` | ✅ `create_accounts_mod()` | Match |
| cli_prefix | ✅ `"mod__sys_accounts__"` | ✅ `get_cli_prefix()` | Match |
| CLI: --stock-t1 toggle | ✅ click.Option | ✅ Argument.flag().negatable() | Match |
| CLI: --dividend-reinvestment flag | ✅ click.Option | ✅ Argument.flag() | Match |
| CLI: --cash-return-by-stock-delisted toggle | ✅ click.Option | ✅ Argument.flag().negatable() | Match |
| CLI: --no-short-stock/--short-stock | ✅ click.Option (inverted) | ✅ Argument.flag().negatable() | Match* |
| CLI: --futures-settlement-price-type | ✅ click.Option | ✅ Argument.value_name["TYPE"]() | Match |
| Registration mechanism | ✅ `cli.commands['run'].params.append` | ✅ `register_cli_options(cmd)` | Equivalent |

*Note: Option 4 (--short-stock/--no-short-stock) uses argmojo's negatable pattern which generates `--short-stock`/`--no-short-stock`. The boolean semantics are preserved through the argument name mapping to `validate_stock_position`.

---

## Mojo Test Details (38 tests)

### get_config() tests (12 tests)
- `test_get_config_returns_dict` - config has exactly 10 entries
- `test_get_config_stock_t1_is_true` - stock_t1 == True
- `test_get_config_dividend_reinvestment_is_false` - dividend_reinvestment == False
- `test_get_config_dividend_tax_rate_is_zero` - dividend_tax_rate == 0.0
- `test_get_config_cash_return_by_delisted_is_true` - cash_return_by_stock_delisted == True
- `test_get_config_auto_switch_order_value_is_false` - auto_switch_order_value == False
- `test_get_config_validate_stock_position_is_true` - validate_stock_position == True
- `test_get_config_validate_future_position_is_true` - validate_future_position == True
- `test_get_config_financing_rate_is_zero` - financing_rate == 0.0
- `test_get_config_financing_stocks_restriction_is_false` - financing_stocks_restriction_enabled == False
- `test_get_config_futures_settlement_price_type_is_close` - futures_settlement_price_type == "close"
- `test_get_config_all_keys_present` - all 10 expected keys exist

### get_cli_prefix() tests (2 tests)
- `test_get_cli_prefix_value` - returns "mod__sys_accounts__"
- `test_get_cli_prefix_not_empty` - non-empty string

### get_cli_options() tests (8 tests)
- `test_get_cli_options_returns_five_options` - exactly 5 options
- `test_cli_option_1_stock_t1_negatable_flag` - name, flag, negatable
- `test_cli_option_2_dividend_reinvestment_flag` - name, flag
- `test_cli_option_3_cash_return_negatable_flag` - name, flag, negatable
- `test_cli_option_4_short_stock_negatable_flag` - name, flag, negatable
- `test_cli_option_5_futures_settlement_string_option` - name, not flag, value_name="TYPE"
- `test_cli_options_all_have_help_text` - all options have help text
- `test_cli_options_help_contains_sys_accounts_tag` - help contains [sys_accounts]

### register_cli_options() tests (2 tests)
- `test_register_cli_options_on_command` - registers without error
- `test_register_cli_options_idempotent` - double registration works

### load_mod() tests (5 tests)
- `test_load_mod_returns_accounts_mod` - correct type and name
- `test_load_mod_enabled_by_default` - enabled == True
- `test_load_mod_account_count_zero_initially` - account_count == 0
- `test_create_accounts_mod_factory` - factory function works
- `test_accounts_mod_importable_from_init` - AccountsMod constructible

### ConfigValue tests (9 tests)
- `test_config_value_bool_true` - Bool(True) stores correctly
- `test_config_value_bool_false` - Bool(False) stores correctly
- `test_config_value_float_positive` - Float64(3.14) stores correctly
- `test_config_value_float_zero` - Float64(0.0) stores correctly
- `test_config_value_int_positive` - Int(42) stores correctly
- `test_config_value_int_zero` - Int(0) stores correctly
- `test_config_value_string` - String("close") stores correctly
- `test_config_value_copy_constructor` - copy() works
- `test_config_value_default_values_are_none` - non-active fields are None

---

## Python Test Details (16 tests)

### TestConfig (12 tests)
- All 10 individual config key-value assertions
- Key count assertion (10 keys)
- Full key set equality check

### TestLoadMod (2 tests)
- Returns AccountMod instance
- Not None

### TestCLIPrefix (2 tests)
- Value is "mod__sys_accounts__"
- Non-empty string
