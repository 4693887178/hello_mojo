"""
Test for mod/rqmojo_mod_sys_analyser/plot/store.mojo
Group 08 - File 5
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.plot.store import PlotStore, create_plot_store
from rqmojo.utils.typing import DateTime
from std.collections import List


fn test_plot_store_init() -> Bool:
    print("Test: PlotStore init")
    var store = create_plot_store()
    print("  PASSED")
    return True


fn test_plot_store_add_series() -> Bool:
    print("Test: PlotStore add_series")
    var store = create_plot_store()
    store.add_series("test_series")
    print("  PASSED")
    return True


fn test_plot_store_add_point() -> Bool:
    print("Test: PlotStore add_point")
    var store = create_plot_store()
    store.add_series("test_series")
    store.add_point("test_series", DateTime(2024, 1, 1, 0, 0, 0, 0), 100.0)
    print("  PASSED")
    return True


fn test_plot_store_get_series_names() -> Bool:
    print("Test: PlotStore get_series_names")
    var store = create_plot_store()
    store.add_series("test_series")
    var names = store.get_series_names()
    if len(names) != 1:
        return False
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 08 File 5: Plot Store Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_plot_store_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_plot_store_add_series():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_plot_store_add_point():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_plot_store_get_series_names():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
