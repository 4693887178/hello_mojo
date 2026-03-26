"""
Test for mod/rqmojo_mod_sys_analyser/plot_store.mojo
Group 08 - File 10
"""

from std.collections import Dict, List
from rqmojo.mod.rqmojo_mod_sys_analyser.plot_store import (
    PlotStore, create_plot_store
)
from rqmojo.utils.typing import DateTimeDate


def test_plot_store_struct() -> Bool:
    print("Test: PlotStore struct exists")
    var store = create_plot_store()
    print("  PASSED")
    return True


def test_plot_store_methods() -> Bool:
    print("Test: PlotStore methods exist")
    var store = create_plot_store()
    
    if not hasattr(store, "add_plot"):
        raise "Should have add_plot method"
    
    if not hasattr(store, "get_plots"):
        raise "Should have get_plots method"
    
    if not hasattr(store, "plot"):
        raise "Should have plot method"
    print("  PASSED")
    return True


def test_add_plot_stores_data() -> Bool:
    print("Test: add_plot stores data")
    var store = create_plot_store()
    
    var test_date = DateTimeDate(2024, 1, 15)
    store.add_plot(test_date, "test_series", 100.0)
    
    var plots = store.get_plots()
    if len(plots) < 1:
        raise "Should have at least 1 plot"
    print("  PASSED")
    return True


def test_get_plots_returns_dict() -> Bool:
    print("Test: get_plots returns dict")
    var store = create_plot_store()
    
    var plots = store.get_plots()
    if len(plots) != 0:
        raise "Empty store should return empty dict"
    print("  PASSED")
    return True


def main() -> None:
    print("=== Group 08 File 10: Plot Store Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    if test_plot_store_struct():
        passed += 1
    else:
        failed += 1
    
    if test_plot_store_methods():
        passed += 1
    else:
        failed += 1
    
    if test_add_plot_stores_data():
        passed += 1
    else:
        failed += 1
    
    if test_get_plots_returns_dict():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
