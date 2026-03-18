# test_L00_01_const.py
# 对应模块: rqalpha.const
# Mojo对应: rqmojo.const
# 层级: L00 - 叶子模块
# 依赖: 无

import pytest
from rqalpha import const


class TestL00Const:
    """L00层 - const模块测试"""
    
    class TestCustomEnumMeta:
        """CustomEnumMeta元类测试"""
        
        def test_contains_member_name(self):
            """测试成员名称包含检查"""
            assert "BUY" in const.SIDE
            assert "SELL" in const.SIDE
        
        def test_contains_member_value(self):
            """测试成员值包含检查"""
            assert "BUY" in const.SIDE
            assert "SELL" in const.SIDE
        
        def test_getitem_by_name(self):
            """测试通过名称获取枚举值"""
            assert const.SIDE["BUY"] == const.SIDE.BUY
            assert const.SIDE["SELL"] == const.SIDE.SELL
        
        def test_getitem_by_value(self):
            """测试通过值获取枚举值"""
            assert const.SIDE["BUY"] == const.SIDE.BUY
            assert const.SIDE["SELL"] == const.SIDE.SELL
    
    class TestSIDE:
        """SIDE枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.SIDE.BUY.value == "BUY"
            assert const.SIDE.SELL.value == "SELL"
            assert const.SIDE.FINANCING.value == "FINANCING"
            assert const.SIDE.MARGIN.value == "MARGIN"
            assert const.SIDE.CONVERT_STOCK.value == "CONVERT_STOCK"
        
        def test_equality(self):
            """测试相等性"""
            assert const.SIDE.BUY == const.SIDE.BUY
            assert const.SIDE.BUY != const.SIDE.SELL
        
        def test_string_representation(self):
            """测试字符串表示"""
            assert str(const.SIDE.BUY) == "SIDE.BUY"
            assert repr(const.SIDE.BUY) == "SIDE.BUY"
    
    class TestPOSITION_EFFECT:
        """POSITION_EFFECT枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.POSITION_EFFECT.OPEN.value == "OPEN"
            assert const.POSITION_EFFECT.CLOSE.value == "CLOSE"
            assert const.POSITION_EFFECT.CLOSE_TODAY.value == "CLOSE_TODAY"
            assert const.POSITION_EFFECT.EXERCISE.value == "EXERCISE"
            assert const.POSITION_EFFECT.MATCH.value == "MATCH"
    
    class TestORDER_STATUS:
        """ORDER_STATUS枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.ORDER_STATUS.PENDING_NEW.value == "PENDING_NEW"
            assert const.ORDER_STATUS.ACTIVE.value == "ACTIVE"
            assert const.ORDER_STATUS.FILLED.value == "FILLED"
            assert const.ORDER_STATUS.REJECTED.value == "REJECTED"
            assert const.ORDER_STATUS.PENDING_CANCEL.value == "PENDING_CANCEL"
            assert const.ORDER_STATUS.CANCELLED.value == "CANCELLED"
    
    class TestORDER_TYPE:
        """ORDER_TYPE枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.ORDER_TYPE.MARKET.value == "MARKET"
            assert const.ORDER_TYPE.LIMIT.value == "LIMIT"
            assert const.ORDER_TYPE.ALGO.value == "ALGO"
    
    class TestEXCHANGE:
        """EXCHANGE枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.EXCHANGE.XSHE.value == "XSHE"
            assert const.EXCHANGE.XSHG.value == "XSHG"
            assert const.EXCHANGE.SHFE.value == "SHFE"
            assert const.EXCHANGE.INE.value == "INE"
            assert const.EXCHANGE.DCE.value == "DCE"
            assert const.EXCHANGE.CZCE.value == "CZCE"
            assert const.EXCHANGE.CFFEX.value == "CFFEX"
            assert const.EXCHANGE.SGEX.value == "SGEX"
            assert const.EXCHANGE.BJSE.value == "BJSE"
    
    class TestINSTRUMENT_TYPE:
        """INSTRUMENT_TYPE枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.INSTRUMENT_TYPE.CS.value == "CS"
            assert const.INSTRUMENT_TYPE.FUTURE.value == "Future"
            assert const.INSTRUMENT_TYPE.OPTION.value == "Option"
            assert const.INSTRUMENT_TYPE.ETF.value == "ETF"
            assert const.INSTRUMENT_TYPE.LOF.value == "LOF"
            assert const.INSTRUMENT_TYPE.INDX.value == "INDX"
            assert const.INSTRUMENT_TYPE.PUBLIC_FUND.value == "PublicFund"
            assert const.INSTRUMENT_TYPE.FUND.value == "Fund"
            assert const.INSTRUMENT_TYPE.BOND.value == "Bond"
            assert const.INSTRUMENT_TYPE.CONVERTIBLE.value == "Convertible"
            assert const.INSTRUMENT_TYPE.SPOT.value == "Spot"
            assert const.INSTRUMENT_TYPE.REPO.value == "Repo"
            assert const.INSTRUMENT_TYPE.REITs.value == "REITs"
    
    class TestRUN_TYPE:
        """RUN_TYPE枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.RUN_TYPE.BACKTEST.value == "BACKTEST"
            assert const.RUN_TYPE.PAPER_TRADING.value == "PAPER_TRADING"
            assert const.RUN_TYPE.LIVE_TRADING.value == "LIVE_TRADING"
    
    class TestEXECUTION_PHASE:
        """EXECUTION_PHASE枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.EXECUTION_PHASE.GLOBAL.value == "[全局]"
            assert const.EXECUTION_PHASE.ON_INIT.value == "[程序初始化]"
            assert const.EXECUTION_PHASE.BEFORE_TRADING.value == "[日内交易前]"
            assert const.EXECUTION_PHASE.OPEN_AUCTION.value == "[集合竞价]"
            assert const.EXECUTION_PHASE.ON_BAR.value == "[盘中 handle_bar 函数]"
            assert const.EXECUTION_PHASE.ON_TICK.value == "[盘中 handle_tick 函数]"
            assert const.EXECUTION_PHASE.AFTER_TRADING.value == "[日内交易后]"
            assert const.EXECUTION_PHASE.FINALIZED.value == "[程序结束]"
            assert const.EXECUTION_PHASE.SCHEDULED.value == "[scheduler函数内]"
    
    class TestMATCHING_TYPE:
        """MATCHING_TYPE枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.MATCHING_TYPE.CURRENT_BAR_CLOSE.value == "CURRENT_BAR_CLOSE"
            assert const.MATCHING_TYPE.VWAP.value == "VWAP"
            assert const.MATCHING_TYPE.COUNTERPARTY_OFFER.value == "COUNTERPARTY_OFFER"
            assert const.MATCHING_TYPE.NEXT_BAR_OPEN.value == "NEXT_BAR_OPEN"
            assert const.MATCHING_TYPE.NEXT_TICK_LAST.value == "NEXT_TICK_LAST"
            assert const.MATCHING_TYPE.NEXT_TICK_BEST_OWN.value == "NEXT_TICK_BEST_OWN"
            assert const.MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY.value == "NEXT_TICK_BEST_COUNTERPARTY"
    
    class TestPOSITION_DIRECTION:
        """POSITION_DIRECTION枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.POSITION_DIRECTION.LONG.value == "LONG"
            assert const.POSITION_DIRECTION.SHORT.value == "SHORT"
    
    class TestDEFAULT_ACCOUNT_TYPE:
        """DEFAULT_ACCOUNT_TYPE枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.DEFAULT_ACCOUNT_TYPE.STOCK.value == "STOCK"
            assert const.DEFAULT_ACCOUNT_TYPE.FUTURE.value == "FUTURE"
            assert const.DEFAULT_ACCOUNT_TYPE.BOND.value == "BOND"
    
    class TestALGO:
        """ALGO枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.ALGO.TWAP.value == "TWAP"
            assert const.ALGO.VWAP.value == "VWAP"
    
    class TestEXC_TYPE:
        """EXC_TYPE枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.EXC_TYPE.USER_EXC.value == "USER_EXC"
            assert const.EXC_TYPE.SYSTEM_EXC.value == "SYSTEM_EXC"
            assert const.EXC_TYPE.NOTSET.value == "NOTSET"
    
    class TestPERSIST_MODE:
        """PERSIST_MODE枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.PERSIST_MODE.ON_CRASH.value == "ON_CRASH"
            assert const.PERSIST_MODE.REAL_TIME.value == "REAL_TIME"
            assert const.PERSIST_MODE.ON_NORMAL_EXIT.value == "ON_NORMAL_EXIT"
    
    class TestCOMMISSION_TYPE:
        """COMMISSION_TYPE枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.COMMISSION_TYPE.BY_MONEY.value == "BY_MONEY"
            assert const.COMMISSION_TYPE.BY_VOLUME.value == "BY_VOLUME"
    
    class TestEXIT_CODE:
        """EXIT_CODE枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.EXIT_CODE.EXIT_SUCCESS.value == "EXIT_SUCCESS"
            assert const.EXIT_CODE.EXIT_USER_ERROR.value == "EXIT_USER_ERROR"
            assert const.EXIT_CODE.EXIT_INTERNAL_ERROR.value == "EXIT_INTERNAL_ERROR"
    
    class TestHEDGE_TYPE:
        """HEDGE_TYPE枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.HEDGE_TYPE.HEDGE.value == "hedge"
            assert const.HEDGE_TYPE.SPECULATION.value == "speculation"
            assert const.HEDGE_TYPE.ARBITRAGE.value == "arbitrage"
    
    class TestDAYS_CNT:
        """DAYS_CNT常量类测试"""
        
        def test_values(self):
            """测试常量值"""
            assert const.DAYS_CNT.DAYS_A_YEAR == 365
            assert const.DAYS_CNT.TRADING_DAYS_A_YEAR == 252
    
    class TestTRADING_CALENDAR_TYPE:
        """TRADING_CALENDAR_TYPE枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.TRADING_CALENDAR_TYPE.CN_STOCK.value == "CN_STOCK"
            assert const.TRADING_CALENDAR_TYPE.HK_STOCK.value == "HK_STOCK"
            assert const.TRADING_CALENDAR_TYPE.SOUTHBOUND.value == "SOUTHBOUND"
            assert const.TRADING_CALENDAR_TYPE.INTER_BANK.value == "INTERBANK"
    
    class TestMARKET:
        """MARKET枚举测试"""
        
        def test_values(self):
            """测试枚举值"""
            assert const.MARKET.CN.value == "CN"
            assert const.MARKET.HK.value == "HK"
