"""
RQAlpha Mojo - Report Module
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/report/report.py

Design (vs Python original):
  Python: Module-level functions using pandas Series/DataFrame + rqrisk.Risk
  Mojo:   Same function signatures delegating to Python via evaluate()/interop

Key functions (matching Python):
  - _returns(unit_net_value) -> returns daily returns from nav series
  - _yearly_indicators(p_nav, p_returns, b_nav, b_returns, risk_free_rates)
  - _monthly_returns(p_returns) -> monthly returns DataFrame
  - _monthly_geometric_excess_returns(p_returns, b_returns)
  - _gen_positions_weight(df) -> positions weight dict
  - generate_report(result_dict, output_path) -> main entry point
"""

from std.python import Python, PythonObject


def _py_none() raises -> PythonObject:
    """Return Python None."""
    var builtins = Python.import_module("builtins")
    return builtins.__getattr__("None")


def _py_is_truthy(obj: PythonObject) raises -> Bool:
    """Check if a Python object is truthy."""
    var builtins = Python.import_module("builtins")
    return Bool(py=builtins.bool(obj))


def _returns(unit_net_value: PythonObject) raises -> PythonObject:
    """
    Calculate daily returns from unit net value Series.

    Ported from Python: unit_net_value.pct_change().fillna(0)

    Args:
        unit_net_value: Pandas Series of NAV values

    Returns:
        Pandas Series of daily returns with NaN filled as 0
    """
    var mod = Python.evaluate(
        "def _calc_returns(nav):\n"
        "    return nav.pct_change().fillna(0)\n",
        file=True,
    )
    var func = mod.__getattr__("_calc_returns")
    return func(unit_net_value)


def _yearly_indicators(
    p_nav: PythonObject,
    p_returns: PythonObject,
    b_nav: PythonObject,
    b_returns: PythonObject,
    risk_free_rates: PythonObject,
) raises -> PythonObject:
    """
    Compute yearly risk indicators using rqrisk.Risk.

    Ported from Python: uses Risk.from_products() to compute yearly metrics.
    Each year gets a dict with keys like alpha, beta, sharpe, max_drawdown, etc.

    Args:
        p_nav: Portfolio NAV Series
        p_returns: Portfolio returns Series
        b_nav: Benchmark NAV Series
        b_returns: Benchmark returns Series
        risk_free_rates: Risk-free rate Series

    Returns:
        Dict mapping year string to indicator dict
    """
    var mod = Python.evaluate(
        "import collections\n"
        "def _calc_yearly_indicators(p_nav, p_returns, b_nav, b_returns, risk_free_rates):\n"
        "    import rqrisk\n"
        "    yearly_indicators = {}\n"
        "    if len(risk_free_rates.index) == 0 or len(b_returns.index) == 0 or len(p_returns.index) == 0:\n"
        "        return yearly_indicators\n"
        "    years = set(idx.year for idx in risk_free_rates.index)\n"
        "    for year in sorted(years):\n"
        "        try:\n"
        "            risk_obj = rqrisk.Risk.from_products(\n"
        "                p_nav=p_nav,\n"
        "                p_returns=p_returns,\n"
        "                b_nav=b_nav,\n"
        "                b_returns=b_returns,\n"
        "                risk_free_rate=risk_free_rates,\n"
        "            )\n"
        "            yearly_indicators[str(year)] = risk_obj.to_dict(year=year)\n"
        "        except Exception:\n"
        "            pass\n"
        "    return yearly_indicators\n",
        file=True,
    )
    var func = mod.__getattr__("_calc_yearly_indicators")
    return func(p_nav, p_returns, b_nav, b_returns, risk_free_rates)


def _monthly_returns(p_returns: PythonObject) raises -> PythonObject:
    """
    Build monthly returns DataFrame with ChainMap structure.

    Ported from Python: builds DataFrame with columns [year, Jan..Dec]
    using ChainMap to merge monthly data.

    Args:
        p_returns: Portfolio returns Series with DatetimeIndex

    Returns:
        DataFrame with monthly returns organized by year/month
    """
    var mod = Python.evaluate(
        "import pandas as pd\n"
        "import datetime\n"
        "import collections\n"
        "def _build_monthly_returns(p_returns):\n"
        "    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',\n"
        "              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']\n"
        "    df_list = []\n"
        "    for year in range(2015, 2031):\n"
        "        data = collections.ChainMap(\n"
        "            {'year': year},\n"
        "            {m: pd.NaT for m in months},\n"
        "        )\n"
        "        df_list.append(data)\n"
        "    df = pd.DataFrame(df_list)\n"
        "    df.set_index(['year'], inplace=True)\n"
        "    grouped = p_returns.resample('M').apply(lambda x: (x + 1).prod() - 1)\n"
        "    for date_idx in grouped.index:\n"
        "        row_year = date_idx.year\n"
        "        month_name = date_idx.strftime('%b')\n"
        "        value = grouped.loc[date_idx]\n"
        "        if row_year in df.index:\n"
        "            df.at[row_year, month_name] = value\n"
        "    return df\n",
        file=True,
    )
    var func = mod.__getattr__("_build_monthly_returns")
    return func(p_returns)


def _monthly_geometric_excess_returns(p_returns: PythonObject, b_returns: PythonObject) raises -> PythonObject:
    """
    Build monthly geometric excess returns DataFrame.

    Ported from Python: similar to _monthly_returns but computes excess returns
    over benchmark using geometric compounding.

    Args:
        p_returns: Portfolio returns Series
        b_returns: Benchmark returns Series

    Returns:
        DataFrame with monthly geometric excess returns by year/month
    """
    var mod = Python.evaluate(
        "import pandas as pd\n"
        "import datetime\n"
        "import collections\n"
        "def _build_monthly_excess(p_returns, b_returns):\n"
        "    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',\n"
        "              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']\n"
        "    df_list = []\n"
        "    for year in range(2015, 2031):\n"
        "        data = collections.ChainMap(\n"
        "            {'year': year},\n"
        "            {m: pd.NaT for m in months},\n"
        "        )\n"
        "        df_list.append(data)\n"
        "    df = pd.DataFrame(df_list)\n"
        "    df.set_index(['year'], inplace=True)\n"
        "    excess_returns = (1 + p_returns) / (1 + b_returns) - 1\n"
        "    grouped = excess_returns.resample('M').apply(lambda x: (x + 1).prod() - 1)\n"
        "    for date_idx in grouped.index:\n"
        "        row_year = date_idx.year\n"
        "        month_name = date_idx.strftime('%b')\n"
        "        value = grouped.loc[date_idx]\n"
        "        if row_year in df.index:\n"
        "            df.at[row_year, month_name] = value\n"
        "    return df\n",
        file=True,
    )
    var func = mod.__getattr__("_build_monthly_excess")
    return func(p_returns, b_returns)


def _gen_positions_weight(df: PythonObject) raises -> PythonObject:
    """
    Convert positions weight DataFrame to nested dict format.

    Ported from Python: converts DataFrame with MultiIndex (date, book_id)
    into {date_str: {book_id: weight}} dict structure.

    Args:
        df: Positions weight DataFrame

    Returns:
        Nested dict {date_string: {book_id: weight}}
    """
    var mod = Python.evaluate(
        "def _convert_positions(df):\n"
        "    result = {}\n"
        "    for idx_tuple in df.index:\n"
        "        date_val = idx_tuple[0]\n"
        "        book_id = idx_tuple[1]\n"
        "        weight = df.loc[idx_tuple]\n"
        "        if hasattr(date_val, 'strftime'):\n"
        "            date_str = str(date_val)[:10]\n"
        "        else:\n"
        "            date_str = str(date_val)\n"
        "        if date_str not in result:\n"
        "            result[date_str] = {}\n"
        "        result[date_str][book_id] = weight\n"
        "    return result\n",
        file=True,
    )
    var func = mod.__getattr__("_convert_positions")
    return func(df)


def generate_report(result_dict: PythonObject, output_path: String) raises -> None:
    """
    Generate analysis report from backtest results.

    Main entry point - ported from Python generate_report().
    Creates report directory, extracts portfolio data, builds report dict,
    generates XLSX reports, exports CSV files.

    Args:
        result_dict: Backtest result dictionary containing:
                     - portfolio: dict with 'unit_net_value', 'total_returns', etc.
                     - benchmark: dict with 'unit_net_value' (optional)
                     - positions: list of position dicts
                     - summary: dict with trade info`.
        output_path: Directory path to write report files`.
    """
    var os_mod = Python.import_module("os")

    if not Bool(py=os_mod.path.exists(output_path)):
        os_mod.makedirs(output_path)

    var portfolio = result_dict.get("portfolio", Python.dict())
    var unit_net_value = portfolio.get("unit_net_value", _py_none())
    var total_returns = portfolio.get("total_returns", _py_none())

    var benchmark = result_dict.get("benchmark", Python.dict())
    var benchmark_unit_net_value = benchmark.get("unit_net_value", _py_none())

    var p_returns = _returns(unit_net_value)
    var b_returns = _py_none()

    if _py_is_truthy(benchmark_unit_net_value):
        b_returns = _returns(benchmark_unit_net_value)

    var report = Python.dict()

    var overview_data = Python.dict()
    overview_data["strategy_name"] = result_dict.get("strategy_name", "")
    overview_data["start_date"] = result_dict.get("start_date", "")
    overview_data["end_date"] = result_dict.get("end_date", "")
    overview_data["running_days"] = result_dict.get("running_days", 0)
    overview_data["portfolio_value"] = portfolio.get("portfolio_value", 0)
    overview_data["annualized_return"] = portfolio.get("annualized_returns", 0)
    overview_data["benchmark_return"] = benchmark.get("annualized_returns", 0)
    overview_data["excess_return"] = portfolio.get("annualized_returns", 0) - benchmark.get("annualized_returns", 0)
    overview_data["volatility"] = portfolio.get("volatility", 0)
    overview_data["sharpe_ratio"] = portfolio.get("sharpe_ratio", 0)
    overview_data["max_drawdown"] = portfolio.get("max_drawdown", 0)
    overview_data["alpha"] = portfolio.get("alpha", 0)
    overview_data["beta"] = portfolio.get("beta", 0)
    overview_data["tracking_error"] = portfolio.get("tracking_error", 0)
    overview_data["information_ratio"] = portfolio.get("information_ratio", 0)
    overview_data["winning_rate"] = portfolio.get("winning_rate", 0)
    overview_data["profit_loss_ratio"] = portfolio.get("profit_loss_ratio", 0)

    report["概览"] = overview_data

    var rf_mod = Python.evaluate(
        "import pandas as pd\n"
        "def _make_risk_free_rates(nav):\n"
        "    return pd.Series(\n"
        "        data=[0.03 / 252] * len(nav),\n"
        "        index=nav.index,\n"
        "    )\n",
        file=True,
    )
    var rf_func = rf_mod.__getattr__("_make_risk_free_rates")
    var risk_free_rates = rf_func(unit_net_value)

    var py_yearly_indicators = _yearly_indicators(
        unit_net_value, p_returns,
        benchmark_unit_net_value, b_returns,
        risk_free_rates,
    )

    var rows_mod = Python.evaluate(
        "def _build_indicator_rows(yearly_indicators):\n"
        "    rows = []\n"
        "    for year_str, ind_dict in yearly_indicators.items():\n"
        "        row = {'year': int(year_str)}\n"
        "        for k in ['annualized_return', 'max_drawdown', 'sharpe_ratio', 'alpha', 'beta']:\n"
        "            row[k] = ind_dict.get(k, None)\n"
        "        rows.append(row)\n"
        "    return rows\n",
        file=True,
    )
    var rows_func = rows_mod.__getattr__("_build_indicator_rows")
    var yearly_indicator_rows = rows_func(py_yearly_indicators)
    report["年度指标"] = yearly_indicator_rows

    var monthly_returns_df = _monthly_returns(p_returns)
    report["月度收益"] = monthly_returns_df

    if _py_is_truthy(benchmark_unit_net_value):
        var monthly_geometric_df = _monthly_geometric_excess_returns(p_returns, b_returns)
        report["月度超额收益（几何）"] = monthly_geometric_df

    var positions = result_dict.get("positions", Python.list())
    if len(positions) > 0:
        var positions_weight = _gen_positions_weight(positions)
        report["个股权重"] = positions_weight

    from rqmojo.mod.rqmojo_mod_sys_analyser.report.excel_template import generate_xlsx_reports
    generate_xlsx_reports(report, output_path)

    var csv_mod = Python.evaluate(
        "import os\n"
        "def _export_csv_files(total_returns, p_returns, b_returns, unit_net_value, benchmark_nav, has_benchmark, csv_base_path):\n"
        "    if not csv_base_path.endswith('/'):\n"
        "        csv_base_path = csv_base_path + '/'\n"
        "    total_returns.to_frame(name='total_returns').to_csv(csv_base_path + 'total_returns.csv')\n"
        "    p_returns.to_frame(name='returns').to_csv(csv_base_path + 'returns.csv')\n"
        "    if has_benchmark:\n"
        "        b_returns.to_frame(name='benchmark_returns').to_csv(csv_base_path + 'benchmark_returns.csv')\n"
        "    unit_net_value.to_frame(name='unit_net_value').to_csv(csv_base_path + 'unit_net_value.csv')\n"
        "    if has_benchmark:\n"
        "        benchmark_nav.to_frame(name='benchmark_nav').to_csv(csv_base_path + 'benchmark_nav.csv')\n",
        file=True,
    )
    var csv_func = csv_mod.__getattr__("_export_csv_files")

    var has_benchmark = _py_is_truthy(benchmark_unit_net_value)
    csv_func(total_returns, p_returns, b_returns, unit_net_value, benchmark_unit_net_value, has_benchmark, output_path)
