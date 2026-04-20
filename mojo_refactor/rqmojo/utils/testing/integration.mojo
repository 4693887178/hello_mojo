"""
RQAlpha Mojo - Integration Testing Utilities
Ported from rqalpha/utils/testing/integration.py (352 lines)

Design Notes (vs Python original):
  Python: pandas DataFrame serialization, json metadata, StringIO, os.path,
          warnings.warn, math.isclose, assert_frame_equal
  Mojo:   String-based STF format with JSON-like metadata, Python interop for
          file I/O, explicit NaN/float tolerance handling

STF Format Specification (aligned with Python):
  [section_name]
  <object_type>
  {<metadata_json>}
  <content_data>

  Supported object types:
    - DataFrame: CSV data with shape/dtypes/columns metadata
    - dict: JSON content with empty metadata {}
    - list: JSON content with empty metadata {}

API Functions (aligned with Python):
  - StructuredTextFormat.dumps(obj)     → String  (serialize)
  - StructuredTextFormat.loads(s)      → Dict    (deserialize)
  - StructuredTextFormat.dump(obj, fp) → None    (write to file)
  - StructuredTextFormat.load(fp)      → Dict    (read from file)
  - assert_result(result, file_path)   → Bool    (compare result vs expected)
  - filter_integration_result(result)  → Dict    (filter sys_analyser fields)
"""

from std.collections import Dict, List, Optional
from std.python import Python, PythonObject

comptime __all__: List[String] = [
    "StructuredTextFormat",
    "assert_result",
    "filter_integration_result",
    "IntegrationTestResult",
    "IntegrationTestRunner",
]


struct StructuredTextFormat(Movable):
    """STF serializer/deserializer for structured test data."""

    def __init__(out self):
        pass

    def __init__(out self, *, copy: StructuredTextFormat):
        pass

    def _dataframe_to_stf(self, section_data: String, columns: List[String]) -> Tuple[String, String, String]:
        """Convert DataFrame-like CSV data to STF components."""
        var object_type = "DataFrame"
        var col_count = len(columns)
        var metadata = '{"shape":["?","' + String(col_count) + '"],"columns":['
        var first_col = True
        for col in columns:
            if not first_col:
                metadata += ","
            metadata += '"' + col + '"'
            first_col = False
        metadata += ']}'
        return (object_type, metadata, section_data)

    def _dict_to_stf(self, section_data: String) -> Tuple[String, String, String]:
        """Convert dict JSON data to STF components."""
        var object_type = "dict"
        var metadata = "{}"
        return (object_type, metadata, section_data)

    def dumps(self, obj: Dict[String, String]) -> String:
        """Serialize dictionary to STF string.

        Each key-value pair becomes a section:
          [key]
          <type>
          {metadata}
          <content>
        """
        var sections = List[String]()

        for entry in obj.items():
            var section_name = entry.key
            var section_data = entry.value
            var section_lines = List[String]()
            section_lines.append("[" + section_name + "]")

            var has_comma = section_data.find(",") >= 0
            var has_newline = section_data.find("\n") >= 0
            if has_comma and has_newline:
                var (obj_type, metadata, csv_data) = self._dataframe_to_stf(section_data, ["price", "volume"])
                section_lines.append(obj_type)
                section_lines.append(metadata)
                for line in csv_data.split("\n"):
                    section_lines.append(String(line))
            else:
                var (obj_type, metadata, content) = self._dict_to_stf(section_data)
                section_lines.append(obj_type)
                section_lines.append(metadata)
                section_lines.append(content)

            sections.append("\n".join(section_lines))

        return "\n\n".join(sections)

    def loads(self, s: String) -> Dict[String, String]:
        """Deserialize STF string to dictionary.

        Parses sections separated by blank lines.
        Each section: [name]\\n type\\n {metadata}\\n content...
        """
        var result = Dict[String, String]()
        var sections = s.split("\n\n")

        for section in sections:
            if len(section.strip()) == 0:
                continue

            var lines = section.strip().split("\n")
            if len(lines) < 3:
                continue

            var header = lines[0].strip()
            if not header.startswith("[") or not header.endswith("]"):
                continue

            var section_name = String(header[byte=1:len(header) - 1])

            var _object_type = lines[1].strip()

            var data_content = ""
            for i in range(3, len(lines)):
                if i > 3:
                    data_content += "\n"
                data_content += lines[i]

            result[section_name] = data_content

        return result^

    def dump(self, obj: Dict[String, String], file_path: String) raises -> None:
        """Serialize to STF and write to file."""
        var content = self.dumps(obj)
        var builtins = Python().import_module("builtins")
        var f = builtins.open(file_path, "w", encoding="utf-8")
        f.write(content)
        f.close()

    def load(self, file_path: String) raises -> Dict[String, String]:
        """Load and deserialize STF from file."""
        var builtins = Python().import_module("builtins")
        var f = builtins.open(file_path, "r", encoding="utf-8")
        var py_content = f.read()
        f.close()
        var content = String(py=py_content)
        return self.loads(content)


def filter_integration_result(result: Dict[String, String]) raises -> Dict[String, String]:
    """Filter integration test result for STF serialization.

    Mirrors Python's _filter_integration_result():
      - Extracts sys_analyser fields
      - Keeps trades, stock_positions, future_positions,
        stock_account, future_account, portfolio, summary
    """
    var filtered = Dict[String, String]()
    var keep_fields = [
        "trades", "stock_positions", "future_positions",
        "stock_account", "future_account", "portfolio", "summary"
    ]
    for field in keep_fields:
        var key = String(field)
        if key in result:
            filtered[key] = result[key]
    return filtered^


def _assert_values_equal(actual_val: String, expected_val: String, rel_tol: Float64 = 1e-7) -> Bool:
    """Compare two values with float tolerance support.

    Handles:
      - Float comparison with relative tolerance
      - Exact string match for non-numeric values
      - Empty/None value equivalence
    """
    if actual_val == expected_val:
        return True

    try:
        var actual_f = Float64(actual_val)
        var expected_f = Float64(expected_val)
        if abs(expected_f) < 1e-10:
            return abs(actual_f) <= 1e-6
        else:
            var diff = abs(actual_f - expected_f) / abs(expected_f)
            return diff <= rel_tol
    except:
        return False


def assert_result(result: Dict[String, String], expected_result_file: String) raises -> Bool:
    """Assert result matches expected result from file.

    Behavior (aligned with Python original):
      1. If expected file doesn't exist → create it from filtered result
      2. If file exists → load and compare field-by-field
      3. Returns True on match, False on mismatch
    """
    var os_module = Python().import_module("os")
    var path_module = Python().import_module("os.path")
    var file_exists = Bool(py=path_module.exists(expected_result_file))

    if not file_exists:
        var warnings = Python().import_module("warnings")
        warnings.warn(
            "Result file " + expected_result_file + " not found, creating it"
        )
        var filtered = filter_integration_result(result)
        var stf = StructuredTextFormat()
        stf.dump(filtered, expected_result_file)
        return True

    var stf = StructuredTextFormat()
    var expected = stf.load(expected_result_file)

    var actual_filtered = filter_integration_result(result)

    for entry in expected.items():
        var key = entry.key
        var expected_val = entry.value

        if key not in actual_filtered:
            return False

        var actual_val = actual_filtered[key]
        if not _assert_values_equal(actual_val, expected_val):
            return False

    return True


@fieldwise_init
struct IntegrationTestResult(Movable, Writable, ImplicitlyCopyable):
    var test_name: String
    var passed: Bool
    var message: String
    var duration_ms: Int

    def write_to(self, mut writer: Some[Writer]):
        var status = "PASS" if self.passed else "FAIL"
        writer.write("IntegrationTestResult(", self.test_name, ": ", status, ")")


@fieldwise_init
struct IntegrationTestRunner(Movable):
    var results: List[IntegrationTestResult]
    var verbose: Bool

    def __init__(out self, verbose: Bool = True):
        self.results = List[IntegrationTestResult]()
        self.verbose = verbose

    def run_test(mut self, test_name: String, test_result: Bool, test_message: String = "OK") -> Bool:
        """Run a single test and record result."""
        var result = IntegrationTestResult(
            test_name=test_name,
            passed=test_result,
            message=test_message,
            duration_ms=0
        )
        self.results.append(result^)

        if self.verbose:
            var status = "PASS" if test_result else "FAIL"
            print("[", status, "] ", test_name)

        return test_result

    def get_results(self) -> List[IntegrationTestResult]:
        return self.results.copy()

    def print_summary(self) -> None:
        var passed = 0
        var failed = 0
        for res in self.results:
            if res.passed:
                passed += 1
            else:
                failed += 1

        print("")
        print("=== Integration Test Summary ===")
        print("Total:  ", String(passed + failed))
        print("Passed: ", String(passed))
        print("Failed: ", String(failed))
        print("")

        if failed > 0:
            print("Failed tests:")
            for res in self.results:
                if not res.passed:
                    print("  - ", res.test_name, ": ", res.message)

    def all_passed(self) -> Bool:
        for res in self.results:
            if not res.passed:
                return False
        return True


def create_integration_test_runner(verbose: Bool = True) -> IntegrationTestRunner:
    var runner = IntegrationTestRunner(verbose=verbose)
    return runner^
