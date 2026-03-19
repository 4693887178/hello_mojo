# -*- coding: utf-8 -*-
"""
Test for rqalpha/const.py - Constants and Enumerations
Compares output with Mojo rqmojo/const.mojo
"""

from rqalpha.const import (
    EXECUTION_PHASE, RUN_TYPE, DEFAULT_ACCOUNT_TYPE, MATCHING_TYPE,
    ORDER_TYPE, ORDER_STATUS, SIDE, POSITION_EFFECT, POSITION_DIRECTION,
    INSTRUMENT_TYPE, EXCHANGE, DAYS_CNT, MARKET
)


def test_execution_phase():
    print("=== Testing EXECUTION_PHASE ===")
    print(f"GLOBAL: name={EXECUTION_PHASE.GLOBAL.name}, value={EXECUTION_PHASE.GLOBAL.value}")
    print(f"ON_INIT: name={EXECUTION_PHASE.ON_INIT.name}, value={EXECUTION_PHASE.ON_INIT.value}")
    print(f"BEFORE_TRADING: name={EXECUTION_PHASE.BEFORE_TRADING.name}, value={EXECUTION_PHASE.BEFORE_TRADING.value}")
    print(f"ON_BAR: name={EXECUTION_PHASE.ON_BAR.name}, value={EXECUTION_PHASE.ON_BAR.value}")
    print(f"ON_TICK: name={EXECUTION_PHASE.ON_TICK.name}, value={EXECUTION_PHASE.ON_TICK.value}")
    print(f"AFTER_TRADING: name={EXECUTION_PHASE.AFTER_TRADING.name}, value={EXECUTION_PHASE.AFTER_TRADING.value}")
    print(f"FINALIZED: name={EXECUTION_PHASE.FINALIZED.name}, value={EXECUTION_PHASE.FINALIZED.value}")
    print(f"SCHEDULED: name={EXECUTION_PHASE.SCHEDULED.name}, value={EXECUTION_PHASE.SCHEDULED.value}")
    print("")


def test_run_type():
    print("=== Testing RUN_TYPE ===")
    print(f"BACKTEST: name={RUN_TYPE.BACKTEST.name}, value={RUN_TYPE.BACKTEST.value}")
    print(f"PAPER_TRADING: name={RUN_TYPE.PAPER_TRADING.name}, value={RUN_TYPE.PAPER_TRADING.value}")
    print(f"LIVE_TRADING: name={RUN_TYPE.LIVE_TRADING.name}, value={RUN_TYPE.LIVE_TRADING.value}")
    print("")


def test_default_account_type():
    print("=== Testing DEFAULT_ACCOUNT_TYPE ===")
    print(f"STOCK: name={DEFAULT_ACCOUNT_TYPE.STOCK.name}, value={DEFAULT_ACCOUNT_TYPE.STOCK.value}")
    print(f"FUTURE: name={DEFAULT_ACCOUNT_TYPE.FUTURE.name}, value={DEFAULT_ACCOUNT_TYPE.FUTURE.value}")
    print(f"BOND: name={DEFAULT_ACCOUNT_TYPE.BOND.name}, value={DEFAULT_ACCOUNT_TYPE.BOND.value}")
    print("")


def test_matching_type():
    print("=== Testing MATCHING_TYPE ===")
    print(f"CURRENT_BAR_CLOSE: name={MATCHING_TYPE.CURRENT_BAR_CLOSE.name}, value={MATCHING_TYPE.CURRENT_BAR_CLOSE.value}")
    print(f"VWAP: name={MATCHING_TYPE.VWAP.name}, value={MATCHING_TYPE.VWAP.value}")
    print(f"COUNTERPARTY_OFFER: name={MATCHING_TYPE.COUNTERPARTY_OFFER.name}, value={MATCHING_TYPE.COUNTERPARTY_OFFER.value}")
    print(f"NEXT_BAR_OPEN: name={MATCHING_TYPE.NEXT_BAR_OPEN.name}, value={MATCHING_TYPE.NEXT_BAR_OPEN.value}")
    print("")


def test_order_type():
    print("=== Testing ORDER_TYPE ===")
    print(f"MARKET: name={ORDER_TYPE.MARKET.name}, value={ORDER_TYPE.MARKET.value}")
    print(f"LIMIT: name={ORDER_TYPE.LIMIT.name}, value={ORDER_TYPE.LIMIT.value}")
    print(f"ALGO: name={ORDER_TYPE.ALGO.name}, value={ORDER_TYPE.ALGO.value}")
    print("")


def test_order_status():
    print("=== Testing ORDER_STATUS ===")
    print(f"PENDING_NEW: name={ORDER_STATUS.PENDING_NEW.name}, value={ORDER_STATUS.PENDING_NEW.value}")
    print(f"ACTIVE: name={ORDER_STATUS.ACTIVE.name}, value={ORDER_STATUS.ACTIVE.value}")
    print(f"FILLED: name={ORDER_STATUS.FILLED.name}, value={ORDER_STATUS.FILLED.value}")
    print(f"REJECTED: name={ORDER_STATUS.REJECTED.name}, value={ORDER_STATUS.REJECTED.value}")
    print(f"CANCELLED: name={ORDER_STATUS.CANCELLED.name}, value={ORDER_STATUS.CANCELLED.value}")
    print("")


def test_side():
    print("=== Testing SIDE ===")
    print(f"BUY: name={SIDE.BUY.name}, value={SIDE.BUY.value}")
    print(f"SELL: name={SIDE.SELL.name}, value={SIDE.SELL.value}")
    print(f"FINANCING: name={SIDE.FINANCING.name}, value={SIDE.FINANCING.value}")
    print(f"MARGIN: name={SIDE.MARGIN.name}, value={SIDE.MARGIN.value}")
    print("")


def test_position_effect():
    print("=== Testing POSITION_EFFECT ===")
    print(f"OPEN: name={POSITION_EFFECT.OPEN.name}, value={POSITION_EFFECT.OPEN.value}")
    print(f"CLOSE: name={POSITION_EFFECT.CLOSE.name}, value={POSITION_EFFECT.CLOSE.value}")
    print(f"CLOSE_TODAY: name={POSITION_EFFECT.CLOSE_TODAY.name}, value={POSITION_EFFECT.CLOSE_TODAY.value}")
    print("")


def test_position_direction():
    print("=== Testing POSITION_DIRECTION ===")
    print(f"LONG: name={POSITION_DIRECTION.LONG.name}, value={POSITION_DIRECTION.LONG.value}")
    print(f"SHORT: name={POSITION_DIRECTION.SHORT.name}, value={POSITION_DIRECTION.SHORT.value}")
    print("")


def test_instrument_type():
    print("=== Testing INSTRUMENT_TYPE ===")
    print(f"CS: name={INSTRUMENT_TYPE.CS.name}, value={INSTRUMENT_TYPE.CS.value}")
    print(f"FUTURE: name={INSTRUMENT_TYPE.FUTURE.name}, value={INSTRUMENT_TYPE.FUTURE.value}")
    print(f"OPTION: name={INSTRUMENT_TYPE.OPTION.name}, value={INSTRUMENT_TYPE.OPTION.value}")
    print(f"ETF: name={INSTRUMENT_TYPE.ETF.name}, value={INSTRUMENT_TYPE.ETF.value}")
    print(f"LOF: name={INSTRUMENT_TYPE.LOF.name}, value={INSTRUMENT_TYPE.LOF.value}")
    print(f"INDX: name={INSTRUMENT_TYPE.INDX.name}, value={INSTRUMENT_TYPE.INDX.value}")
    print("")


def test_exchange():
    print("=== Testing EXCHANGE ===")
    print(f"XSHE: name={EXCHANGE.XSHE.name}, value={EXCHANGE.XSHE.value}")
    print(f"XSHG: name={EXCHANGE.XSHG.name}, value={EXCHANGE.XSHG.value}")
    print(f"SHFE: name={EXCHANGE.SHFE.name}, value={EXCHANGE.SHFE.value}")
    print(f"DCE: name={EXCHANGE.DCE.name}, value={EXCHANGE.DCE.value}")
    print(f"CZCE: name={EXCHANGE.CZCE.name}, value={EXCHANGE.CZCE.value}")
    print(f"CFFEX: name={EXCHANGE.CFFEX.name}, value={EXCHANGE.CFFEX.value}")
    print("")


def test_days_cnt():
    print("=== Testing DAYS_CNT ===")
    print(f"DAYS_A_YEAR: {DAYS_CNT.DAYS_A_YEAR}")
    print(f"TRADING_DAYS_A_YEAR: {DAYS_CNT.TRADING_DAYS_A_YEAR}")
    print("")


def test_market():
    print("=== Testing MARKET ===")
    print(f"CN: name={MARKET.CN.name}, value={MARKET.CN.value}")
    print(f"HK: name={MARKET.HK.name}, value={MARKET.HK.value}")
    print("")


def test_equality():
    print("=== Testing Equality ===")
    buy1 = SIDE.BUY
    buy2 = SIDE.BUY
    sell = SIDE.SELL
    
    if buy1 == buy2:
        print("PASS: buy1 == buy2")
    else:
        print("FAIL: buy1 should equal buy2")
    
    if buy1 != sell:
        print("PASS: buy1 != sell")
    else:
        print("FAIL: buy1 should not equal sell")
    print("")


if __name__ == "__main__":
    print("=" * 60)
    print("RQAlpha Python const.py Test")
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
