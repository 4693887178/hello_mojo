"""
第五组测试 - mod/rqmojo_mod_sys_analyser/plot/consts.mojo
测试Mojo版本的绘图常量模块
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.plot.consts import ChartType, Color, PlotConst


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_chart_type_line() raises:
    var line = ChartType.LINE()
    assert_equal(line.name, "LINE", "name should be LINE")
    assert_equal(line.value, "line", "value should be line")


def test_chart_type_bar() raises:
    var bar = ChartType.BAR()
    assert_equal(bar.name, "BAR", "name should be BAR")
    assert_equal(bar.value, "bar", "value should be bar")


def test_chart_type_scatter() raises:
    var scatter = ChartType.SCATTER()
    assert_equal(scatter.name, "SCATTER", "name should be SCATTER")
    assert_equal(scatter.value, "scatter", "value should be scatter")


def test_color_red() raises:
    var red = Color.RED()
    assert_equal(red.r, 255, "r should be 255")
    assert_equal(red.g, 0, "g should be 0")
    assert_equal(red.b, 0, "b should be 0")
    assert_equal(red.a, 1.0, "a should be 1.0")


def test_color_green() raises:
    var green = Color.GREEN()
    assert_equal(green.r, 0, "r should be 0")
    assert_equal(green.g, 255, "g should be 255")
    assert_equal(green.b, 0, "b should be 0")
    assert_equal(green.a, 1.0, "a should be 1.0")


def test_color_blue() raises:
    var blue = Color.BLUE()
    assert_equal(blue.r, 0, "r should be 0")
    assert_equal(blue.g, 0, "g should be 0")
    assert_equal(blue.b, 255, "b should be 255")
    assert_equal(blue.a, 1.0, "a should be 1.0")


def test_color_black() raises:
    var black = Color.BLACK()
    assert_equal(black.r, 0, "r should be 0")
    assert_equal(black.g, 0, "g should be 0")
    assert_equal(black.b, 0, "b should be 0")
    assert_equal(black.a, 1.0, "a should be 1.0")


def test_plot_const_defaults() raises:
    assert_equal(PlotConst.DEFAULT_WIDTH, 800, "DEFAULT_WIDTH should be 800")
    assert_equal(PlotConst.DEFAULT_HEIGHT, 400, "DEFAULT_HEIGHT should be 400")
    assert_equal(PlotConst.DEFAULT_DPI, 100, "DEFAULT_DPI should be 100")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
