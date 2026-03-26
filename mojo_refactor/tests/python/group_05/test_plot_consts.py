"""
Test for rqalpha/mod/rqalpha_mod_sys_analyser/plot/consts.py
"""


class TestPlotConsts:
    """Test plot constants"""

    def test_color_constants(self):
        """Test color constants"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.consts import RED, BLUE, YELLOW, BLACK
        
        assert RED == "#aa4643"
        assert BLUE == "#4572a7"
        assert YELLOW == "#F3A423"
        assert BLACK == "#000000"

    def test_size_constants(self):
        """Test size constants"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.consts import (
            IMG_WIDTH, PLOT_TITLE_HEIGHT,
            INDICATOR_AREA_HEIGHT, PLOT_AREA_HEIGHT,
            USER_PLOT_AREA_HEIGHT
        )
        
        assert IMG_WIDTH == 15
        assert PLOT_TITLE_HEIGHT == 1
        assert INDICATOR_AREA_HEIGHT == 3
        assert PLOT_AREA_HEIGHT == 5
        assert USER_PLOT_AREA_HEIGHT == 2

    def test_font_size_constants(self):
        """Test font size constants"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.consts import (
            TITLE_FONT_SIZE, LABEL_FONT_SIZE
        )
        
        assert TITLE_FONT_SIZE == 16
        assert isinstance(LABEL_FONT_SIZE, int)

    def test_line_info_constants(self):
        """Test LineInfo constants"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.consts import (
            LINE_STRATEGY, LINE_BENCHMARK, LINE_EXCESS
        )
        
        assert LINE_STRATEGY.label is not None
        assert LINE_BENCHMARK.label is not None
        assert LINE_EXCESS.label is not None

    def test_spot_info_constants(self):
        """Test SpotInfo constants"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.consts import (
            MAX_DD, MAX_DDD, OPEN_POINT, CLOSE_POINT
        )
        
        assert MAX_DD.label is not None
        assert MAX_DDD.label is not None
        assert OPEN_POINT.label is not None
        assert CLOSE_POINT.label is not None


class TestPlotTemplate:
    """Test PlotTemplate class"""

    def test_plot_template_exists(self):
        """Test PlotTemplate class exists"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.consts import PlotTemplate
        
        assert PlotTemplate is not None

    def test_default_plot_exists(self):
        """Test DefaultPlot class exists"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.consts import DefaultPlot
        
        assert DefaultPlot is not None

    def test_default_plot_indicators(self):
        """Test DefaultPlot has INDICATORS"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.consts import DefaultPlot
        
        assert hasattr(DefaultPlot, 'INDICATORS')
        assert len(DefaultPlot.INDICATORS) > 0

    def test_ricequant_plot_exists(self):
        """Test RiceQuant class exists"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.consts import RiceQuant
        
        assert RiceQuant is not None

    def test_plot_template_dict(self):
        """Test PLOT_TEMPLATE dict"""
        from rqalpha.mod.rqalpha_mod_sys_analyser.plot.consts import PLOT_TEMPLATE
        
        assert isinstance(PLOT_TEMPLATE, dict)
        assert "default" in PLOT_TEMPLATE
        assert "ricequant" in PLOT_TEMPLATE
