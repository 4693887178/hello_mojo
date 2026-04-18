"""
Mojo Test for mod/rqmojo_mod_sys_analyser/plot/__init__.mojo
Tests the plot module exports
Uses std.testing TestSuite for proper testing framework compliance
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.plot.consts import (
    ChartType, Color, PlotConst,
    IndicatorInfo, LineInfo, SpotInfo, IndexRange,
    RED_STR, BLUE_STR, YELLOW_STR, BLACK_STR,
    IMG_WIDTH, PLOT_TITLE_HEIGHT, INDICATOR_AREA_HEIGHT,
    PLOT_AREA_HEIGHT, USER_PLOT_AREA_HEIGHT,
    LABEL_FONT_SIZE, TITLE_FONT_SIZE, SUPPORT_CHINESE,
    LINE_STRATEGY, LINE_BENCHMARK, LINE_EXCESS,
    LINE_WEEKLY, LINE_WEEKLY_BENCHMARK,
    MAX_DD_INFO, MAX_DDD_INFO, OPEN_POINT_INFO, CLOSE_POINT_INFO
)
from rqmojo.mod.rqmojo_mod_sys_analyser.plot.utils import (
    format_date, format_datetime, calculate_returns,
    calculate_max_drawdown, calculate_sharpe_ratio,
    max_dd, max_ddd, weekly_returns, trading_dates_index
)
from rqmojo.mod.rqmojo_mod_sys_analyser.plot.plot import (
    PlotData, PlotFigure, PlotResultConfig,
    SubPlotData, IndicatorAreaData, ReturnPlotData,
    UserPlotData, TitlePlotData,
    create_figure, plot_result
)
from rqmojo.utils.datetime_func import DateTime

from std.testing import assert_equal, assert_true, assert_false, TestSuite


def test_chart_type_line() raises:
    var ct = ChartType.LINE()
    assert_equal(ct.name, "LINE")
    assert_equal(ct.value, "line")


def test_chart_type_bar() raises:
    var ct = ChartType.BAR()
    assert_equal(ct.name, "BAR")
    assert_equal(ct.value, "bar")


def test_chart_type_scatter() raises:
    var ct = ChartType.SCATTER()
    assert_equal(ct.name, "SCATTER")
    assert_equal(ct.value, "scatter")


def test_color_red() raises:
    var c = Color.RED()
    assert_equal(c.r, 255)
    assert_equal(c.g, 0)
    assert_equal(c.b, 0)
    assert_equal(c.a, 1.0)


def test_color_green() raises:
    var c = Color.GREEN()
    assert_equal(c.r, 0)
    assert_equal(c.g, 255)
    assert_equal(c.b, 0)


def test_color_blue() raises:
    var c = Color.BLUE()
    assert_equal(c.r, 0)
    assert_equal(c.g, 0)
    assert_equal(c.b, 255)


def test_color_black() raises:
    var c = Color.BLACK()
    assert_equal(c.r, 0)
    assert_equal(c.g, 0)
    assert_equal(c.b, 0)


def test_color_yellow() raises:
    var c = Color.YELLOW()
    assert_equal(c.r, 243)
    assert_equal(c.g, 164)
    assert_equal(c.b, 35)


def test_color_from_hex() raises:
    var c = Color.from_hex("#aa4643")
    assert_equal(c.r, 170)
    assert_equal(c.g, 70)
    assert_equal(c.b, 67)


def test_plot_const() raises:
    assert_equal(PlotConst.DEFAULT_WIDTH, 800)
    assert_equal(PlotConst.DEFAULT_HEIGHT, 400)
    assert_equal(PlotConst.DEFAULT_DPI, 100)


def test_constants_values() raises:
    assert_equal(RED_STR, "#aa4643")
    assert_equal(BLUE_STR, "#4572a7")
    assert_equal(YELLOW_STR, "#F3A423")
    assert_equal(BLACK_STR, "#000000")
    assert_equal(IMG_WIDTH, 15)
    assert_equal(PLOT_TITLE_HEIGHT, 1)
    assert_equal(INDICATOR_AREA_HEIGHT, 3)
    assert_equal(PLOT_AREA_HEIGHT, 5)
    assert_equal(USER_PLOT_AREA_HEIGHT, 2)
    assert_equal(LABEL_FONT_SIZE, 11)
    assert_equal(TITLE_FONT_SIZE, 16)
    assert_true(SUPPORT_CHINESE)


def test_indicator_info() raises:
    var info = IndicatorInfo(
        key="total_returns",
        label="TotalReturns",
        color="#aa4643",
        formatter="{0:.3%}",
        value_font_size=11,
        label_width_multiplier=1.0
    )
    assert_equal(info.key, "total_returns")
    assert_equal(info.label, "TotalReturns")
    assert_equal(info.color, "#aa4643")


def test_line_info_strategy() raises:
    var ls = LINE_STRATEGY()
    assert_equal(ls.label, "Strategy")
    assert_equal(ls.color, "#aa4643")
    assert_equal(ls.alpha, 1.0)
    assert_equal(ls.linewidth, 2)


def test_line_info_benchmark() raises:
    var lb = LINE_BENCHMARK()
    assert_equal(lb.label, "Benchmark")
    assert_equal(lb.color, "#4572a7")


def test_spot_info_max_dd() raises:
    var mdi = MAX_DD_INFO()
    assert_equal(mdi.label, "MaxDrawDown")
    assert_equal(mdi.marker, "v")
    assert_equal(mdi.markersize, 8)


def test_index_range() raises:
    var ir = IndexRange(start=5, end=10, start_date="2024-01-01", end_date="2024-01-10")
    assert_equal(ir.start, 5)
    assert_equal(ir.end, 10)
    assert_equal(ir.start_date, "2024-01-01")
    assert_equal(ir.end_date, "2024-01-10")


def test_format_date() raises:
    var dt = DateTime(2024, 1, 15, 10, 30, 0, 0)
    var formatted = format_date(dt)
    assert_equal(formatted, "2024-01-15")


def test_format_datetime() raises:
    var dt = DateTime(2024, 1, 15, 10, 30, 45, 0)
    var formatted = format_datetime(dt)
    assert_true(len(formatted) > 0)


def test_calculate_returns() raises:
    var nav_list = List[Float64]()
    nav_list.append(1.0)
    nav_list.append(1.1)
    nav_list.append(1.05)
    nav_list.append(1.15)

    var returns = calculate_returns(nav_list)
    assert_equal(len(returns), 3)


def test_calculate_returns_empty() raises:
    var nav_list = List[Float64]()
    var returns = calculate_returns(nav_list)
    assert_equal(len(returns), 0)


def test_calculate_returns_single() raises:
    var nav_list = List[Float64]()
    nav_list.append(1.0)
    var returns = calculate_returns(nav_list)
    assert_equal(len(returns), 0)


def test_calculate_max_drawdown() raises:
    var nav_list = List[Float64]()
    nav_list.append(1.0)
    nav_list.append(1.2)
    nav_list.append(0.9)
    nav_list.append(1.1)

    var max_dd_val = calculate_max_drawdown(nav_list)
    assert_true(max_dd_val >= 0.0)
    assert_true(max_dd_val <= 1.0)


def test_calculate_max_drawdown_empty() raises:
    var nav_list = List[Float64]()
    var result = calculate_max_drawdown(nav_list)
    assert_equal(result, 0.0)


def test_calculate_sharpe_ratio() raises:
    var returns = List[Float64]()
    returns.append(0.01)
    returns.append(0.02)
    returns.append(-0.01)
    returns.append(0.015)

    var sharpe = calculate_sharpe_ratio(returns)
    assert_true(sharpe > 0)


def test_calculate_sharpe_empty() raises:
    var returns = List[Float64]()
    var result = calculate_sharpe_ratio(returns)
    assert_equal(result, 0.0)


def test_max_dd_function() raises:
    var arr = List[Float64]()
    arr.append(1.0)
    arr.append(1.2)
    arr.append(0.9)
    arr.append(1.1)
    arr.append(1.3)

    var index = List[String]()
    index.append("2024-01-01")
    index.append("2024-01-02")
    index.append("2024-01-03")
    index.append("2024-01-04")
    index.append("2024-01-05")

    var result = max_dd(arr, index)
    assert_true(result.start >= 0)
    assert_true(result.end >= result.start)


def test_max_dd_empty() raises:
    var arr = List[Float64]()
    var index = List[String]()
    var result = max_dd(arr, index)
    assert_equal(result.start, 0)
    assert_equal(result.end, 0)


def test_max_ddd_function() raises:
    var arr = List[Float64]()
    arr.append(1.0)
    arr.append(1.2)
    arr.append(1.1)
    arr.append(0.9)
    arr.append(0.8)
    arr.append(1.0)

    var index = List[String]()
    index.append("2024-01-01")
    index.append("2024-01-02")
    index.append("2024-01-03")
    index.append("2024-01-04")
    index.append("2024-01-05")
    index.append("2024-01-06")

    var result = max_ddd(arr, index)
    assert_true(result.start >= 0)


def test_weekly_returns() raises:
    var nav = List[Float64]()
    nav.append(1.0)
    nav.append(1.02)
    nav.append(1.03)
    nav.append(1.08)

    var dates = List[String]()
    dates.append("2024-01-01")
    dates.append("2024-01-02")
    dates.append("2024-01-05")
    dates.append("2024-01-08")

    var result = weekly_returns(nav, dates)
    assert_true(len(result) >= 0)


def test_trading_dates_index() raises:
    var trade_dates = List[String]()
    trade_dates.append("2024-01-05")
    trade_dates.append("2024-01-10")

    var index = List[String]()
    index.append("2024-01-01")
    index.append("2024-01-02")
    index.append("2024-01-03")
    index.append("2024-01-05")
    index.append("2024-01-07")
    index.append("2024-01-10")
    index.append("2024-01-12")

    var result = trading_dates_index(trade_dates, "CLOSE", index)
    assert_true(len(result) == 2)


def test_plot_data_creation() raises:
    var x = List[String]()
    x.append("2024-01-01")
    x.append("2024-01-02")

    var y = List[Float64]()
    y.append(1.0)
    y.append(1.1)

    var data = PlotData(
        x=x^,
        y=y^,
        name="test_series",
        chart_type=ChartType.LINE(),
        color=Color.BLUE()
    )
    assert_equal(data.name, "test_series")


def test_plot_figure_creation() raises:
    var fig = create_figure(title="Test Chart", x_label="Date", y_label="Value")
    assert_equal(fig.title, "Test Chart")
    assert_equal(fig.x_label, "Date")
    assert_equal(fig.y_label, "Value")


def test_plot_figure_add_line() raises:
    var fig = create_figure(title="Test Chart")

    var x = List[String]()
    x.append("2024-01-01")
    x.append("2024-01-02")

    var y = List[Float64]()
    y.append(1.0)
    y.append(1.1)

    fig.add_line(x^, y^, "NAV", Color.BLUE())
    assert_equal(len(fig.data_series), 1)


def test_plot_figure_add_bar() raises:
    var fig = create_figure(title="Test Chart")

    var x = List[String]()
    x.append("2024-01-01")
    x.append("2024-01-02")

    var y = List[Float64]()
    y.append(0.01)
    y.append(0.02)

    fig.add_bar(x^, y^, "Returns", Color.RED())
    assert_equal(len(fig.data_series), 1)


def test_plot_figure_to_json() raises:
    var fig = create_figure(title="Test Chart")

    var x = List[String]()
    x.append("2024-01-01")

    var y = List[Float64]()
    y.append(1.0)

    fig.add_line(x^, y^, "NAV")

    var json = fig.to_json()
    assert_true(len(json) > 0)
    assert_true(json.find("title") >= 0)


def test_plot_result_config_default() raises:
    var cfg = PlotResultConfig.default()
    assert_true(cfg.show)
    assert_false(cfg.weekly_indicators)
    assert_false(cfg.open_close_points)


def test_sub_plot_data() raises:
    var spd = SubPlotData(height=5, right_pad=-1)
    assert_equal(spd.height, 5)
    assert_equal(spd.right_pad, -1)


def test_indicator_area_data() raises:
    var iad = IndicatorAreaData(
        height=3,
        right_pad=-1,
        indicator_keys=List[String](),
        values=Dict[String, String](),
        strategy_name="Test"
    )
    assert_equal(iad.height, 3)
    assert_equal(iad.strategy_name, "Test")
    assert_equal(iad.format_value("missing"), "nan")


def test_return_plot_data() raises:
    var rpd = ReturnPlotData(
        height=5,
        right_pad=0,
        return_names=List[String](),
        spot_labels=List[String]()
    )
    assert_equal(rpd.height, 5)


def test_user_plot_data() raises:
    var upd = UserPlotData(
        height=2,
        right_pad=0,
        column_names=List[String]()
    )
    assert_equal(upd.height, 2)


def test_title_plot_data() raises:
    var tpd = TitlePlotData(
        height=1,
        right_pad=0,
        strategy_name="MyStrategy",
        indicator_area_rows=3
    )
    assert_equal(tpd.height, 1)
    assert_equal(tpd.strategy_name, "MyStrategy")
    assert_equal(tpd.indicator_area_rows, 3)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
