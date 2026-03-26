# Test Result: test_risk_validators_init.mojo

Test Date: Thu Mar 26 17:40:12 CST 2026

## Test Output
```
Failed to initialize Crashpad.  Crash reporting will not be available.  Cause: while locating crashpad handler: unable to locate crashpad handler executable
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_risk_validators_init.mojo:20:42: warning: assignment to 'validator' was never used; assign to '_' instead?
    var validator = create_cash_validator()
                                         ^
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_risk_validators_init.mojo:27:43: warning: assignment to 'validator' was never used; assign to '_' instead?
    var validator = create_price_validator()
                                          ^
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_risk_validators_init.mojo:34:48: warning: assignment to 'validator' was never used; assign to '_' instead?
    var validator = create_is_trading_validator()
                                               ^
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_risk_validators_init.mojo:41:48: warning: assignment to 'validator' was never used; assign to '_' instead?
    var validator = create_self_trade_validator()
                                               ^
=== Group 06 File 02: Risk Validators Init Tests ===

Test: CashValidator exists
  CashValidator created successfully
Test: PriceValidator exists
  PriceValidator created successfully
Test: IsTradingValidator exists
  IsTradingValidator created successfully
Test: SelfTradeValidator exists
  SelfTradeValidator created successfully

=== Test Summary ===
Passed:  4
Failed:  0
Total:   4
```

## Result
Status: **PASSED**
