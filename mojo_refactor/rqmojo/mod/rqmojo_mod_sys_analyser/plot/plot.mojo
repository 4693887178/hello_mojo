"""
RQAlpha Mojo - Plot Implementation
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/plot/plot.py
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.plot.consts import (
    ChartType, Color, IndicatorInfo, LineInfo, SpotInfo,
    IndexRange, PlotConst,
    IMG_WIDTH, PLOT_TITLE_HEIGHT, INDICATOR_AREA_HEIGHT,
    PLOT_AREA_HEIGHT, USER_PLOT_AREA_HEIGHT, LABEL_FONT_SIZE,
    TITLE_FONT_SIZE, BLACK_STR,
    LINE_STRATEGY, LINE_BENCHMARK, LINE_EXCESS,
    LINE_WEEKLY, LINE_WEEKLY_BENCHMARK,
    MAX_DD_INFO, MAX_DDD_INFO, OPEN_POINT_INFO, CLOSE_POINT_INFO
)
from rqmojo.utils.typing import DateTime


@fieldwise_init
struct SubPlotData(Copyable, Movable):
    var height: Int
    var right_pad: Int


@fieldwise_init
struct IndicatorAreaData(Copyable, Movable):
    var height: Int
    var right_pad: Int
    var indicator_keys: List[String]
    var values: Dict[String, String]
    var strategy_name: String

    def format_value(self, key: String) raises -> String:
        if key in self.values:
            return self.values[key]
        return "nan"


@fieldwise_init
struct ReturnPlotData(Copyable, Movable):
    var height: Int
    var right_pad: Int
    var return_names: List[String]
    var spot_labels: List[String]


@fieldwise_init
struct UserPlotData(Copyable, Movable):
    var height: Int
    var right_pad: Int
    var column_names: List[String]


@fieldwise_init
struct TitlePlotData(Copyable, Movable):
    var height: Int
    var right_pad: Int
    var strategy_name: String
    var indicator_area_rows: Int


@fieldwise_init
struct ReturnLineItem(Copyable, Movable):
    var returns: List[Float64]
    var info: LineInfo


@fieldwise_init
struct SpotLineItem(Copyable, Movable):
    var positions: List[Int]
    var info: SpotInfo


@fieldwise_init
struct PlotResultConfig(Copyable, Movable):
    var show: Bool
    var save_path: Optional[String]
    var weekly_indicators: Bool
    var open_close_points: Bool
    var strategy_name: Optional[String]

    @staticmethod
    def default() -> PlotResultConfig:
        return PlotResultConfig(
            show=True,
            save_path=None,
            weekly_indicators=False,
            open_close_points=False,
            strategy_name=None
        )


@fieldwise_init
struct PlotData(Copyable, Movable):
    var x: List[String]
    var y: List[Float64]
    var name: String
    var chart_type: ChartType
    var color: Color


@fieldwise_init
struct PlotFigure(Movable):
    var title: String
    var x_label: String
    var y_label: String
    var width: Int
    var height: Int
    var data_series: List[PlotData]

    def add_line(mut self, var x: List[String], var y: List[Float64], name: String, var color: Color = Color.BLUE()) -> None:
        var data = PlotData(
            x=x^,
            y=y^,
            name=name,
            chart_type=ChartType.LINE(),
            color=color^
        )
        self.data_series.append(data^)

    def add_bar(mut self, var x: List[String], var y: List[Float64], name: String, var color: Color = Color.RED()) -> None:
        var data = PlotData(
            x=x^,
            y=y^,
            name=name,
            chart_type=ChartType.BAR(),
            color=color^
        )
        self.data_series.append(data^)

    def to_json(self) -> String:
        var json = "{\"title\":\"" + self.title + "\","
        json += "\"x_label\":\"" + self.x_label + "\","
        json += "\"y_label\":\"" + self.y_label + "\","
        json += "\"width\":" + String(self.width) + ","
        json += "\"height\":" + String(self.height) + ","
        json += "\"data\":["

        for i in range(len(self.data_series)):
            if i > 0:
                json += ","
            var d = self.data_series[i].copy()
            json += "{\"name\":\"" + d.name + "\","
            json += "\"type\":\"" + d.chart_type.value + "\","
            var color_str = String.write(d.color)
            json += "\"color\":\"" + color_str + "\","
            json += "\"x\":["
            for j in range(len(d.x)):
                if j > 0:
                    json += ","
                json += "\"" + d.x[j] + "\""
            json += "],\"y\":["
            for j in range(len(d.y)):
                if j > 0:
                    json += ","
                json += String(d.y[j])
            json += "]}"

        json += "]}"
        return json


def create_figure(
    title: String = "",
    x_label: String = "Date",
    y_label: String = "Value",
    width: Int = 800,
    height: Int = 400
) -> PlotFigure:
    return PlotFigure(
        title=title,
        x_label=x_label,
        y_label=y_label,
        width=width,
        height=height,
        data_series=List[PlotData]()
    )


def plot_result(
    result_dict: Dict[String, PythonObject],
    config: PlotResultConfig = PlotResultConfig.default()
) raises -> String:
    from std.python import PythonObject
    from std.python import Python

    var summary = _extract_dict(result_dict, "summary")
    var portfolio = _extract_dict(result_dict, "portfolio")

    var nav_list = _extract_nav(portfolio)
    var index_dates = _extract_index_dates(portfolio)

    var return_lines: List[ReturnLineItem] = List[ReturnLineItem]()
    var returns = _calculate_cumulative_returns(nav_list)
    return_lines.append(ReturnLineItem(returns=returns^, info=LINE_STRATEGY()))

    var ex_max_dd_ddd = "nan"

    if "benchmark_portfolio" in result_dict:
        var benchmark_portfolio = _extract_dict(result_dict, "benchmark_portfolio")
        var bench_nav = _extract_nav(benchmark_portfolio)
        var ex_returns = _geometric_excess_returns(nav_list, bench_nav)
        ex_max_dd_ddd = _format_ex_max_dd_ddd(ex_returns, nav_list, index_dates)
        var bench_returns = _calculate_cumulative_returns(bench_nav)
        return_lines.append(ReturnLineItem(returns=bench_returns^, info=LINE_BENCHMARK()))
        return_lines.append(ReturnLineItem(returns=ex_returns^, info=LINE_EXCESS()))

        if config.weekly_indicators:
            var wr = _weekly_returns_from_nav(bench_nav, index_dates)
            return_lines.append(ReturnLineItem(returns=wr^, info=LINE_WEEKLY_BENCHMARK()))

    if config.weekly_indicators:
        var wr = _weekly_returns_from_nav(nav_list, index_dates)
        return_lines.append(ReturnLineItem(returns=wr^, info=LINE_WEEKLY()))

    var dd_range = max_dd(nav_list, index_dates)
    var max_dd_duration = _get_summary_int(summary, "max_drawdown_duration", 0)

    var spots_on_returns: List[SpotLineItem] = List[SpotLineItem]()
    var dd_positions = List[Int]()
    dd_positions.append(dd_range.start)
    dd_positions.append(dd_range.end)
    spots_on_returns.append(SpotLineItem(positions=dd_positions^, info=MAX_DD_INFO()))

    var ddd_positions = List[Int]()
    ddd_positions.append(0)
    ddd_positions.append(max_dd_duration)
    spots_on_returns.append(SpotLineItem(positions=ddd_positions^, info=MAX_DDD_INFO()))

    if config.open_close_points:
        if "trades" in result_dict:
            var trades_obj = result_dict["trades"]
            var close_dates = _extract_trade_dates(trades_obj, "CLOSE")
            var open_dates = _extract_trade_dates(trades_obj, "OPEN")

            var close_idx = trading_dates_index(close_dates, "CLOSE", index_dates)
            var open_idx = trading_dates_index(open_dates, "OPEN", index_dates)

            if len(close_idx) > 0:
                spots_on_returns.append(SpotLineItem(positions=close_idx^, info=CLOSE_POINT_INFO()))
            if len(open_idx) > 0:
                spots_on_returns.append(SpotLineItem(positions=open_idx^, info=OPEN_POINT_INFO()))

    var fig = create_figure(
        title=_get_summary_string(summary, "strategy_file", "Strategy"),
        width=PlotConst.DEFAULT_WIDTH,
        height=PLOT_AREA_HEIGHT + INDICATOR_AREA_HEIGHT
    )

    for item in return_lines:
        var rets = item.returns.copy()
        var x_copy = index_dates.copy()
        fig.add_line(x_copy^, rets^, item.info.label, Color.from_hex(item.info.color))

    var output = fig.to_json()

    if config.save_path is not None:
        var path_str = String(config.save_path)
        _save_output(output, path_str)

    return output


def _extract_dict(parent: Dict[String, PythonObject], key: String) raises -> Dict[String, PythonObject]:
    if key in parent:
        var obj = parent[key]
        var result = Dict[String, PythonObject]()
        try:
            var keys_attr = obj.__dict__["keys"]()
            for k in keys_attr:
                result[String(py=k)] = obj.__dict__[k]
        except:
            pass
        return result^
    return Dict[String, PythonObject]()


def _extract_nav(portfolio: Dict[String, PythonObject]) raises -> List[Float64]:
    var result = List[Float64]()
    if "unit_net_value" in portfolio:
        var unv = portfolio["unit_net_value"]
        try:
            var vals = unv.values
            var n = Int(py=len(vals))
            for i in range(n):
                result.append(Float64(py=vals[i]))
        except:
            pass
    return result^


def _extract_index_dates(portfolio: Dict[String, PythonObject]) raises -> List[String]:
    var result = List[String]()
    if "index" in portfolio or "unit_net_value" in portfolio:
        var idx_obj = portfolio["unit_net_value"]
        try:
            var idx = idx_obj.index
            var n = Int(py=len(idx))
            for i in range(n):
                var dt = idx[i]
                result.append(String(py=dt))
        except:
            pass
    return result^


def _calculate_cumulative_returns(nav_list: List[Float64]) -> List[Float64]:
    var result = List[Float64]()
    if len(nav_list) == 0:
        return result^
    var base = nav_list[0]
    if base == 0:
        base = 1.0
    for nav in nav_list:
        result.append(nav / base - 1.0)
    return result^


def _geometric_excess_returns(p_nav: List[Float64], b_nav: List[Float64]) -> List[Float64]:
    var result = List[Float64]()
    var n = min(len(p_nav), len(b_nav))
    for i in range(n):
        if b_nav[i] != 0:
            result.append(p_nav[i] / b_nav[i] - 1.0)
        else:
            result.append(0.0)
    return result^


def _format_ex_max_dd_ddd(ex_returns: List[Float64], nav_list: List[Float64], index: List[String]) -> String:
    var adj_returns = List[Float64]()
    for r in ex_returns:
        adj_returns.append(r + 1.0)

    var dd = max_dd(adj_returns, index)
    var ddd = max_ddd(adj_returns, index)

    var dd_repr = String.write(dd)
    var ddd_repr = String.write(ddd)
    return "MaxDD " + dd_repr + "\nMaxDDD " + ddd_repr


def _weekly_returns_from_nav(nav_list: List[Float64], dates: List[String]) -> List[Float64]:
    return weekly_returns(nav_list, dates)


def _get_summary_string(summary: Dict[String, PythonObject], key: String, default: String) raises -> String:
    if key in summary:
        return String(py=summary[key])
    return default


def _get_summary_int(summary: Dict[String, PythonObject], key: String, default: Int) raises -> Int:
    if key in summary:
        return Int(py=summary[key])
    return default


def _extract_trade_dates(trades_obj: PythonObject, effect: String) raises -> List[String]:
    var result = List[String]()
    from std.python import Python
    try:
        var df = trades_obj
        var mask = df[df.position_effect == effect]
        var dates = mask.trading_datetime
        var n = Int(py=len(dates))
        for i in range(n):
            result.append(String(py=dates[i]))
    except:
        pass
    return result^


def _save_output(output: String, path: String) raises:
    from std.python import Python
    var py_builtins = Python.import_module("builtins")
    var f = py_builtins.open(path, "w")
    f.write(output)
    f.close()
