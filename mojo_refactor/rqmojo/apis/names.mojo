"""
RQAlpha Mojo - API Names
Ported from rqalpha/apis/names.py
"""

from collections import List
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


fn all_instrument_type_values() -> List[String]:
    return [
        INSTRUMENT_TYPE.CS().value,
        INSTRUMENT_TYPE.FUTURE().value,
        INSTRUMENT_TYPE.OPTION().value,
        INSTRUMENT_TYPE.ETF().value,
        INSTRUMENT_TYPE.LOF().value,
        INSTRUMENT_TYPE.INDX().value,
        INSTRUMENT_TYPE.PUBLIC_FUND().value,
        INSTRUMENT_TYPE.FUND().value,
        INSTRUMENT_TYPE.BOND().value,
        INSTRUMENT_TYPE.CONVERTIBLE().value,
        INSTRUMENT_TYPE.SPOT().value,
        INSTRUMENT_TYPE.REPO().value,
        INSTRUMENT_TYPE.REITs().value,
        INSTRUMENT_TYPE.FutureArbitrage().value,
    ]


comptime VALID_INSTRUMENT_TYPES: List[String] = all_instrument_type_values() + ["Fund", "Stock"]

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
    "operating_revenue_yoy",
    "gross_profit_yoy",
    "operating_profit_yoy",
    "total_profit_yoy",
    "np_parent_minority_pany_yoy",
    "ne_t_minority_ty_yoy",
    "net_operate_cash_flow_yoy",
    "total_assets_to_opening",
    "se_without_minority_to_opening",
    "basic_eps_yoy",
    "eps_weighted_yoy",
    "eps_cut_yoy",
    "eps_cut_weighted_yoy",
    "roe_yoy",
    "roe_weighted_yoy",
    "roe_cut_yoy",
    "roe_cut_weighted_yoy",
    "net_operate_cash_flow_per_share_yoy",
    "net_asset_psto_opening",
]
