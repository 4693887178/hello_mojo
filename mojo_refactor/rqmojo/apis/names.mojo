"""
RQAlpha Mojo - API Names Module
Ported from rqalpha/apis/names.py
"""

from std.collections import List
from rqmojo.const import INSTRUMENT_TYPE


def get_valid_history_fields() -> List[String]:
    var result = List[String]()
    result.append("datetime")
    result.append("open")
    result.append("close")
    result.append("high")
    result.append("low")
    result.append("total_turnover")
    result.append("volume")
    result.append("acc_net_value")
    result.append("discount_rate")
    result.append("unit_net_value")
    result.append("limit_up")
    result.append("limit_down")
    result.append("open_interest")
    result.append("basis_spread")
    result.append("settlement")
    result.append("prev_settlement")
    return result^


def get_valid_tenors() -> List[String]:
    var result = List[String]()
    result.append("0S")
    result.append("1M")
    result.append("2M")
    result.append("3M")
    result.append("6M")
    result.append("9M")
    result.append("1Y")
    result.append("2Y")
    result.append("3Y")
    result.append("4Y")
    result.append("5Y")
    result.append("6Y")
    result.append("7Y")
    result.append("8Y")
    result.append("9Y")
    result.append("10Y")
    result.append("15Y")
    result.append("20Y")
    result.append("30Y")
    result.append("40Y")
    result.append("50Y")
    return result^


def get_valid_margin_fields() -> List[String]:
    var result = List[String]()
    result.append("margin_balance")
    result.append("buy_on_margin_value")
    result.append("short_sell_quantity")
    result.append("margin_repayment")
    result.append("short_balance_quantity")
    result.append("short_repayment_quantity")
    result.append("short_balance")
    result.append("total_balance")
    return result^


def get_valid_share_fields() -> List[String]:
    var result = List[String]()
    result.append("total")
    result.append("circulation_a")
    result.append("management_circulation")
    result.append("non_circulation_a")
    result.append("total_a")
    return result^


def get_valid_instrument_types() -> List[String]:
    var result = List[String]()
    result.append(INSTRUMENT_TYPE.CS.value)
    result.append(INSTRUMENT_TYPE.FUTURE.value)
    result.append(INSTRUMENT_TYPE.OPTION.value)
    result.append(INSTRUMENT_TYPE.ETF.value)
    result.append(INSTRUMENT_TYPE.LOF.value)
    result.append(INSTRUMENT_TYPE.INDX.value)
    result.append(INSTRUMENT_TYPE.PUBLIC_FUND.value)
    result.append(INSTRUMENT_TYPE.FUND.value)
    result.append(INSTRUMENT_TYPE.BOND.value)
    result.append(INSTRUMENT_TYPE.CONVERTIBLE.value)
    result.append(INSTRUMENT_TYPE.SPOT.value)
    result.append(INSTRUMENT_TYPE.REPO.value)
    result.append(INSTRUMENT_TYPE.REITs.value)
    result.append(INSTRUMENT_TYPE.FutureArbitrage.value)
    result.append("Fund")
    result.append("Stock")
    return result^


def get_valid_turnover_fields() -> List[String]:
    var result = List[String]()
    result.append("today")
    result.append("week")
    result.append("month")
    result.append("three_month")
    result.append("six_month")
    result.append("year")
    result.append("current_year")
    result.append("total")
    return result^


def get_valid_stock_connect_fields() -> List[String]:
    var result = List[String]()
    result.append("shares_holding")
    result.append("holding_ratio")
    return result^


def get_valid_current_performance_fields() -> List[String]:
    var result = List[String]()
    result.append("operating_revenue")
    result.append("gross_profit")
    result.append("operating_profit")
    result.append("total_profit")
    result.append("np_parent_owners")
    result.append("net_profit_cut")
    result.append("net_operate_cashflow")
    result.append("total_assets")
    result.append("se_without_minority")
    result.append("total_shares")
    result.append("basic_eps")
    result.append("eps_weighted")
    result.append("eps_cut_epscut")
    result.append("eps_cut_weighted")
    result.append("roe")
    result.append("roe_weighted")
    result.append("roe_cut")
    result.append("roe_cut_weighted")
    result.append("net_operate_cashflow_per_share")
    result.append("equity_per_share")
    result.append("operating_revenue_yoy")
    result.append("gross_profit_yoy")
    result.append("operating_profit_yoy")
    result.append("total_profit_yoy")
    result.append("np_parent_minority_pany_yoy")
    result.append("ne_t_minority_ty_yoy")
    result.append("net_operate_cash_flow_yoy")
    result.append("total_assets_to_opening")
    result.append("se_without_minority_to_opening")
    result.append("basic_eps_yoy")
    result.append("eps_weighted_yoy")
    result.append("eps_cut_yoy")
    result.append("eps_cut_weighted_yoy")
    result.append("roe_yoy")
    result.append("roe_weighted_yoy")
    result.append("roe_cut_yoy")
    result.append("roe_cut_weighted_yoy")
    result.append("net_operate_cash_flow_per_share_yoy")
    result.append("net_asset_psto_opening")
    return result^


def main():
    print("names.mojo - API names module loaded successfully")
