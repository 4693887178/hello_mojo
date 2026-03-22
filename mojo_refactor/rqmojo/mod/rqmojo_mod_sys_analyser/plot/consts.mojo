"""
RQAlpha Mojo - Plot Constants
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/plot/consts.py
"""


@fieldwise_init
struct ChartType(Stringable, Copyable, Movable, Equatable):
    var name: String
    var value: String
    
    def __str__(self) -> String:
        return self.value
    
    @staticmethod
    def LINE() -> ChartType:
        return ChartType(name="LINE", value="line")
    
    @staticmethod
    def BAR() -> ChartType:
        return ChartType(name="BAR", value="bar")
    
    @staticmethod
    def SCATTER() -> ChartType:
        return ChartType(name="SCATTER", value="scatter")


@fieldwise_init
struct Color(Stringable, Copyable, Movable, Equatable):
    var r: Int
    var g: Int
    var b: Int
    var a: Float64
    
    def __str__(self) -> String:
        return "rgba(" + String(self.r) + "," + String(self.g) + "," + String(self.b) + "," + String(self.a) + ")"
    
    @staticmethod
    def RED() -> Color:
        return Color(r=255, g=0, b=0, a=1.0)
    
    @staticmethod
    def GREEN() -> Color:
        return Color(r=0, g=255, b=0, a=1.0)
    
    @staticmethod
    def BLUE() -> Color:
        return Color(r=0, g=0, b=255, a=1.0)
    
    @staticmethod
    def BLACK() -> Color:
        return Color(r=0, g=0, b=0, a=1.0)


struct PlotConst:
    alias DEFAULT_WIDTH: Int = 800
    alias DEFAULT_HEIGHT: Int = 400
    alias DEFAULT_DPI: Int = 100
