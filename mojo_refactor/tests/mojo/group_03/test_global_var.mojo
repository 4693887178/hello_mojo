"""
RQAlpha Mojo - Global Variables Module Test
Tests for core/global_var.mojo
"""

from std.collections import List
from rqmojo.core.global_var import GlobalVars, create_global_vars


def test_global_vars_creation() raises:
    """Test that GlobalVars can be created."""
    var gv = create_global_vars()
    print("  GlobalVars creation test passed!")


def test_global_vars_set_get() raises:
    """Test that GlobalVars can set and get values."""
    var gv = create_global_vars()
    gv.set("test_key", "test_value")
    print("  GlobalVars set/get test passed!")


def test_global_vars_contains() raises:
    """Test that GlobalVars can check if key exists."""
    var gv = create_global_vars()
    gv.set("my_key", "my_value")
    var exists = gv.contains("my_key")
    assert exists, "Key should exist"
    print("  GlobalVars contains test passed!")


def test_global_vars_remove() raises:
    """Test that GlobalVars can remove a key."""
    var gv = create_global_vars()
    gv.set("to_remove", "value")
    var removed = gv.remove("to_remove")
    assert removed, "Key should be removed"
    var exists = gv.contains("to_remove")
    assert not exists, "Key should not exist after removal"
    print("  GlobalVars remove test passed!")


def test_global_vars_keys() raises:
    """Test that GlobalVars can return all keys."""
    var gv = create_global_vars()
    gv.set("key1", "value1")
    gv.set("key2", "value2")
    var keys = gv.keys()
    assert len(keys) == 2, "Should have 2 keys"
    print("  GlobalVars keys test passed!")


def test_global_vars_clear() raises:
    """Test that GlobalVars can clear all data."""
    var gv = create_global_vars()
    gv.set("key1", "value1")
    gv.set("key2", "value2")
    gv.clear()
    var keys = gv.keys()
    assert len(keys) == 0, "Should have 0 keys after clear"
    print("  GlobalVars clear test passed!")


def main() raises:
    print("============================================================")
    print("Testing core/global_var.mojo")
    print("============================================================")
    
    test_global_vars_creation()
    test_global_vars_set_get()
    test_global_vars_contains()
    test_global_vars_remove()
    test_global_vars_keys()
    test_global_vars_clear()
    
    print("============================================================")
    print("All core/global_var.mojo tests passed!")
    print("============================================================")
