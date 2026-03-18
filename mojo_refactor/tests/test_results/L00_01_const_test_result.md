# L00_01_const Module Test Result

## Test Information

| Item | Value |
|------|-------|
| Module | rqmojo.const / rqalpha.const |
| Level | L00 - Leaf module |
| Dependencies | None |
| Test Date | 2026-03-02 |

## Python Test Results

```
============================= test session starts ==============================
platform linux -- Python 3.14.3, pytest-9.0.2, pluggy-1.6.0
collected 26 items

test_L00_01_const.py::TestL00Const::TestCustomEnumMeta::test_contains_member_name PASSED
test_L00_01_const.py::TestL00Const::TestCustomEnumMeta::test_contains_member_value PASSED
test_L00_01_const.py::TestL00Const::TestCustomEnumMeta::test_getitem_by_name PASSED
test_L00_01_const.py::TestL00Const::TestCustomEnumMeta::test_getitem_by_value PASSED
test_L00_01_const.py::TestL00Const::TestSIDE::test_values PASSED
test_L00_01_const.py::TestL00Const::TestSIDE::test_equality PASSED
test_L00_01_const.py::TestL00Const::TestSIDE::test_string_representation PASSED
test_L00_01_const.py::TestL00Const::TestPOSITION_EFFECT::test_values PASSED
test_L00_01_const.py::TestL00Const::TestORDER_STATUS::test_values PASSED
test_L00_01_const.py::TestL00Const::TestORDER_TYPE::test_values PASSED
test_L00_01_const.py::TestL00Const::TestEXCHANGE::test_values PASSED
test_L00_01_const.py::TestL00Const::TestINSTRUMENT_TYPE::test_values PASSED
test_L00_01_const.py::TestL00Const::TestRUN_TYPE::test_values PASSED
test_L00_01_const.py::TestL00Const::TestEXECUTION_PHASE::test_values PASSED
test_L00_01_const.py::TestL00Const::TestMATCHING_TYPE::test_values PASSED
test_L00_01_const.py::TestL00Const::TestPOSITION_DIRECTION::test_values PASSED
test_L00_01_const.py::TestL00Const::TestDEFAULT_ACCOUNT_TYPE::test_values PASSED
test_L00_01_const.py::TestL00Const::TestALGO::test_values PASSED
test_L00_01_const.py::TestL00Const::TestEXC_TYPE::test_values PASSED
test_L00_01_const.py::TestL00Const::TestPERSIST_MODE::test_values PASSED
test_L00_01_const.py::TestL00Const::TestCOMMISSION_TYPE::test_values PASSED
test_L00_01_const.py::TestL00Const::TestEXIT_CODE::test_values PASSED
test_L00_01_const.py::TestL00Const::TestHEDGE_TYPE::test_values PASSED
test_L00_01_const.py::TestL00Const::TestDAYS_CNT::test_values PASSED
test_L00_01_const.py::TestL00Const::TestTRADING_CALENDAR_TYPE::test_values PASSED
test_L00_01_const.py::TestL00Const::TestMARKET::test_values PASSED

============================== 26 passed in 1.88s ==============================
```

**Python Test Summary**: 26 tests passed

## Mojo Test Results

```
============================================================
L00_01_const Module Tests
============================================================
PASS: EXECUTION_PHASE.GLOBAL name
PASS: EXECUTION_PHASE.ON_INIT name
PASS: EXECUTION_PHASE.BEFORE_TRADING name
PASS: EXECUTION_PHASE.OPEN_AUCTION name
PASS: EXECUTION_PHASE.ON_BAR name
PASS: EXECUTION_PHASE.ON_TICK name
PASS: EXECUTION_PHASE.AFTER_TRADING name
PASS: EXECUTION_PHASE.FINALIZED name
PASS: EXECUTION_PHASE.SCHEDULED name
PASS: RUN_TYPE.BACKTEST value
PASS: RUN_TYPE.BACKTEST name
PASS: RUN_TYPE.PAPER_TRADING value
PASS: RUN_TYPE.LIVE_TRADING value
... (all 95 tests)
PASS: SIDE.BUY __str__
PASS: EXCHANGE.XSHE __str__
============================================================
Results: 95/95 tests passed
============================================================
```

**Mojo Test Summary**: 95 tests passed

## Test Coverage

### Enum Types Tested

| Enum Type | Python | Mojo | Values Match |
|-----------|--------|------|--------------|
| EXECUTION_PHASE | Yes | Yes | Yes |
| RUN_TYPE | Yes | Yes | Yes |
| DEFAULT_ACCOUNT_TYPE | Yes | Yes | Yes |
| MATCHING_TYPE | Yes | Yes | Yes |
| ORDER_TYPE | Yes | Yes | Yes |
| ALGO | Yes | Yes | Yes |
| ORDER_STATUS | Yes | Yes | Yes |
| SIDE | Yes | Yes | Yes |
| POSITION_EFFECT | Yes | Yes | Yes |
| POSITION_DIRECTION | Yes | Yes | Yes |
| EXC_TYPE | Yes | Yes | Yes |
| INSTRUMENT_TYPE | Yes | Yes | Yes |
| PERSIST_MODE | Yes | Yes | Yes |
| COMMISSION_TYPE | Yes | Yes | Yes |
| EXIT_CODE | Yes | Yes | Yes |
| HEDGE_TYPE | Yes | Yes | Yes |
| EXCHANGE | Yes | Yes | Yes |
| TRADING_CALENDAR_TYPE | Yes | Yes | Yes |
| MARKET | Yes | Yes | Yes |

### Constants Tested

| Constant | Python | Mojo | Values Match |
|----------|--------|------|--------------|
| DAYS_CNT.DAYS_A_YEAR | Yes | Yes | Yes (365) |
| DAYS_CNT.TRADING_DAYS_A_YEAR | Yes | Yes | Yes (252) |

## Verification

- [x] Python tests pass
- [x] Mojo tests pass
- [x] Enum values match between Python and Mojo
- [x] Constants match between Python and Mojo
- [x] String representation works correctly

## Conclusion

**L00_01_const module test PASSED**

All enum types and constants in the const module have been verified to work correctly in both Python and Mojo implementations. The values are consistent between the two implementations.
