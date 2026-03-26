"""
RQAlpha Mojo - Plot Constants
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/plot/consts.py
"""

from std.io import Writer


@fieldwise_init
struct ChartType(Writable, Copyable, Movable, Equatable):
    var name: String
    var value: String
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)
    
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
struct Color(Writable, Copyable, Movable, Equatable):
    var r: Int
    var g: Int
    var b: Int
    var a: Float64
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("rgba(", String(self.r), ",", String(self.g), ",", String(self.b), ",", String(self.a), ")")
    
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
    comptime DEFAULT_WIDTH: Int = 800
    comptime DEFAULT_HEIGHT: Int = 400
    comptime DEFAULT_DPI: Int = 100
