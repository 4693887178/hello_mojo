"""
RQAlpha Mojo - Test const.mojo
Tests for constants and enumerations
"""

from std.collections import Dict
from rqmojo.const import (
    EXECUTION_PHASE, RUN_TYPE, DEFAULT_ACCOUNT_TYPE, MATCHING_TYPE,
    ORDER_TYPE, ALGO, ORDER_STATUS, SIDE, POSITION_EFFECT,
    POSITION_DIRECTION, EXC_TYPE, INSTRUMENT_TYPE, PERSIST_MODE,
    COMMISSION_TYPE, EXIT_CODE, HEDGE_TYPE, DAYS_CNT, EXCHANGE,
    TRADING_CALENDAR_TYPE, MARKET, EnumRegistry
)


def test_execution_phase():
    print("Testing EXECUTION_PHASE...")
    
    assert EXECUTION_PHASE.GLOBAL.name == "GLOBAL"
    assert EXECUTION_PHASE.GLOBAL.value == "[全局]"
    
    assert EXECUTION_PHASE.ON_INIT.name == "ON_INIT"
    assert EXECUTION_PHASE.ON_INIT.value == "[程序初始化]"
    
    assert EXECUTION_PHASE.BEFORE_TRADING.name == "BEFORE_TRADING"
    assert EXECUTION_PHASE.BEFORE_TRADING.value == "[日内交易前]"
    
    assert EXECUTION_PHASE.OPEN_AUCTION.name == "OPEN_AUCTION"
    assert EXECUTION_PHASE.OPEN_AUCTION.value == "[集合竞价]"
    
    assert EXECUTION_PHASE.ON_BAR.name == "ON_BAR"
    assert EXECUTION_PHASE.ON_BAR.value == "[盘中 handle_bar 函数]"
    
    assert EXECUTION_PHASE.ON_TICK.name == "ON_TICK"
    assert EXECUTION_PHASE.ON_TICK.value == "[盘中 handle_tick 函数]"
    
    assert EXECUTION_PHASE.AFTER_TRADING.name == "AFTER_TRADING"
    assert EXECUTION_PHASE.AFTER_TRADING.value == "[日内交易后]"
    
    assert EXECUTION_PHASE.FINALIZED.name == "FINALIZED"
    assert EXECUTION_PHASE.FINALIZED.value == "[程序结束]"
    
    assert EXECUTION_PHASE.SCHEDULED.name == "SCHEDULED"
    assert EXECUTION_PHASE.SCHEDULED.value == "[scheduler函数内]"
    
    print("  EXECUTION_PHASE tests passed!")


def test_run_type():
    print("Testing RUN_TYPE...")
    
    assert RUN_TYPE.BACKTEST.name == "BACKTEST"
    assert RUN_TYPE.BACKTEST.value == "BACKTEST"
    
    assert RUN_TYPE.PAPER_TRADING.name == "PAPER_TRADING"
    assert RUN_TYPE.PAPER_TRADING.value == "PAPER_TRADING"
    
    assert RUN_TYPE.LIVE_TRADING.name == "LIVE_TRADING"
    assert RUN_TYPE.LIVE_TRADING.value == "LIVE_TRADING"
    
    print("  RUN_TYPE tests passed!")


def test_default_account_type():
    print("Testing DEFAULT_ACCOUNT_TYPE...")
    
    assert DEFAULT_ACCOUNT_TYPE.STOCK.name == "STOCK"
    assert DEFAULT_ACCOUNT_TYPE.STOCK.value == "STOCK"
    
    assert DEFAULT_ACCOUNT_TYPE.FUTURE.name == "FUTURE"
    assert DEFAULT_ACCOUNT_TYPE.FUTURE.value == "FUTURE"
    
    assert DEFAULT_ACCOUNT_TYPE.BOND.name == "BOND"
    assert DEFAULT_ACCOUNT_TYPE.BOND.value == "BOND"
    
    print("  DEFAULT_ACCOUNT_TYPE tests passed!")


def test_matching_type():
    print("Testing MATCHING_TYPE...")
    
    assert MATCHING_TYPE.CURRENT_BAR_CLOSE.name == "CURRENT_BAR_CLOSE"
    assert MATCHING_TYPE.CURRENT_BAR_CLOSE.value == "CURRENT_BAR_CLOSE"
    
    assert MATCHING_TYPE.VWAP.name == "VWAP"
    assert MATCHING_TYPE.VWAP.value == "VWAP"
    
    assert MATCHING_TYPE.COUNTERPARTY_OFFER.name == "COUNTERPARTY_OFFER"
    assert MATCHING_TYPE.COUNTERPARTY_OFFER.value == "COUNTERPARTY_OFFER"
    
    assert MATCHING_TYPE.NEXT_BAR_OPEN.name == "NEXT_BAR_OPEN"
    assert MATCHING_TYPE.NEXT_BAR_OPEN.value == "NEXT_BAR_OPEN"
    
    assert MATCHING_TYPE.NEXT_TICK_LAST.name == "NEXT_TICK_LAST"
    assert MATCHING_TYPE.NEXT_TICK_LAST.value == "NEXT_TICK_LAST"
    
    assert MATCHING_TYPE.NEXT_TICK_BEST_OWN.name == "NEXT_TICK_BEST_OWN"
    assert MATCHING_TYPE.NEXT_TICK_BEST_OWN.value == "NEXT_TICK_BEST_OWN"
    
    assert MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY.name == "NEXT_TICK_BEST_COUNTERPARTY"
    assert MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY.value == "NEXT_TICK_BEST_COUNTERPARTY"
    
    print("  MATCHING_TYPE tests passed!")


def test_order_type():
    print("Testing ORDER_TYPE...")
    
    assert ORDER_TYPE.MARKET.name == "MARKET"
    assert ORDER_TYPE.MARKET.value == "MARKET"
    
    assert ORDER_TYPE.LIMIT.name == "LIMIT"
    assert ORDER_TYPE.LIMIT.value == "LIMIT"
    
    assert ORDER_TYPE.ALGO.name == "ALGO"
    assert ORDER_TYPE.ALGO.value == "ALGO"
    
    print("  ORDER_TYPE tests passed!")


def test_algo():
    print("Testing ALGO...")
    
    assert ALGO.TWAP.name == "TWAP"
    assert ALGO.TWAP.value == "TWAP"
    
    assert ALGO.VWAP.name == "VWAP"
    assert ALGO.VWAP.value == "VWAP"
    
    print("  ALGO tests passed!")


def test_order_status():
    print("Testing ORDER_STATUS...")
    
    assert ORDER_STATUS.PENDING_NEW.name == "PENDING_NEW"
    assert ORDER_STATUS.PENDING_NEW.value == "PENDING_NEW"
    
    assert ORDER_STATUS.ACTIVE.name == "ACTIVE"
    assert ORDER_STATUS.ACTIVE.value == "ACTIVE"
    
    assert ORDER_STATUS.FILLED.name == "FILLED"
    assert ORDER_STATUS.FILLED.value == "FILLED"
    
    assert ORDER_STATUS.REJECTED.name == "REJECTED"
    assert ORDER_STATUS.REJECTED.value == "REJECTED"
    
    assert ORDER_STATUS.PENDING_CANCEL.name == "PENDING_CANCEL"
    assert ORDER_STATUS.PENDING_CANCEL.value == "PENDING_CANCEL"
    
    assert ORDER_STATUS.CANCELLED.name == "CANCELLED"
    assert ORDER_STATUS.CANCELLED.value == "CANCELLED"
    
    print("  ORDER_STATUS tests passed!")


def test_side():
    print("Testing SIDE...")
    
    assert SIDE.BUY.name == "BUY"
    assert SIDE.BUY.value == "BUY"
    
    assert SIDE.SELL.name == "SELL"
    assert SIDE.SELL.value == "SELL"
    
    assert SIDE.FINANCING.name == "FINANCING"
    assert SIDE.FINANCING.value == "FINANCING"
    
    assert SIDE.MARGIN.name == "MARGIN"
    assert SIDE.MARGIN.value == "MARGIN"
    
    assert SIDE.CONVERT_STOCK.name == "CONVERT_STOCK"
    assert SIDE.CONVERT_STOCK.value == "CONVERT_STOCK"
    
    print("  SIDE tests passed!")


def test_position_effect():
    print("Testing POSITION_EFFECT...")
    
    assert POSITION_EFFECT.OPEN.name == "OPEN"
    assert POSITION_EFFECT.OPEN.value == "OPEN"
    
    assert POSITION_EFFECT.CLOSE.name == "CLOSE"
    assert POSITION_EFFECT.CLOSE.value == "CLOSE"
    
    assert POSITION_EFFECT.CLOSE_TODAY.name == "CLOSE_TODAY"
    assert POSITION_EFFECT.CLOSE_TODAY.value == "CLOSE_TODAY"
    
    assert POSITION_EFFECT.EXERCISE.name == "EXERCISE"
    assert POSITION_EFFECT.EXERCISE.value == "EXERCISE"
    
    assert POSITION_EFFECT.MATCH.name == "MATCH"
    assert POSITION_EFFECT.MATCH.value == "MATCH"
    
    print("  POSITION_EFFECT tests passed!")


def test_position_direction():
    print("Testing POSITION_DIRECTION...")
    
    assert POSITION_DIRECTION.LONG.name == "LONG"
    assert POSITION_DIRECTION.LONG.value == "LONG"
    
    assert POSITION_DIRECTION.SHORT.name == "SHORT"
    assert POSITION_DIRECTION.SHORT.value == "SHORT"
    
    print("  POSITION_DIRECTION tests passed!")


def test_exc_type():
    print("Testing EXC_TYPE...")
    
    assert EXC_TYPE.USER_EXC.name == "USER_EXC"
    assert EXC_TYPE.USER_EXC.value == "USER_EXC"
    
    assert EXC_TYPE.SYSTEM_EXC.name == "SYSTEM_EXC"
    assert EXC_TYPE.SYSTEM_EXC.value == "SYSTEM_EXC"
    
    assert EXC_TYPE.NOTSET.name == "NOTSET"
    assert EXC_TYPE.NOTSET.value == "NOTSET"
    
    print("  EXC_TYPE tests passed!")


def test_instrument_type():
    print("Testing INSTRUMENT_TYPE...")
    
    assert INSTRUMENT_TYPE.CS.name == "CS"
    assert INSTRUMENT_TYPE.CS.value == "CS"
    
    assert INSTRUMENT_TYPE.FUTURE.name == "FUTURE"
    assert INSTRUMENT_TYPE.FUTURE.value == "Future"
    
    assert INSTRUMENT_TYPE.OPTION.name == "OPTION"
    assert INSTRUMENT_TYPE.OPTION.value == "Option"
    
    assert INSTRUMENT_TYPE.ETF.name == "ETF"
    assert INSTRUMENT_TYPE.ETF.value == "ETF"
    
    assert INSTRUMENT_TYPE.LOF.name == "LOF"
    assert INSTRUMENT_TYPE.LOF.value == "LOF"
    
    assert INSTRUMENT_TYPE.INDX.name == "INDX"
    assert INSTRUMENT_TYPE.INDX.value == "INDX"
    
    assert INSTRUMENT_TYPE.PUBLIC_FUND.name == "PUBLIC_FUND"
    assert INSTRUMENT_TYPE.PUBLIC_FUND.value == "PublicFund"
    
    assert INSTRUMENT_TYPE.FUND.name == "FUND"
    assert INSTRUMENT_TYPE.FUND.value == "Fund"
    
    assert INSTRUMENT_TYPE.BOND.name == "BOND"
    assert INSTRUMENT_TYPE.BOND.value == "Bond"
    
    assert INSTRUMENT_TYPE.CONVERTIBLE.name == "CONVERTIBLE"
    assert INSTRUMENT_TYPE.CONVERTIBLE.value == "Convertible"
    
    assert INSTRUMENT_TYPE.SPOT.name == "SPOT"
    assert INSTRUMENT_TYPE.SPOT.value == "Spot"
    
    assert INSTRUMENT_TYPE.REPO.name == "REPO"
    assert INSTRUMENT_TYPE.REPO.value == "Repo"
    
    assert INSTRUMENT_TYPE.REITs.name == "REITs"
    assert INSTRUMENT_TYPE.REITs.value == "REITs"
    
    assert INSTRUMENT_TYPE.FutureArbitrage.name == "FutureArbitrage"
    assert INSTRUMENT_TYPE.FutureArbitrage.value == "FutureArbitrage"
    
    print("  INSTRUMENT_TYPE tests passed!")


def test_persist_mode():
    print("Testing PERSIST_MODE...")
    
    assert PERSIST_MODE.ON_CRASH.name == "ON_CRASH"
    assert PERSIST_MODE.ON_CRASH.value == "ON_CRASH"
    
    assert PERSIST_MODE.REAL_TIME.name == "REAL_TIME"
    assert PERSIST_MODE.REAL_TIME.value == "REAL_TIME"
    
    assert PERSIST_MODE.ON_NORMAL_EXIT.name == "ON_NORMAL_EXIT"
    assert PERSIST_MODE.ON_NORMAL_EXIT.value == "ON_NORMAL_EXIT"
    
    print("  PERSIST_MODE tests passed!")


def test_commission_type():
    print("Testing COMMISSION_TYPE...")
    
    assert COMMISSION_TYPE.BY_MONEY.name == "BY_MONEY"
    assert COMMISSION_TYPE.BY_MONEY.value == "BY_MONEY"
    
    assert COMMISSION_TYPE.BY_VOLUME.name == "BY_VOLUME"
    assert COMMISSION_TYPE.BY_VOLUME.value == "BY_VOLUME"
    
    print("  COMMISSION_TYPE tests passed!")


def test_exit_code():
    print("Testing EXIT_CODE...")
    
    assert EXIT_CODE.EXIT_SUCCESS.name == "EXIT_SUCCESS"
    assert EXIT_CODE.EXIT_SUCCESS.value == "EXIT_SUCCESS"
    
    assert EXIT_CODE.EXIT_USER_ERROR.name == "EXIT_USER_ERROR"
    assert EXIT_CODE.EXIT_USER_ERROR.value == "EXIT_USER_ERROR"
    
    assert EXIT_CODE.EXIT_INTERNAL_ERROR.name == "EXIT_INTERNAL_ERROR"
    assert EXIT_CODE.EXIT_INTERNAL_ERROR.value == "EXIT_INTERNAL_ERROR"
    
    print("  EXIT_CODE tests passed!")


def test_hedge_type():
    print("Testing HEDGE_TYPE...")
    
    assert HEDGE_TYPE.HEDGE.name == "HEDGE"
    assert HEDGE_TYPE.HEDGE.value == "hedge"
    
    assert HEDGE_TYPE.SPECULATION.name == "SPECULATION"
    assert HEDGE_TYPE.SPECULATION.value == "speculation"
    
    assert HEDGE_TYPE.ARBITRAGE.name == "ARBITRAGE"
    assert HEDGE_TYPE.ARBITRAGE.value == "arbitrage"
    
    print("  HEDGE_TYPE tests passed!")


def test_days_cnt():
    print("Testing DAYS_CNT...")
    
    assert DAYS_CNT.DAYS_A_YEAR == 365
    assert DAYS_CNT.TRADING_DAYS_A_YEAR == 252
    
    print("  DAYS_CNT tests passed!")


def test_exchange():
    print("Testing EXCHANGE...")
    
    assert EXCHANGE.XSHE.name == "XSHE"
    assert EXCHANGE.XSHE.value == "XSHE"
    
    assert EXCHANGE.XSHG.name == "XSHG"
    assert EXCHANGE.XSHG.value == "XSHG"
    
    assert EXCHANGE.SHFE.name == "SHFE"
    assert EXCHANGE.SHFE.value == "SHFE"
    
    assert EXCHANGE.INE.name == "INE"
    assert EXCHANGE.INE.value == "INE"
    
    assert EXCHANGE.DCE.name == "DCE"
    assert EXCHANGE.DCE.value == "DCE"
    
    assert EXCHANGE.CZCE.name == "CZCE"
    assert EXCHANGE.CZCE.value == "CZCE"
    
    assert EXCHANGE.CFFEX.name == "CFFEX"
    assert EXCHANGE.CFFEX.value == "CFFEX"
    
    assert EXCHANGE.SGEX.name == "SGEX"
    assert EXCHANGE.SGEX.value == "SGEX"
    
    assert EXCHANGE.BJSE.name == "BJSE"
    assert EXCHANGE.BJSE.value == "BJSE"
    
    print("  EXCHANGE tests passed!")


def test_trading_calendar_type():
    print("Testing TRADING_CALENDAR_TYPE...")
    
    assert TRADING_CALENDAR_TYPE.CN_STOCK.name == "CN_STOCK"
    assert TRADING_CALENDAR_TYPE.CN_STOCK.value == "CN_STOCK"
    
    assert TRADING_CALENDAR_TYPE.HK_STOCK.name == "HK_STOCK"
    assert TRADING_CALENDAR_TYPE.HK_STOCK.value == "HK_STOCK"
    
    assert TRADING_CALENDAR_TYPE.SOUTHBOUND.name == "SOUTHBOUND"
    assert TRADING_CALENDAR_TYPE.SOUTHBOUND.value == "SOUTHBOUND"
    
    assert TRADING_CALENDAR_TYPE.INTER_BANK.name == "INTER_BANK"
    assert TRADING_CALENDAR_TYPE.INTER_BANK.value == "INTERBANK"
    
    assert TRADING_CALENDAR_TYPE.EXCHANGE.name == "CN_STOCK"
    assert TRADING_CALENDAR_TYPE.EXCHANGE.value == "CN_STOCK"
    
    print("  TRADING_CALENDAR_TYPE tests passed!")


def test_market():
    print("Testing MARKET...")
    
    assert MARKET.CN.name == "CN"
    assert MARKET.CN.value == "CN"
    
    assert MARKET.HK.name == "HK"
    assert MARKET.HK.value == "HK"
    
    print("  MARKET tests passed!")


def test_enum_registry() raises:
    print("Testing EnumRegistry...")
    
    var registry = EnumRegistry()
    
    var result = registry.get[EXECUTION_PHASE]("GLOBAL")
    assert result.value.name == "GLOBAL"
    
    var result2 = registry.get[RUN_TYPE]("BACKTEST")
    assert result2.value.name == "BACKTEST"
    
    print("  EnumRegistry tests passed!")


def test_equality():
    print("Testing equality...")
    
    assert EXECUTION_PHASE.GLOBAL == EXECUTION_PHASE.GLOBAL
    assert EXECUTION_PHASE.GLOBAL != EXECUTION_PHASE.ON_INIT
    
    assert RUN_TYPE.BACKTEST == RUN_TYPE.BACKTEST
    assert RUN_TYPE.BACKTEST != RUN_TYPE.PAPER_TRADING
    
    print("  Equality tests passed!")


def main():
    print("=" * 60)
    print("Testing const.mojo - Constants and Enumerations")
    print("=" * 60)
    
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
    test_enum_registry()
    test_equality()
    
    print("=" * 60)
    print("All const.mojo tests passed!")
    print("=" * 60)
