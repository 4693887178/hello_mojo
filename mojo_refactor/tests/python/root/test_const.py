"""
RQAlpha const.py 测试文件
测试所有枚举类和常量的正确性
"""

import pytest
from rqalpha.const import (
    EXECUTION_PHASE, RUN_TYPE, DEFAULT_ACCOUNT_TYPE, MATCHING_TYPE,
    ORDER_TYPE, ALGO, ORDER_STATUS, SIDE, POSITION_EFFECT,
    POSITION_DIRECTION, EXC_TYPE, INSTRUMENT_TYPE, PERSIST_MODE,
    COMMISSION_TYPE, EXIT_CODE, HEDGE_TYPE, DAYS_CNT, EXCHANGE,
    TRADING_CALENDAR_TYPE, MARKET
)


class TestEXECUTION_PHASE:
    def test_global(self):
        assert EXECUTION_PHASE.GLOBAL.value == "[全局]"
        assert EXECUTION_PHASE.GLOBAL.name == "GLOBAL"
    
    def test_on_init(self):
        assert EXECUTION_PHASE.ON_INIT.value == "[程序初始化]"
        assert EXECUTION_PHASE.ON_INIT.name == "ON_INIT"
    
    def test_before_trading(self):
        assert EXECUTION_PHASE.BEFORE_TRADING.value == "[日内交易前]"
        assert EXECUTION_PHASE.BEFORE_TRADING.name == "BEFORE_TRADING"
    
    def test_open_auction(self):
        assert EXECUTION_PHASE.OPEN_AUCTION.value == "[集合竞价]"
        assert EXECUTION_PHASE.OPEN_AUCTION.name == "OPEN_AUCTION"
    
    def test_on_bar(self):
        assert EXECUTION_PHASE.ON_BAR.value == "[盘中 handle_bar 函数]"
        assert EXECUTION_PHASE.ON_BAR.name == "ON_BAR"
    
    def test_on_tick(self):
        assert EXECUTION_PHASE.ON_TICK.value == "[盘中 handle_tick 函数]"
        assert EXECUTION_PHASE.ON_TICK.name == "ON_TICK"
    
    def test_after_trading(self):
        assert EXECUTION_PHASE.AFTER_TRADING.value == "[日内交易后]"
        assert EXECUTION_PHASE.AFTER_TRADING.name == "AFTER_TRADING"
    
    def test_finalized(self):
        assert EXECUTION_PHASE.FINALIZED.value == "[程序结束]"
        assert EXECUTION_PHASE.FINALIZED.name == "FINALIZED"
    
    def test_scheduled(self):
        assert EXECUTION_PHASE.SCHEDULED.value == "[scheduler函数内]"
        assert EXECUTION_PHASE.SCHEDULED.name == "SCHEDULED"
    
    def test_count(self):
        assert len(EXECUTION_PHASE) == 9
    
    def test_contains_by_name(self):
        assert "GLOBAL" in EXECUTION_PHASE
    
    def test_contains_by_value(self):
        assert "[全局]" in EXECUTION_PHASE
    
    def test_getitem_by_name(self):
        assert EXECUTION_PHASE["GLOBAL"] == EXECUTION_PHASE.GLOBAL
    
    def test_getitem_by_value(self):
        assert EXECUTION_PHASE["[全局]"] == EXECUTION_PHASE.GLOBAL


class TestRUN_TYPE:
    def test_backtest(self):
        assert RUN_TYPE.BACKTEST.value == "BACKTEST"
        assert RUN_TYPE.BACKTEST.name == "BACKTEST"
    
    def test_paper_trading(self):
        assert RUN_TYPE.PAPER_TRADING.value == "PAPER_TRADING"
        assert RUN_TYPE.PAPER_TRADING.name == "PAPER_TRADING"
    
    def test_live_trading(self):
        assert RUN_TYPE.LIVE_TRADING.value == "LIVE_TRADING"
        assert RUN_TYPE.LIVE_TRADING.name == "LIVE_TRADING"
    
    def test_count(self):
        assert len(RUN_TYPE) == 3


class TestDEFAULT_ACCOUNT_TYPE:
    def test_stock(self):
        assert DEFAULT_ACCOUNT_TYPE.STOCK.value == "STOCK"
        assert DEFAULT_ACCOUNT_TYPE.STOCK.name == "STOCK"
    
    def test_future(self):
        assert DEFAULT_ACCOUNT_TYPE.FUTURE.value == "FUTURE"
        assert DEFAULT_ACCOUNT_TYPE.FUTURE.name == "FUTURE"
    
    def test_bond(self):
        assert DEFAULT_ACCOUNT_TYPE.BOND.value == "BOND"
        assert DEFAULT_ACCOUNT_TYPE.BOND.name == "BOND"
    
    def test_count(self):
        assert len(DEFAULT_ACCOUNT_TYPE) == 3


class TestMATCHING_TYPE:
    def test_current_bar_close(self):
        assert MATCHING_TYPE.CURRENT_BAR_CLOSE.value == "CURRENT_BAR_CLOSE"
    
    def test_vwap(self):
        assert MATCHING_TYPE.VWAP.value == "VWAP"
    
    def test_counterparty_offer(self):
        assert MATCHING_TYPE.COUNTERPARTY_OFFER.value == "COUNTERPARTY_OFFER"
    
    def test_next_bar_open(self):
        assert MATCHING_TYPE.NEXT_BAR_OPEN.value == "NEXT_BAR_OPEN"
    
    def test_next_tick_last(self):
        assert MATCHING_TYPE.NEXT_TICK_LAST.value == "NEXT_TICK_LAST"
    
    def test_next_tick_best_own(self):
        assert MATCHING_TYPE.NEXT_TICK_BEST_OWN.value == "NEXT_TICK_BEST_OWN"
    
    def test_next_tick_best_counterparty(self):
        assert MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY.value == "NEXT_TICK_BEST_COUNTERPARTY"
    
    def test_count(self):
        assert len(MATCHING_TYPE) == 7


class TestORDER_TYPE:
    def test_market(self):
        assert ORDER_TYPE.MARKET.value == "MARKET"
    
    def test_limit(self):
        assert ORDER_TYPE.LIMIT.value == "LIMIT"
    
    def test_algo(self):
        assert ORDER_TYPE.ALGO.value == "ALGO"
    
    def test_count(self):
        assert len(ORDER_TYPE) == 3


class TestALGO:
    def test_twap(self):
        assert ALGO.TWAP.value == "TWAP"
    
    def test_vwap(self):
        assert ALGO.VWAP.value == "VWAP"
    
    def test_count(self):
        assert len(ALGO) == 2


class TestORDER_STATUS:
    def test_pending_new(self):
        assert ORDER_STATUS.PENDING_NEW.value == "PENDING_NEW"
    
    def test_active(self):
        assert ORDER_STATUS.ACTIVE.value == "ACTIVE"
    
    def test_filled(self):
        assert ORDER_STATUS.FILLED.value == "FILLED"
    
    def test_rejected(self):
        assert ORDER_STATUS.REJECTED.value == "REJECTED"
    
    def test_pending_cancel(self):
        assert ORDER_STATUS.PENDING_CANCEL.value == "PENDING_CANCEL"
    
    def test_cancelled(self):
        assert ORDER_STATUS.CANCELLED.value == "CANCELLED"
    
    def test_count(self):
        assert len(ORDER_STATUS) == 6


class TestSIDE:
    def test_buy(self):
        assert SIDE.BUY.value == "BUY"
    
    def test_sell(self):
        assert SIDE.SELL.value == "SELL"
    
    def test_financing(self):
        assert SIDE.FINANCING.value == "FINANCING"
    
    def test_margin(self):
        assert SIDE.MARGIN.value == "MARGIN"
    
    def test_convert_stock(self):
        assert SIDE.CONVERT_STOCK.value == "CONVERT_STOCK"
    
    def test_count(self):
        assert len(SIDE) == 5


class TestPOSITION_EFFECT:
    def test_open(self):
        assert POSITION_EFFECT.OPEN.value == "OPEN"
    
    def test_close(self):
        assert POSITION_EFFECT.CLOSE.value == "CLOSE"
    
    def test_close_today(self):
        assert POSITION_EFFECT.CLOSE_TODAY.value == "CLOSE_TODAY"
    
    def test_exercise(self):
        assert POSITION_EFFECT.EXERCISE.value == "EXERCISE"
    
    def test_match(self):
        assert POSITION_EFFECT.MATCH.value == "MATCH"
    
    def test_count(self):
        assert len(POSITION_EFFECT) == 5


class TestPOSITION_DIRECTION:
    def test_long(self):
        assert POSITION_DIRECTION.LONG.value == "LONG"
    
    def test_short(self):
        assert POSITION_DIRECTION.SHORT.value == "SHORT"
    
    def test_count(self):
        assert len(POSITION_DIRECTION) == 2


class TestEXC_TYPE:
    def test_user_exc(self):
        assert EXC_TYPE.USER_EXC.value == "USER_EXC"
    
    def test_system_exc(self):
        assert EXC_TYPE.SYSTEM_EXC.value == "SYSTEM_EXC"
    
    def test_notset(self):
        assert EXC_TYPE.NOTSET.value == "NOTSET"
    
    def test_count(self):
        assert len(EXC_TYPE) == 3


class TestINSTRUMENT_TYPE:
    def test_cs(self):
        assert INSTRUMENT_TYPE.CS.value == "CS"
    
    def test_future(self):
        assert INSTRUMENT_TYPE.FUTURE.value == "Future"
    
    def test_option(self):
        assert INSTRUMENT_TYPE.OPTION.value == "Option"
    
    def test_etf(self):
        assert INSTRUMENT_TYPE.ETF.value == "ETF"
    
    def test_lof(self):
        assert INSTRUMENT_TYPE.LOF.value == "LOF"
    
    def test_indx(self):
        assert INSTRUMENT_TYPE.INDX.value == "INDX"
    
    def test_public_fund(self):
        assert INSTRUMENT_TYPE.PUBLIC_FUND.value == "PublicFund"
    
    def test_fund(self):
        assert INSTRUMENT_TYPE.FUND.value == "Fund"
    
    def test_bond(self):
        assert INSTRUMENT_TYPE.BOND.value == "Bond"
    
    def test_convertible(self):
        assert INSTRUMENT_TYPE.CONVERTIBLE.value == "Convertible"
    
    def test_spot(self):
        assert INSTRUMENT_TYPE.SPOT.value == "Spot"
    
    def test_repo(self):
        assert INSTRUMENT_TYPE.REPO.value == "Repo"
    
    def test_reits(self):
        assert INSTRUMENT_TYPE.REITs.value == "REITs"
    
    def test_future_arbitrage(self):
        assert INSTRUMENT_TYPE.FutureArbitrage.value == "FutureArbitrage"
    
    def test_count(self):
        assert len(INSTRUMENT_TYPE) == 14


class TestPERSIST_MODE:
    def test_on_crash(self):
        assert PERSIST_MODE.ON_CRASH.value == "ON_CRASH"
    
    def test_real_time(self):
        assert PERSIST_MODE.REAL_TIME.value == "REAL_TIME"
    
    def test_on_normal_exit(self):
        assert PERSIST_MODE.ON_NORMAL_EXIT.value == "ON_NORMAL_EXIT"
    
    def test_count(self):
        assert len(PERSIST_MODE) == 3


class TestCOMMISSION_TYPE:
    def test_by_money(self):
        assert COMMISSION_TYPE.BY_MONEY.value == "BY_MONEY"
    
    def test_by_volume(self):
        assert COMMISSION_TYPE.BY_VOLUME.value == "BY_VOLUME"
    
    def test_count(self):
        assert len(COMMISSION_TYPE) == 2


class TestEXIT_CODE:
    def test_exit_success(self):
        assert EXIT_CODE.EXIT_SUCCESS.value == "EXIT_SUCCESS"
    
    def test_exit_user_error(self):
        assert EXIT_CODE.EXIT_USER_ERROR.value == "EXIT_USER_ERROR"
    
    def test_exit_internal_error(self):
        assert EXIT_CODE.EXIT_INTERNAL_ERROR.value == "EXIT_INTERNAL_ERROR"
    
    def test_count(self):
        assert len(EXIT_CODE) == 3


class TestHEDGE_TYPE:
    def test_hedge(self):
        assert HEDGE_TYPE.HEDGE.value == "hedge"
    
    def test_speculation(self):
        assert HEDGE_TYPE.SPECULATION.value == "speculation"
    
    def test_arbitrage(self):
        assert HEDGE_TYPE.ARBITRAGE.value == "arbitrage"
    
    def test_count(self):
        assert len(HEDGE_TYPE) == 3


class TestDAYS_CNT:
    def test_days_a_year(self):
        assert DAYS_CNT.DAYS_A_YEAR == 365
    
    def test_trading_days_a_year(self):
        assert DAYS_CNT.TRADING_DAYS_A_YEAR == 252


class TestEXCHANGE:
    def test_xshe(self):
        assert EXCHANGE.XSHE.value == "XSHE"
    
    def test_xshg(self):
        assert EXCHANGE.XSHG.value == "XSHG"
    
    def test_shfe(self):
        assert EXCHANGE.SHFE.value == "SHFE"
    
    def test_ine(self):
        assert EXCHANGE.INE.value == "INE"
    
    def test_dce(self):
        assert EXCHANGE.DCE.value == "DCE"
    
    def test_czce(self):
        assert EXCHANGE.CZCE.value == "CZCE"
    
    def test_cffex(self):
        assert EXCHANGE.CFFEX.value == "CFFEX"
    
    def test_sgex(self):
        assert EXCHANGE.SGEX.value == "SGEX"
    
    def test_bjse(self):
        assert EXCHANGE.BJSE.value == "BJSE"
    
    def test_count(self):
        assert len(EXCHANGE) == 9


class TestTRADING_CALENDAR_TYPE:
    def test_cn_stock(self):
        assert TRADING_CALENDAR_TYPE.CN_STOCK.value == "CN_STOCK"
    
    def test_hk_stock(self):
        assert TRADING_CALENDAR_TYPE.HK_STOCK.value == "HK_STOCK"
    
    def test_southbound(self):
        assert TRADING_CALENDAR_TYPE.SOUTHBOUND.value == "SOUTHBOUND"
    
    def test_inter_bank(self):
        assert TRADING_CALENDAR_TYPE.INTER_BANK.value == "INTERBANK"
    
    def test_exchange_backward_compatible(self):
        assert TRADING_CALENDAR_TYPE.EXCHANGE == TRADING_CALENDAR_TYPE.CN_STOCK
    
    def test_count(self):
        assert len(TRADING_CALENDAR_TYPE) == 4


class TestMARKET:
    def test_cn(self):
        assert MARKET.CN.value == "CN"
    
    def test_hk(self):
        assert MARKET.HK.value == "HK"
    
    def test_count(self):
        assert len(MARKET) == 2


class TestCustomEnumFeatures:
    def test_repr_format(self):
        assert repr(EXECUTION_PHASE.GLOBAL) == "EXECUTION_PHASE.GLOBAL"
    
    def test_string_inheritance(self):
        assert isinstance(EXECUTION_PHASE.GLOBAL, str)
    
    def test_equality(self):
        assert EXECUTION_PHASE.GLOBAL == EXECUTION_PHASE.GLOBAL
        assert EXECUTION_PHASE.GLOBAL != EXECUTION_PHASE.ON_INIT
    
    def test_hashable(self):
        phase_set = {EXECUTION_PHASE.GLOBAL, EXECUTION_PHASE.ON_INIT}
        assert len(phase_set) == 2
        assert EXECUTION_PHASE.GLOBAL in phase_set
