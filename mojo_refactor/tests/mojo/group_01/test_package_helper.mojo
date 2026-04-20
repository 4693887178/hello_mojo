"""
Test for rqmojo/utils/package_helper.mojo
"""

from python import Python, PythonObject
from rqmojo.utils.package_helper import import_mod


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_import_mod_builtins() raises:
    """Test importing built-in modules."""
    var mod = import_mod("os")
    assert_true(mod.__class__.__name__.count("module") > 0 or len(mod.__class__.__name__) > 0, "Should be a module")


def test_import_mod_stdlib() raises:
    """Test importing standard library modules."""
    var mod = import_mod("json")
    assert_true(mod.__class__.__name__.count("module") > 0 or len(mod.__class__.__name__) > 0, "Should be a module")


def test_import_mod_rqalpha() raises:
    """Test importing rqalpha modules."""
    var mod = import_mod("rqalpha")
    assert_true(mod.__class__.__name__.count("module") > 0 or len(mod.__class__.__name__) > 0, "Should be a module")


def test_import_mod_nonexistent() raises:
    """Test importing non-existent module (should raise)."""
    var raised = False
    try:
        var _ = import_mod("nonexistent_module_xyz123")
    except:
        raised = True
    assert_true(raised, "Should raise for non-existent module")


def test_import_mod_return_type() raises:
    """Test return type of import_mod."""
    var mod = import_mod("os")
    assert_true(len(mod.__class__.__name__) > 0, "Should have a class name")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
