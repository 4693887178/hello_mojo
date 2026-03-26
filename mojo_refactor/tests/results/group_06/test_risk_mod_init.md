# Test Result: test_risk_mod_init.mojo

Test Date: Thu Mar 26 17:40:09 CST 2026

## Test Output
```
Failed to initialize Crashpad.  Crash reporting will not be available.  Cause: while locating crashpad handler: unable to locate crashpad handler executable
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_risk_mod_init.mojo:16:15: warning: 'except' logic is unreachable, try doesn't raise an exception
        print("  create_risk_mod failed")
              ^
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_risk_mod_init.mojo:31:15: warning: 'except' logic is unreachable, try doesn't raise an exception
        print("  RiskMod name test failed")
              ^
=== Group 06 File 01: Risk Mod Init Tests ===

Test: create_risk_mod function
  RiskMod created:  risk
Test: RiskMod name property
  RiskMod name is correct:  risk

=== Test Summary ===
Passed:  2
Failed:  0
Total:   2
```

## Result
Status: **PASSED**
