"""
第五组测试 - mod/rqmojo_mod_sys_analyser/plot/consts.mojo
测试Mojo版本的绘图常量模块 - 全面覆盖所有功能点
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
    MAX_DD_INFO, MAX_DDD_INFO, OPEN_POINT_INFO, CLOSE_POINT_INFO,
    PlotTemplate, DefaultPlot, RiceQuant
)

from std.testing import assert_equal, assert_true, assert_false, TestSuite


def test_chart_type_line() raises:
    var line = ChartType.LINE()
    assert_equal(line.name, "LINE")
    assert_equal(line.value, "line")


def test_chart_type_bar() raises:
    var bar = ChartType.BAR()
    assert_equal(bar.name, "BAR")
    assert_equal(bar.value, "bar")


def test_chart_type_scatter() raises:
    var scatter = ChartType.SCATTER()
    assert_equal(scatter.name, "SCATTER")
    assert_equal(scatter.value, "scatter")


def test_color_red() raises:
    var red = Color.RED()
    assert_equal(red.r, 170)
    assert_equal(red.g, 70)
    assert_equal(red.b, 67)
    assert_equal(red.a, 1.0)


def test_color_green() raises:
    var green = Color.GREEN()
    assert_equal(green.r, 0)
    assert_equal(green.g, 255)
    assert_equal(green.b, 0)
    assert_equal(green.a, 1.0)


def test_color_blue() raises:
    var blue = Color.BLUE()
    assert_equal(blue.r, 69)
    assert_equal(blue.g, 114)
    assert_equal(blue.b, 167)
    assert_equal(blue.a, 1.0)


def test_color_black() raises:
    var black = Color.BLACK()
    assert_equal(black.r, 0)
    assert_equal(black.g, 0)
    assert_equal(black.b, 0)
    assert_equal(black.a, 1.0)


def test_color_yellow() raises:
    var yellow = Color.YELLOW()
    assert_equal(yellow.r, 243)
    assert_equal(yellow.g, 164)
    assert_equal(yellow.b, 35)
    assert_equal(yellow.a, 1.0)


def test_color_from_hex() raises:
    var color = Color.from_hex("#aa4643")
    assert_equal(color.r, 170)
    assert_equal(color.g, 70)
    assert_equal(color.b, 67)
    assert_equal(color.a, 1.0)


def test_plot_const_defaults() raises:
    assert_equal(PlotConst.DEFAULT_WIDTH, 800)
    assert_equal(PlotConst.DEFAULT_HEIGHT, 400)
    assert_equal(PlotConst.DEFAULT_DPI, 100)


def test_color_string_constants() raises:
    assert_equal(RED_STR, "#aa4643")
    assert_equal(BLUE_STR, "#4572a7")
    assert_equal(YELLOW_STR, "#F3A423")
    assert_equal(BLACK_STR, "#000000")


def test_size_constants() raises:
    assert_equal(IMG_WIDTH, 15)
    assert_equal(PLOT_TITLE_HEIGHT, 1)
    assert_equal(INDICATOR_AREA_HEIGHT, 3)
    assert_equal(PLOT_AREA_HEIGHT, 5)
    assert_equal(USER_PLOT_AREA_HEIGHT, 2)


def test_font_size_constants() raises:
    assert_equal(TITLE_FONT_SIZE, 16)
    assert_equal(LABEL_FONT_SIZE, 11)
    assert_true(SUPPORT_CHINESE)


def test_line_strategy_info() raises:
    var line = LINE_STRATEGY()
    assert_equal(line.label, "Strategy")
    assert_equal(line.color, "#aa4643")
    assert_equal(line.alpha, 1.0)
    assert_equal(line.linewidth, 2)


def test_line_benchmark_info() raises:
    var line = LINE_BENCHMARK()
    assert_equal(line.label, "Benchmark")
    assert_equal(line.color, "#4572a7")
    assert_equal(line.alpha, 1.0)
    assert_equal(line.linewidth, 2)


def test_line_excess_info() raises:
    var line = LINE_EXCESS()
    assert_equal(line.label, "Excess")
    assert_equal(line.color, "#F3A423")
    assert_equal(line.alpha, 1.0)
    assert_equal(line.linewidth, 2)


def test_line_weekly_info() raises:
    var line = LINE_WEEKLY()
    assert_equal(line.label, "Weekly")
    assert_equal(line.color, "#aa4643")
    assert_equal(line.alpha, 0.6)
    assert_equal(line.linewidth, 2)


def test_line_weekly_benchmark_info() raises:
    var line = LINE_WEEKLY_BENCHMARK()
    assert_equal(line.label, "BenchmarkWeekly")
    assert_equal(line.color, "#4572a7")
    assert_equal(line.alpha, 0.6)
    assert_equal(line.linewidth, 2)


def test_max_dd_info() raises:
    var info = MAX_DD_INFO()
    assert_equal(info.label, "MaxDrawDown")
    assert_equal(info.marker, "v")
    assert_equal(info.color, "Green")
    assert_equal(info.markersize, 8)
    assert_equal(info.alpha, 0.7)


def test_max_ddd_info() raises:
    var info = MAX_DDD_INFO()
    assert_equal(info.label, "MaxDDD")
    assert_equal(info.marker, "D")
    assert_equal(info.color, "Blue")
    assert_equal(info.markersize, 8)
    assert_equal(info.alpha, 0.7)


def test_open_point_info() raises:
    var info = OPEN_POINT_INFO()
    assert_equal(info.label, "Open")
    assert_equal(info.marker, "P")
    assert_equal(info.color, "#FF7F50")
    assert_equal(info.markersize, 8)
    assert_equal(info.alpha, 0.9)


def test_close_point_info() raises:
    var info = CLOSE_POINT_INFO()
    assert_equal(info.label, "Close")
    assert_equal(info.marker, "X")
    assert_equal(info.color, "#008B8B")
    assert_equal(info.markersize, 8)
    assert_equal(info.alpha, 0.9)


def test_indicator_info_struct() raises:
    var info = IndicatorInfo(
        key="test_key",
        label="Test Label",
        color="#FF0000",
        formatter="{0:.2%}",
        value_font_size=12,
        label_width_multiplier=1.5
    )
    assert_equal(info.key, "test_key")
    assert_equal(info.label, "Test Label")
    assert_equal(info.color, "#FF0000")
    assert_equal(info.formatter, "{0:.2%}")
    assert_equal(info.value_font_size, 12)
    assert_equal(info.label_width_multiplier, 1.5)


def test_line_info_struct() raises:
    var line = LineInfo(
        label="Test Line",
        color="#00FF00",
        alpha=0.8,
        linewidth=3
    )
    assert_equal(line.label, "Test Line")
    assert_equal(line.color, "#00FF00")
    assert_equal(line.alpha, 0.8)
    assert_equal(line.linewidth, 3)


def test_spot_info_struct() raises:
    var spot = SpotInfo(
        label="Test Spot",
        marker="o",
        color="#0000FF",
        markersize=10,
        alpha=0.5
    )
    assert_equal(spot.label, "Test Spot")
    assert_equal(spot.marker, "o")
    assert_equal(spot.color, "#0000FF")
    assert_equal(spot.markersize, 10)
    assert_equal(spot.alpha, 0.5)


def test_index_range_struct() raises:
    var idx_range = IndexRange(
        start=0,
        end=100,
        start_date="2024-01-01",
        end_date="2024-04-10"
    )
    assert_equal(idx_range.start, 0)
    assert_equal(idx_range.end, 100)
    assert_equal(idx_range.start_date, "2024-01-01")
    assert_equal(idx_range.end_date, "2024-04-10")
    assert_equal(idx_range._days(), 100)


def test_plot_template_exists() raises:
    var p_nav = [1.0, 1.1, 1.2]
    var b_nav = [1.0, 1.05, 1.1]
    var template = PlotTemplate(p_nav=p_nav.copy(), b_nav=b_nav.copy())
    assert_equal(len(template.p_nav), 3)
    assert_equal(len(template.b_nav), 3)


def test_plot_template_geometric_excess_returns() raises:
    var p_nav = [1.2]
    var b_nav = [1.0]
    var template = PlotTemplate(p_nav=p_nav.copy(), b_nav=b_nav.copy())
    var result = template.geometric_excess_returns()
    assert_true(abs(result - 0.2) < 0.001)


def test_plot_template_geometric_excess_returns_zero_benchmark() raises:
    var p_nav = [1.2]
    var b_nav = [0.0]
    var template = PlotTemplate(p_nav=p_nav.copy(), b_nav=b_nav.copy())
    var result = template.geometric_excess_returns()
    assert_equal(result, 0.0)


def test_default_plot_dimensions() raises:
    assert_equal(DefaultPlot.INDICATOR_WIDTH, 0.15)
    assert_equal(DefaultPlot.INDICATOR_VALUE_HEIGHT, 0.15)
    assert_equal(DefaultPlot.INDICATOR_LABEL_HEIGHT, 0.1)


def test_default_plot_indicators() raises:
    var indicators = DefaultPlot.get_indicators()
    assert_true(len(indicators) > 0)
    assert_equal(len(indicators), 3)
    var first_group = indicators[0].copy()
    assert_true(len(first_group) > 0)
    assert_equal(first_group[0].key, "total_returns")
    assert_equal(first_group[0].label, "TotalReturns")
    assert_equal(first_group[0].color, "#aa4643")


def test_default_plot_weekly_indicators() raises:
    var weekly_indicators = DefaultPlot.get_weekly_indicators()
    assert_true(len(weekly_indicators) > 0)
    var weekly_group = weekly_indicators[0].copy()
    assert_equal(weekly_group[0].key, "weekly_alpha")


def test_default_plot_excess_indicators() raises:
    var excess_indicators = DefaultPlot.get_excess_indicators()
    assert_true(len(excess_indicators) > 0)
    var excess_group = excess_indicators[0].copy()
    assert_equal(excess_group[0].key, "excess_returns")


def test_ricequant_plot_dimensions() raises:
    assert_equal(RiceQuant.INDICATOR_WIDTH, 0.22)
    assert_equal(RiceQuant.INDICATOR_VALUE_HEIGHT, 0.15)
    assert_equal(RiceQuant.INDICATOR_LABEL_HEIGHT, 0.1)


def test_ricequant_plot_indicators() raises:
    var indicators = RiceQuant.get_indicators()
    assert_true(len(indicators) > 0)
    assert_equal(len(indicators), 3)
    var first_group = indicators[0].copy()
    assert_true(len(first_group) > 0)
    assert_equal(first_group[0].key, "total_returns")
    assert_equal(first_group[0].label, "TotalReturns")


def test_ricequant_plot_excess_indicators() raises:
    var excess_indicators = RiceQuant.get_excess_indicators()
    assert_true(len(excess_indicators) > 0)
    assert_equal(len(excess_indicators), 2)


def test_ricequant_plot_weekly_indicators_empty() raises:
    var weekly_indicators = RiceQuant.get_weekly_indicators()
    assert_equal(len(weekly_indicators), 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
