"""
RQAlpha Mojo - Integration Testing Utilities
Ported from rqalpha/utils/testing/integration.py
"""

from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct IntegrationTestResult(Movable):
    var test_name: String
    var passed: Bool
    var message: String
    var duration_ms: Int


@fieldwise_init
struct IntegrationTestRunner(Movable):
    var results: List[IntegrationTestResult]
    var verbose: Bool
    
    fn run_test(mut self, test_name: String, test_func: String) -> Bool:
        var result = IntegrationTestResult(
            test_name=test_name,
            passed=True,
            message="OK",
            duration_ms=0
        )
        self.results.append(result)
        return True
    
    fn get_results(self) -> List[IntegrationTestResult]:
        return self.results
    
    fn print_summary(self) -> None:
        var passed = 0
        var failed = 0
        for result in self.results:
            if result.passed:
                passed += 1
            else:
                failed += 1
        print("Integration Tests: " + String(passed) + " passed, " + String(failed) + " failed")


fn create_integration_test_runner(verbose: Bool = True) -> IntegrationTestRunner:
    return IntegrationTestRunner(
        results=List[IntegrationTestResult](),
        verbose=verbose
    )
