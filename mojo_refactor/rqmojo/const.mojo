"""
RQAlpha Mojo - Constants and Enumerations
Ported from rqalpha/const.py
Mojo 0.26+ compatible - Phantom type pattern (Option B)

Usage:
  from rqmojo.const import SIDE, SIDE_BUY, SIDE_SELL
  var s: SIDE = SIDE_BUY    # type-safe annotation
  print(s == SIDE_BUY)      # True
"""


from std.reflection import get_type_name


# ============================================================
# Base enum struct with phantom type parameter for type safety
# ============================================================
@fieldwise_init
struct EnumValue[Tag: AnyType](Equatable, ImplicitlyCopyable, Writable, Hashable):
    """Phantom-type enum value. Different Tag = different type."""
    var name: String
    var value: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)

    def hash(self) -> UInt:
        return UInt(hash(self.value))


# ============================================================
# Tag structs (one per enum type — enables type differentiation)
# ============================================================
struct _ExecutionPhaseTag: pass
struct _RunTypeTag: pass
struct _DefaultAccountTypeTag: pass
struct _MatchingTypeTag: pass
struct _OrderTypeTag: pass
struct _AlgoTag: pass
struct _OrderStatusTag: pass
struct _SideTag: pass
struct _PositionEffectTag: pass
struct _PositionDirectionTag: pass
struct _ExcTypeTag: pass
struct _InstrumentTypeTag: pass
struct _PersistModeTag: pass
struct _CommissionTypeTag: pass
struct _ExitCodeTag: pass
struct _HedgeTypeTag: pass
struct _DaysCntTag: pass
struct _ExchangeTag: pass
struct _TradingCalendarTypeTag: pass
struct _MarketTag: pass


# ============================================================
# Type aliases (for type annotations: var x: SIDE = SIDE_BUY)
# ============================================================
comptime EXECUTION_PHASE = EnumValue[_ExecutionPhaseTag]
comptime RUN_TYPE = EnumValue[_RunTypeTag]
comptime DEFAULT_ACCOUNT_TYPE = EnumValue[_DefaultAccountTypeTag]
comptime MATCHING_TYPE = EnumValue[_MatchingTypeTag]
comptime ORDER_TYPE = EnumValue[_OrderTypeTag]
comptime ALGO = EnumValue[_AlgoTag]
comptime ORDER_STATUS = EnumValue[_OrderStatusTag]
comptime SIDE = EnumValue[_SideTag]
comptime POSITION_EFFECT = EnumValue[_PositionEffectTag]
comptime POSITION_DIRECTION = EnumValue[_PositionDirectionTag]
comptime EXC_TYPE = EnumValue[_ExcTypeTag]
comptime INSTRUMENT_TYPE = EnumValue[_InstrumentTypeTag]
comptime PERSIST_MODE = EnumValue[_PersistModeTag]
comptime COMMISSION_TYPE = EnumValue[_CommissionTypeTag]
comptime EXIT_CODE = EnumValue[_ExitCodeTag]
comptime HEDGE_TYPE = EnumValue[_HedgeTypeTag]
comptime EXCHANGE = EnumValue[_ExchangeTag]
comptime TRADING_CALENDAR_TYPE = EnumValue[_TradingCalendarTypeTag]
comptime MARKET = EnumValue[_MarketTag]


# ============================================================
# EXECUTION_PHASE members
# ============================================================
comptime EXECUTION_PHASE_GLOBAL = EXECUTION_PHASE("GLOBAL", "[全局]")
comptime EXECUTION_PHASE_ON_INIT = EXECUTION_PHASE("ON_INIT", "[程序初始化]")
comptime EXECUTION_PHASE_BEFORE_TRADING = EXECUTION_PHASE("BEFORE_TRADING", "[日内交易前]")
comptime EXECUTION_PHASE_OPEN_AUCTION = EXECUTION_PHASE("OPEN_AUCTION", "[集合竞价]")
comptime EXECUTION_PHASE_ON_BAR = EXECUTION_PHASE("ON_BAR", "[盘中 handle_bar 函数]")
comptime EXECUTION_PHASE_ON_TICK = EXECUTION_PHASE("ON_TICK", "[盘中 handle_tick 函数]")
comptime EXECUTION_PHASE_AFTER_TRADING = EXECUTION_PHASE("AFTER_TRADING", "[日内交易后]")
comptime EXECUTION_PHASE_FINALIZED = EXECUTION_PHASE("FINALIZED", "[程序结束]")
comptime EXECUTION_PHASE_SCHEDULED = EXECUTION_PHASE("SCHEDULED", "[scheduler函数内]")


# ============================================================
# RUN_TYPE members
# ============================================================
# TODO: 取消 RUN_TYPE, 取而代之的是使用开启哪些Mod来控制策略所运行的类型
comptime RUN_TYPE_BACKTEST = RUN_TYPE("BACKTEST", "BACKTEST")
comptime RUN_TYPE_PAPER_TRADING = RUN_TYPE("PAPER_TRADING", "PAPER_TRADING")
comptime RUN_TYPE_LIVE_TRADING = RUN_TYPE("LIVE_TRADING", "LIVE_TRADING")


# ============================================================
# DEFAULT_ACCOUNT_TYPE members
# ============================================================
comptime DEFAULT_ACCOUNT_TYPE_STOCK = DEFAULT_ACCOUNT_TYPE("STOCK", "STOCK")
comptime DEFAULT_ACCOUNT_TYPE_FUTURE = DEFAULT_ACCOUNT_TYPE("FUTURE", "FUTURE")
comptime DEFAULT_ACCOUNT_TYPE_BOND = DEFAULT_ACCOUNT_TYPE("BOND", "BOND")


# ============================================================
# MATCHING_TYPE members
# ============================================================
comptime MATCHING_TYPE_CURRENT_BAR_CLOSE = MATCHING_TYPE("CURRENT_BAR_CLOSE", "CURRENT_BAR_CLOSE")
comptime MATCHING_TYPE_VWAP = MATCHING_TYPE("VWAP", "VWAP")
comptime MATCHING_TYPE_COUNTERPARTY_OFFER = MATCHING_TYPE("COUNTERPARTY_OFFER", "COUNTERPARTY_OFFER")
comptime MATCHING_TYPE_NEXT_BAR_OPEN = MATCHING_TYPE("NEXT_BAR_OPEN", "NEXT_BAR_OPEN")
comptime MATCHING_TYPE_NEXT_TICK_LAST = MATCHING_TYPE("NEXT_TICK_LAST", "NEXT_TICK_LAST")
comptime MATCHING_TYPE_NEXT_TICK_BEST_OWN = MATCHING_TYPE("NEXT_TICK_BEST_OWN", "NEXT_TICK_BEST_OWN")
comptime MATCHING_TYPE_NEXT_TICK_BEST_COUNTERPARTY = MATCHING_TYPE("NEXT_TICK_BEST_COUNTERPARTY", "NEXT_TICK_BEST_COUNTERPARTY")


# ============================================================
# ORDER_TYPE members
# ============================================================
comptime ORDER_TYPE_MARKET = ORDER_TYPE("MARKET", "MARKET")
comptime ORDER_TYPE_LIMIT = ORDER_TYPE("LIMIT", "LIMIT")
comptime ORDER_TYPE_ALGO = ORDER_TYPE("ALGO", "ALGO")


# ============================================================
# ALGO members
# ============================================================
comptime ALGO_TWAP = ALGO("TWAP", "TWAP")
comptime ALGO_VWAP = ALGO("VWAP", "VWAP")


# ============================================================
# ORDER_STATUS members
# ============================================================
comptime ORDER_STATUS_PENDING_NEW = ORDER_STATUS("PENDING_NEW", "PENDING_NEW")
comptime ORDER_STATUS_ACTIVE = ORDER_STATUS("ACTIVE", "ACTIVE")
comptime ORDER_STATUS_FILLED = ORDER_STATUS("FILLED", "FILLED")
comptime ORDER_STATUS_REJECTED = ORDER_STATUS("REJECTED", "REJECTED")
comptime ORDER_STATUS_PENDING_CANCEL = ORDER_STATUS("PENDING_CANCEL", "PENDING_CANCEL")
comptime ORDER_STATUS_CANCELLED = ORDER_STATUS("CANCELLED", "CANCELLED")


# ============================================================
# SIDE members
# ============================================================
comptime SIDE_BUY = SIDE("BUY", "BUY")
comptime SIDE_SELL = SIDE("SELL", "SELL")
comptime SIDE_FINANCING = SIDE("FINANCING", "FINANCING")
comptime SIDE_MARGIN = SIDE("MARGIN", "MARGIN")
comptime SIDE_CONVERT_STOCK = SIDE("CONVERT_STOCK", "CONVERT_STOCK")


# ============================================================
# POSITION_EFFECT members
# ============================================================
comptime POSITION_EFFECT_OPEN = POSITION_EFFECT("OPEN", "OPEN")
comptime POSITION_EFFECT_CLOSE = POSITION_EFFECT("CLOSE", "CLOSE")
comptime POSITION_EFFECT_CLOSE_TODAY = POSITION_EFFECT("CLOSE_TODAY", "CLOSE_TODAY")
comptime POSITION_EFFECT_EXERCISE = POSITION_EFFECT("EXERCISE", "EXERCISE")
comptime POSITION_EFFECT_MATCH = POSITION_EFFECT("MATCH", "MATCH")


# ============================================================
# POSITION_DIRECTION members
# ============================================================
comptime POSITION_DIRECTION_LONG = POSITION_DIRECTION("LONG", "LONG")
comptime POSITION_DIRECTION_SHORT = POSITION_DIRECTION("SHORT", "SHORT")


# ============================================================
# EXC_TYPE members
# ============================================================
comptime EXC_TYPE_USER_EXC = EXC_TYPE("USER_EXC", "USER_EXC")
comptime EXC_TYPE_SYSTEM_EXC = EXC_TYPE("SYSTEM_EXC", "SYSTEM_EXC")
comptime EXC_TYPE_NOTSET = EXC_TYPE("NOTSET", "NOTSET")


# ============================================================
# INSTRUMENT_TYPE members
# ============================================================
comptime INSTRUMENT_TYPE_CS = INSTRUMENT_TYPE("CS", "CS")
comptime INSTRUMENT_TYPE_FUTURE = INSTRUMENT_TYPE("FUTURE", "Future")
comptime INSTRUMENT_TYPE_OPTION = INSTRUMENT_TYPE("OPTION", "Option")
comptime INSTRUMENT_TYPE_ETF = INSTRUMENT_TYPE("ETF", "ETF")
comptime INSTRUMENT_TYPE_LOF = INSTRUMENT_TYPE("LOF", "LOF")
comptime INSTRUMENT_TYPE_INDX = INSTRUMENT_TYPE("INDX", "INDX")
comptime INSTRUMENT_TYPE_PUBLIC_FUND = INSTRUMENT_TYPE("PUBLIC_FUND", "PublicFund")
comptime INSTRUMENT_TYPE_FUND = INSTRUMENT_TYPE("FUND", "Fund")
comptime INSTRUMENT_TYPE_BOND = INSTRUMENT_TYPE("BOND", "Bond")
comptime INSTRUMENT_TYPE_CONVERTIBLE = INSTRUMENT_TYPE("CONVERTIBLE", "Convertible")
comptime INSTRUMENT_TYPE_SPOT = INSTRUMENT_TYPE("SPOT", "Spot")
comptime INSTRUMENT_TYPE_REPO = INSTRUMENT_TYPE("REPO", "Repo")
comptime INSTRUMENT_TYPE_REITS = INSTRUMENT_TYPE("REITs", "REITs")
comptime INSTRUMENT_TYPE_FUTURE_ARBITRAGE = INSTRUMENT_TYPE("FutureArbitrage", "FutureArbitrage")


# ============================================================
# PERSIST_MODE members
# ============================================================
comptime PERSIST_MODE_ON_CRASH = PERSIST_MODE("ON_CRASH", "ON_CRASH")
comptime PERSIST_MODE_REAL_TIME = PERSIST_MODE("REAL_TIME", "REAL_TIME")
comptime PERSIST_MODE_ON_NORMAL_EXIT = PERSIST_MODE("ON_NORMAL_EXIT", "ON_NORMAL_EXIT")


# ============================================================
# COMMISSION_TYPE members
# ============================================================
comptime COMMISSION_TYPE_BY_MONEY = COMMISSION_TYPE("BY_MONEY", "BY_MONEY")
comptime COMMISSION_TYPE_BY_VOLUME = COMMISSION_TYPE("BY_VOLUME", "BY_VOLUME")


# ============================================================
# EXIT_CODE members
# ============================================================
comptime EXIT_CODE_SUCCESS = EXIT_CODE("EXIT_SUCCESS", "EXIT_SUCCESS")
comptime EXIT_CODE_USER_ERROR = EXIT_CODE("EXIT_USER_ERROR", "EXIT_USER_ERROR")
comptime EXIT_CODE_INTERNAL_ERROR = EXIT_CODE("EXIT_INTERNAL_ERROR", "EXIT_INTERNAL_ERROR")


# ============================================================
# HEDGE_TYPE members
# ============================================================
comptime HEDGE_TYPE_HEDGE = HEDGE_TYPE("HEDGE", "hedge")
comptime HEDGE_TYPE_SPECULATION = HEDGE_TYPE("SPECULATION", "speculation")
comptime HEDGE_TYPE_ARBITRAGE = HEDGE_TYPE("ARBITRAGE", "arbitrage")


# ============================================================
# DAYS_CNT (constant class, not an enum)
# ============================================================
struct DAYS_CNT:
    comptime DAYS_A_YEAR: Int = 365
    comptime TRADING_DAYS_A_YEAR: Int = 252


# ============================================================
# EXCHANGE members
# ============================================================
comptime EXCHANGE_XSHE = EXCHANGE("XSHE", "XSHE")
comptime EXCHANGE_XSHG = EXCHANGE("XSHG", "XSHG")
comptime EXCHANGE_SHFE = EXCHANGE("SHFE", "SHFE")
comptime EXCHANGE_INE = EXCHANGE("INE", "INE")
comptime EXCHANGE_DCE = EXCHANGE("DCE", "DCE")
comptime EXCHANGE_CZCE = EXCHANGE("CZCE", "CZCE")
comptime EXCHANGE_CFFEX = EXCHANGE("CFFEX", "CFFEX")
comptime EXCHANGE_SGEX = EXCHANGE("SGEX", "SGEX")
comptime EXCHANGE_BJSE = EXCHANGE("BJSE", "BJSE")


# ============================================================
# TRADING_CALENDAR_TYPE members
# ============================================================
comptime TRADING_CALENDAR_TYPE_CN_STOCK = TRADING_CALENDAR_TYPE("CN_STOCK", "CN_STOCK")
comptime TRADING_CALENDAR_TYPE_HK_STOCK = TRADING_CALENDAR_TYPE("HK_STOCK", "HK_STOCK")
comptime TRADING_CALENDAR_TYPE_SOUTHBOUND = TRADING_CALENDAR_TYPE("SOUTHBOUND", "SOUTHBOUND")
comptime TRADING_CALENDAR_TYPE_INTER_BANK = TRADING_CALENDAR_TYPE("INTER_BANK", "INTERBANK")

# backward compatible
comptime TRADING_CALENDAR_TYPE_EXCHANGE = TRADING_CALENDAR_TYPE("CN_STOCK", "CN_STOCK")


# ============================================================
# MARKET members
# ============================================================
comptime MARKET_CN = MARKET("CN", "CN")
comptime MARKET_HK = MARKET("HK", "HK")
