"""
第五组测试 - mod/rqmojo_mod_sys_analyser/plot/__init__.mojo
测试Mojo版本的绘图模块
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.plot.consts import ChartType, Color, PlotConst
from rqmojo.mod.rqmojo_mod_sys_analyser.plot.plot import PlotData, PlotFigure, create_figure


def test_create_figure() -> Bool:
    var fig = create_figure(title="Test Figure", x_label="Date", y_label="Value")
    return fig.title == "Test Figure"


def test_figure_add_line() -> Bool:
    var fig = create_figure()
    
    var x = List[String]()
    x.append("2020-01-01")
    x.append("2020-01-02")
    
    var y = List[Float64]()
    y.append(1.0)
    y.append(1.05)
    
    fig.add_line(x^, y^, "nav")
    return len(fig.data_series) == 1


def test_figure_add_bar() -> Bool:
    var fig = create_figure()
    
    var x = List[String]()
    x.append("2020-01-01")
    x.append("2020-01-02")
    
    var y = List[Float64]()
    y.append(100.0)
    y.append(200.0)
    
    fig.add_bar(x^, y^, "volume")
    return len(fig.data_series) == 1


def test_figure_to_json() -> Bool:
    var fig = create_figure(title="Test")
    
    var x = List[String]()
    x.append("2020-01-01")
    
    var y = List[Float64]()
    y.append(1.0)
    
    fig.add_line(x^, y^, "nav")
    
    var json = fig.to_json()
    return json.find("Test") >= 0 and json.find("nav") >= 0


def main():
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Testing: mod/rqmojo_mod_sys_analyser/plot/__init__.mojo")
    print("=" * 60)
    
    if test_create_figure():
        print("PASS: test_create_figure")
        passed += 1
    else:
        print("FAIL: test_create_figure")
        failed += 1
    
    if test_figure_add_line():
        print("PASS: test_figure_add_line")
        passed += 1
    else:
        print("FAIL: test_figure_add_line")
        failed += 1
    
    if test_figure_add_bar():
        print("PASS: test_figure_add_bar")
        passed += 1
    else:
        print("FAIL: test_figure_add_bar")
        failed += 1
    
    if test_figure_to_json():
        print("PASS: test_figure_to_json")
        passed += 1
    else:
        print("FAIL: test_figure_to_json")
        failed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, " passed, ", failed, " failed")
    print("=" * 60)
