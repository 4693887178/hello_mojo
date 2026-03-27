"""
Test for core/executor.mojo
Group 09 - File 5
"""

from rqmojo.core.executor import Executor, create_executor

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_executor_init() raises:
    print("Test: Executor init")
    var _ = create_executor()
    print("  PASSED")


def test_executor_get_state() raises:
    print("Test: Executor get_state")
    var executor = create_executor()
    var _ = executor.get_state()
    print("  PASSED")


def test_executor_set_state() raises:
    print("Test: Executor set_state")
    var executor = create_executor()
    executor.set_state("")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
