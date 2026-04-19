from std.testing import assert_equal, assert_true, TestSuite
from rqmojo.mod.rqmojo_mod_sys_analyser.plot.plot import (
    SubPlotData,
    IndicatorAreaData,
    ReturnPlotData,
    UserPlotData,
    TitlePlotData,
    WaterMark,
    plot_result,
    create_default_watermark,
    get_available_templates,
)
from std.python import Python, PythonObject


def test_sub_plot_data() raises:
    """Test SubPlotData struct initialization."""
    var subplot = SubPlotData(height=100, width=1.0)

    assert_equal(subplot.height, 100)
    assert_true(subplot.width == 1.0)


def test_indicator_area_data() raises:
    """Test IndicatorAreaData struct with all fields."""
    var area = IndicatorAreaData(
        height=80,
        width=0.8,
        indicator_count=6
    )

    assert_equal(area.height, 80)
    assert_true(area.width == 0.8)
    assert_equal(area.indicator_count, 6)


def test_return_plot_data() raises:
    """Test ReturnPlotData struct with complete field set."""
    var return_plot = ReturnPlotData(
        height=300,
        width=1.0,
        p_nav_count=250,
        b_nav_count=250,
        has_max_drawdown=True,
        has_weekly_returns=True,
        has_excess_return=False
    )

    assert_equal(return_plot.height, 300)
    assert_equal(return_plot.p_nav_count, 250)
    assert_equal(return_plot.b_nav_count, 250)
    assert_true(return_plot.has_max_drawdown == True)
    assert_true(return_plot.has_weekly_returns == True)
    assert_true(return_plot.has_excess_return == False)


def test_user_plot_data() raises:
    """Test UserPlotData struct."""
    var user_plot = UserPlotData(
        height=150,
        width=1.0,
        chart_count=2
    )

    assert_equal(user_plot.height, 150)
    assert_equal(user_plot.chart_count, 2)


def test_title_plot_data() raises:
    """Test TitlePlotData struct."""
    var title = TitlePlotData(
        height=50,
        width=1.0,
        title_text="Backtest Results",
        subtitle_text="Default Template"
    )

    assert_equal(title.height, 50)
    assert_true(title.title_text == "Backtest Results")
    assert_true(title.subtitle_text == "Default Template")


def test_watermark_struct() raises:
    """Test WaterMark struct initialization and default factory."""
    # Custom creation
    var wm = WaterMark(
        text="Custom",
        x_position=0.95,
        y_position=0.05,
        font_size=12,
        alpha=0.7
    )

    assert_true(wm.text == "Custom")
    assert_true(wm.x_position == 0.95)
    assert_true(wm.y_position == 0.05)
    assert_equal(wm.font_size, 12)
    assert_true(wm.alpha == 0.7)

    # Default factory
    var default_wm = WaterMark.default()
    assert_true(default_wm.text == "RQAlpha")
    assert_true(default_wm.x_position == 0.98)
    assert_true(default_wm.font_size == 10)


def test_create_default_watermark() raises:
    """Test create_default_watermark helper function."""
    var wm = create_default_watermark()

    assert_true(wm.text == "RQAlpha")
    assert_true(wm.x_position == 0.98)

    # Custom text
    var custom_wm = create_default_watermark("Custom Text")
    assert_true(custom_wm.text == "Custom Text")


def test_get_available_templates() raises:
    """Test get_available_templates returns expected templates."""
    var templates = get_available_templates()

    assert_equal(len(templates), 3)
    assert_true(templates[0] == "DefaultPlot")
    assert_true(templates[1] == "RiceQuant")
    assert_true(templates[2] == "PlotTemplate")


def test_plot_result_with_empty_dict() raises:
    """Test plot_result handles empty result dictionary gracefully."""
    var empty_result = Python.evaluate("{}")

    var json_str = plot_result(empty_result)

    # Should return valid JSON string (non-empty, starts with {)
    assert_true(len(json_str) > 0)
    assert_true(json_str[byte=0:1] == "{")


def _string_contains(haystack: String, needle: String) -> Bool:
    """Helper to check if haystack contains needle substring."""
    var n_len = len(needle)
    if n_len == 0:
        return True
    var h_len = len(haystack)
    if n_len > h_len:
        return False
    for i in range(h_len - n_len + 1):
        if haystack[byte=i:i + n_len] == needle:
            return True
    return False


def test_plot_result_with_portfolio_data() raises:
    """Test plot_result extracts NAV counts from portfolio data."""
    # Create mock result dict with portfolio
    var py_dict = Python.evaluate("""
{
    'portfolio': {
        'unit_net_value': [1.0, 1.05, 1.10, 1.08, 1.15],
        'benchmark_unit_net_value': [1.0, 1.02, 1.03, 1.01, 1.04]
    }
}
""")

    var json_str = plot_result(py_dict)

    # Should contain valid JSON output with expected keys
    assert_true(len(json_str) > 0)
    assert_true(_string_contains(json_str, "p_nav_count"))
    # Verify JSON has return_plot section
    assert_true(_string_contains(json_str, "return_plot"))


def test_plot_result_with_options() raises:
    """Test plot_result respects optional parameters."""
    var empty_result = Python.evaluate("{}")

    # With weekly return enabled
    var json_weekly = plot_result(
        empty_result,
        show_weekly_return=True
    )
    assert_true(_string_contains(json_weekly, "has_weekly_returns"))
    assert_true(_string_contains(json_weekly, "true"))

    # With excess return enabled
    var json_excess = plot_result(
        empty_result,
        show_excess_return=True
    )
    assert_true(_string_contains(json_excess, "has_excess_return"))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
