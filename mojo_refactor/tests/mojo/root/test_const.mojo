"""
Test for const.mojo - Constants and Enumerations
Compares output with Python rqalpha.const
"""

from rqmojo.const import *


fn test_execution_phase():
    print("=== Testing EXECUTION_PHASE ===")
    var global_phase = EXECUTION_PHASE.GLOBAL()
    print("GLOBAL: name=" + global_phase.name + ", value=" + global_phase.value)
    
    var on_init = EXECUTION_PHASE.ON_INIT()
    print("ON_INIT: name=" + on_init.name + ", value=" + on_init.value)
    
    var before_trading = EXECUTION_PHASE.BEFORE_TRADING()
    print("BEFORE_TRADING: name=" + before_trading.name + ", value=" + before_trading.value)
    
    var on_bar = EXECUTION_PHASE.ON_BAR()
    print("ON_BAR: name=" + on_bar.name + ", value=" + on_bar.value)
    
    var on_tick = EXECUTION_PHASE.ON_TICK()
    print("ON_TICK: name=" + on_tick.name + ", value=" + on_tick.value)
    
    var after_trading = EXECUTION_PHASE.AFTER_TRADING()
    print("AFTER_TRADING: name=" + after_trading.name + ", value=" + after_trading.value)
    
    var finalized = EXECUTION_PHASE.FINALIZED()
    print("FINALIZED: name=" + finalized.name + ", value=" + finalized.value)
    
    var scheduled = EXECUTION_PHASE.SCHEDULED()
    print("SCHEDULED: name=" + scheduled.name + ", value=" + scheduled.value)
    print("")


fn test_run_type():
    print("=== Testing RUN_TYPE ===")
    var backtest = RUN_TYPE.BACKTEST()
    print("BACKTEST: name=" + backtest.name + ", value=" + backtest.value)
    
    var paper_trading = RUN_TYPE.PAPER_TRADING()
    print("PAPER_TRADING: name=" + paper_trading.name + ", value=" + paper_trading.value)
    
    var live_trading = RUN_TYPE.LIVE_TRADING()
    print("LIVE_TRADING: name=" + live_trading.name + ", value=" + live_trading.value)
    print("")


fn test_default_account_type():
    print("=== Testing DEFAULT_ACCOUNT_TYPE ===")
    var stock = DEFAULT_ACCOUNT_TYPE.STOCK()
    print("STOCK: name=" + stock.name + ", value=" + stock.value)
    
    var future = DEFAULT_ACCOUNT_TYPE.FUTURE()
    print("FUTURE: name=" + future.name + ", value=" + future.value)
    
    var bond = DEFAULT_ACCOUNT_TYPE.BOND()
    print("BOND: name=" + bond.name + ", value=" + bond.value)
    print("")


fn test_matching_type():
    print("=== Testing MATCHING_TYPE ===")
    var current_bar_close = MATCHING_TYPE.CURRENT_BAR_CLOSE()
    print("CURRENT_BAR_CLOSE: name=" + current_bar_close.name + ", value=" + current_bar_close.value)
    
    var vwap = MATCHING_TYPE.VWAP()
    print("VWAP: name=" + vwap.name + ", value=" + vwap.value)
    
    var counterparty_offer = MATCHING_TYPE.COUNTERPARTY_OFFER()
    print("COUNTERPARTY_OFFER: name=" + counterparty_offer.name + ", value=" + counterparty_offer.value)
    
    var next_bar_open = MATCHING_TYPE.NEXT_BAR_OPEN()
    print("NEXT_BAR_OPEN: name=" + next_bar_open.name + ", value=" + next_bar_open.value)
    print("")


fn test_order_type():
    print("=== Testing ORDER_TYPE ===")
    var market = ORDER_TYPE.MARKET()
    print("MARKET: name=" + market.name + ", value=" + market.value)
    
    var limit = ORDER_TYPE.LIMIT()
    print("LIMIT: name=" + limit.name + ", value=" + limit.value)
    
    var algo = ORDER_TYPE.ALGO()
    print("ALGO: name=" + algo.name + ", value=" + algo.value)
    print("")


fn test_order_status():
    print("=== Testing ORDER_STATUS ===")
    var pending_new = ORDER_STATUS.PENDING_NEW()
    print("PENDING_NEW: name=" + pending_new.name + ", value=" + pending_new.value)
    
    var active = ORDER_STATUS.ACTIVE()
    print("ACTIVE: name=" + active.name + ", value=" + active.value)
    
    var filled = ORDER_STATUS.FILLED()
    print("FILLED: name=" + filled.name + ", value=" + filled.value)
    
    var rejected = ORDER_STATUS.REJECTED()
    print("REJECTED: name=" + rejected.name + ", value=" + rejected.value)
    
    var cancelled = ORDER_STATUS.CANCELLED()
    print("CANCELLED: name=" + cancelled.name + ", value=" + cancelled.value)
    print("")


fn test_side():
    print("=== Testing SIDE ===")
    var buy = SIDE.BUY()
    print("BUY: name=" + buy.name + ", value=" + buy.value)
    
    var sell = SIDE.SELL()
    print("SELL: name=" + sell.name + ", value=" + sell.value)
    
    var financing = SIDE.FINANCING()
    print("FINANCING: name=" + financing.name + ", value=" + financing.value)
    
    var margin = SIDE.MARGIN()
    print("MARGIN: name=" + margin.name + ", value=" + margin.value)
    print("")


fn test_position_effect():
    print("=== Testing POSITION_EFFECT ===")
    var open = POSITION_EFFECT.OPEN()
    print("OPEN: name=" + open.name + ", value=" + open.value)
    
    var close = POSITION_EFFECT.CLOSE()
    print("CLOSE: name=" + close.name + ", value=" + close.value)
    
    var close_today = POSITION_EFFECT.CLOSE_TODAY()
    print("CLOSE_TODAY: name=" + close_today.name + ", value=" + close_today.value)
    print("")


fn test_position_direction():
    print("=== Testing POSITION_DIRECTION ===")
    var long = POSITION_DIRECTION.LONG()
    print("LONG: name=" + long.name + ", value=" + long.value)
    
    var short = POSITION_DIRECTION.SHORT()
    print("SHORT: name=" + short.name + ", value=" + short.value)
    print("")


fn test_instrument_type():
    print("=== Testing INSTRUMENT_TYPE ===")
    var cs = INSTRUMENT_TYPE.CS()
    print("CS: name=" + cs.name + ", value=" + cs.value)
    
    var future = INSTRUMENT_TYPE.FUTURE()
    print("FUTURE: name=" + future.name + ", value=" + future.value)
    
    var option = INSTRUMENT_TYPE.OPTION()
    print("OPTION: name=" + option.name + ", value=" + option.value)
    
    var etf = INSTRUMENT_TYPE.ETF()
    print("ETF: name=" + etf.name + ", value=" + etf.value)
    
    var lof = INSTRUMENT_TYPE.LOF()
    print("LOF: name=" + lof.name + ", value=" + lof.value)
    
    var indx = INSTRUMENT_TYPE.INDX()
    print("INDX: name=" + indx.name + ", value=" + indx.value)
    print("")


fn test_exchange():
    print("=== Testing EXCHANGE ===")
    var xshe = EXCHANGE.XSHE()
    print("XSHE: name=" + xshe.name + ", value=" + xshe.value)
    
    var xshg = EXCHANGE.XSHG()
    print("XSHG: name=" + xshg.name + ", value=" + xshg.value)
    
    var shfe = EXCHANGE.SHFE()
    print("SHFE: name=" + shfe.name + ", value=" + shfe.value)
    
    var dce = EXCHANGE.DCE()
    print("DCE: name=" + dce.name + ", value=" + dce.value)
    
    var czce = EXCHANGE.CZCE()
    print("CZCE: name=" + czce.name + ", value=" + czce.value)
    
    var cffex = EXCHANGE.CFFEX()
    print("CFFEX: name=" + cffex.name + ", value=" + cffex.value)
    print("")


fn test_days_cnt():
    print("=== Testing DAYS_CNT ===")
    print("DAYS_A_YEAR: " + String(DAYS_CNT.DAYS_A_YEAR))
    print("TRADING_DAYS_A_YEAR: " + String(DAYS_CNT.TRADING_DAYS_A_YEAR))
    print("")


fn test_market():
    print("=== Testing MARKET ===")
    var cn = MARKET.CN()
    print("CN: name=" + cn.name + ", value=" + cn.value)
    
    var hk = MARKET.HK()
    print("HK: name=" + hk.name + ", value=" + hk.value)
    print("")


fn test_equality():
    print("=== Testing Equality ===")
    var buy1 = SIDE.BUY()
    var buy2 = SIDE.BUY()
    var sell = SIDE.SELL()
    
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
    print("RQAlpha Mojo const.mojo Test")
    print("=" * 60)
    print("")
    
    test_execution_phase()
    test_run_type()
    test_default_account_type()
    test_matching_type()
    test_order_type()
    test_order_status()
    test_side()
    test_position_effect()
    test_position_direction()
    test_instrument_type()
    test_exchange()
    test_days_cnt()
    test_market()
    test_equality()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
