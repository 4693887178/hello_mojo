"""
Comprehensive Tests for utils/testing/integration.mojo
Tests all functions against Python rqalpha/utils/testing/integration.py behavior.
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Dict, List
from std.python import Python

from rqmojo.utils.testing.integration import (
    StructuredTextFormat,
    assert_result,
    filter_integration_result,
    _assert_values_equal,
    IntegrationTestResult,
    IntegrationTestRunner,
    create_integration_test_runner,
)


def _contains(s: String, sub: String) -> Bool:
    return s.find(sub) >= 0


def test_stf_dumps_single_dict() raises:
    print("Test: STF.dumps single dict entry")
    var stf = StructuredTextFormat()
    var obj = Dict[String, String]()
    obj["summary"] = '{"total_returns":0.15,"sharpe":0.8}'
    var output = stf.dumps(obj)
    assert_true(_contains(output, "[summary]"), "should contain section header")
    assert_true(_contains(output, "dict"), "should contain type dict")
    print("  PASSED")


def test_stf_dumps_multiple_entries() raises:
    print("Test: STF.dumps multiple entries with blank line separator")
    var stf = StructuredTextFormat()
    var obj = Dict[String, String]()
    obj["portfolio"] = "value_data"
    obj["summary"] = '{"total_returns":0.15}'
    var output = stf.dumps(obj)
    assert_true(_contains(output, "[portfolio]"), "contains portfolio section")
    assert_true(_contains(output, "[summary]"), "contains summary section")
    assert_true(_contains(output, "\n\n"), "sections separated by blank line")
    print("  PASSED")


def test_stf_dumps_dataframe_like() raises:
    print("Test: STF.dumps DataFrame-like data with metadata")
    var stf = StructuredTextFormat()
    var obj = Dict[String, String]()
    obj["trades"] = ",price,volume\n2025-01-01,100.5,1000\n2025-01-02,101.2,1500"
    var output = stf.dumps(obj)
    assert_true(_contains(output, "[trades]"), "contains trades header")
    assert_true(_contains(output, "DataFrame"), "contains DataFrame type")
    assert_true(_contains(output, "columns"), "contains columns metadata")
    print("  PASSED")


def test_stf_dumps_empty_dict() raises:
    print("Test: STF.dumps empty dict returns empty string")
    var stf = StructuredTextFormat()
    var obj = Dict[String, String]()
    var output = stf.dumps(obj)
    assert_equal(len(output), 0, "empty dict produces empty string")
    print("  PASSED")


def test_stf_loads_single_section() raises:
    print("Test: STF.loads single section")
    var stf = StructuredTextFormat()
    var input_str = "[portfolio]\ndict\n{}\nportfolio_data_here"
    var result = stf.loads(input_str)
    assert_true("portfolio" in result, "contains portfolio key")
    assert_equal(result["portfolio"], "portfolio_data_here", "correct data content")
    print("  PASSED")


def test_stf_loads_multiple_sections() raises:
    print("Test: STF.loads multiple sections")
    var stf = StructuredTextFormat()
    var input_str = "[section_a]\ndict\n{}\ndata_a\n\n[section_b]\ndict\n{}\ndata_b"
    var result = stf.loads(input_str)
    assert_true("section_a" in result, "contains section_a")
    assert_true("section_b" in result, "contains section_b")
    assert_equal(result["section_a"], "data_a", "correct data_a")
    assert_equal(result["section_b"], "data_b", "correct data_b")
    print("  PASSED")


def test_stf_loads_multiline_content() raises:
    print("Test: STF.loads multi-line content preserved")
    var stf = StructuredTextFormat()
    var input_str = "[trades]\nDataFrame\n{...}\nline1\nline2\nline3"
    var result = stf.loads(input_str)
    assert_true(_contains(result["trades"], "line1"), "preserves line1")
    assert_true(_contains(result["trades"], "line2"), "preserves line2")
    assert_true(_contains(result["trades"], "line3"), "preserves line3")
    print("  PASSED")


def test_stf_loads_invalid_header_skipped() raises:
    print("Test: STF.loads skips invalid headers (no brackets)")
    var stf = StructuredTextFormat()
    var input_str = "no_brackets_here\ndict\n{}\nsome_data"
    var result = stf.loads(input_str)
    assert_equal(len(result), 0, "invalid sections skipped")
    print("  PASSED")


def test_stf_loads_short_sections_skipped() raises:
    print("Test: STF.loads skips short sections (< 3 lines)")
    var stf = StructuredTextFormat()
    var input_str = "[short]\ntype"
    var result = stf.loads(input_str)
    assert_equal(len(result), 0, "short section skipped")
    print("  PASSED")


def test_stf_loads_empty_sections_skipped() raises:
    print("Test: STF.loads skips empty sections")
    var stf = StructuredTextFormat()
    var input_str = "\n\n[real]\ndict\n{}\ndata"
    var result = stf.loads(input_str)
    assert_equal(len(result), 1, "only real section parsed")
    print("  PASSED")


def test_stf_roundtrip_dict() raises:
    print("Test: STF roundtrip: dumps -> loads preserves data")
    var stf = StructuredTextFormat()
    var original = Dict[String, String]()
    original["key1"] = "value1"
    original["key2"] = "value2"
    var serialized = stf.dumps(original)
    var deserialized = stf.loads(serialized)
    assert_equal(deserialized["key1"], "value1", "key1 preserved")
    assert_equal(deserialized["key2"], "value2", "key2 preserved")
    print("  PASSED")


def test_filter_integration_result_all_fields_present() raises:
    print("Test: filter_integration_result keeps known fields")
    var result = Dict[String, String]()
    result["trades"] = "trade_data"
    result["stock_positions"] = "pos_data"
    result["future_positions"] = "future_pos"
    result["stock_account"] = "stock_acc"
    result["future_account"] = "future_acc"
    result["portfolio"] = "port_data"
    result["summary"] = "summary_data"
    result["extra_field"] = "extra_data"
    var filtered = filter_integration_result(result)
    assert_true("trades" in filtered, "keeps trades")
    assert_true("summary" in filtered, "keeps summary")
    assert_false("extra_field" in filtered, "filters out extra fields")
    assert_equal(len(filtered), 7, "exactly 7 fields kept")
    print("  PASSED")


def test_filter_integration_result_partial_fields() raises:
    print("Test: filter_integration_result partial match")
    var result = Dict[String, String]()
    result["trades"] = "t"
    result["unknown_field"] = "u"
    var filtered = filter_integration_result(result)
    assert_true("trades" in filtered, "keeps present field")
    assert_false("unknown_field" in filtered, "skips unknown field")
    assert_equal(len(filtered), 1, "only 1 field kept")
    print("  PASSED")


def test_filter_integration_result_empty() raises:
    print("Test: filter_integration_result empty input")
    var result = Dict[String, String]()
    var filtered = filter_integration_result(result)
    assert_equal(len(filtered), 0, "empty result")
    print("  PASSED")


def test_assert_values_equal_exact_match() raises:
    print("Test: _assert_values_equal exact string match")
    assert_true(_assert_values_equal("hello", "hello"), "identical strings equal")
    assert_false(_assert_values_equal("hello", "world"), "different strings not equal")
    print("  PASSED")


def test_assert_values_equal_float_tolerance() raises:
    print("Test: _assert_values_equal float relative tolerance")
    assert_true(_assert_values_equal("100.5", "100.5000001"), "within tolerance")
    assert_true(_assert_values_equal("100.0", "100.00001"), "relative tolerance works")
    assert_false(_assert_values_equal("100.0", "200.0"), "out of tolerance")
    print("  PASSED")


def test_assert_values_equal_mixed_types() raises:
    print("Test: _assert_values_equal non-numeric vs numeric")
    assert_false(_assert_values_equal("abc", "123"), "string vs number mismatch")
    print("  PASSED")


def test_assert_result_file_not_exists_creates() raises:
    print("Test: assert_result creates file when missing")
    var result = Dict[String, String]()
    result["trades"] = "test_trades"
    result["summary"] = "test_summary"
    var tmp_file = "/tmp/rqmojo_test_assert_" + String(Int(10000)) + ".stf"
    var created = assert_result(result, tmp_file)
    assert_true(created, "returns True when creating new file")

    var path_module = Python().import_module("os.path")
    var exists = Bool(py=path_module.exists(tmp_file))
    assert_true(exists, "file was created on disk")

    var os_mod = Python().import_module("os")
    os_mod.remove(tmp_file)
    print("  PASSED")


def test_integration_test_result_default() raises:
    print("Test: IntegrationTestResult default construction")
    var r = IntegrationTestResult(test_name="my_test", passed=True, message="OK", duration_ms=10)
    assert_equal(r.test_name, "my_test")
    assert_true(r.passed)
    assert_equal(r.message, "OK")
    assert_equal(r.duration_ms, 10)
    print("  PASSED")


def test_integration_test_result_writable() raises:
    print("Test: IntegrationTestResult Writable trait")
    var r = IntegrationTestResult(test_name="fail_test", passed=False, message="ERROR", duration_ms=0)
    var s = String.write(r)
    assert_true(s.byte_length() > 0, "Writable produces output")
    print("  PASSED")


def test_integration_runner_run_passing_test() raises:
    print("Test: IntegrationTestRunner run passing test")
    var runner = IntegrationTestRunner(verbose=True)
    _ = runner.run_test("test_one", True, "OK")
    assert_equal(len(runner.results), 1, "one result recorded")
    assert_true(runner.results[0].passed, "result marked as passed")
    print("  PASSED")


def test_integration_runner_run_failing_test() raises:
    print("Test: IntegrationTestRunner run failing test")
    var runner = IntegrationTestRunner(verbose=True)
    var result = runner.run_test("test_fail", False, "ASSERTION FAILED")
    assert_false(result, "failing test returns False")
    assert_false(runner.results[0].passed, "result marked as failed")
    print("  PASSED")


def test_integration_runner_multiple_tests() raises:
    print("Test: IntegrationTestRunner multiple tests")
    var runner = IntegrationTestRunner(verbose=False)
    _ = runner.run_test("t1", True)
    _ = runner.run_test("t2", True)
    _ = runner.run_test("t3", False)
    assert_equal(len(runner.results), 3, "3 results recorded")
    print("  PASSED")


def test_integration_runner_get_results_copy() raises:
    print("Test: IntegrationTestRunner.get_results returns copy")
    var runner = IntegrationTestRunner(verbose=False)
    _ = runner.run_test("t1", True)
    var copy_results = runner.get_results()
    assert_equal(len(copy_results), 1, "copy has same length")
    print("  PASSED")


def test_integration_runner_all_passed_true() raises:
    print("Test: IntegrationTestRunner.all_passed when all pass")
    var runner = IntegrationTestRunner(verbose=False)
    _ = runner.run_test("t1", True)
    _ = runner.run_test("t2", True)
    assert_true(runner.all_passed(), "all passed")
    print("  PASSED")


def test_integration_runner_all_passed_false() raises:
    print("Test: IntegrationTestRunner.all_passed when one fails")
    var runner = IntegrationTestRunner(verbose=False)
    _ = runner.run_test("t1", True)
    _ = runner.run_test("t2", False)
    assert_false(runner.all_passed(), "not all passed")
    print("  PASSED")


def test_integration_runner_print_summary() raises:
    print("Test: IntegrationTestRunner.print_summary runs without error")
    var runner = IntegrationTestRunner(verbose=False)
    _ = runner.run_test("test_a", True)
    _ = runner.run_test("test_b", False, "expected X got Y")
    runner.print_summary()
    print("  PASSED")


def test_create_integration_test_runner_default() raises:
    print("Test: create_integration_test_runner default verbose=True")
    var runner = create_integration_test_runner()
    assert_true(runner.verbose, "default verbose is True")
    print("  PASSED")


def test_create_integration_test_runner_quiet() raises:
    print("Test: create_integration_test_runner quiet mode")
    var runner = create_integration_test_runner(verbose=False)
    assert_false(runner.verbose, "quiet mode set correctly")
    print("  PASSED")


def main() raises:
    print("=" * 60)
    print("Running integration.mojo Comprehensive Tests")
    print("=" * 60)
    print("")

    print("--- StructuredTextFormat.dumps ---")
    test_stf_dumps_single_dict()
    test_stf_dumps_multiple_entries()
    test_stf_dumps_dataframe_like()
    test_stf_dumps_empty_dict()

    print("")
    print("--- StructuredTextFormat.loads ---")
    test_stf_loads_single_section()
    test_stf_loads_multiple_sections()
    test_stf_loads_multiline_content()
    test_stf_loads_invalid_header_skipped()
    test_stf_loads_short_sections_skipped()
    test_stf_loads_empty_sections_skipped()

    print("")
    print("--- STF Roundtrip ---")
    test_stf_roundtrip_dict()

    print("")
    print("--- filter_integration_result ---")
    test_filter_integration_result_all_fields_present()
    test_filter_integration_result_partial_fields()
    test_filter_integration_result_empty()

    print("")
    print("--- _assert_values_equal ---")
    test_assert_values_equal_exact_match()
    test_assert_values_equal_float_tolerance()
    test_assert_values_equal_mixed_types()

    print("")
    print("--- assert_result ---")
    test_assert_result_file_not_exists_creates()

    print("")
    print("--- IntegrationTestResult ---")
    test_integration_test_result_default()
    test_integration_test_result_writable()

    print("")
    print("--- IntegrationTestRunner ---")
    test_integration_runner_run_passing_test()
    test_integration_runner_run_failing_test()
    test_integration_runner_multiple_tests()
    test_integration_runner_get_results_copy()
    test_integration_runner_all_passed_true()
    test_integration_runner_all_passed_false()
    test_integration_runner_print_summary()

    print("")
    print("--- Factory Function ---")
    test_create_integration_test_runner_default()
    test_create_integration_test_runner_quiet()

    print("")
    print("=" * 60)
    print("All integration tests completed successfully!")
    print("=" * 60)
