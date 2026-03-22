"""
RQAlpha Mojo - Constants and Enumerations (Optimized Version)
Ported from rqalpha/const.py
Mojo 0.26+ compatible - Optimized with Variant Registry and Reflection

改进点:
1. 使用 Variant 存储所有枚举列表
2. 使用反射访问字段，无需 name()/value() 方法
3. 每个枚举类只需定义字段和常量
4. 统一在 EnumRegistry 中提供 to_string 方法
"""

from std.reflection import get_base_type_name, struct_field_index_by_name
from std.utils import Variant


# ============================================================
# 枚举类定义 - 只需定义字段和常量
# ============================================================
@fieldwise_init
struct EXECUTION_PHASE(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime GLOBAL = EXECUTION_PHASE("GLOBAL", "[全局]")
    comptime ON_INIT = EXECUTION_PHASE("ON_INIT", "[程序初始化]")
    comptime BEFORE_TRADING = EXECUTION_PHASE("BEFORE_TRADING", "[日内交易前]")
    comptime OPEN_AUCTION = EXECUTION_PHASE("OPEN_AUCTION", "[集合竞价]")
    comptime ON_BAR = EXECUTION_PHASE("ON_BAR", "[盘中 handle_bar 函数]")
    comptime ON_TICK = EXECUTION_PHASE("ON_TICK", "[盘中 handle_tick 函数]")
    comptime AFTER_TRADING = EXECUTION_PHASE("AFTER_TRADING", "[日内交易后]")
    comptime FINALIZED = EXECUTION_PHASE("FINALIZED", "[程序结束]")
    comptime SCHEDULED = EXECUTION_PHASE("SCHEDULED", "[scheduler函数内]")


@fieldwise_init
struct RUN_TYPE(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime BACKTEST = RUN_TYPE("BACKTEST", "BACKTEST")
    comptime PAPER_TRADING = RUN_TYPE("PAPER_TRADING", "PAPER_TRADING")
    comptime LIVE_TRADING = RUN_TYPE("LIVE_TRADING", "LIVE_TRADING")


@fieldwise_init
struct DEFAULT_ACCOUNT_TYPE(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime STOCK = DEFAULT_ACCOUNT_TYPE("STOCK", "STOCK")
    comptime FUTURE = DEFAULT_ACCOUNT_TYPE("FUTURE", "FUTURE")
    comptime BOND = DEFAULT_ACCOUNT_TYPE("BOND", "BOND")


@fieldwise_init
struct MATCHING_TYPE(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime CURRENT_BAR_CLOSE = MATCHING_TYPE("CURRENT_BAR_CLOSE", "CURRENT_BAR_CLOSE")
    comptime VWAP = MATCHING_TYPE("VWAP", "VWAP")
    comptime COUNTERPARTY_OFFER = MATCHING_TYPE("COUNTERPARTY_OFFER", "COUNTERPARTY_OFFER")
    comptime NEXT_BAR_OPEN = MATCHING_TYPE("NEXT_BAR_OPEN", "NEXT_BAR_OPEN")
    comptime NEXT_TICK_LAST = MATCHING_TYPE("NEXT_TICK_LAST", "NEXT_TICK_LAST")
    comptime NEXT_TICK_BEST_OWN = MATCHING_TYPE("NEXT_TICK_BEST_OWN", "NEXT_TICK_BEST_OWN")
    comptime NEXT_TICK_BEST_COUNTERPARTY = MATCHING_TYPE("NEXT_TICK_BEST_COUNTERPARTY", "NEXT_TICK_BEST_COUNTERPARTY")


@fieldwise_init
struct ORDER_TYPE(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime MARKET = ORDER_TYPE("MARKET", "MARKET")
    comptime LIMIT = ORDER_TYPE("LIMIT", "LIMIT")
    comptime ALGO = ORDER_TYPE("ALGO", "ALGO")


@fieldwise_init
struct ALGO(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime TWAP = ALGO("TWAP", "TWAP")
    comptime VWAP = ALGO("VWAP", "VWAP")


@fieldwise_init
struct ORDER_STATUS(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime PENDING_NEW = ORDER_STATUS("PENDING_NEW", "PENDING_NEW")
    comptime ACTIVE = ORDER_STATUS("ACTIVE", "ACTIVE")
    comptime FILLED = ORDER_STATUS("FILLED", "FILLED")
    comptime REJECTED = ORDER_STATUS("REJECTED", "REJECTED")
    comptime PENDING_CANCEL = ORDER_STATUS("PENDING_CANCEL", "PENDING_CANCEL")
    comptime CANCELLED = ORDER_STATUS("CANCELLED", "CANCELLED")


@fieldwise_init
struct SIDE(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime BUY = SIDE("BUY", "BUY")
    comptime SELL = SIDE("SELL", "SELL")
    comptime FINANCING = SIDE("FINANCING", "FINANCING")
    comptime MARGIN = SIDE("MARGIN", "MARGIN")
    comptime CONVERT_STOCK = SIDE("CONVERT_STOCK", "CONVERT_STOCK")


@fieldwise_init
struct POSITION_EFFECT(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime OPEN = POSITION_EFFECT("OPEN", "OPEN")
    comptime CLOSE = POSITION_EFFECT("CLOSE", "CLOSE")
    comptime CLOSE_TODAY = POSITION_EFFECT("CLOSE_TODAY", "CLOSE_TODAY")
    comptime EXERCISE = POSITION_EFFECT("EXERCISE", "EXERCISE")
    comptime MATCH = POSITION_EFFECT("MATCH", "MATCH")


@fieldwise_init
struct POSITION_DIRECTION(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime LONG = POSITION_DIRECTION("LONG", "LONG")
    comptime SHORT = POSITION_DIRECTION("SHORT", "SHORT")


@fieldwise_init
struct EXC_TYPE(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime USER_EXC = EXC_TYPE("USER_EXC", "USER_EXC")
    comptime SYSTEM_EXC = EXC_TYPE("SYSTEM_EXC", "SYSTEM_EXC")
    comptime NOTSET = EXC_TYPE("NOTSET", "NOTSET")


@fieldwise_init
struct INSTRUMENT_TYPE(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime CS = INSTRUMENT_TYPE("CS", "CS")
    comptime FUTURE = INSTRUMENT_TYPE("FUTURE", "Future")
    comptime OPTION = INSTRUMENT_TYPE("OPTION", "Option")
    comptime ETF = INSTRUMENT_TYPE("ETF", "ETF")
    comptime LOF = INSTRUMENT_TYPE("LOF", "LOF")
    comptime INDX = INSTRUMENT_TYPE("INDX", "INDX")
    comptime PUBLIC_FUND = INSTRUMENT_TYPE("PUBLIC_FUND", "PublicFund")
    comptime FUND = INSTRUMENT_TYPE("FUND", "Fund")
    comptime BOND = INSTRUMENT_TYPE("BOND", "Bond")
    comptime CONVERTIBLE = INSTRUMENT_TYPE("CONVERTIBLE", "Convertible")
    comptime SPOT = INSTRUMENT_TYPE("SPOT", "Spot")
    comptime REPO = INSTRUMENT_TYPE("REPO", "Repo")
    comptime REITs = INSTRUMENT_TYPE("REITs", "REITs")
    comptime FutureArbitrage = INSTRUMENT_TYPE("FutureArbitrage", "FutureArbitrage")


@fieldwise_init
struct PERSIST_MODE(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime ON_CRASH = PERSIST_MODE("ON_CRASH", "ON_CRASH")
    comptime REAL_TIME = PERSIST_MODE("REAL_TIME", "REAL_TIME")
    comptime ON_NORMAL_EXIT = PERSIST_MODE("ON_NORMAL_EXIT", "ON_NORMAL_EXIT")


@fieldwise_init
struct COMMISSION_TYPE(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime BY_MONEY = COMMISSION_TYPE("BY_MONEY", "BY_MONEY")
    comptime BY_VOLUME = COMMISSION_TYPE("BY_VOLUME", "BY_VOLUME")


@fieldwise_init
struct EXIT_CODE(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime EXIT_SUCCESS = EXIT_CODE("EXIT_SUCCESS", "EXIT_SUCCESS")
    comptime EXIT_USER_ERROR = EXIT_CODE("EXIT_USER_ERROR", "EXIT_USER_ERROR")
    comptime EXIT_INTERNAL_ERROR = EXIT_CODE("EXIT_INTERNAL_ERROR", "EXIT_INTERNAL_ERROR")


@fieldwise_init
struct HEDGE_TYPE(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime HEDGE = HEDGE_TYPE("HEDGE", "hedge")
    comptime SPECULATION = HEDGE_TYPE("SPECULATION", "speculation")
    comptime ARBITRAGE = HEDGE_TYPE("ARBITRAGE", "arbitrage")


struct DAYS_CNT:
    comptime DAYS_A_YEAR: Int = 365
    comptime TRADING_DAYS_A_YEAR: Int = 252


@fieldwise_init
struct EXCHANGE(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime XSHE = EXCHANGE("XSHE", "XSHE")
    comptime XSHG = EXCHANGE("XSHG", "XSHG")
    comptime SHFE = EXCHANGE("SHFE", "SHFE")
    comptime INE = EXCHANGE("INE", "INE")
    comptime DCE = EXCHANGE("DCE", "DCE")
    comptime CZCE = EXCHANGE("CZCE", "CZCE")
    comptime CFFEX = EXCHANGE("CFFEX", "CFFEX")
    comptime SGEX = EXCHANGE("SGEX", "SGEX")
    comptime BJSE = EXCHANGE("BJSE", "BJSE")


@fieldwise_init
struct TRADING_CALENDAR_TYPE(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime CN_STOCK = TRADING_CALENDAR_TYPE("CN_STOCK", "CN_STOCK")
    comptime HK_STOCK = TRADING_CALENDAR_TYPE("HK_STOCK", "HK_STOCK")
    comptime SOUTHBOUND = TRADING_CALENDAR_TYPE("SOUTHBOUND", "SOUTHBOUND")
    comptime INTER_BANK = TRADING_CALENDAR_TYPE("INTER_BANK", "INTERBANK")
    comptime EXCHANGE = TRADING_CALENDAR_TYPE("CN_STOCK", "CN_STOCK")


@fieldwise_init
struct MARKET(Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String

    comptime CN = MARKET("CN", "CN")
    comptime HK = MARKET("HK", "HK")


# ============================================================
# Variant 类型定义 - 包含所有枚举类型的列表
# ============================================================
comptime EnumListVariant = Variant[
    List[EXECUTION_PHASE],
    List[RUN_TYPE],
    List[DEFAULT_ACCOUNT_TYPE],
    List[MATCHING_TYPE],
    List[ORDER_TYPE],
    List[ALGO],
    List[ORDER_STATUS],
    List[SIDE],
    List[POSITION_EFFECT],
    List[POSITION_DIRECTION],
    List[EXC_TYPE],
    List[INSTRUMENT_TYPE],
    List[PERSIST_MODE],
    List[COMMISSION_TYPE],
    List[EXIT_CODE],
    List[HEDGE_TYPE],
    List[EXCHANGE],
    List[TRADING_CALENDAR_TYPE],
    List[MARKET],
]


# ============================================================
# EnumRegistry - 枚举注册表
# ============================================================
struct EnumRegistry:
    var registry: Dict[String, EnumListVariant]
    
    def __init__(out self):
        self.registry = {
            "EXECUTION_PHASE": EnumListVariant([
                EXECUTION_PHASE.GLOBAL, EXECUTION_PHASE.ON_INIT, EXECUTION_PHASE.BEFORE_TRADING,
                EXECUTION_PHASE.OPEN_AUCTION, EXECUTION_PHASE.ON_BAR, EXECUTION_PHASE.ON_TICK,
                EXECUTION_PHASE.AFTER_TRADING, EXECUTION_PHASE.FINALIZED, EXECUTION_PHASE.SCHEDULED
            ]),
            "RUN_TYPE": EnumListVariant([RUN_TYPE.BACKTEST, RUN_TYPE.PAPER_TRADING, RUN_TYPE.LIVE_TRADING]),
            "DEFAULT_ACCOUNT_TYPE": EnumListVariant([DEFAULT_ACCOUNT_TYPE.STOCK, DEFAULT_ACCOUNT_TYPE.FUTURE, DEFAULT_ACCOUNT_TYPE.BOND]),
            "MATCHING_TYPE": EnumListVariant([
                MATCHING_TYPE.CURRENT_BAR_CLOSE, MATCHING_TYPE.VWAP, MATCHING_TYPE.COUNTERPARTY_OFFER,
                MATCHING_TYPE.NEXT_BAR_OPEN, MATCHING_TYPE.NEXT_TICK_LAST, MATCHING_TYPE.NEXT_TICK_BEST_OWN,
                MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY
            ]),
            "ORDER_TYPE": EnumListVariant([ORDER_TYPE.MARKET, ORDER_TYPE.LIMIT, ORDER_TYPE.ALGO]),
            "ALGO": EnumListVariant([ALGO.TWAP, ALGO.VWAP]),
            "ORDER_STATUS": EnumListVariant([
                ORDER_STATUS.PENDING_NEW, ORDER_STATUS.ACTIVE, ORDER_STATUS.FILLED,
                ORDER_STATUS.REJECTED, ORDER_STATUS.PENDING_CANCEL, ORDER_STATUS.CANCELLED
            ]),
            "SIDE": EnumListVariant([SIDE.BUY, SIDE.SELL, SIDE.FINANCING, SIDE.MARGIN, SIDE.CONVERT_STOCK]),
            "POSITION_EFFECT": EnumListVariant([
                POSITION_EFFECT.OPEN, POSITION_EFFECT.CLOSE, POSITION_EFFECT.CLOSE_TODAY,
                POSITION_EFFECT.EXERCISE, POSITION_EFFECT.MATCH
            ]),
            "POSITION_DIRECTION": EnumListVariant([POSITION_DIRECTION.LONG, POSITION_DIRECTION.SHORT]),
            "EXC_TYPE": EnumListVariant([EXC_TYPE.USER_EXC, EXC_TYPE.SYSTEM_EXC, EXC_TYPE.NOTSET]),
            "INSTRUMENT_TYPE": EnumListVariant([
                INSTRUMENT_TYPE.CS, INSTRUMENT_TYPE.FUTURE, INSTRUMENT_TYPE.OPTION, INSTRUMENT_TYPE.ETF,
                INSTRUMENT_TYPE.LOF, INSTRUMENT_TYPE.INDX, INSTRUMENT_TYPE.PUBLIC_FUND, INSTRUMENT_TYPE.FUND,
                INSTRUMENT_TYPE.BOND, INSTRUMENT_TYPE.CONVERTIBLE, INSTRUMENT_TYPE.SPOT, INSTRUMENT_TYPE.REPO,
                INSTRUMENT_TYPE.REITs, INSTRUMENT_TYPE.FutureArbitrage
            ]),
            "PERSIST_MODE": EnumListVariant([PERSIST_MODE.ON_CRASH, PERSIST_MODE.REAL_TIME, PERSIST_MODE.ON_NORMAL_EXIT]),
            "COMMISSION_TYPE": EnumListVariant([COMMISSION_TYPE.BY_MONEY, COMMISSION_TYPE.BY_VOLUME]),
            "EXIT_CODE": EnumListVariant([EXIT_CODE.EXIT_SUCCESS, EXIT_CODE.EXIT_USER_ERROR, EXIT_CODE.EXIT_INTERNAL_ERROR]),
            "HEDGE_TYPE": EnumListVariant([HEDGE_TYPE.HEDGE, HEDGE_TYPE.SPECULATION, HEDGE_TYPE.ARBITRAGE]),
            "EXCHANGE": EnumListVariant([
                EXCHANGE.XSHE, EXCHANGE.XSHG, EXCHANGE.SHFE, EXCHANGE.INE, EXCHANGE.DCE,
                EXCHANGE.CZCE, EXCHANGE.CFFEX, EXCHANGE.SGEX, EXCHANGE.BJSE
            ]),
            "TRADING_CALENDAR_TYPE": EnumListVariant([
                TRADING_CALENDAR_TYPE.CN_STOCK, TRADING_CALENDAR_TYPE.HK_STOCK,
                TRADING_CALENDAR_TYPE.SOUTHBOUND, TRADING_CALENDAR_TYPE.INTER_BANK, TRADING_CALENDAR_TYPE.EXCHANGE
            ]),
            "MARKET": EnumListVariant([MARKET.CN, MARKET.HK]),
        }
    
    def get[T: Movable & Copyable](self, name: String) raises -> Optional[T]:
        comptime type_name = get_base_type_name[T]()
        comptime name_idx = struct_field_index_by_name[T, "name"]()
        
        var val = self.registry[type_name]
        for v in val[List[T]]:
            ref field_ref = __struct_field_ref(name_idx, v)
            var field_val = rebind[String](field_ref)
            if field_val == name:
                return v.copy()
        
        return None
    
    def get_by_value[T: Movable & Copyable](self, value: String) raises -> Optional[T]:
        comptime type_name = get_base_type_name[T]()
        comptime value_idx = struct_field_index_by_name[T, "value"]()
        
        var val = self.registry[type_name]
        for v in val[List[T]]:
            ref field_ref = __struct_field_ref(value_idx, v)
            var field_val = rebind[String](field_ref)
            if field_val == value:
                return v.copy()
        
        return None
    
    def to_string[T: Movable](self, obj: T) raises -> String:
        comptime type_name = get_base_type_name[T]()
        comptime name_idx = struct_field_index_by_name[T, "name"]()
        ref name_ref = __struct_field_ref(name_idx, obj)
        var name_val = rebind[String](name_ref)
        return String(type_name, ".", name_val)
