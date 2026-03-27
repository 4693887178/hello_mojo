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



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_execution_phase() raises:
    print("Testing EXECUTION_PHASE...")
    
    assert_equal(EXECUTION_PHASE.GLOBAL.name, "GLOBAL")
    assert_equal(EXECUTION_PHASE.GLOBAL.value, "[全局]")
    assert_equal(EXECUTION_PHASE.ON_INIT.name, "ON_INIT")
    assert_equal(EXECUTION_PHASE.ON_INIT.value, "[程序初始化]")
    assert_equal(EXECUTION_PHASE.BEFORE_TRADING.name, "BEFORE_TRADING")
    assert_equal(EXECUTION_PHASE.BEFORE_TRADING.value, "[日内交易前]")
    assert_equal(EXECUTION_PHASE.OPEN_AUCTION.name, "OPEN_AUCTION")
    assert_equal(EXECUTION_PHASE.OPEN_AUCTION.value, "[集合竞价]")
    assert_equal(EXECUTION_PHASE.ON_BAR.name, "ON_BAR")
    assert_true(EXECUTION_PHASE.ON_BAR.value == "[盘中 handle_bar 函数]")
    
    assert_equal(EXECUTION_PHASE.ON_TICK.name, "ON_TICK")
    assert_true(EXECUTION_PHASE.ON_TICK.value == "[盘中 handle_tick 函数]")
    
    assert_equal(EXECUTION_PHASE.AFTER_TRADING.name, "AFTER_TRADING")
    assert_equal(EXECUTION_PHASE.AFTER_TRADING.value, "[日内交易后]")
    assert_equal(EXECUTION_PHASE.FINALIZED.name, "FINALIZED")
    assert_equal(EXECUTION_PHASE.FINALIZED.value, "[程序结束]")
    assert_equal(EXECUTION_PHASE.SCHEDULED.name, "SCHEDULED")
    assert_equal(EXECUTION_PHASE.SCHEDULED.value, "[scheduler函数内]")
    print("  EXECUTION_PHASE tests passed!")


def test_run_type() raises:
    print("Testing RUN_TYPE...")
    
    assert_equal(RUN_TYPE.BACKTEST.name, "BACKTEST")
    assert_equal(RUN_TYPE.BACKTEST.value, "BACKTEST")
    assert_equal(RUN_TYPE.PAPER_TRADING.name, "PAPER_TRADING")
    assert_equal(RUN_TYPE.PAPER_TRADING.value, "PAPER_TRADING")
    assert_equal(RUN_TYPE.LIVE_TRADING.name, "LIVE_TRADING")
    assert_equal(RUN_TYPE.LIVE_TRADING.value, "LIVE_TRADING")
    print("  RUN_TYPE tests passed!")


def test_default_account_type() raises:
    print("Testing DEFAULT_ACCOUNT_TYPE...")
    
    assert_equal(DEFAULT_ACCOUNT_TYPE.STOCK.name, "STOCK")
    assert_equal(DEFAULT_ACCOUNT_TYPE.STOCK.value, "STOCK")
    assert_equal(DEFAULT_ACCOUNT_TYPE.FUTURE.name, "FUTURE")
    assert_equal(DEFAULT_ACCOUNT_TYPE.FUTURE.value, "FUTURE")
    assert_equal(DEFAULT_ACCOUNT_TYPE.BOND.name, "BOND")
    assert_equal(DEFAULT_ACCOUNT_TYPE.BOND.value, "BOND")
    print("  DEFAULT_ACCOUNT_TYPE tests passed!")


def test_matching_type() raises:
    print("Testing MATCHING_TYPE...")
    
    assert_equal(MATCHING_TYPE.CURRENT_BAR_CLOSE.name, "CURRENT_BAR_CLOSE")
    assert_equal(MATCHING_TYPE.CURRENT_BAR_CLOSE.value, "CURRENT_BAR_CLOSE")
    assert_equal(MATCHING_TYPE.VWAP.name, "VWAP")
    assert_equal(MATCHING_TYPE.VWAP.value, "VWAP")
    assert_equal(MATCHING_TYPE.COUNTERPARTY_OFFER.name, "COUNTERPARTY_OFFER")
    assert_equal(MATCHING_TYPE.COUNTERPARTY_OFFER.value, "COUNTERPARTY_OFFER")
    assert_equal(MATCHING_TYPE.NEXT_BAR_OPEN.name, "NEXT_BAR_OPEN")
    assert_equal(MATCHING_TYPE.NEXT_BAR_OPEN.value, "NEXT_BAR_OPEN")
    assert_equal(MATCHING_TYPE.NEXT_TICK_LAST.name, "NEXT_TICK_LAST")
    assert_equal(MATCHING_TYPE.NEXT_TICK_LAST.value, "NEXT_TICK_LAST")
    assert_equal(MATCHING_TYPE.NEXT_TICK_BEST_OWN.name, "NEXT_TICK_BEST_OWN")
    assert_equal(MATCHING_TYPE.NEXT_TICK_BEST_OWN.value, "NEXT_TICK_BEST_OWN")
    assert_equal(MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY.name, "NEXT_TICK_BEST_COUNTERPARTY")
    assert_equal(MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY.value, "NEXT_TICK_BEST_COUNTERPARTY")
    print("  MATCHING_TYPE tests passed!")


def test_order_type() raises:
    print("Testing ORDER_TYPE...")
    
    assert_equal(ORDER_TYPE.MARKET.name, "MARKET")
    assert_equal(ORDER_TYPE.MARKET.value, "MARKET")
    assert_equal(ORDER_TYPE.LIMIT.name, "LIMIT")
    assert_equal(ORDER_TYPE.LIMIT.value, "LIMIT")
    assert_equal(ORDER_TYPE.ALGO.name, "ALGO")
    assert_equal(ORDER_TYPE.ALGO.value, "ALGO")
    print("  ORDER_TYPE tests passed!")


def test_algo() raises:
    print("Testing ALGO...")
    
    assert_equal(ALGO.TWAP.name, "TWAP")
    assert_equal(ALGO.TWAP.value, "TWAP")
    assert_equal(ALGO.VWAP.name, "VWAP")
    assert_equal(ALGO.VWAP.value, "VWAP")
    print("  ALGO tests passed!")


def test_order_status() raises:
    print("Testing ORDER_STATUS...")
    
    assert_equal(ORDER_STATUS.PENDING_NEW.name, "PENDING_NEW")
    assert_equal(ORDER_STATUS.PENDING_NEW.value, "PENDING_NEW")
    assert_equal(ORDER_STATUS.ACTIVE.name, "ACTIVE")
    assert_equal(ORDER_STATUS.ACTIVE.value, "ACTIVE")
    assert_equal(ORDER_STATUS.FILLED.name, "FILLED")
    assert_equal(ORDER_STATUS.FILLED.value, "FILLED")
    assert_equal(ORDER_STATUS.REJECTED.name, "REJECTED")
    assert_equal(ORDER_STATUS.REJECTED.value, "REJECTED")
    assert_equal(ORDER_STATUS.PENDING_CANCEL.name, "PENDING_CANCEL")
    assert_equal(ORDER_STATUS.PENDING_CANCEL.value, "PENDING_CANCEL")
    assert_equal(ORDER_STATUS.CANCELLED.name, "CANCELLED")
    assert_equal(ORDER_STATUS.CANCELLED.value, "CANCELLED")
    print("  ORDER_STATUS tests passed!")


def test_side() raises:
    print("Testing SIDE...")
    
    assert_equal(SIDE.BUY.name, "BUY")
    assert_equal(SIDE.BUY.value, "BUY")
    assert_equal(SIDE.SELL.name, "SELL")
    assert_equal(SIDE.SELL.value, "SELL")
    assert_equal(SIDE.FINANCING.name, "FINANCING")
    assert_equal(SIDE.FINANCING.value, "FINANCING")
    assert_equal(SIDE.MARGIN.name, "MARGIN")
    assert_equal(SIDE.MARGIN.value, "MARGIN")
    assert_equal(SIDE.CONVERT_STOCK.name, "CONVERT_STOCK")
    assert_equal(SIDE.CONVERT_STOCK.value, "CONVERT_STOCK")
    print("  SIDE tests passed!")


def test_position_effect() raises:
    print("Testing POSITION_EFFECT...")
    
    assert_equal(POSITION_EFFECT.OPEN.name, "OPEN")
    assert_equal(POSITION_EFFECT.OPEN.value, "OPEN")
    assert_equal(POSITION_EFFECT.CLOSE.name, "CLOSE")
    assert_equal(POSITION_EFFECT.CLOSE.value, "CLOSE")
    assert_equal(POSITION_EFFECT.CLOSE_TODAY.name, "CLOSE_TODAY")
    assert_equal(POSITION_EFFECT.CLOSE_TODAY.value, "CLOSE_TODAY")
    assert_equal(POSITION_EFFECT.EXERCISE.name, "EXERCISE")
    assert_equal(POSITION_EFFECT.EXERCISE.value, "EXERCISE")
    assert_equal(POSITION_EFFECT.MATCH.name, "MATCH")
    assert_equal(POSITION_EFFECT.MATCH.value, "MATCH")
    print("  POSITION_EFFECT tests passed!")


def test_position_direction() raises:
    print("Testing POSITION_DIRECTION...")
    
    assert_equal(POSITION_DIRECTION.LONG.name, "LONG")
    assert_equal(POSITION_DIRECTION.LONG.value, "LONG")
    assert_equal(POSITION_DIRECTION.SHORT.name, "SHORT")
    assert_equal(POSITION_DIRECTION.SHORT.value, "SHORT")
    print("  POSITION_DIRECTION tests passed!")


def test_exc_type() raises:
    print("Testing EXC_TYPE...")
    
    assert_equal(EXC_TYPE.USER_EXC.name, "USER_EXC")
    assert_equal(EXC_TYPE.USER_EXC.value, "USER_EXC")
    assert_equal(EXC_TYPE.SYSTEM_EXC.name, "SYSTEM_EXC")
    assert_equal(EXC_TYPE.SYSTEM_EXC.value, "SYSTEM_EXC")
    assert_equal(EXC_TYPE.NOTSET.name, "NOTSET")
    assert_equal(EXC_TYPE.NOTSET.value, "NOTSET")
    print("  EXC_TYPE tests passed!")


def test_instrument_type() raises:
    print("Testing INSTRUMENT_TYPE...")
    
    assert_equal(INSTRUMENT_TYPE.CS.name, "CS")
    assert_equal(INSTRUMENT_TYPE.CS.value, "CS")
    assert_equal(INSTRUMENT_TYPE.FUTURE.name, "FUTURE")
    assert_equal(INSTRUMENT_TYPE.FUTURE.value, "Future")
    assert_equal(INSTRUMENT_TYPE.OPTION.name, "OPTION")
    assert_equal(INSTRUMENT_TYPE.OPTION.value, "Option")
    assert_equal(INSTRUMENT_TYPE.ETF.name, "ETF")
    assert_equal(INSTRUMENT_TYPE.ETF.value, "ETF")
    assert_equal(INSTRUMENT_TYPE.LOF.name, "LOF")
    assert_equal(INSTRUMENT_TYPE.LOF.value, "LOF")
    assert_equal(INSTRUMENT_TYPE.INDX.name, "INDX")
    assert_equal(INSTRUMENT_TYPE.INDX.value, "INDX")
    assert_equal(INSTRUMENT_TYPE.PUBLIC_FUND.name, "PUBLIC_FUND")
    assert_equal(INSTRUMENT_TYPE.PUBLIC_FUND.value, "PublicFund")
    assert_equal(INSTRUMENT_TYPE.FUND.name, "FUND")
    assert_equal(INSTRUMENT_TYPE.FUND.value, "Fund")
    assert_equal(INSTRUMENT_TYPE.BOND.name, "BOND")
    assert_equal(INSTRUMENT_TYPE.BOND.value, "Bond")
    assert_equal(INSTRUMENT_TYPE.CONVERTIBLE.name, "CONVERTIBLE")
    assert_equal(INSTRUMENT_TYPE.CONVERTIBLE.value, "Convertible")
    assert_equal(INSTRUMENT_TYPE.SPOT.name, "SPOT")
    assert_equal(INSTRUMENT_TYPE.SPOT.value, "Spot")
    assert_equal(INSTRUMENT_TYPE.REPO.name, "REPO")
    assert_equal(INSTRUMENT_TYPE.REPO.value, "Repo")
    assert_equal(INSTRUMENT_TYPE.REITs.name, "REITs")
    assert_equal(INSTRUMENT_TYPE.REITs.value, "REITs")
    assert_equal(INSTRUMENT_TYPE.FutureArbitrage.name, "FutureArbitrage")
    assert_equal(INSTRUMENT_TYPE.FutureArbitrage.value, "FutureArbitrage")
    print("  INSTRUMENT_TYPE tests passed!")


def test_persist_mode() raises:
    print("Testing PERSIST_MODE...")
    
    assert_equal(PERSIST_MODE.ON_CRASH.name, "ON_CRASH")
    assert_equal(PERSIST_MODE.ON_CRASH.value, "ON_CRASH")
    assert_equal(PERSIST_MODE.REAL_TIME.name, "REAL_TIME")
    assert_equal(PERSIST_MODE.REAL_TIME.value, "REAL_TIME")
    assert_equal(PERSIST_MODE.ON_NORMAL_EXIT.name, "ON_NORMAL_EXIT")
    assert_equal(PERSIST_MODE.ON_NORMAL_EXIT.value, "ON_NORMAL_EXIT")
    print("  PERSIST_MODE tests passed!")


def test_commission_type() raises:
    print("Testing COMMISSION_TYPE...")
    
    assert_equal(COMMISSION_TYPE.BY_MONEY.name, "BY_MONEY")
    assert_equal(COMMISSION_TYPE.BY_MONEY.value, "BY_MONEY")
    assert_equal(COMMISSION_TYPE.BY_VOLUME.name, "BY_VOLUME")
    assert_equal(COMMISSION_TYPE.BY_VOLUME.value, "BY_VOLUME")
    print("  COMMISSION_TYPE tests passed!")


def test_exit_code() raises:
    print("Testing EXIT_CODE...")
    
    assert_equal(EXIT_CODE.EXIT_SUCCESS.name, "EXIT_SUCCESS")
    assert_equal(EXIT_CODE.EXIT_SUCCESS.value, "EXIT_SUCCESS")
    assert_equal(EXIT_CODE.EXIT_USER_ERROR.name, "EXIT_USER_ERROR")
    assert_equal(EXIT_CODE.EXIT_USER_ERROR.value, "EXIT_USER_ERROR")
    assert_equal(EXIT_CODE.EXIT_INTERNAL_ERROR.name, "EXIT_INTERNAL_ERROR")
    assert_equal(EXIT_CODE.EXIT_INTERNAL_ERROR.value, "EXIT_INTERNAL_ERROR")
    print("  EXIT_CODE tests passed!")


def test_hedge_type() raises:
    print("Testing HEDGE_TYPE...")
    
    assert_equal(HEDGE_TYPE.HEDGE.name, "HEDGE")
    assert_equal(HEDGE_TYPE.HEDGE.value, "hedge")
    assert_equal(HEDGE_TYPE.SPECULATION.name, "SPECULATION")
    assert_equal(HEDGE_TYPE.SPECULATION.value, "speculation")
    assert_equal(HEDGE_TYPE.ARBITRAGE.name, "ARBITRAGE")
    assert_equal(HEDGE_TYPE.ARBITRAGE.value, "arbitrage")
    print("  HEDGE_TYPE tests passed!")


def test_days_cnt() raises:
    print("Testing DAYS_CNT...")
    
    assert_equal(DAYS_CNT.DAYS_A_YEAR, 365)
    assert_equal(DAYS_CNT.TRADING_DAYS_A_YEAR, 252)
    print("  DAYS_CNT tests passed!")


def test_exchange() raises:
    print("Testing EXCHANGE...")
    
    assert_equal(EXCHANGE.XSHE.name, "XSHE")
    assert_equal(EXCHANGE.XSHE.value, "XSHE")
    assert_equal(EXCHANGE.XSHG.name, "XSHG")
    assert_equal(EXCHANGE.XSHG.value, "XSHG")
    assert_equal(EXCHANGE.SHFE.name, "SHFE")
    assert_equal(EXCHANGE.SHFE.value, "SHFE")
    assert_equal(EXCHANGE.INE.name, "INE")
    assert_equal(EXCHANGE.INE.value, "INE")
    assert_equal(EXCHANGE.DCE.name, "DCE")
    assert_equal(EXCHANGE.DCE.value, "DCE")
    assert_equal(EXCHANGE.CZCE.name, "CZCE")
    assert_equal(EXCHANGE.CZCE.value, "CZCE")
    assert_equal(EXCHANGE.CFFEX.name, "CFFEX")
    assert_equal(EXCHANGE.CFFEX.value, "CFFEX")
    assert_equal(EXCHANGE.SGEX.name, "SGEX")
    assert_equal(EXCHANGE.SGEX.value, "SGEX")
    assert_equal(EXCHANGE.BJSE.name, "BJSE")
    assert_equal(EXCHANGE.BJSE.value, "BJSE")
    print("  EXCHANGE tests passed!")


def test_trading_calendar_type() raises:
    print("Testing TRADING_CALENDAR_TYPE...")
    
    assert_equal(TRADING_CALENDAR_TYPE.CN_STOCK.name, "CN_STOCK")
    assert_equal(TRADING_CALENDAR_TYPE.CN_STOCK.value, "CN_STOCK")
    assert_equal(TRADING_CALENDAR_TYPE.HK_STOCK.name, "HK_STOCK")
    assert_equal(TRADING_CALENDAR_TYPE.HK_STOCK.value, "HK_STOCK")
    assert_equal(TRADING_CALENDAR_TYPE.SOUTHBOUND.name, "SOUTHBOUND")
    assert_equal(TRADING_CALENDAR_TYPE.SOUTHBOUND.value, "SOUTHBOUND")
    assert_equal(TRADING_CALENDAR_TYPE.INTER_BANK.name, "INTER_BANK")
    assert_equal(TRADING_CALENDAR_TYPE.INTER_BANK.value, "INTERBANK")
    assert_equal(TRADING_CALENDAR_TYPE.EXCHANGE.name, "CN_STOCK")
    assert_equal(TRADING_CALENDAR_TYPE.EXCHANGE.value, "CN_STOCK")
    print("  TRADING_CALENDAR_TYPE tests passed!")


def test_market() raises:
    print("Testing MARKET...")
    
    assert_equal(MARKET.CN.name, "CN")
    assert_equal(MARKET.CN.value, "CN")
    assert_equal(MARKET.HK.name, "HK")
    assert_equal(MARKET.HK.value, "HK")
    print("  MARKET tests passed!")


def test_enum_registry() raises:
    print("Testing EnumRegistry...")
    
    var registry = EnumRegistry()
    
    var result = registry.get[EXECUTION_PHASE]("GLOBAL")
    assert_equal(result.value().name, "GLOBAL")
    
    var result2 = registry.get[RUN_TYPE]("BACKTEST")
    assert_equal(result2.value().name, "BACKTEST")
    
    print("  EnumRegistry tests passed!")


def test_equality() raises:
    print("Testing equality...")
    
    assert_true(EXECUTION_PHASE.GLOBAL == EXECUTION_PHASE.GLOBAL)
    assert_true(EXECUTION_PHASE.GLOBAL != EXECUTION_PHASE.ON_INIT)
    
    assert_equal(RUN_TYPE.BACKTEST, RUN_TYPE.BACKTEST)
    assert_true(RUN_TYPE.BACKTEST != RUN_TYPE.PAPER_TRADING)
    
    print("  Equality tests passed!")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()