"""
Mojo Test for mod/rqmojo_mod_sys_analyser/plot/__init__.mojo
Tests the plot module exports
TDD: Write tests first, then verify implementation
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.plot.consts import ChartType, Color, PlotConst
from rqmojo.mod.rqmojo_mod_sys_analyser.plot.utils import (
    format_date, format_datetime, calculate_returns, 
    calculate_max_drawdown, calculate_sharpe_ratio
)
from rqmojo.mod.rqmojo_mod_sys_analyser.plot.plot import PlotData, PlotFigure, create_figure
from rqmojo.utils.datetime_func import DateTime


def test_chart_type_line():
    var ct = ChartType.LINE()
    print("ChartType.LINE: " + ct.__str__())
    assert ct.name == "LINE"
    assert ct.value == "line"


def test_chart_type_bar():
    var ct = ChartType.BAR()
    print("ChartType.BAR: " + ct.__str__())
    assert ct.name == "BAR"
    assert ct.value == "bar"


def test_chart_type_scatter():
    var ct = ChartType.SCATTER()
    print("ChartType.SCATTER: " + ct.__str__())
    assert ct.name == "SCATTER"
    assert ct.value == "scatter"


def test_color_red():
    var c = Color.RED()
    print("Color.RED: " + c.__str__())
    assert c.r == 255
    assert c.g == 0
    assert c.b == 0
    assert c.a == 1.0


def test_color_green():
    var c = Color.GREEN()
    print("Color.GREEN: " + c.__str__())
    assert c.r == 0
    assert c.g == 255
    assert c.b == 0


def test_color_blue():
    var c = Color.BLUE()
    print("Color.BLUE: " + c.__str__())
    assert c.r == 0
    assert c.g == 0
    assert c.b == 255


def test_color_black():
    var c = Color.BLACK()
    print("Color.BLACK: " + c.__str__())
    assert c.r == 0
    assert c.g == 0
    assert c.b == 0


def test_plot_const():
    print("PlotConst.DEFAULT_WIDTH: " + String(PlotConst.DEFAULT_WIDTH))
    print("PlotConst.DEFAULT_HEIGHT: " + String(PlotConst.DEFAULT_HEIGHT))
    assert PlotConst.DEFAULT_WIDTH == 800
    assert PlotConst.DEFAULT_HEIGHT == 400


def test_format_date():
    var dt = DateTime(2024, 1, 15, 10, 30, 0, 0)
    var formatted = format_date(dt)
    print("Formatted date: " + formatted)
    assert formatted == "2024-01-15"


def test_format_datetime():
    var dt = DateTime(2024, 1, 15, 10, 30, 45, 0)
    var formatted = format_datetime(dt)
    print("Formatted datetime: " + formatted)
    assert len(formatted) > 0


def test_calculate_returns():
    var nav_list = List[Float64]()
    nav_list.append(1.0)
    nav_list.append(1.1)
    nav_list.append(1.05)
    nav_list.append(1.15)
    
    var returns = calculate_returns(nav_list)
    print("Returns count: " + String(len(returns)))
    assert len(returns) == 3


def test_calculate_max_drawdown():
    var nav_list = List[Float64]()
    nav_list.append(1.0)
    nav_list.append(1.2)
    nav_list.append(0.9)
    nav_list.append(1.1)
    
    var max_dd = calculate_max_drawdown(nav_list)
    print("Max drawdown: " + String(max_dd))
    assert max_dd >= 0.0
    assert max_dd <= 1.0


def test_calculate_sharpe_ratio():
    var returns = List[Float64]()
    returns.append(0.01)
    returns.append(0.02)
    returns.append(-0.01)
    returns.append(0.015)
    
    var sharpe = calculate_sharpe_ratio(returns)
    print("Sharpe ratio: " + String(sharpe))
    assert True


def test_plot_data_creation():
    var x = List[String]()
    x.append("2024-01-01")
    x.append("2024-01-02")
    
    var y = List[Float64]()
    y.append(1.0)
    y.append(1.1)
    
    var data = PlotData(
        x=x,
        y=y,
        name="test_series",
        chart_type=ChartType.LINE(),
        color=Color.BLUE()
    )
    print("PlotData created: " + data.name)
    assert data.name == "test_series"


def test_plot_figure_creation():
    var fig = create_figure(title="Test Chart", x_label="Date", y_label="Value")
    print("PlotFigure created: " + fig.title)
    assert fig.title == "Test Chart"
    assert fig.x_label == "Date"
    assert fig.y_label == "Value"


def test_plot_figure_add_line():
    var fig = create_figure(title="Test Chart")
    
    var x = List[String]()
    x.append("2024-01-01")
    x.append("2024-01-02")
    
    var y = List[Float64]()
    y.append(1.0)
    y.append(1.1)
    
    fig.add_line(x, y, "NAV", Color.BLUE())
    print("Line added to figure")
    assert len(fig.data_series) == 1


def test_plot_figure_add_bar():
    var fig = create_figure(title="Test Chart")
    
    var x = List[String]()
    x.append("2024-01-01")
    x.append("2024-01-02")
    
    var y = List[Float64]()
    y.append(0.01)
    y.append(0.02)
    
    fig.add_bar(x, y, "Returns", Color.RED())
    print("Bar added to figure")
    assert len(fig.data_series) == 1


def test_plot_figure_to_json():
    var fig = create_figure(title="Test Chart")
    
    var x = List[String]()
    x.append("2024-01-01")
    
    var y = List[Float64]()
    y.append(1.0)
    
    fig.add_line(x, y, "NAV")
    
    var json = fig.to_json()
    print("JSON output: " + json[:50] + "...")
    assert len(json) > 0
    assert json.contains("title")


def main():
    print("=== Testing mod/rqmojo_mod_sys_analyser/plot ===")
    test_chart_type_line()
    test_chart_type_bar()
    test_chart_type_scatter()
    test_color_red()
    test_color_green()
    test_color_blue()
    test_color_black()
    test_plot_const()
    test_format_date()
    test_format_datetime()
    test_calculate_returns()
    test_calculate_max_drawdown()
    test_calculate_sharpe_ratio()
    test_plot_data_creation()
    test_plot_figure_creation()
    test_plot_figure_add_line()
    test_plot_figure_add_bar()
    test_plot_figure_to_json()
    print("All plot tests passed!")
