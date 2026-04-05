"""
RQAlpha Mojo - Testing Module
Ported from rqalpha/utils/testing/__init__.py
"""

from .mocking import mock_instrument, mock_bar, mock_tick
from .fixtures import (
    MagicMock,
    RQAlphaFixture,
    EnvironmentFixture,
    UniverseFixture,
    DataProxyFixture,
    BaseDataSourceFixture,
    BarDictPriceBoardFixture,
    MatcherFixture,
)
from .integration import (
    StructuredTextFormat,
    assert_result,
    IntegrationTestResult,
    IntegrationTestRunner,
)


comptime __all__: List[String] = [
    "IntegrationTestRunner",
    "IntegrationTestResult",
    "MagicMock",
    "RQAlphaFixture",
    "RQAlphaTestCase",
    "StructuredTextFormat",
    "assert_result",
    "EnvironmentFixture",
    "UniverseFixture",
    "DataProxyFixture",
    "BaseDataSourceFixture",
    "BarDictPriceBoardFixture",
    "MatcherFixture",
    "mock_instrument",
    "mock_bar",
    "mock_tick",
]


struct RQAlphaTestCase:
    var _test_count: Int
    var _pass_count: Int

    def __init__(out self):
        self._test_count = 0
        self._pass_count = 0

    def init_fixture(mut self):
        pass

    def assert_equal(mut self, actual: Int, expected: Int, msg: String = "") -> Bool:
        self._test_count += 1
        if actual == expected:
            self._pass_count += 1
            print("PASS: " + msg + " - " + String(actual) + " == " + String(expected))
            return True
        else:
            print("FAIL: " + msg + " - expected " + String(expected) + " but got " + String(actual))
            return False

    def assert_equal_float(mut self, actual: Float64, expected: Float64, msg: String = "") -> Bool:
        self._test_count += 1
        if actual == expected:
            self._pass_count += 1
            print("PASS: " + msg + " - " + String(actual) + " == " + String(expected))
            return True
        else:
            print("FAIL: " + msg + " - expected " + String(expected) + " but got " + String(actual))
            return False

    def assert_equal_string(mut self, actual: String, expected: String, msg: String = "") -> Bool:
        self._test_count += 1
        if actual == expected:
            self._pass_count += 1
            print("PASS: " + msg + " - " + actual + " == " + expected)
            return True
        else:
            print("FAIL: " + msg + " - expected " + expected + " but got " + actual)
            return False

    def assert_true(mut self, condition: Bool, msg: String = "") -> Bool:
        self._test_count += 1
        if condition:
            self._pass_count += 1
            print("PASS: " + msg)
            return True
        else:
            print("FAIL: " + msg + " - expected True but got False")
            return False

    def assert_false(mut self, condition: Bool, msg: String = "") -> Bool:
        self._test_count += 1
        if not condition:
            self._pass_count += 1
            print("PASS: " + msg)
            return True
        else:
            print("FAIL: " + msg + " - expected False but got True")
            return False

    def assert_set_equal(mut self, set1: List[String], set2: List[String], msg: String = "") -> Bool:
        self._test_count += 1

        if len(set1) != len(set2):
            print("FAIL: " + msg + " - set sizes differ: " + String(len(set1)) + " vs " + String(len(set2)))
            return False

        var matched = List[Bool]()
        for i in range(len(set2)):
            matched.append(False)

        for i in range(len(set1)):
            var found = False
            for j in range(len(set2)):
                if not matched[j] and set1[i] == set2[j]:
                    matched[j] = True
                    found = True
                    break
            if not found:
                print("FAIL: " + msg + " - sets not equal")
                return False

        self._pass_count += 1
        print("PASS: " + msg)
        return True
