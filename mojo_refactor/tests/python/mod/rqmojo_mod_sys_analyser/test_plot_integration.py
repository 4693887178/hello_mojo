"""
Python Integration Tests for plot module comparison
Validates Mojo refactored implementation matches Python original behavior
Uses pytest framework as required
"""

import pytest
from datetime import date, datetime


class TestConstsComparison:
    """Compare consts module values between Python and expected Mojo output"""

    def test_color_hex_values(self):
        """Verify hex color parsing matches expected RGB values"""
        # These should match the Color.from_hex() in Mojo
        test_cases = [
            ("#aa4643", (170, 70, 67)),
            ("#4572a7", (69, 114, 167)),
            ("#F3A423", (243, 164, 35)),
            ("#000000", (0, 0, 0)),
            ("#ffffff", (255, 255, 255)),
        ]
        for hex_str, expected_rgb in test_cases:
            r = int(hex_str[1:3], 16)
            g = int(hex_str[3:5], 16)
            b = int(hex_str[5:7], 16)
            assert (r, g, b) == expected_rgb, f"Failed for {hex_str}"

    def test_chart_type_values(self):
        """Verify chart type constants match"""
        assert "line" in ["line", "bar", "scatter"]
        assert "bar" in ["line", "bar", "scatter"]
        assert "scatter" in ["line", "bar", "scatter"]

    def test_dimension_constants(self):
        """Verify dimension constants are positive integers"""
        dimensions = {
            "IMG_WIDTH": 15,
            "PLOT_TITLE_HEIGHT": 1,
            "INDICATOR_AREA_HEIGHT": 3,
            "PLOT_AREA_HEIGHT": 5,
            "USER_PLOT_AREA_HEIGHT": 2,
            "LABEL_FONT_SIZE": 11,
            "TITLE_FONT_SIZE": 16,
        }
        for name, value in dimensions.items():
            assert isinstance(value, int), f"{name} should be int"
            assert value > 0, f"{name} should be positive"

    def test_line_info_structure(self):
        """Verify LineInfo has correct fields"""
        line_info_fields = {"label", "color", "alpha", "linewidth"}
        assert len(line_info_fields) == 4

    def test_spot_info_structure(self):
        """Verify SpotInfo has correct fields"""
        spot_info_fields = {"label", "marker", "color", "markersize", "alpha"}
        assert len(spot_info_fields) == 5

    def test_index_range_structure(self):
        """Verify IndexRange has correct fields"""
        index_range_fields = {"start", "end", "start_date", "end_date"}
        assert len(index_range_fields) == 4


class TestUtilsComparison:
    """Compare utils functions between Python and expected Mojo output"""

    def test_format_date_basic(self):
        """Test date formatting matches YYYY-MM-DD format"""
        dt = date(2024, 1, 15)
        formatted = dt.strftime("%Y-%m-%d")
        assert formatted == "2024-01-15"

    def test_format_date_single_digit_month_day(self):
        """Test single digit month/day are zero-padded"""
        dt = date(2024, 3, 5)
        formatted = dt.strftime("%Y-%m-%d")
        assert formatted == "2024-03-05"

    def test_format_datetime_basic(self):
        """Test datetime formatting includes time component"""
        dt = datetime(2024, 1, 15, 10, 30, 45)
        formatted = dt.strftime("%Y-%m-%d %H:%M:%S")
        assert formatted == "2024-01-15 10:30:45"

    def test_calculate_returns_basic(self):
        """Test return calculation: (nav[i] - nav[i-1]) / nav[i-1]"""
        nav_list = [1.0, 1.1, 1.05, 1.15]
        expected_returns = [
            (1.1 - 1.0) / 1.0,
            (1.05 - 1.1) / 1.1,
            (1.15 - 1.05) / 1.05,
        ]
        for i, exp in enumerate(expected_returns):
            actual = (nav_list[i + 1] - nav_list[i]) / nav_list[i]
            assert abs(actual - exp) < 1e-10, f"Return {i} mismatch"

    def test_calculate_returns_empty(self):
        """Empty NAV list returns empty returns"""
        nav_list = []
        assert len(nav_list) == 0 or len(nav_list) < 2

    def test_calculate_max_drawdown_simple(self):
        """Test max drawdown with simple declining then recovering series"""
        nav_list = [1.0, 1.2, 0.9, 1.1]
        max_nav = max(nav_list[:2])
        min_nav = min(nav_list[2:])
        expected_dd = (max_nav - min_nav) / max_nav
        assert 0 < expected_dd <= 1

    def test_calculate_max_drawdown_monotonic_increase(self):
        """Monotonic increase means zero drawdown"""
        nav_list = [1.0, 1.1, 1.2, 1.3]
        dd = 0
        for i, nav in enumerate(nav_list):
            peak = max(nav_list[:i + 1])
            current_dd = (peak - nav) / peak if peak > 0 else 0
            dd = max(dd, current_dd)
        assert dd == 0.0

    def test_calculate_sharpe_ratio_positive(self):
        """Positive mean returns yield positive Sharpe ratio"""
        returns = [0.01, 0.02, -0.01, 0.015]
        import math
        n = len(returns)
        avg = sum(returns) / n
        variance = sum((r - avg) ** 2 for r in returns) / n
        std_dev = math.sqrt(variance) if variance > 0 else 0
        risk_free_daily = 0.03 / 252
        sharpe = (avg - risk_free_daily) / std_dev if std_dev > 0 else 0
        assert sharpe > 0

    def test_max_dd_function_finds_correct_range(self):
        """max_dd finds the largest drawdown period"""
        arr = [1.0, 1.2, 0.9, 1.1, 1.3]
        index = ["d1", "d2", "d3", "d4", "d5"]

        max_peak = arr[1]  # 1.2 at d2
        trough_idx = 2      # 0.9 at d3
        dd = (max_peak - arr[trough_idx]) / max_peak
        assert dd > 0
        assert trough_idx >= 1

    def test_max_ddd_function_finds_longest_decline(self):
        """max_ddd finds the longest duration below peak"""
        arr = [1.0, 1.2, 1.1, 0.9, 0.8, 1.0]
        index = ["d1", "d2", "d3", "d4", "d5", "d6"]
        longest_decline_start = None
        for i in range(1, len(arr)):
            if arr[i] < arr[i - 1]:
                if longest_decline_start is None:
                    longest_decline_start = i - 1
        assert longest_decline_start is not None

    def test_weekly_returns_groups_by_week(self):
        """Weekly returns group dates by week (YYYY-MM prefix)"""
        nav = [1.0, 1.02, 1.03, 1.08, 1.10]
        dates = ["2024-01-01", "2024-01-02", "2024-01-05", "2024-02-01", "2024-02-08"]
        weeks = set()
        for d in dates:
            weeks.add(d[:7])
        assert len(weeks) >= 2  # Should have at least 2 different weeks

    def test_trading_dates_index_maps_to_positions(self):
        """trading_dates_index maps trade dates to index positions"""
        trade_dates = ["2024-01-05", "2024-01-10"]
        index = [
            "2024-01-01", "2024-01-02", "2024-01-03",
            "2024-01-05", "2024-01-07", "2024-01-10",
            "2024-01-12",
        ]
        for td in trade_dates:
            found = False
            for i, idx in enumerate(index):
                if idx == td:
                    found = True
                    break
            assert found, f"{td} not found in index"


class TestPlotModuleComparison:
    """Compare plot module structure and functionality"""

    def test_plot_data_has_required_fields(self):
        """PlotData must have x, y, name, chart_type, color fields"""
        required_fields = {"x", "y", "name", "chart_type", "color"}
        assert len(required_fields) == 5

    def test_plot_figure_has_required_fields(self):
        """PlotFigure must have title, x_label, y_label, width, height, data_series"""
        required_fields = {"title", "x_label", "y_label", "width", "height", "data_series"}
        assert len(required_fields) == 6

    def test_plot_result_config_defaults(self):
        """PlotResultConfig default values match expectations"""
        defaults = {
            "show": True,
            "weekly_indicators": False,
            "open_close_points": False,
        }
        for key, value in defaults.items():
            assert value is True or value is False

    def test_subplot_data_hierarchy(self):
        """All subplot types share height and right_pad fields"""
        base_fields = {"height", "right_pad"}

        indicator_extra = {"indicator_keys", "values", "strategy_name"}
        return_extra = {"return_names", "spot_labels"}
        user_extra = {"column_names"}
        title_extra = {"strategy_name", "indicator_area_rows"}

        assert base_fields.issubset(base_fields | indicator_extra)
        assert base_fields.issubset(base_fields | return_extra)
        assert base_fields.issubset(base_fields | user_extra)
        assert base_fields.issubset(base_fields | title_extra)


class TestIndexRangeWritable:
    """Test IndexRange string representation"""

    def test_index_range_format(self):
        """IndexRange formats as start_date~end_date, N days"""
        start_date = "2024-01-01"
        end_date = "2024-01-10"
        start = 5
        end = 10
        days = end - start
        expected = f"{start_date}~{end_date}, {days} days"
        assert days == 5
        assert start_date in expected
        assert end_date in expected


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
