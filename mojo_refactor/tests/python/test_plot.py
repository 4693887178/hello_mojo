"""
Test suite for RQAlpha plot.py (Python original)
Validates that plot module implementation matches expected behavior.
Tests are based on actual Python original class constructors from:
  rqalpha/mod/rqalpha_mod_sys_analyser/plot/plot.py
"""

import pytest
import sys
from unittest.mock import Mock, MagicMock, patch

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')

from rqalpha.mod.rqalpha_mod_sys_analyser.plot.plot import (
    SubPlot,
    IndicatorArea,
    ReturnPlot,
    UserPlot,
    TitlePlot,
    WaterMark,
    _plot,
    plot_result,
)


class TestSubPlot:
    """Test SubPlot base class."""

    def test_can_instantiate(self):
        """Test SubPlot can be created (no-arg init)."""
        subplot = SubPlot()
        assert subplot is not None

    def test_has_height_attribute(self):
        """Verify SubPlot has height and right_pad as class annotations."""
        subplot = SubPlot()
        # SubPlot uses class-level type annotations, check __annotations__
        assert 'height' in SubPlot.__annotations__
        assert 'right_pad' in SubPlot.__annotations__
        # right_pad has default value None at class level
        assert SubPlot.right_pad is None


class TestIndicatorArea:
    """Test IndicatorArea class."""

    def test_inherits_from_sub_plot(self):
        """Verify IndicatorArea is a SubPlot subclass."""
        assert issubclass(IndicatorArea, SubPlot)

    def test_creation_with_required_args(self):
        """Test IndicatorArea creation with required arguments."""
        area = IndicatorArea(
            indicators=[],
            indicator_values={},
            plot_template=Mock(),
        )
        assert area is not None
        assert area.height > 0  # INDICATOR_AREA_HEIGHT default

    def test_stores_indicators_and_values(self):
        """Verify IndicatorArea stores indicators and values."""
        mock_template = Mock()
        mock_template.INDICATOR_WIDTH = 100
        mock_template.INDICATOR_VALUE_HEIGHT = 15
        mock_template.INDICATOR_LABEL_HEIGHT = 12
        area = IndicatorArea(
            indicators=[],
            indicator_values={"total_returns": 0.15},
            plot_template=mock_template,
            strategy_name="test_strategy",
        )
        assert area._indicators == []
        assert area._values == {"total_returns": 0.15}
        assert area._strategy_name == "test_strategy"


class TestReturnPlot:
    """Test ReturnPlot class."""

    def test_inherits_from_sub_plot(self):
        """Verify ReturnPlot is a SubPlot subclass."""
        assert issubclass(ReturnPlot, SubPlot)

    def test_creation_with_required_args(self):
        """Test ReturnPlot creation with required arguments."""
        import pandas as pd
        plot = ReturnPlot(
            returns=pd.Series([1.0, 1.05]),
            lines=[],
            spots_on_returns=[],
        )
        assert plot is not None
        assert plot.height > 0  # PLOT_AREA_HEIGHT default

    def test_stores_returns_and_lines(self):
        """Verify ReturnPlot stores returns, lines, and spots."""
        import pandas as pd
        ret = pd.Series([1.0, 1.05, 1.10])
        plot = ReturnPlot(
            returns=ret,
            lines=[(pd.Series([1.0, 1.02]), Mock())],
            spots_on_returns=[([0, 1], Mock())],
        )
        assert plot._returns is ret
        assert len(plot._lines) == 1
        assert len(plot._spots_on_returns) == 1


class TestUserPlot:
    """Test UserPlot class."""

    def test_inherits_from_sub_plot(self):
        """Verify UserPlot is a SubPlot subclass."""
        assert issubclass(UserPlot, SubPlot)

    def test_creation_with_dataframe(self):
        """Test UserPlot creation with DataFrame."""
        import pandas as pd
        plots_df = pd.DataFrame({"a": [1, 2], "b": [3, 4]})
        plot = UserPlot(plots_df)
        assert plot is not None
        assert plot._df is plots_df


class TestTitlePlot:
    """Test TitlePlot class."""

    def test_inherits_from_sub_plot(self):
        """Verify TitlePlot is a SubPlot subclass."""
        assert issubclass(TitlePlot, SubPlot)

    def test_creation_with_required_args(self):
        """Test TitlePlot creation: (strategy_name, indicator_area_rows, plot_template)."""
        mock_template = Mock()
        mock_template.INDICATOR_LABEL_HEIGHT = 12
        mock_template.INDICATOR_VALUE_HEIGHT = 15
        plot = TitlePlot(strategy_name="MyStrategy", indicator_area_rows=2, plot_template=mock_template)
        assert plot is not None
        assert plot._strategy_name == "MyStrategy"
        assert plot._indicator_area_rows == 2


class TestWaterMark:
    """Test WaterMark class."""

    def test_can_instantiate(self):
        """Verify WaterMark can be instantiated: (img_width, img_height, strategy_name)."""
        wm = WaterMark(img_width=10, img_height=5, strategy_name="test")
        assert wm is not None
        assert wm.img_width == 10
        assert wm.img_height == 5

    def test_has_required_attributes(self):
        """Verify WaterMark has all required attributes."""
        wm = WaterMark(img_width=10, img_height=5, strategy_name="test")
        assert hasattr(wm, 'img_width')
        assert hasattr(wm, 'img_height')
        assert hasattr(wm, 'logo_img')
        assert hasattr(wm, 'dpi')


class TestPlotResult:
    """Test plot_result() main function."""

    def _create_mock_result_dict(self, with_benchmark=False):
        """Helper to create mock result dictionary matching plot_result requirements."""
        result = {
            "summary": {
                "strategy_file": "test_strategy.py",
                "strategy_name": "test_strategy",
                "max_drawdown_duration": Mock(start=1, end=3, repr="2 days"),
                "benchmark_symbol": "HS300",
                "benchmark": "000300",
            },
            "portfolio": Mock(),
            "trades": Mock(empty=True),
        }
        result["portfolio"].unit_net_value = __import__("pandas").Series([1.0, 1.05, 1.10, 1.08, 1.15])
        result["portfolio"].index = __import__("pandas").date_range("2024-01-01", periods=5, freq="D")

        if with_benchmark:
            bp = Mock()
            bp.unit_net_value = __import__("pandas").Series([1.0, 1.02, 1.03, 1.01, 1.04])
            result["benchmark_portfolio"] = bp

        return result

    @patch("rqalpha.mod.rqalpha_mod_sys_analyser.plot.plot.pyplot")
    @patch("rqalpha.mod.rqalpha_mod_sys_analyser.plot.plot.WaterMark")
    def test_plot_result_renders_figure(self, mock_wm, mock_pyplot):
        """Verify plot_result renders figure without exceptions (with mocked matplotlib)."""
        result_dict = self._create_mock_result_dict(with_benchmark=True)
        mock_fig = Mock()
        mock_gs = Mock()

        # Create a properly configured mock axes
        mock_ax = Mock()
        mock_ax.get_yticks.return_value = [0.0, 0.5, 1.0]
        mock_xaxis = Mock()
        mock_yaxis = Mock()
        mock_ax.get_xaxis.return_value = mock_xaxis
        mock_ax.get_yaxis.return_value = mock_yaxis
        mock_ax.patch = Mock()

        mock_subplot_func = Mock(return_value=mock_ax)
        mock_pyplot.figure.return_value = mock_fig
        mock_pyplot.subplot = mock_subplot_func
        mock_pyplot.legend.return_value = Mock(get_frame=Mock(set_alpha=Mock()))
        mock_pyplot.get_backend.return_value = "Agg"
        import matplotlib.gridspec as gs_mock
        gs_mock.GridSpec.return_value = mock_gs

        try:
            plot_result(result_dict, show=False)
            assert True
        except Exception as e:
            pytest.fail(f"plot_result raised unexpected exception: {e}")

    def test_handles_missing_summary_key(self):
        """Verify plot_result raises KeyError when summary missing (expected behavior)."""
        result = {"portfolio": Mock()}
        with pytest.raises(KeyError):
            plot_result(result)


class TestDataStructuresConsistency:
    """Test that data structures match Python original design."""

    def test_subplot_has_class_annotations(self):
        """SubPlot has height and right_pad as class annotations."""
        assert 'height' in SubPlot.__annotations__
        assert 'right_pad' in SubPlot.__annotations__

    def test_indicator_area_has_default_height(self):
        """IndicatorArea has default height from constant."""
        assert IndicatorArea.height > 0

    def test_return_plot_has_default_height(self):
        """ReturnPlot has default height from constant."""
        assert ReturnPlot.height > 0

    def test_user_plot_has_default_height(self):
        """UserPlot has default height from constant."""
        assert UserPlot.height > 0

    def test_title_plot_has_default_height(self):
        """TitlePlot has default height from constant."""
        assert TitlePlot.height > 0


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
