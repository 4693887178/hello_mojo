Failed to initialize Crashpad.  Crash reporting will not be available.  Cause: while locating crashpad handler: unable to locate crashpad handler executable
============================================================
Running integration.mojo Comprehensive Tests
============================================================

--- StructuredTextFormat.dumps ---
Test: STF.dumps single dict entry
  PASSED
Test: STF.dumps multiple entries with blank line separator
  PASSED
Test: STF.dumps DataFrame-like data with metadata
  PASSED
Test: STF.dumps empty dict returns empty string
  PASSED

--- StructuredTextFormat.loads ---
Test: STF.loads single section
  PASSED
Test: STF.loads multiple sections
  PASSED
Test: STF.loads multi-line content preserved
  PASSED
Test: STF.loads skips invalid headers (no brackets)
  PASSED
Test: STF.loads skips short sections (< 3 lines)
  PASSED
Test: STF.loads skips empty sections
  PASSED

--- STF Roundtrip ---
Test: STF roundtrip: dumps -> loads preserves data
  PASSED

--- filter_integration_result ---
Test: filter_integration_result keeps known fields
  PASSED
Test: filter_integration_result partial match
  PASSED
Test: filter_integration_result empty input
  PASSED

--- _assert_values_equal ---
Test: _assert_values_equal exact string match
  PASSED
Test: _assert_values_equal float relative tolerance
  PASSED
Test: _assert_values_equal non-numeric vs numeric
  PASSED

--- assert_result ---
Test: assert_result creates file when missing
<sys>:0: UserWarning: Result file /tmp/rqmojo_test_assert_10000.stf not found, creating it
  PASSED

--- IntegrationTestResult ---
Test: IntegrationTestResult default construction
  PASSED
Test: IntegrationTestResult Writable trait
  PASSED

--- IntegrationTestRunner ---
Test: IntegrationTestRunner run passing test
[ PASS ]  test_one
  PASSED
Test: IntegrationTestRunner run failing test
[ FAIL ]  test_fail
  PASSED
Test: IntegrationTestRunner multiple tests
  PASSED
Test: IntegrationTestRunner.get_results returns copy
  PASSED
Test: IntegrationTestRunner.all_passed when all pass
  PASSED
Test: IntegrationTestRunner.all_passed when one fails
  PASSED
Test: IntegrationTestRunner.print_summary runs without error

=== Integration Test Summary ===
Total:   2
Passed:  1
Failed:  1

Failed tests:
  -  test_b :  expected X got Y
  PASSED

--- Factory Function ---
Test: create_integration_test_runner default verbose=True
  PASSED
Test: create_integration_test_runner quiet mode
  PASSED

============================================================
All integration tests completed successfully!
============================================================
