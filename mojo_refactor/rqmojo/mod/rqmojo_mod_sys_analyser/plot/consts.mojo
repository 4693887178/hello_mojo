"""
RQAlpha Mojo - Plot Constants
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/plot/consts.py
"""

from std.io import Writer
from std.collections import List, Dict


@fieldwise_init
struct IndicatorInfo(Copyable, Movable, Writable):
    var key: String
    var label: String
    var color: String
    var formatter: String
    var value_font_size: Int
    var label_width_multiplier: Float64

    def write_to(self, mut writer: Some[Writer]):
        writer.write("IndicatorInfo(", self.key, ", ", self.label, ")")


@fieldwise_init
struct LineInfo(Copyable, Movable, Writable):
    var label: String
    var color: String
    var alpha: Float64
    var linewidth: Int

    def write_to(self, mut writer: Some[Writer]):
        writer.write("LineInfo(", self.label, ", ", self.color, ")")


@fieldwise_init
struct SpotInfo(Copyable, Movable, Writable):
    var label: String
    var marker: String
    var color: String
    var markersize: Int
    var alpha: Float64

    def write_to(self, mut writer: Some[Writer]):
        writer.write("SpotInfo(", self.label, ", ", self.marker, ")")


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

    @staticmethod
    def new(start_idx: Int, end_idx: Int, index: List[String]) -> IndexRange:
        """Factory method matching Python IndexRange.new(start, end, index).
        
        Extracts date strings from index at given positions.
        Falls back to empty string if index is too short.
        """
        var sd = ""
        var ed = ""
        if start_idx >= 0 and start_idx < len(index):
            sd = index[start_idx]
        if end_idx >= 0 and end_idx < len(index):
            ed = index[end_idx]
        return IndexRange(start=start_idx, end=end_idx, start_date=sd, end_date=ed)


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
        return Color(r=170, g=70, b=67, a=1.0)

    @staticmethod
    def GREEN() -> Color:
        return Color(r=0, g=255, b=0, a=1.0)

    @staticmethod
    def BLUE() -> Color:
        return Color(r=69, g=114, b=167, a=1.0)

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

def LINE_STRATEGY() -> LineInfo:
    return LineInfo(label="Strategy", color="#aa4643", alpha=1.0, linewidth=2)

def LINE_BENCHMARK() -> LineInfo:
    return LineInfo(label="Benchmark", color="#4572a7", alpha=1.0, linewidth=2)

def LINE_EXCESS() -> LineInfo:
    return LineInfo(label="Excess", color="#F3A423", alpha=1.0, linewidth=2)

def LINE_WEEKLY() -> LineInfo:
    return LineInfo(label="Weekly", color="#aa4643", alpha=0.6, linewidth=2)

def LINE_WEEKLY_BENCHMARK() -> LineInfo:
    return LineInfo(label="BenchmarkWeekly", color="#4572a7", alpha=0.6, linewidth=2)

def MAX_DD_INFO() -> SpotInfo:
    return SpotInfo(label="MaxDrawDown", marker="v", color="Green", markersize=8, alpha=0.7)

def MAX_DDD_INFO() -> SpotInfo:
    return SpotInfo(label="MaxDDD", marker="D", color="Blue", markersize=8, alpha=0.7)

def OPEN_POINT_INFO() -> SpotInfo:
    return SpotInfo(label="Open", marker="P", color="#FF7F50", markersize=8, alpha=0.9)

def CLOSE_POINT_INFO() -> SpotInfo:
    return SpotInfo(label="Close", marker="X", color="#008B8B", markersize=8, alpha=0.9)


@fieldwise_init
struct PlotTemplate:
    """作图模版"""

    var p_nav: List[Float64]
    var b_nav: List[Float64]

    comptime INDICATOR_WIDTH: Float64 = 0.0
    comptime INDICATOR_VALUE_HEIGHT: Float64 = 0.0
    comptime INDICATOR_LABEL_HEIGHT: Float64 = 0.0

    def geometric_excess_returns(self) -> Float64:
        if len(self.b_nav) == 0 or len(self.p_nav) == 0 or self.b_nav[0] == 0:
            return 0.0
        return self.p_nav[0] / self.b_nav[0] - 1.0


@fieldwise_init
struct DefaultPlot:
    """基础"""

    var p_nav: List[Float64]
    var b_nav: List[Float64]

    comptime INDICATOR_WIDTH: Float64 = 0.15
    comptime INDICATOR_VALUE_HEIGHT: Float64 = 0.15
    comptime INDICATOR_LABEL_HEIGHT: Float64 = 0.1

    def geometric_excess_returns(self) -> Float64:
        if len(self.b_nav) == 0 or len(self.p_nav) == 0 or self.b_nav[0] == 0:
            return 0.0
        return self.p_nav[0] / self.b_nav[0] - 1.0

    @staticmethod
    def get_indicators() -> List[List[IndicatorInfo]]:
        return [[
            IndicatorInfo(key="total_returns", label="TotalReturns", color="#aa4643", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="annualized_returns", label="AnnualReturns", color="#aa4643", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="alpha", label="Alpha", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="beta", label="Beta", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="sharpe", label="Sharpe", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="sortino", label="Sortino", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="weekly_ulcer_index", label="WeeklyUlcerIndex", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1.4),
        ], [
            IndicatorInfo(key="benchmark_total_returns", label="BenchmarkReturns", color="#4572a7", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="benchmark_annualized_returns", label="BenchmarkAnnual", color="#4572a7", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="volatility", label="Volatility", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="tracking_error", label="TrackingError", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="downside_risk", label="DownsideRisk", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="information_ratio", label="InformationRatio", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="weekly_ulcer_performance_index", label="WeeklyUlcerPerformanceIndex", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1.4),
        ], [
            IndicatorInfo(key="excess_cum_returns", label="ExcessCumReturns", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="win_rate", label="WinRate", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="weekly_win_rate", label="WeeklyWinRate", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="profit_loss_rate", label="ProfitLossRate", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="max_drawdown", label="MaxDrawDown", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="max_dd_ddd", label="MaxDD/MaxDDD", color="#000000", formatter="{}", value_font_size=6, label_width_multiplier=1),
            IndicatorInfo(key="weekly_excess_ulcer_index", label="WeeklyExcessUlcerIndex", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1.4),
        ]]

    @staticmethod
    def get_weekly_indicators() -> List[List[IndicatorInfo]]:
        return [[
            IndicatorInfo(key="weekly_alpha", label="WeeklyAlpha", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="weekly_beta", label="WeeklyBeta", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="weekly_sharpe", label="WeeklySharpe", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="weekly_information_ratio", label="WeeklyInfoRatio", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="weekly_tracking_error", label="WeeklyTrackingError", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="weekly_max_drawdown", label="WeeklyMaxDrawdown", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="weekly_excess_sharpe", label="WeeklyExcessSharpe", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1.4),
        ]]

    @staticmethod
    def get_excess_indicators() -> List[List[IndicatorInfo]]:
        return [[
            IndicatorInfo(key="excess_returns", label="ExcessReturns", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="excess_annual_returns", label="ExcessAnnual", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="excess_sharpe", label="ExcessSharpe", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="excess_volatility", label="ExcessVolatility", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="excess_max_drawdown", label="ExcessMaxDD", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="excess_max_dd_ddd", label="ExcessMaxDD/ExcessMaxDDD", color="#000000", formatter="{}", value_font_size=6, label_width_multiplier=1),
            IndicatorInfo(key="weekly_excess_ulcer_performance_index", label="WeeklyExcessUlcerPerformanceIndex", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1.4),
        ]]


@fieldwise_init
struct RiceQuant:

    var p_nav: List[Float64]
    var b_nav: List[Float64]

    comptime INDICATOR_WIDTH: Float64 = 0.22
    comptime INDICATOR_VALUE_HEIGHT: Float64 = 0.15
    comptime INDICATOR_LABEL_HEIGHT: Float64 = 0.1

    def geometric_excess_returns(self) -> Float64:
        if len(self.b_nav) == 0 or len(self.p_nav) == 0 or self.b_nav[0] == 0:
            return 0.0
        return self.p_nav[0] / self.b_nav[0] - 1.0

    @staticmethod
    def get_indicators() -> List[List[IndicatorInfo]]:
        return [[
            IndicatorInfo(key="total_returns", label="TotalReturns", color="#aa4643", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="annualized_returns", label="AnnualReturns", color="#aa4643", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="alpha", label="Alpha", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="beta", label="Beta", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="win_rate", label="WinRate", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
        ], [
            IndicatorInfo(key="sharpe", label="Sharpe", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="weekly_sharpe", label="WeeklySharpe", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="monthly_sharpe", label="MonthlySharpe", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="information_ratio", label="InformationRatio", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="sortino", label="Sortino", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
        ], [
            IndicatorInfo(key="volatility", label="Volatility", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="weekly_volatility", label="WeeklyVolatility", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="monthly_volatility", label="MonthlyVolatility", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="max_drawdown", label="MaxDrawDown", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="max_dd_ddd", label="MaxDD/MaxDDD", color="#000000", formatter="{}", value_font_size=6, label_width_multiplier=1),
        ]]

    @staticmethod
    def get_excess_indicators() -> List[List[IndicatorInfo]]:
        return [[
            IndicatorInfo(key="benchmark_total_returns", label="BenchmarkReturns", color="#4572a7", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="benchmark_annualized_returns", label="BenchmarkAnnual", color="#4572a7", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="excess_returns", label="ExcessReturns", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="excess_annual_returns", label="ExcessAnnual", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="excess_cum_returns", label="ExcessCumReturns", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
        ], [
            IndicatorInfo(key="excess_sharpe", label="ExcessSharpe", color="#000000", formatter="{0:.4}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="excess_volatility", label="ExcessVolatility", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="excess_win_rate", label="ExcessWinRate", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="excess_max_drawdown", label="ExcessMaxDD", color="#000000", formatter="{0:.3%}", value_font_size=11, label_width_multiplier=1),
            IndicatorInfo(key="excess_max_dd_ddd", label="ExcessMaxDD/ExcessMaxDDD", color="#000000", formatter="{}", value_font_size=6, label_width_multiplier=1),
        ]]

    @staticmethod
    def get_weekly_indicators() -> List[List[IndicatorInfo]]:
        return []


struct PlotConst:
    comptime DEFAULT_WIDTH: Int = 800
    comptime DEFAULT_HEIGHT: Int = 400
    comptime DEFAULT_DPI: Int = 100
