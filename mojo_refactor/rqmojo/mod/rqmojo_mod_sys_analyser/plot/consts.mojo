"""
RQAlpha Mojo - Plot Constants
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/plot/consts.py
"""


struct ChartType(Stringable, Copyable, Movable, Equatable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn LINE() -> ChartType:
        return ChartType("LINE", "line")
    
    @staticmethod
    fn BAR() -> ChartType:
        return ChartType("BAR", "bar")
    
    @staticmethod
    fn SCATTER() -> ChartType:
        return ChartType("SCATTER", "scatter")


struct Color(Stringable, Copyable, Movable, Equatable):
    var r: Int
    var g: Int
    var b: Int
    var a: Float64
    
    fn __str__(self) -> String:
        return "rgba(" + String(self.r) + "," + String(self.g) + "," + String(self.b) + "," + String(self.a) + ")"
    
    @staticmethod
    fn RED() -> Color:
        return Color(255, 0, 0, 1.0)
    
    @staticmethod
    fn GREEN() -> Color:
        return Color(0, 255, 0, 1.0)
    
    @staticmethod
    fn BLUE() -> Color:
        return Color(0, 0, 255, 1.0)
    
    @staticmethod
    fn BLACK() -> Color:
        return Color(0, 0, 0, 1.0)


struct PlotConst:
    alias DEFAULT_WIDTH: Int = 800
    alias DEFAULT_HEIGHT: Int = 400
    alias DEFAULT_DPI: Int = 100
