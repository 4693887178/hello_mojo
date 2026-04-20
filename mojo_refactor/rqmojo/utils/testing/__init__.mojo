"""
RQAlpha Mojo - Testing Module
Ported from rqalpha/utils/testing/__init__.py
"""

from std.python import Python, PythonObject
from std.collections import Dict, List
from rqmojo.utils.testing.mocking import mock_instrument, mock_bar, mock_tick
from rqmojo.utils.testing.fixtures import (
    MagicMock,
    RQAlphaFixture,
    EnvironmentFixture,
    UniverseFixture,
    DataProxyFixture,
    BaseDataSourceFixture,
    BarDictPriceBoardFixture,
    MatcherFixture,
)


comptime __all__: List[String] = [
    "integration_test",
    "MagicMock",
    "RQAlphaFixture",
    "RQAlphaTestCase",
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


@fieldwise_init
struct RQAlphaTestCase:
    """
    Base test case class for RQMojo testing.
    Ported from unittest.TestCase with RQAlpha-specific functionality.
    """

    def init_fixture(mut self):
        """Initialize test fixtures. Override in subclasses."""
        pass

    def assert_obj(
        mut self,
        obj: PythonObject,
        kwargs: Dict[String, PythonObject]
    ) raises -> None:
        """
        Recursively assert object attributes match expected values.

        Args:
            obj: Object to inspect (PythonObject).
            kwargs: Attribute name -> expected value pairs. If value is a dict, recursively asserts nested object's attributes.
        """
        var builtins = Python().import_module("builtins")

        var attr_names = List[String]()
        for key in kwargs.keys():
            attr_names.append(key)

        for attr_name in attr_names:
            var expected = kwargs[attr_name].copy()
            var actual: PythonObject = Python.none()

            try:
                actual = builtins.getattr(obj, attr_name)
            except:
                raise Error("Attribute '" + attr_name + "' not found on object")

            var is_expected_dict = isinstance_pydict(expected)
            var is_actual_dict = isinstance_pydict(actual)

            if is_expected_dict and not is_actual_dict:
                var nested_kwargs = pyobject_to_dict(expected)
                self.assert_obj(actual, nested_kwargs)
            else:
                if actual != expected:
                    raise Error(
                        "Attribute '" + attr_name + "' mismatch: expected "
                        + str_pyobject(expected) + " but got " + str_pyobject(actual)
                    )

    def set_up(mut self):
        """Set up test fixtures before each test."""
        self.init_fixture()


def isinstance_pydict(obj: PythonObject) raises -> Bool:
    """Check if PythonObject is a dict instance."""
    var builtins = Python().import_module("builtins")
    return Bool(py=builtins.isinstance(obj, builtins.dict))


def str_pyobject(obj: PythonObject) raises -> String:
    """Convert PythonObject to string representation."""
    var builtins = Python().import_module("builtins")
    var result = builtins.str(obj)
    return String(py=result)


def pyobject_to_dict(py_dict: PythonObject) raises -> Dict[String, PythonObject]:
    """Convert PythonObject (dict) to Dict[String, PythonObject]."""
    var result = Dict[String, PythonObject]()

    for key in py_dict.keys():
        var key_str = String(py=key)
        result[key_str] = py_dict[key]

    return result^
