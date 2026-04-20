"""
Test for mod/rqmojo_mod_sys_analyser/plot_store.mojo
Group 08 - File 5
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.plot_store import PlotStore, create_plot_store
from rqmojo.utils.typing import DateTime
from std.collections import List



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_plot_store_init() raises:
    print("Test: PlotStore init")
    var store = create_plot_store()
    assert_equal(store.get_figure_count(), 0, "Initial figure count should be 0")
    print("  PASSED")


def test_plot_store_add_figure() raises:
    print("Test: PlotStore add_figure")
    var store = create_plot_store()
    store.add_figure("test_figure")
    assert_equal(store.get_figure_count(), 1, "Figure count should be 1 after add_figure")
    print("  PASSED")


def test_plot_store_create_figure() raises:
    print("Test: PlotStore create_figure")
    var store = create_plot_store()
    var figure = store.create_figure("test_figure")
    assert_equal(figure.title, "test_figure", "Figure title should match")
    print("  PASSED")


def test_plot_store_clear() raises:
    print("Test: PlotStore clear")
    var store = create_plot_store()
    store.add_figure("test_figure")
    store.clear()
    assert_equal(store.get_figure_count(), 0, "Figure count should be 0 after clear")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
