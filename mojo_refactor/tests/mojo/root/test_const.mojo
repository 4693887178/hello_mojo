"""
Test for const.mojo - Constants and Enumerations
Compares output with Python rqalpha.const
Covers ALL structs and enum values in const.mojo
"""

from rqmojo.const import *


fn test_execution_phase():
    print("=== Testing EXECUTION_PHASE ===")
    var global_phase = EXECUTION_PHASE.GLOBAL
    print("GLOBAL: name=" + global_phase.name + ", value=" + global_phase.value)

    var on_init = EXECUTION_PHASE.ON_INIT
    print("ON_INIT: name=" + on_init.name + ", value=" + on_init.value)

    var before_trading = EXECUTION_PHASE.BEFORE_TRADING
    print("BEFORE_TRADING: name=" + before_trading.name + ", value=" + before_trading.value)

    var open_auction = EXECUTION_PHASE.OPEN_AUCTION
    print("OPEN_AUCTION: name=" + open_auction.name + ", value=" + open_auction.value)

    var on_bar = EXECUTION_PHASE.ON_BAR
    print("ON_BAR: name=" + on_bar.name + ", value=" + on_bar.value)

    var on_tick = EXECUTION_PHASE.ON_TICK
    print("ON_TICK: name=" + on_tick.name + ", value=" + on_tick.value)

    var after_trading = EXECUTION_PHASE.AFTER_TRADING
    print("AFTER_TRADING: name=" + after_trading.name + ", value=" + after_trading.value)

    var finalized = EXECUTION_PHASE.FINALIZED
    print("FINALIZED: name=" + finalized.name + ", value=" + finalized.value)

    var scheduled = EXECUTION_PHASE.SCHEDULED
    print("SCHEDULED: name=" + scheduled.name + ", value=" + scheduled.value)
    print("")


fn test_run_type():
    print("=== Testing RUN_TYPE ===")
    var backtest = RUN_TYPE.BACKTEST
    print("BACKTEST: name=" + backtest.name + ", value=" + backtest.value)

    var paper_trading = RUN_TYPE.PAPER_TRADING
    print("PAPER_TRADING: name=" + paper_trading.name + ", value=" + paper_trading.value)

    var live_trading = RUN_TYPE.LIVE_TRADING
    print("LIVE_TRADING: name=" + live_trading.name + ", value=" + live_trading.value)
    print("")


fn test_default_account_type():
    print("=== Testing DEFAULT_ACCOUNT_TYPE ===")
    var stock = DEFAULT_ACCOUNT_TYPE.STOCK
    print("STOCK: name=" + stock.name + ", value=" + stock.value)

    var future = DEFAULT_ACCOUNT_TYPE.FUTURE
    print("FUTURE: name=" + future.name + ", value=" + future.value)

    var bond = DEFAULT_ACCOUNT_TYPE.BOND
    print("BOND: name=" + bond.name + ", value=" + bond.value)
    print("")


fn test_matching_type():
    print("=== Testing MATCHING_TYPE ===")
    var current_bar_close = MATCHING_TYPE.CURRENT_BAR_CLOSE
    print("CURRENT_BAR_CLOSE: name=" + current_bar_close.name + ", value=" + current_bar_close.value)

    var vwap = MATCHING_TYPE.VWAP
    print("VWAP: name=" + vwap.name + ", value=" + vwap.value)

    var counterparty_offer = MATCHING_TYPE.COUNTERPARTY_OFFER
    print("COUNTERPARTY_OFFER: name=" + counterparty_offer.name + ", value=" + counterparty_offer.value)

    var next_bar_open = MATCHING_TYPE.NEXT_BAR_OPEN
    print("NEXT_BAR_OPEN: name=" + next_bar_open.name + ", value=" + next_bar_open.value)

    var next_tick_last = MATCHING_TYPE.NEXT_TICK_LAST
    print("NEXT_TICK_LAST: name=" + next_tick_last.name + ", value=" + next_tick_last.value)

    var next_tick_best_own = MATCHING_TYPE.NEXT_TICK_BEST_OWN
    print("NEXT_TICK_BEST_OWN: name=" + next_tick_best_own.name + ", value=" + next_tick_best_own.value)

    var next_tick_best_counterparty = MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY
    print("NEXT_TICK_BEST_COUNTERPARTY: name=" + next_tick_best_counterparty.name + ", value=" + next_tick_best_counterparty.value)
    print("")


fn test_order_type():
    print("=== Testing ORDER_TYPE ===")
    var market = ORDER_TYPE.MARKET
    print("MARKET: name=" + market.name + ", value=" + market.value)

    var limit = ORDER_TYPE.LIMIT
    print("LIMIT: name=" + limit.name + ", value=" + limit.value)

    var algo = ORDER_TYPE.ALGO
    print("ALGO: name=" + algo.name + ", value=" + algo.value)
    print("")


fn test_algo():
    print("=== Testing ALGO ===")
    var twap = ALGO.TWAP
    print("TWAP: name=" + twap.name + ", value=" + twap.value)

    var vwap = ALGO.VWAP
    print("VWAP: name=" + vwap.name + ", value=" + vwap.value)
    print("")


fn test_order_status():
    print("=== Testing ORDER_STATUS ===")
    var pending_new = ORDER_STATUS.PENDING_NEW
    print("PENDING_NEW: name=" + pending_new.name + ", value=" + pending_new.value)

    var active = ORDER_STATUS.ACTIVE
    print("ACTIVE: name=" + active.name + ", value=" + active.value)

    var filled = ORDER_STATUS.FILLED
    print("FILLED: name=" + filled.name + ", value=" + filled.value)

    var rejected = ORDER_STATUS.REJECTED
    print("REJECTED: name=" + rejected.name + ", value=" + rejected.value)

    var pending_cancel = ORDER_STATUS.PENDING_CANCEL
    print("PENDING_CANCEL: name=" + pending_cancel.name + ", value=" + pending_cancel.value)

    var cancelled = ORDER_STATUS.CANCELLED
    print("CANCELLED: name=" + cancelled.name + ", value=" + cancelled.value)
    print("")


fn test_side():
    print("=== Testing SIDE ===")
    var buy = SIDE.BUY
    print("BUY: name=" + buy.name + ", value=" + buy.value)

    var sell = SIDE.SELL
    print("SELL: name=" + sell.name + ", value=" + sell.value)

    var financing = SIDE.FINANCING
    print("FINANCING: name=" + financing.name + ", value=" + financing.value)

    var margin = SIDE.MARGIN
    print("MARGIN: name=" + margin.name + ", value=" + margin.value)

    var convert_stock = SIDE.CONVERT_STOCK
    print("CONVERT_STOCK: name=" + convert_stock.name + ", value=" + convert_stock.value)
    print("")


fn test_position_effect():
    print("=== Testing POSITION_EFFECT ===")
    var open_pe = POSITION_EFFECT.OPEN
    print("OPEN: name=" + open_pe.name + ", value=" + open_pe.value)

    var close_pe = POSITION_EFFECT.CLOSE
    print("CLOSE: name=" + close_pe.name + ", value=" + close_pe.value)

    var close_today = POSITION_EFFECT.CLOSE_TODAY
    print("CLOSE_TODAY: name=" + close_today.name + ", value=" + close_today.value)

    var exercise = POSITION_EFFECT.EXERCISE
    print("EXERCISE: name=" + exercise.name + ", value=" + exercise.value)

    var match_pe = POSITION_EFFECT.MATCH
    print("MATCH: name=" + match_pe.name + ", value=" + match_pe.value)
    print("")


fn test_position_direction():
    print("=== Testing POSITION_DIRECTION ===")
    var long = POSITION_DIRECTION.LONG
    print("LONG: name=" + long.name + ", value=" + long.value)

    var short = POSITION_DIRECTION.SHORT
    print("SHORT: name=" + short.name + ", value=" + short.value)
    print("")


fn test_exc_type():
    print("=== Testing EXC_TYPE ===")
    var user_exc = EXC_TYPE.USER_EXC
    print("USER_EXC: name=" + user_exc.name + ", value=" + user_exc.value)

    var system_exc = EXC_TYPE.SYSTEM_EXC
    print("SYSTEM_EXC: name=" + system_exc.name + ", value=" + system_exc.value)

    var notset = EXC_TYPE.NOTSET
    print("NOTSET: name=" + notset.name + ", value=" + notset.value)
    print("")


fn test_instrument_type():
    print("=== Testing INSTRUMENT_TYPE ===")
    var cs = INSTRUMENT_TYPE.CS
    print("CS: name=" + cs.name + ", value=" + cs.value)

    var future = INSTRUMENT_TYPE.FUTURE
    print("FUTURE: name=" + future.name + ", value=" + future.value)

    var option = INSTRUMENT_TYPE.OPTION
    print("OPTION: name=" + option.name + ", value=" + option.value)

    var etf = INSTRUMENT_TYPE.ETF
    print("ETF: name=" + etf.name + ", value=" + etf.value)

    var lof = INSTRUMENT_TYPE.LOF
    print("LOF: name=" + lof.name + ", value=" + lof.value)

    var indx = INSTRUMENT_TYPE.INDX
    print("INDX: name=" + indx.name + ", value=" + indx.value)

    var public_fund = INSTRUMENT_TYPE.PUBLIC_FUND
    print("PUBLIC_FUND: name=" + public_fund.name + ", value=" + public_fund.value)

    var fund = INSTRUMENT_TYPE.FUND
    print("FUND: name=" + fund.name + ", value=" + fund.value)

    var bond = INSTRUMENT_TYPE.BOND
    print("BOND: name=" + bond.name + ", value=" + bond.value)

    var convertible = INSTRUMENT_TYPE.CONVERTIBLE
    print("CONVERTIBLE: name=" + convertible.name + ", value=" + convertible.value)

    var spot = INSTRUMENT_TYPE.SPOT
    print("SPOT: name=" + spot.name + ", value=" + spot.value)

    var repo = INSTRUMENT_TYPE.REPO
    print("REPO: name=" + repo.name + ", value=" + repo.value)

    var reits = INSTRUMENT_TYPE.REITs
    print("REITs: name=" + reits.name + ", value=" + reits.value)

    var future_arbitrage = INSTRUMENT_TYPE.FutureArbitrage
    print("FutureArbitrage: name=" + future_arbitrage.name + ", value=" + future_arbitrage.value)
    print("")


fn test_persist_mode():
    print("=== Testing PERSIST_MODE ===")
    var on_crash = PERSIST_MODE.ON_CRASH
    print("ON_CRASH: name=" + on_crash.name + ", value=" + on_crash.value)

    var real_time = PERSIST_MODE.REAL_TIME
    print("REAL_TIME: name=" + real_time.name + ", value=" + real_time.value)

    var on_normal_exit = PERSIST_MODE.ON_NORMAL_EXIT
    print("ON_NORMAL_EXIT: name=" + on_normal_exit.name + ", value=" + on_normal_exit.value)
    print("")


fn test_commission_type():
    print("=== Testing COMMISSION_TYPE ===")
    var by_money = COMMISSION_TYPE.BY_MONEY
    print("BY_MONEY: name=" + by_money.name + ", value=" + by_money.value)

    var by_volume = COMMISSION_TYPE.BY_VOLUME
    print("BY_VOLUME: name=" + by_volume.name + ", value=" + by_volume.value)
    print("")


fn test_exit_code():
    print("=== Testing EXIT_CODE ===")
    var exit_success = EXIT_CODE.EXIT_SUCCESS
    print("EXIT_SUCCESS: name=" + exit_success.name + ", value=" + exit_success.value)

    var exit_user_error = EXIT_CODE.EXIT_USER_ERROR
    print("EXIT_USER_ERROR: name=" + exit_user_error.name + ", value=" + exit_user_error.value)

    var exit_internal_error = EXIT_CODE.EXIT_INTERNAL_ERROR
    print("EXIT_INTERNAL_ERROR: name=" + exit_internal_error.name + ", value=" + exit_internal_error.value)
    print("")


fn test_hedge_type():
    print("=== Testing HEDGE_TYPE ===")
    var hedge = HEDGE_TYPE.HEDGE
    print("HEDGE: name=" + hedge.name + ", value=" + hedge.value)

    var speculation = HEDGE_TYPE.SPECULATION
    print("SPECULATION: name=" + speculation.name + ", value=" + speculation.value)

    var arbitrage = HEDGE_TYPE.ARBITRAGE
    print("ARBITRAGE: name=" + arbitrage.name + ", value=" + arbitrage.value)
    print("")


fn test_days_cnt():
    print("=== Testing DAYS_CNT ===")
    print("DAYS_A_YEAR: " + String(DAYS_CNT.DAYS_A_YEAR))
    print("TRADING_DAYS_A_YEAR: " + String(DAYS_CNT.TRADING_DAYS_A_YEAR))
    print("")


fn test_exchange():
    print("=== Testing EXCHANGE ===")
    var xshe = EXCHANGE.XSHE
    print("XSHE: name=" + xshe.name + ", value=" + xshe.value)

    var xshg = EXCHANGE.XSHG
    print("XSHG: name=" + xshg.name + ", value=" + xshg.value)

    var shfe = EXCHANGE.SHFE
    print("SHFE: name=" + shfe.name + ", value=" + shfe.value)

    var ine = EXCHANGE.INE
    print("INE: name=" + ine.name + ", value=" + ine.value)

    var dce = EXCHANGE.DCE
    print("DCE: name=" + dce.name + ", value=" + dce.value)

    var czce = EXCHANGE.CZCE
    print("CZCE: name=" + czce.name + ", value=" + czce.value)

    var cffex = EXCHANGE.CFFEX
    print("CFFEX: name=" + cffex.name + ", value=" + cffex.value)

    var sgex = EXCHANGE.SGEX
    print("SGEX: name=" + sgex.name + ", value=" + sgex.value)

    var bjse = EXCHANGE.BJSE
    print("BJSE: name=" + bjse.name + ", value=" + bjse.value)
    print("")


fn test_trading_calendar_type():
    print("=== Testing TRADING_CALENDAR_TYPE ===")
    var cn_stock = TRADING_CALENDAR_TYPE.CN_STOCK
    print("CN_STOCK: name=" + cn_stock.name + ", value=" + cn_stock.value)

    var hk_stock = TRADING_CALENDAR_TYPE.HK_STOCK
    print("HK_STOCK: name=" + hk_stock.name + ", value=" + hk_stock.value)

    var southbound = TRADING_CALENDAR_TYPE.SOUTHBOUND
    print("SOUTHBOUND: name=" + southbound.name + ", value=" + southbound.value)

    var inter_bank = TRADING_CALENDAR_TYPE.INTER_BANK
    print("INTER_BANK: name=" + inter_bank.name + ", value=" + inter_bank.value)

    var exchange = TRADING_CALENDAR_TYPE.EXCHANGE
    print("EXCHANGE: name=" + exchange.name + ", value=" + exchange.value)
    print("")


fn test_market():
    print("=== Testing MARKET ===")
    var cn = MARKET.CN
    print("CN: name=" + cn.name + ", value=" + cn.value)

    var hk = MARKET.HK
    print("HK: name=" + hk.name + ", value=" + hk.value)
    print("")


fn test_equality():
    print("=== Testing Equality ===")
    var buy1 = SIDE.BUY
    var buy2 = SIDE.BUY
    var sell = SIDE.SELL

    if buy1 == buy2:
        print("PASS: buy1 == buy2")
    else:
        print("FAIL: buy1 should equal buy2")

    if buy1 != sell:
        print("PASS: buy1 != sell")
    else:
        print("FAIL: buy1 should not equal sell")
    print("")


fn main():
    print("=" * 60)
    print("RQAlpha Mojo root/const.mojo Test")
    print("=" * 60)
    print("")

    test_execution_phase()
    test_run_type()
    test_default_account_type()
    test_matching_type()
    test_order_type()
    test_algo()
    test_order_status()
    test_side()
    test_position_effect()
    test_position_direction()
    test_exc_type()
    test_instrument_type()
    test_persist_mode()
    test_commission_type()
    test_exit_code()
    test_hedge_type()
    test_days_cnt()
    test_exchange()
    test_trading_calendar_type()
    test_market()
    test_equality()

    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
