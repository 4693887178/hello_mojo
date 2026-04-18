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

    @staticmethod
    def YELLOW() -> Color:
        return Color(r=243, g=164, b=35, a=1.0)

    @staticmethod
    def from_hex(hex_str: String) raises -> Color:
        var r = 0
        var g = 0
        var b = 0
        if len(hex_str) == 7 and hex_str[byte=0] == '#':
            r = _hex_to_int(hex_str[byte=1:3])
            g = _hex_to_int(hex_str[byte=3:5])
            b = _hex_to_int(hex_str[byte=5:7])
        return Color(r=r, g=g, b=b, a=1.0)


def _hex_to_int(s: StringSlice) raises -> Int:
    var result = 0
    var s_str = String(s)
    for i in range(len(s_str)):
        var ci = ord(s_str[byte=i])
        result *= 16
        if ci >= ord('0') and ci <= ord('9'):
            result += ci - ord('0')
        elif ci >= ord('a') and ci <= ord('f'):
            result += ci - ord('a') + 10
        elif ci >= ord('A') and ci <= ord('F'):
            result += ci - ord('A') + 10
    return result


@fieldwise_init
struct IndicatorInfo(Copyable, Movable):
    var key: String
    var label: String
    var color: String
    var formatter: String
    var value_font_size: Int
    var label_width_multiplier: Float64


@fieldwise_init
struct LineInfo(Copyable, Movable):
    var label: String
    var color: String
    var alpha: Float64
    var linewidth: Int


@fieldwise_init
struct SpotInfo(Copyable, Movable):
    var label: String
    var marker: String
    var color: String
    var markersize: Int
    var alpha: Float64


@fieldwise_init
struct IndexRange(Copyable, Movable, Writable):
    var start: Int
    var end: Int
    var start_date: String
    var end_date: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write(
            self.start_date, "~", self.end_date, ", ",
            String((self._days())), " days"
        )

    def _days(self) -> Int:
        return self.end - self.start


comptime RED_STR: String = "#aa4643"
comptime BLUE_STR: String = "#4572a7"
comptime YELLOW_STR: String = "#F3A423"
comptime BLACK_STR: String = "#000000"

comptime IMG_WIDTH: Int = 15
comptime PLOT_TITLE_HEIGHT: Int = 1
comptime INDICATOR_AREA_HEIGHT: Int = 3
comptime PLOT_AREA_HEIGHT: Int = 5
comptime USER_PLOT_AREA_HEIGHT: Int = 2

comptime LABEL_FONT_SIZE: Int = 11
comptime TITLE_FONT_SIZE: Int = 16
comptime SUPPORT_CHINESE: Bool = True

comptime LINE_STRATEGY_VAL: LineInfo = LineInfo(label="Strategy", color="#aa4643", alpha=1.0, linewidth=2)
comptime LINE_BENCHMARK_VAL: LineInfo = LineInfo(label="Benchmark", color="#4572a7", alpha=1.0, linewidth=2)
comptime LINE_EXCESS_VAL: LineInfo = LineInfo(label="Excess", color="#F3A423", alpha=1.0, linewidth=2)
comptime LINE_WEEKLY_VAL: LineInfo = LineInfo(label="Weekly", color="#aa4643", alpha=0.6, linewidth=2)
comptime LINE_WEEKLY_BENCHMARK_VAL: LineInfo = LineInfo(label="BenchmarkWeekly", color="#4572a7", alpha=0.6, linewidth=2)

comptime MAX_DD_INFO_VAL: SpotInfo = SpotInfo(label="MaxDrawDown", marker="v", color="Green", markersize=8, alpha=0.7)
comptime MAX_DDD_INFO_VAL: SpotInfo = SpotInfo(label="MaxDDD", marker="D", color="Blue", markersize=8, alpha=0.7)
comptime OPEN_POINT_INFO_VAL: SpotInfo = SpotInfo(label="Open", marker="P", color="#FF7F50", markersize=8, alpha=0.9)
comptime CLOSE_POINT_INFO_VAL: SpotInfo = SpotInfo(label="Close", marker="X", color="#008B8B", markersize=8, alpha=0.9)

def LINE_STRATEGY() -> LineInfo:
    return materialize[LINE_STRATEGY_VAL]()

def LINE_BENCHMARK() -> LineInfo:
    return materialize[LINE_BENCHMARK_VAL]()

def LINE_EXCESS() -> LineInfo:
    return materialize[LINE_EXCESS_VAL]()

def LINE_WEEKLY() -> LineInfo:
    return materialize[LINE_WEEKLY_VAL]()

def LINE_WEEKLY_BENCHMARK() -> LineInfo:
    return materialize[LINE_WEEKLY_BENCHMARK_VAL]()

def MAX_DD_INFO() -> SpotInfo:
    return materialize[MAX_DD_INFO_VAL]()

def MAX_DDD_INFO() -> SpotInfo:
    return materialize[MAX_DDD_INFO_VAL]()

def OPEN_POINT_INFO() -> SpotInfo:
    return materialize[OPEN_POINT_INFO_VAL]()

def CLOSE_POINT_INFO() -> SpotInfo:
    return materialize[CLOSE_POINT_INFO_VAL]()


struct PlotConst:
    comptime DEFAULT_WIDTH: Int = 800
    comptime DEFAULT_HEIGHT: Int = 400
    comptime DEFAULT_DPI: Int = 100
