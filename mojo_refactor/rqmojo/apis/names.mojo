"""
RQAlpha Mojo - API Names Module
Ported from rqalpha/apis/names.py
"""

from std.collections import List
from rqmojo.const import INSTRUMENT_TYPE


comptime VALID_HISTORY_FIELDS: List[String] = [
    "datetime",
    "open",
    "close",
    "high",
    "low",
    "total_turnover",
    "volume",
    "acc_net_value",
    "discount_rate",
    "unit_net_value",
    "limit_up",
    "limit_down",
    "open_interest",
    "basis_spread",
    "settlement",
    "prev_settlement",
]


comptime VALID_TENORS: List[String] = [
    "0S",
    "1M",
    "2M",
    "3M",
    "6M",
    "9M",
    "1Y",
    "2Y",
    "3Y",
    "4Y",
    "5Y",
    "6Y",
    "7Y",
    "8Y",
    "9Y",
    "10Y",
    "15Y",
    "20Y",
    "30Y",
    "40Y",
    "50Y",
]


def get_valid_instrument_types() -> List[String]:
    var result = List[String]()
    result.append("CS")
    result.append("Future")
    result.append("ETF")
    result.append("LOF")
    result.append("INDX")
    result.append("Future")
    result.append("PY")
    result.append("Fund")
    result.append("Stock")
    return result


comptime VALID_MARGIN_FIELDS: List[String] = [
    "margin_balance",
    "buy_on_margin_value",
    "short_sell_quantity",
    "margin_repayment",
    "short_balance_quantity",
    "short_repayment_quantity",
    "short_balance",
    "total_balance",
]


comptime VALID_SHARE_FIELDS: List[String] = [
    "total",
    "circulation_a",
    "management_circulation",
    "non_circulation_a",
    "total_a",
]


comptime VALID_TURNOVER_FIELDS: List[String] = [
    "today",
    "week",
    "month",
    "three_month",
    "six_month",
    "year",
    "current_year",
    "total",
]


comptime VALID_STOCK_CONNECT_FIELDS: List[String] = [
    "shares_holding",
    "holding_ratio",
]


comptime VALID_CURRENT_PERFORMANCE_FIELDS: List[String] = [
    "operating_revenue",
    "gross_profit",
    "operating_profit",
    "total_profit",
    "np_parent_owners",
    "net_profit_cut",
    "net_operate_cashflow",
    "total_assets",
    "se_without_minority",
    "total_shares",
    "basic_eps",
    "eps_weighted",
    "eps_cut_epscut",
    "eps_cut_weighted",
    "roe",
    "roe_weighted",
    "roe_cut",
    "roe_cut_weighted",
    "net_operate_cashflow_per_share",
    "equity_per_share",
]


def main():
    print("names.mojo - API names module loaded successfully")
