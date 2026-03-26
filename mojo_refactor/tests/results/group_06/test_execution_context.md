# Test Result: test_execution_context.mojo

Test Date: Thu Mar 26 17:40:21 CST 2026

## Test Output
```
Failed to initialize Crashpad.  Crash reporting will not be available.  Cause: while locating crashpad handler: unable to locate crashpad handler executable
=== Group 06 File 08: Execution Context Tests ===

Test: ContextStack struct
  Stack top:  ON_BAR
Test: ContextStack push and pop
  Top after push:  BEFORE_TRADING
  Popped:  BEFORE_TRADING
Test: ExecutionContext struct
  ExecutionContext phase:  ON_BAR
Test: create_bar_execution_context
  Bar context phase:  ON_BAR
Test: create_tick_execution_context
  Tick context phase:  ON_TICK
Test: ExecutionContext.is_on_bar
  is_on_bar returned True

=== Test Summary ===
Passed:  6
Failed:  0
Total:   6
```

## Result
Status: **PASSED**
