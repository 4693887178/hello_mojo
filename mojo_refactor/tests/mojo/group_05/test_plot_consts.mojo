"""
第五组测试 - mod/rqmojo_mod_sys_analyser/plot/consts.mojo
测试Mojo版本的绘图常量模块
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.plot.consts import ChartType, Color, PlotConst


def test_chart_type_line() -> Bool:
    var line = ChartType.LINE()
    return line.name == "LINE" and line.value == "line"


def test_chart_type_bar() -> Bool:
    var bar = ChartType.BAR()
    return bar.name == "BAR" and bar.value == "bar"


def test_chart_type_scatter() -> Bool:
    var scatter = ChartType.SCATTER()
    return scatter.name == "SCATTER" and scatter.value == "scatter"


def test_color_red() -> Bool:
    var red = Color.RED()
    return red.r == 255 and red.g == 0 and red.b == 0 and red.a == 1.0


def test_color_green() -> Bool:
    var green = Color.GREEN()
    return green.r == 0 and green.g == 255 and green.b == 0 and green.a == 1.0


def test_color_blue() -> Bool:
    var blue = Color.BLUE()
    return blue.r == 0 and blue.g == 0 and blue.b == 255 and blue.a == 1.0


def test_color_black() -> Bool:
    var black = Color.BLACK()
    return black.r == 0 and black.g == 0 and black.b == 0 and black.a == 1.0


def test_plot_const_defaults() -> Bool:
    return PlotConst.DEFAULT_WIDTH == 800


def main():
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Testing: mod/rqmojo_mod_sys_analyser/plot/consts.mojo")
    print("=" * 60)
    
    if test_chart_type_line():
        print("PASS: test_chart_type_line")
        passed += 1
    else:
        print("FAIL: test_chart_type_line")
        failed += 1
    
    if test_chart_type_bar():
        print("PASS: test_chart_type_bar")
        passed += 1
    else:
        print("FAIL: test_chart_type_bar")
        failed += 1
    
    if test_chart_type_scatter():
        print("PASS: test_chart_type_scatter")
        passed += 1
    else:
        print("FAIL: test_chart_type_scatter")
        failed += 1
    
    if test_color_red():
        print("PASS: test_color_red")
        passed += 1
    else:
        print("FAIL: test_color_red")
        failed += 1
    
    if test_color_green():
        print("PASS: test_color_green")
        passed += 1
    else:
        print("FAIL: test_color_green")
        failed += 1
    
    if test_color_blue():
        print("PASS: test_color_blue")
        passed += 1
    else:
        print("FAIL: test_color_blue")
        failed += 1
    
    if test_color_black():
        print("PASS: test_color_black")
        passed += 1
    else:
        print("FAIL: test_color_black")
        failed += 1
    
    if test_plot_const_defaults():
        print("PASS: test_plot_const_defaults")
        passed += 1
    else:
        print("FAIL: test_plot_const_defaults")
        failed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, " passed, ", failed, " failed")
    print("=" * 60)
