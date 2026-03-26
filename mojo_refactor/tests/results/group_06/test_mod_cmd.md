# Test Result: test_mod_cmd.mojo

Test Date: Thu Mar 26 17:40:19 CST 2026

## Test Output
```
Failed to initialize Crashpad.  Crash reporting will not be available.  Cause: while locating crashpad handler: unable to locate crashpad handler executable
=== Group 06 File 07: Mod Commands Tests ===

Test: ModInfo struct
  ModInfo created:  test  -  Test mod
Test: ModCommand struct
  ModCommand created:  list  -  test
Test: get_builtin_mods function
  Found  7  builtin mods
Test: list_mods function
  Found  7  mods
Test: enable_mod function
  enable_mod returned:  True
Test: disable_mod function
  disable_mod returned:  True
Test: run_mod_command with list action
=== Available Modules ===
Name          Status      Description
------------------------------------------------------------
simulation          enabled          Simulation broker and matcher
risk          enabled          Risk management and validation
accounts          enabled          Account management
analyser          enabled          Performance analysis and reporting
scheduler          enabled          Task scheduling
progress          enabled          Progress tracking
transaction_cost          enabled          Transaction cost calculation

Use 'rqalpha mod enable <name>' to enable a mod
Use 'rqalpha mod disable <name>' to disable a mod
  run_mod_command list returned:  0

=== Test Summary ===
Passed:  7
Failed:  0
Total:   7
```

## Result
Status: **PASSED**
