"""
RQAlpha Mojo - Integration Testing Utilities
Ported from rqalpha/utils/testing/integration.py
"""

from std.collections import Dict, List
from std.python import Python, PythonObject
from rqmojo.utils.typing import DateTime, DateTimeDate


comptime __all__: List[String] = [
    "StructuredTextFormat",
    "assert_result",
    "IntegrationTestResult",
    "IntegrationTestRunner",
]


@fieldwise_init
struct StructuredTextFormat(Movable, Copyable):
    """A specialized text format for serializing structured data."""
    
    def dumps(mut self, obj: Dict[String, String]) raises -> String:
        """Serialize dictionary to STF string."""
        var sections = List[String]()
        
        for key in obj.keys():
            var value = obj[key]
            var section = "[" + key + "]\nString\n{}\n" + value
            sections.append(section)
        
        return "\n\n".join(sections)
    
    def loads(mut self, s: String) -> Dict[String, String]:
        """Deserialize STF string to dictionary."""
        var result = Dict[String, String]()
        
        var sections = s.split("\n\n")
        
        for section in sections:
            var lines = section.split("\n")
            if len(lines) < 4:
                continue
            
            var header = lines[0].strip()
            if not header.startswith("[") or not header.endswith("]"):
                continue
            
            var section_name = header.replace("[", "").replace("]", "")
            
            var data_content = ""
            for i in range(3, len(lines)):
                if i > 3:
                    data_content = data_content + "\n"
                data_content = data_content + lines[i]
            
            result[section_name] = data_content
        
        return result^
    
    def dump(mut self, obj: Dict[String, String], file_path: String) raises -> None:
        """Serialize object to STF format and write to file."""
        var content = self.dumps(obj)
        var builtins = Python().import_module("builtins")
        var f = builtins.open(file_path, "w", encoding="utf-8")
        f.write(content)
        f.close()
    
    def load(mut self, file_path: String) raises -> Dict[String, String]:
        """Load and deserialize STF format from file."""
        var builtins = Python().import_module("builtins")
        var f = builtins.open(file_path, "r", encoding="utf-8")
        var content = f.read()
        f.close()
        return self.loads(String(content))


def assert_result(result: Dict[String, String], expected_result_file: String) raises -> Bool:
    """Assert result matches expected result from file."""
    var os_module = Python().import_module("os")
    var file_exists = os_module.path.exists(expected_result_file)
    
    if not Bool(py=file_exists):
        var warnings = Python().import_module("warnings")
        warnings.warn("Result file " + expected_result_file + " not found, creating it")
        
        var stf = StructuredTextFormat()
        stf.dump(result, expected_result_file)
        return True
    
    var stf = StructuredTextFormat()
    var expected = stf.load(expected_result_file)
    
    var keys_list = List[String]()
    for key in expected.keys():
        keys_list.append(key)
    
    for key in keys_list:
        if key not in result:
            return False
        var expected_val = expected[key]
        var result_val = result[key]
        if expected_val != result_val:
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
        for result in self.results:
            if result.passed:
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
            for result in self.results:
                if not result.passed:
                    print("  - ", result.test_name, ": ", result.message)
    
    def all_passed(self) -> Bool:
        for result in self.results:
            if not result.passed:
                return False
        return True


def create_integration_test_runner(verbose: Bool = True) -> IntegrationTestRunner:
    return IntegrationTestRunner(
        results=List[IntegrationTestResult](),
        verbose=verbose
    )


def main() -> None:
    print("RQMojo Integration Testing Utilities")
    print("")
    print("Usage:")
    print("  from rqmojo.utils.testing.integration import IntegrationTestRunner, assert_result")
    print("")
    print("  runner = IntegrationTestRunner()")
    print("  runner.run_test('test_name', True, 'OK')")
    print("  runner.print_summary()")
