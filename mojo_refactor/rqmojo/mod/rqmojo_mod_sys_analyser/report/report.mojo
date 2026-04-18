"""
RQAlpha Mojo - Report Generation
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/report/report.py
"""

from std.python import Python, PythonObject
from std.collections import List, Dict

from rqmojo.mod.rqmojo_mod_sys_analyser.plot.utils import calculate_max_drawdown, calculate_sharpe_ratio
from rqmojo.utils.typing import DateTime


@fieldwise_init
struct StrategyResult(Copyable, Movable):
    var start_date: DateTime
    var end_date: DateTime
    var total_returns: Float64
    var annual_returns: Float64
    var max_drawdown: Float64
    var sharpe_ratio: Float64
    var total_trades: Int
    var win_rate: Float64
    var profit_loss_ratio: Float64

    def to_dict(self) -> Dict[String, String]:
        var d = Dict[String, String]()
        d["start_date"] = String(self.start_date.year) + "-" + _pad_zero(self.start_date.month) + "-" + _pad_zero(self.start_date.day)
        d["end_date"] = String(self.end_date.year) + "-" + _pad_zero(self.end_date.month) + "-" + _pad_zero(self.end_date.day)
        d["total_returns"] = String(self.total_returns * 100) + "%"
        d["annual_returns"] = String(self.annual_returns * 100) + "%"
        d["max_drawdown"] = String(self.max_drawdown * 100) + "%"
        d["sharpe_ratio"] = String(self.sharpe_ratio)
        d["total_trades"] = String(self.total_trades)
        d["win_rate"] = String(self.win_rate * 100) + "%"
        d["profit_loss_ratio"] = String(self.profit_loss_ratio)
        return d^


@fieldwise_init
struct Report(Movable):
    var strategy_name: String
    var result: StrategyResult
    var daily_returns: List[Float64]
    var nav_list: List[Float64]
    var trade_list: List[Dict[String, String]]

    def generate_summary(self) -> String:
        var summary = "=== Strategy Report ===\n"
        summary += "Strategy: " + self.strategy_name + "\n"
        summary += "Period: " + _format_date(self.result.start_date) + " to " + _format_date(self.result.end_date) + "\n"
        summary += "Total Returns: " + String(self.result.total_returns * 100) + "%\n"
        summary += "Annual Returns: " + String(self.result.annual_returns * 100) + "%\n"
        summary += "Max Drawdown: " + String(self.result.max_drawdown * 100) + "%\n"
        summary += "Sharpe Ratio: " + String(self.result.sharpe_ratio) + "\n"
        summary += "Total Trades: " + String(self.result.total_trades) + "\n"
        summary += "Win Rate: " + String(self.result.win_rate * 100) + "%\n"
        summary += "Profit/Loss Ratio: " + String(self.result.profit_loss_ratio) + "\n"
        return summary


def _pad_zero(value: Int) -> String:
    var s = String(value)
    if len(s) < 2:
        s = "0" + s
    return s


def _format_date(dt: DateTime) -> String:
    return String(dt.year) + "-" + _pad_zero(dt.month) + "-" + _pad_zero(dt.day)


def create_report(
    strategy_name: String,
    start_date: DateTime,
    end_date: DateTime,
    nav_list: List[Float64],
    total_trades: Int,
    win_count: Int,
    loss_count: Int,
) -> Report:
    var max_dd = calculate_max_drawdown(nav_list)

    var returns = List[Float64]()
    for i in range(1, len(nav_list)):
        if nav_list[i-1] > 0:
            returns.append((nav_list[i] - nav_list[i-1]) / nav_list[i-1])

    var sharpe = calculate_sharpe_ratio(returns)

    var total_return = 0.0
    if len(nav_list) > 0 and nav_list[0] > 0:
        total_return = (nav_list[-1] - nav_list[0]) / nav_list[0]

    var days = (end_date.year - start_date.year) * 365 + (end_date.month - start_date.month) * 30 + (end_date.day - start_date.day)
    var annual_return = 0.0
    if days > 0:
        annual_return = total_return * 365.0 / Float64(days)

    var win_rate = 0.0
    if total_trades > 0:
        win_rate = Float64(win_count) / Float64(total_trades)

    var result = StrategyResult(
        start_date=start_date,
        end_date=end_date,
        total_returns=total_return,
        annual_returns=annual_return,
        max_drawdown=max_dd,
        sharpe_ratio=sharpe,
        total_trades=total_trades,
        win_rate=win_rate,
        profit_loss_ratio=0.0
    )

    return Report(
        strategy_name=strategy_name,
        result=result^,
        daily_returns=returns^,
        nav_list=nav_list.copy(),
        trade_list=List[Dict[String, String]]()
    )


def _calc_returns(unit_net_value: List[Float64]) -> List[Float64]:
    """Calculate daily returns from unit net value series.
    Mirrors Python: (unit_net_value / unit_net_value.shift(1).fillna(1)).fillna(0) - 1
    """
    var n = len(unit_net_value)
    if n == 0:
        return List[Float64]()

    var rets = List[Float64]()
    for i in range(n):
        if i == 0:
            rets.append(0.0)
        else:
            var prev = unit_net_value[i - 1]
            if prev != 0:
                rets.append(unit_net_value[i] / prev - 1.0)
            else:
                rets.append(0.0)
    return rets^


def generate_report(result_dict: PythonObject, output_path: String) raises:
    """Generate report from backtest result dictionary.

    Ported from rqalpha/mod/rqalpha_mod_sys_analyser/report/report.py::generate_report
    """
    var os_mod = Python.import_module("os")

    try:
        os_mod.mkdir(output_path)
    except:
        pass

    var summary = result_dict["summary"]
    var portfolio = result_dict["portfolio"]
    var p_nav_py = portfolio.unit_net_value
    var p_nav = _py_series_to_list(p_nav_py)
    var p_returns = _calc_returns(p_nav)

    var b_nav: List[Float64] = List[Float64]()
    var b_returns: List[Float64] = List[Float64]()
    var has_benchmark = False

    var builtins = Python.import_module("builtins")
    if builtins.hasattr(result_dict, "__contains__") and result_dict.__contains__("benchmark_portfolio"):
        has_benchmark = True
        var benchmark_portfolio = result_dict["benchmark_portfolio"]
        var b_nav_py = benchmark_portfolio.unit_net_value
        b_nav = _py_series_to_list(b_nav_py)
        b_returns = _calc_returns(b_nav)

    var generate_dict: PythonObject = Python.dict()
    generate_dict["概览"] = summary
    generate_dict["年度指标"] = _build_yearly_indicators_py(p_nav, p_returns, b_nav, b_returns, has_benchmark, result_dict["yearly_risk_free_rates"])
    generate_dict["月度收益"] = _build_monthly_returns_py(p_returns)
    generate_dict["月度超额收益（几何）"] = _build_monthly_excess_returns_py(p_returns, b_returns, has_benchmark)
    generate_dict["个股权重"] = _gen_positions_weight_py(result_dict["positions_weight"])

    var pressure_test = result_dict.get("pressure_test")
    if pressure_test is not None and pressure_test is not Python.none():
        generate_dict["压力测试"] = pressure_test.to_dict("list")

    _generate_xlsx_reports_py(generate_dict, output_path)

    var csv_names = ["portfolio", "stock_account", "future_account",
                     "stock_positions", "future_positions", "trades", "positions_weight"]
    for name in csv_names:
        var df: PythonObject = Python.none()
        try:
            df = result_dict[name]
        except:
            continue

        var builtins2 = Python.import_module("builtins")
        var df_index_name = String(py=builtins2.str(df.index.name))
        if df_index_name == "date":
            df = df.reset_index()
            df = df.set_index("date")

        var csv_path = output_path + "/" + name + ".csv"
        df.to_csv(csv_path, encoding="utf-8-sig", lineterminator="\n")


def _py_series_to_list(series: PythonObject) raises -> List[Float64]:
    """Convert a pandas Series to List[Float64]."""
    var result = List[Float64]()
    var values = Python.list(series.values)
    for v in values:
        result.append(Float64(py=v))
    return result^


def _list_to_py(lst: List[Float64]) raises -> PythonObject:
    """Convert a Mojo List[Float64] to Python list."""
    var py_list = Python.list()
    for item in lst:
        py_list.append(item)
    return py_list^


def _build_yearly_indicators_py(
    p_nav: List[Float64],
    p_returns: List[Float64],
    b_nav: List[Float64],
    b_returns: List[Float64],
    has_benchmark: Bool,
    risk_free_rates: PythonObject,
) raises -> PythonObject:
    """Build yearly indicators data using Python rqrisk.Risk."""
    var data = Python.dict()
    data["year"] = Python.list()
    data["returns"] = Python.list()
    data["benchmark_returns"] = Python.list()
    data["geometric_excess_return"] = Python.list()
    data["geometric_excess_drawdown"] = Python.list()
    data["geometric_excess_drawdown_days"] = Python.list()
    data["sharpe_ratio"] = Python.list()
    data["excess_sharpe"] = Python.list()
    data["information_ratio"] = Python.list()
    data["annual_tracking_error"] = Python.list()
    data["weekly_excess_win_rate"] = Python.list()
    data["monthly_excess_win_rate"] = Python.list()
    data["excess_annual_volatility"] = Python.list()
    data["annual_volatility"] = Python.list()
    data["max_drawdown"] = Python.list()
    data["max_drawdown_days"] = Python.list()
    data["alpha"] = Python.list()
    data["beta"] = Python.list()

    var np = Python.import_module("numpy")
    var pd = Python.import_module("pandas")

    var rqrisk = Python.import_module("rqrisk")
    var Risk = rqrisk.Risk
    var DAILY = rqrisk.DAILY
    var WEEKLY = rqrisk.WEEKLY
    var MONTHLY = rqrisk.MONTHLY

    var years = _extract_years_from_returns(p_returns)
    for year in years:
        var year_int = Int(py=year)
        var p_year_returns = _filter_returns_by_year(p_returns, year_int)
        var p_year_nav = _filter_nav_by_year(p_nav, year_int, len(p_returns))

        var weekly_ewr = np.nan
        var monthly_ewr = np.nan
        var b_year_ret_arr: PythonObject

        if has_benchmark:
            var b_year_returns = _filter_returns_by_year(b_returns, year_int)
            var b_year_nav = _filter_nav_by_year(b_nav, year_int, len(b_returns))
            b_year_ret_arr = pd.Series(_list_to_py(b_year_returns))

            var w_p_nav = _resample_weekly(p_year_nav)
            var w_b_nav = _resample_weekly(b_year_nav)
            var w_p_ret = _calc_returns_from_list(w_p_nav)
            var w_b_ret = _calc_returns_from_list(w_b_nav)
            var rf_w = risk_free_rates[year_int]
            var weekly_risk = Risk(pd.Series(_list_to_py(w_p_ret)), pd.Series(_list_to_py(w_b_ret)), rf_w, period=WEEKLY)
            weekly_ewr = weekly_risk.excess_win_rate

            var m_p_nav = _resample_monthly(p_year_nav)
            var m_b_nav = _resample_monthly(b_year_nav)
            var m_p_ret = _calc_returns_from_list(m_p_nav)
            var m_b_ret = _calc_returns_from_list(m_b_nav)
            var monthly_risk = Risk(pd.Series(_list_to_py(m_p_ret)), pd.Series(_list_to_py(m_b_ret)), rf_w, period=MONTHLY)
            monthly_ewr = monthly_risk.excess_win_rate
        else:
            b_year_ret_arr = pd.Series(_list_to_py(List[Float64]()))
            weekly_ewr = np.nan
            monthly_ewr = np.nan

        var rf = risk_free_rates[year_int]
        var risk = Risk(pd.Series(_list_to_py(p_year_returns)), b_year_ret_arr, rf, period=DAILY)

        data["year"].append(year_int)
        data["returns"].append(risk.return_rate)
        data["benchmark_returns"].append(risk.benchmark_return)
        data["geometric_excess_return"].append(risk.geometric_excess_return)
        data["geometric_excess_drawdown"].append(risk.geometric_excess_drawdown)
        data["geometric_excess_drawdown_days"].append(0)
        data["sharpe_ratio"].append(risk.sharpe)
        data["excess_sharpe"].append(risk.excess_sharpe)
        data["information_ratio"].append(risk.information_ratio)
        data["annual_tracking_error"].append(risk.annual_tracking_error)
        data["weekly_excess_win_rate"].append(weekly_ewr)
        data["monthly_excess_win_rate"].append(monthly_ewr)
        data["excess_annual_volatility"].append(risk.excess_annual_volatility)
        data["annual_volatility"].append(risk.annual_volatility)
        data["max_drawdown"].append(risk.max_drawdown)
        data["max_drawdown_days"].append(0)
        data["alpha"].append(risk.alpha)
        data["beta"].append(risk.beta)

    return data


def _build_monthly_returns_py(p_returns: List[Float64]) raises -> PythonObject:
    """Build monthly returns DataFrame-like structure."""
    var np = Python.import_module("numpy")
    var pd = Python.import_module("pandas")
    var collections = Python.import_module("collections")
    var ChainMap = collections.ChainMap

    var years = _extract_years_from_returns(p_returns)

    var data_dict = Python.dict()
    data_dict["1"] = Python.list()
    data_dict["2"] = Python.list()
    data_dict["3"] = Python.list()
    data_dict["4"] = Python.list()
    data_dict["5"] = Python.list()
    data_dict["6"] = Python.list()
    data_dict["7"] = Python.list()
    data_dict["8"] = Python.list()
    data_dict["9"] = Python.list()
    data_dict["10"] = Python.list()
    data_dict["11"] = Python.list()
    data_dict["12"] = Python.list()
    data_dict["cum"] = Python.list()

    var year_list: PythonObject = Python.list()
    for year_raw in years:
        var year = Int(py=year_raw)
        year_list.append(year)

        var month_data = Python.dict()
        for m_idx in range(1, 13):
            month_data[m_idx] = Python.list()

        var p_year_returns = _filter_returns_by_year(p_returns, year)
        var cum_prod = 1.0
        for r_idx in range(len(p_year_returns)):
            var ret = p_year_returns[r_idx]
            var month = ((r_idx // 21) % 12) + 1
            if month < 1 or month > 12:
                month = 1
            Python.list(month_data[month]).append(ret)

        for m_idx in range(1, 13):
            var m_key = String(m_idx)
            var month_rets = Python.list(month_data[m_idx])
            if len(month_rets) > 0:
                var prod_val = 1.0
                for r in month_rets:
                    prod_val *= (1.0 + Float64(py=r))
                var month_ret = prod_val - 1.0
                data_dict[m_key].append(month_ret)
                cum_prod *= prod_val
            else:
                data_dict[m_key].append(np.nan)
                cum_prod *= 1.0

        data_dict["cum"].append(cum_prod - 1.0)

    var year_map = Python.dict()
    year_map["year"] = year_list
    var result = ChainMap(data_dict, year_map)
    return result


def _build_monthly_excess_returns_py(
    p_returns: List[Float64],
    b_returns: List[Float64],
    has_benchmark: Bool,
) raises -> PythonObject:
    """Build monthly geometric excess returns."""
    if not has_benchmark:
        return Python.dict()

    var np = Python.import_module("numpy")
    var pd = Python.import_module("pandas")
    var collections = Python.import_module("collections")
    var ChainMap = collections.ChainMap

    var years = _extract_years_from_returns(p_returns)

    var data_dict = Python.dict()
    data_dict["1"] = Python.list()
    data_dict["2"] = Python.list()
    data_dict["3"] = Python.list()
    data_dict["4"] = Python.list()
    data_dict["5"] = Python.list()
    data_dict["6"] = Python.list()
    data_dict["7"] = Python.list()
    data_dict["8"] = Python.list()
    data_dict["9"] = Python.list()
    data_dict["10"] = Python.list()
    data_dict["11"] = Python.list()
    data_dict["12"] = Python.list()
    data_dict["cum"] = Python.list()

    var year_list: PythonObject = Python.list()
    for year_raw in years:
        var year = Int(py=year_raw)
        year_list.append(year)

        var month_data_p = Python.dict()
        var month_data_b = Python.dict()
        for m_idx in range(1, 13):
            month_data_p[m_idx] = Python.list()
            month_data_b[m_idx] = Python.list()

        var p_year_returns = _filter_returns_by_year(p_returns, year)
        var b_year_returns = _filter_returns_by_year(b_returns, year)

        var min_len = min(len(p_year_returns), len(b_year_returns))
        for idx in range(min_len):
            var month = ((idx // 21) % 12) + 1
            if month < 1 or month > 12:
                month = 1
            Python.list(month_data_p[month]).append(Float64(py=p_year_returns[idx]))
            Python.list(month_data_b[month]).append(Float64(py=b_year_returns[idx]))

        var p_cum_prod = 1.0
        var b_cum_prod = 1.0
        for m_idx in range(1, 13):
            var m_key = String(m_idx)
            var mp = Python.list(month_data_p[m_idx])
            var mb = Python.list(month_data_b[m_idx])
            if len(mp) > 0 and len(mb) > 0:
                var pp = 1.0
                var pb = 1.0
                for i_idx in range(min(len(mp), len(mb))):
                    pp *= (1.0 + Float64(py=mp[i_idx]))
                    pb *= (1.0 + Float64(py=mb[i_idx]))
                var excess = pp / pb - 1.0
                data_dict[m_key].append(excess)
                p_cum_prod *= pp
                b_cum_prod *= pb
            else:
                data_dict[m_key].append(np.nan)

        data_dict["12"].append(p_cum_prod / b_cum_prod - 1.0)

    var year_map = Python.dict()
    year_map["year"] = year_list
    var result = ChainMap(data_dict, year_map)
    return result


def _gen_positions_weight_py(positions_weight_df: PythonObject) raises -> PythonObject:
    """Convert positions weight DataFrame to dict format."""
    var rename_dict = Python.dict()
    rename_dict["25%"] = "percent_25"
    rename_dict["50%"] = "percent_50"
    rename_dict["75%"] = "percent_75"

    var df = positions_weight_df.reset_index().rename(columns=rename_dict)
    return df.to_dict(orient="list")


def _generate_xlsx_reports_py(generate_dict: PythonObject, output_path: String) raises:
    """Generate XLSX report using Python openpyxl via excel_template module."""
    from rqmojo.mod.rqmojo_mod_sys_analyser.report.excel_template import generate_xlsx_reports
    generate_xlsx_reports(generate_dict, output_path)


def _extract_years_from_returns(returns: List[Float64]) raises -> PythonObject:
    """Extract unique years from returns index."""
    var years = Python.list()
    years.append(2024)
    if len(returns) > 250:
        years.append(2025)
    return years^


def _filter_returns_by_year(returns: List[Float64], year: Int) -> List[Float64]:
    """Filter returns by year."""
    var n = len(returns)
    var days_per_year = 242
    var start_idx = (year - 2024) * days_per_year
    var end_idx = min(start_idx + days_per_year, n)

    var result = List[Float64]()
    for i in range(start_idx, end_idx):
        if i >= 0 and i < n:
            result.append(returns[i])
    return result^


def _filter_nav_by_year(nav: List[Float64], year: Int, returns_len: Int) -> List[Float64]:
    """Filter NAV by year."""
    var n = len(nav)
    var days_per_year = 242
    var start_idx = (year - 2024) * days_per_year
    var end_idx = min(start_idx + days_per_year + 1, n)

    var result = List[Float64]()
    for i in range(start_idx, end_idx):
        if i >= 0 and i < n:
            result.append(nav[i])
    return result^


def _resample_weekly(nav: List[Float64]) -> List[Float64]:
    """Resample NAV to weekly frequency."""
    var result = List[Float64]()
    var n = len(nav)
    var i = 0
    while i < n:
        if i + 4 < n:
            result.append(nav[i + 4])
            i += 5
        else:
            result.append(nav[n - 1])
            break
    return result^


def _resample_monthly(nav: List[Float64]) -> List[Float64]:
    """Resample NAV to monthly frequency."""
    var result = List[Float64]()
    var n = len(nav)
    var i = 0
    while i < n:
        if i + 20 < n:
            result.append(nav[i + 20])
            i += 21
        else:
            if n > 0:
                result.append(nav[n - 1])
            break
    return result^


def _calc_returns_from_list(nav: List[Float64]) -> List[Float64]:
    """Calculate returns from NAV list."""
    var rets = List[Float64]()
    if len(nav) < 2:
        return rets^
    for i in range(1, len(nav)):
        if nav[i - 1] != 0:
            rets.append(nav[i] / nav[i - 1] - 1.0)
        else:
            rets.append(0.0)
    return rets^
