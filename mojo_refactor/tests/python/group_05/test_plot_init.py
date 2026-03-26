"""
Test for rqalpha/mod/rqalpha_mod_sys_analyser/plot/__init__.py
"""


class TestPlotInit:
    """Test plot module initialization"""

    def test_plot_result_function_exists(self):
        """Test plot_result function exists"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot import plot_result
        
        assert callable(plot_result)

    def test_plot_utils_imports(self):
        """Test plot utils can be imported"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import IndicatorInfo, LineInfo, SpotInfo
        
        assert IndicatorInfo is not None
        assert LineInfo is not None
        assert SpotInfo is not None

    def test_consts_imports(self):
        """Test plot consts can be imported"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.consts import (
            RED, BLUE, YELLOW, BLACK,
            IMG_WIDTH, PLOT_TITLE_HEIGHT,
            INDICATOR_AREA_HEIGHT, PLOT_AREA_HEIGHT
        )
        
        assert RED is not None
        assert BLUE is not None
        assert YELLOW is not None
        assert BLACK is not None


class TestPlotUtils:
    """Test plot utils"""

    def test_indicator_info_creation(self):
        """Test IndicatorInfo creation"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import IndicatorInfo
        
        info = IndicatorInfo("total_returns", "Total Returns", "#aa4643", "{0:.3%}", 11, 1)
        assert info.key == "total_returns"
        assert info.label == "Total Returns"
        assert info.color == "#aa4643"

    def test_line_info_creation(self):
        """Test LineInfo creation"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import LineInfo
        
        info = LineInfo("Strategy", "#aa4643", 1, 2)
        assert info.label == "Strategy"
        assert info.color == "#aa4643"

    def test_spot_info_creation(self):
        """Test SpotInfo creation"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.utils import SpotInfo
        
        info = SpotInfo("MaxDrawDown", "v", "Green", 8, 0.7)
        assert info.label == "MaxDrawDown"
        assert info.marker == "v"
