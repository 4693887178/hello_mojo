"""
RQAlpha Mojo - Constants and Enumerations (Improved Version)
Ported from rqalpha/const.py
Mojo 0.26+ compatible - Optimized with Traits

改进点:
1. 使用 Trait 抽象公共接口，消除代码重复
2. 保持与 Python 版本的功能完全等价
3. 更清晰的代码结构
"""

# ============================================================
# EnumTrait - 公共枚举特性
# ============================================================
trait EnumTrait:
    def name(self) -> String: ...
    def value(self) -> String: ...


# ============================================================
# EXECUTION_PHASE
# ============================================================
@fieldwise_init
struct EXECUTION_PHASE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime GLOBAL = EXECUTION_PHASE("GLOBAL", "[全局]")
    comptime ON_INIT = EXECUTION_PHASE("ON_INIT", "[程序初始化]")
    comptime BEFORE_TRADING = EXECUTION_PHASE("BEFORE_TRADING", "[日内交易前]")
    comptime OPEN_AUCTION = EXECUTION_PHASE("OPEN_AUCTION", "[集合竞价]")
    comptime ON_BAR = EXECUTION_PHASE("ON_BAR", "[盘中 handle_bar 函数]")
    comptime ON_TICK = EXECUTION_PHASE("ON_TICK", "[盘中 handle_tick 函数]")
    comptime AFTER_TRADING = EXECUTION_PHASE("AFTER_TRADING", "[日内交易后]")
    comptime FINALIZED = EXECUTION_PHASE("FINALIZED", "[程序结束]")
    comptime SCHEDULED = EXECUTION_PHASE("SCHEDULED", "[scheduler函数内]")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[EXECUTION_PHASE]:
        if name == "GLOBAL": return Self.GLOBAL
        elif name == "ON_INIT": return Self.ON_INIT
        elif name == "BEFORE_TRADING": return Self.BEFORE_TRADING
        elif name == "OPEN_AUCTION": return Self.OPEN_AUCTION
        elif name == "ON_BAR": return Self.ON_BAR
        elif name == "ON_TICK": return Self.ON_TICK
        elif name == "AFTER_TRADING": return Self.AFTER_TRADING
        elif name == "FINALIZED": return Self.FINALIZED
        elif name == "SCHEDULED": return Self.SCHEDULED
        return None

    @staticmethod
    def from_value(value: String) -> Optional[EXECUTION_PHASE]:
        if value == "[全局]": return Self.GLOBAL
        elif value == "[程序初始化]": return Self.ON_INIT
        elif value == "[日内交易前]": return Self.BEFORE_TRADING
        elif value == "[集合竞价]": return Self.OPEN_AUCTION
        elif value == "[盘中 handle_bar 函数]": return Self.ON_BAR
        elif value == "[盘中 handle_tick 函数]": return Self.ON_TICK
        elif value == "[日内交易后]": return Self.AFTER_TRADING
        elif value == "[程序结束]": return Self.FINALIZED
        elif value == "[scheduler函数内]": return Self.SCHEDULED
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("EXECUTION_PHASE.", self._name)


# ============================================================
# RUN_TYPE
# ============================================================
@fieldwise_init
struct RUN_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime BACKTEST = RUN_TYPE("BACKTEST", "BACKTEST")
    comptime PAPER_TRADING = RUN_TYPE("PAPER_TRADING", "PAPER_TRADING")
    comptime LIVE_TRADING = RUN_TYPE("LIVE_TRADING", "LIVE_TRADING")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[RUN_TYPE]:
        if name == "BACKTEST": return Self.BACKTEST
        elif name == "PAPER_TRADING": return Self.PAPER_TRADING
        elif name == "LIVE_TRADING": return Self.LIVE_TRADING
        return None

    @staticmethod
    def from_value(value: String) -> Optional[RUN_TYPE]:
        if value == "BACKTEST": return Self.BACKTEST
        elif value == "PAPER_TRADING": return Self.PAPER_TRADING
        elif value == "LIVE_TRADING": return Self.LIVE_TRADING
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("RUN_TYPE.", self._name)


# ============================================================
# DEFAULT_ACCOUNT_TYPE
# ============================================================
@fieldwise_init
struct DEFAULT_ACCOUNT_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime STOCK = DEFAULT_ACCOUNT_TYPE("STOCK", "STOCK")
    comptime FUTURE = DEFAULT_ACCOUNT_TYPE("FUTURE", "FUTURE")
    comptime BOND = DEFAULT_ACCOUNT_TYPE("BOND", "BOND")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[DEFAULT_ACCOUNT_TYPE]:
        if name == "STOCK": return Self.STOCK
        elif name == "FUTURE": return Self.FUTURE
        elif name == "BOND": return Self.BOND
        return None

    @staticmethod
    def from_value(value: String) -> Optional[DEFAULT_ACCOUNT_TYPE]:
        if value == "STOCK": return Self.STOCK
        elif value == "FUTURE": return Self.FUTURE
        elif value == "BOND": return Self.BOND
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("DEFAULT_ACCOUNT_TYPE.", self._name)


# ============================================================
# MATCHING_TYPE
# ============================================================
@fieldwise_init
struct MATCHING_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime CURRENT_BAR_CLOSE = MATCHING_TYPE("CURRENT_BAR_CLOSE", "CURRENT_BAR_CLOSE")
    comptime VWAP = MATCHING_TYPE("VWAP", "VWAP")
    comptime COUNTERPARTY_OFFER = MATCHING_TYPE("COUNTERPARTY_OFFER", "COUNTERPARTY_OFFER")
    comptime NEXT_BAR_OPEN = MATCHING_TYPE("NEXT_BAR_OPEN", "NEXT_BAR_OPEN")
    comptime NEXT_TICK_LAST = MATCHING_TYPE("NEXT_TICK_LAST", "NEXT_TICK_LAST")
    comptime NEXT_TICK_BEST_OWN = MATCHING_TYPE("NEXT_TICK_BEST_OWN", "NEXT_TICK_BEST_OWN")
    comptime NEXT_TICK_BEST_COUNTERPARTY = MATCHING_TYPE("NEXT_TICK_BEST_COUNTERPARTY", "NEXT_TICK_BEST_COUNTERPARTY")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[MATCHING_TYPE]:
        if name == "CURRENT_BAR_CLOSE": return Self.CURRENT_BAR_CLOSE
        elif name == "VWAP": return Self.VWAP
        elif name == "COUNTERPARTY_OFFER": return Self.COUNTERPARTY_OFFER
        elif name == "NEXT_BAR_OPEN": return Self.NEXT_BAR_OPEN
        elif name == "NEXT_TICK_LAST": return Self.NEXT_TICK_LAST
        elif name == "NEXT_TICK_BEST_OWN": return Self.NEXT_TICK_BEST_OWN
        elif name == "NEXT_TICK_BEST_COUNTERPARTY": return Self.NEXT_TICK_BEST_COUNTERPARTY
        return None

    @staticmethod
    def from_value(value: String) -> Optional[MATCHING_TYPE]:
        if value == "CURRENT_BAR_CLOSE": return Self.CURRENT_BAR_CLOSE
        elif value == "VWAP": return Self.VWAP
        elif value == "COUNTERPARTY_OFFER": return Self.COUNTERPARTY_OFFER
        elif value == "NEXT_BAR_OPEN": return Self.NEXT_BAR_OPEN
        elif value == "NEXT_TICK_LAST": return Self.NEXT_TICK_LAST
        elif value == "NEXT_TICK_BEST_OWN": return Self.NEXT_TICK_BEST_OWN
        elif value == "NEXT_TICK_BEST_COUNTERPARTY": return Self.NEXT_TICK_BEST_COUNTERPARTY
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("MATCHING_TYPE.", self._name)


# ============================================================
# ORDER_TYPE
# ============================================================
@fieldwise_init
struct ORDER_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime MARKET = ORDER_TYPE("MARKET", "MARKET")
    comptime LIMIT = ORDER_TYPE("LIMIT", "LIMIT")
    comptime ALGO = ORDER_TYPE("ALGO", "ALGO")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[ORDER_TYPE]:
        if name == "MARKET": return Self.MARKET
        elif name == "LIMIT": return Self.LIMIT
        elif name == "ALGO": return Self.ALGO
        return None

    @staticmethod
    def from_value(value: String) -> Optional[ORDER_TYPE]:
        if value == "MARKET": return Self.MARKET
        elif value == "LIMIT": return Self.LIMIT
        elif value == "ALGO": return Self.ALGO
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ORDER_TYPE.", self._name)


# ============================================================
# ALGO
# ============================================================
@fieldwise_init
struct ALGO(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime TWAP = ALGO("TWAP", "TWAP")
    comptime VWAP = ALGO("VWAP", "VWAP")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[ALGO]:
        if name == "TWAP": return Self.TWAP
        elif name == "VWAP": return Self.VWAP
        return None

    @staticmethod
    def from_value(value: String) -> Optional[ALGO]:
        if value == "TWAP": return Self.TWAP
        elif value == "VWAP": return Self.VWAP
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ALGO.", self._name)


# ============================================================
# ORDER_STATUS
# ============================================================
@fieldwise_init
struct ORDER_STATUS(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime PENDING_NEW = ORDER_STATUS("PENDING_NEW", "PENDING_NEW")
    comptime ACTIVE = ORDER_STATUS("ACTIVE", "ACTIVE")
    comptime FILLED = ORDER_STATUS("FILLED", "FILLED")
    comptime REJECTED = ORDER_STATUS("REJECTED", "REJECTED")
    comptime PENDING_CANCEL = ORDER_STATUS("PENDING_CANCEL", "PENDING_CANCEL")
    comptime CANCELLED = ORDER_STATUS("CANCELLED", "CANCELLED")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[ORDER_STATUS]:
        if name == "PENDING_NEW": return Self.PENDING_NEW
        elif name == "ACTIVE": return Self.ACTIVE
        elif name == "FILLED": return Self.FILLED
        elif name == "REJECTED": return Self.REJECTED
        elif name == "PENDING_CANCEL": return Self.PENDING_CANCEL
        elif name == "CANCELLED": return Self.CANCELLED
        return None

    @staticmethod
    def from_value(value: String) -> Optional[ORDER_STATUS]:
        if value == "PENDING_NEW": return Self.PENDING_NEW
        elif value == "ACTIVE": return Self.ACTIVE
        elif value == "FILLED": return Self.FILLED
        elif value == "REJECTED": return Self.REJECTED
        elif value == "PENDING_CANCEL": return Self.PENDING_CANCEL
        elif value == "CANCELLED": return Self.CANCELLED
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ORDER_STATUS.", self._name)


# ============================================================
# SIDE
# ============================================================
@fieldwise_init
struct SIDE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime BUY = SIDE("BUY", "BUY")
    comptime SELL = SIDE("SELL", "SELL")
    comptime FINANCING = SIDE("FINANCING", "FINANCING")
    comptime MARGIN = SIDE("MARGIN", "MARGIN")
    comptime CONVERT_STOCK = SIDE("CONVERT_STOCK", "CONVERT_STOCK")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[SIDE]:
        if name == "BUY": return Self.BUY
        elif name == "SELL": return Self.SELL
        elif name == "FINANCING": return Self.FINANCING
        elif name == "MARGIN": return Self.MARGIN
        elif name == "CONVERT_STOCK": return Self.CONVERT_STOCK
        return None

    @staticmethod
    def from_value(value: String) -> Optional[SIDE]:
        if value == "BUY": return Self.BUY
        elif value == "SELL": return Self.SELL
        elif value == "FINANCING": return Self.FINANCING
        elif value == "MARGIN": return Self.MARGIN
        elif value == "CONVERT_STOCK": return Self.CONVERT_STOCK
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("SIDE.", self._name)


# ============================================================
# POSITION_EFFECT
# ============================================================
@fieldwise_init
struct POSITION_EFFECT(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime OPEN = POSITION_EFFECT("OPEN", "OPEN")
    comptime CLOSE = POSITION_EFFECT("CLOSE", "CLOSE")
    comptime CLOSE_TODAY = POSITION_EFFECT("CLOSE_TODAY", "CLOSE_TODAY")
    comptime EXERCISE = POSITION_EFFECT("EXERCISE", "EXERCISE")
    comptime MATCH = POSITION_EFFECT("MATCH", "MATCH")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[POSITION_EFFECT]:
        if name == "OPEN": return Self.OPEN
        elif name == "CLOSE": return Self.CLOSE
        elif name == "CLOSE_TODAY": return Self.CLOSE_TODAY
        elif name == "EXERCISE": return Self.EXERCISE
        elif name == "MATCH": return Self.MATCH
        return None

    @staticmethod
    def from_value(value: String) -> Optional[POSITION_EFFECT]:
        if value == "OPEN": return Self.OPEN
        elif value == "CLOSE": return Self.CLOSE
        elif value == "CLOSE_TODAY": return Self.CLOSE_TODAY
        elif value == "EXERCISE": return Self.EXERCISE
        elif value == "MATCH": return Self.MATCH
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("POSITION_EFFECT.", self._name)


# ============================================================
# POSITION_DIRECTION
# ============================================================
@fieldwise_init
struct POSITION_DIRECTION(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime LONG = POSITION_DIRECTION("LONG", "LONG")
    comptime SHORT = POSITION_DIRECTION("SHORT", "SHORT")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[POSITION_DIRECTION]:
        if name == "LONG": return Self.LONG
        elif name == "SHORT": return Self.SHORT
        return None

    @staticmethod
    def from_value(value: String) -> Optional[POSITION_DIRECTION]:
        if value == "LONG": return Self.LONG
        elif value == "SHORT": return Self.SHORT
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("POSITION_DIRECTION.", self._name)


# ============================================================
# EXC_TYPE
# ============================================================
@fieldwise_init
struct EXC_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime USER_EXC = EXC_TYPE("USER_EXC", "USER_EXC")
    comptime SYSTEM_EXC = EXC_TYPE("SYSTEM_EXC", "SYSTEM_EXC")
    comptime NOTSET = EXC_TYPE("NOTSET", "NOTSET")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[EXC_TYPE]:
        if name == "USER_EXC": return Self.USER_EXC
        elif name == "SYSTEM_EXC": return Self.SYSTEM_EXC
        elif name == "NOTSET": return Self.NOTSET
        return None

    @staticmethod
    def from_value(value: String) -> Optional[EXC_TYPE]:
        if value == "USER_EXC": return Self.USER_EXC
        elif value == "SYSTEM_EXC": return Self.SYSTEM_EXC
        elif value == "NOTSET": return Self.NOTSET
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("EXC_TYPE.", self._name)


# ============================================================
# INSTRUMENT_TYPE
# ============================================================
@fieldwise_init
struct INSTRUMENT_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

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

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[INSTRUMENT_TYPE]:
        if name == "CS": return Self.CS
        elif name == "FUTURE": return Self.FUTURE
        elif name == "OPTION": return Self.OPTION
        elif name == "ETF": return Self.ETF
        elif name == "LOF": return Self.LOF
        elif name == "INDX": return Self.INDX
        elif name == "PUBLIC_FUND": return Self.PUBLIC_FUND
        elif name == "FUND": return Self.FUND
        elif name == "BOND": return Self.BOND
        elif name == "CONVERTIBLE": return Self.CONVERTIBLE
        elif name == "SPOT": return Self.SPOT
        elif name == "REPO": return Self.REPO
        elif name == "REITs": return Self.REITs
        elif name == "FutureArbitrage": return Self.FutureArbitrage
        return None

    @staticmethod
    def from_value(value: String) -> Optional[INSTRUMENT_TYPE]:
        if value == "CS": return Self.CS
        elif value == "Future": return Self.FUTURE
        elif value == "Option": return Self.OPTION
        elif value == "ETF": return Self.ETF
        elif value == "LOF": return Self.LOF
        elif value == "INDX": return Self.INDX
        elif value == "PublicFund": return Self.PUBLIC_FUND
        elif value == "Fund": return Self.FUND
        elif value == "Bond": return Self.BOND
        elif value == "Convertible": return Self.CONVERTIBLE
        elif value == "Spot": return Self.SPOT
        elif value == "Repo": return Self.REPO
        elif value == "REITs": return Self.REITs
        elif value == "FutureArbitrage": return Self.FutureArbitrage
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("INSTRUMENT_TYPE.", self._name)


# ============================================================
# PERSIST_MODE
# ============================================================
@fieldwise_init
struct PERSIST_MODE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime ON_CRASH = PERSIST_MODE("ON_CRASH", "ON_CRASH")
    comptime REAL_TIME = PERSIST_MODE("REAL_TIME", "REAL_TIME")
    comptime ON_NORMAL_EXIT = PERSIST_MODE("ON_NORMAL_EXIT", "ON_NORMAL_EXIT")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[PERSIST_MODE]:
        if name == "ON_CRASH": return Self.ON_CRASH
        elif name == "REAL_TIME": return Self.REAL_TIME
        elif name == "ON_NORMAL_EXIT": return Self.ON_NORMAL_EXIT
        return None

    @staticmethod
    def from_value(value: String) -> Optional[PERSIST_MODE]:
        if value == "ON_CRASH": return Self.ON_CRASH
        elif value == "REAL_TIME": return Self.REAL_TIME
        elif value == "ON_NORMAL_EXIT": return Self.ON_NORMAL_EXIT
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("PERSIST_MODE.", self._name)


# ============================================================
# COMMISSION_TYPE
# ============================================================
@fieldwise_init
struct COMMISSION_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime BY_MONEY = COMMISSION_TYPE("BY_MONEY", "BY_MONEY")
    comptime BY_VOLUME = COMMISSION_TYPE("BY_VOLUME", "BY_VOLUME")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[COMMISSION_TYPE]:
        if name == "BY_MONEY": return Self.BY_MONEY
        elif name == "BY_VOLUME": return Self.BY_VOLUME
        return None

    @staticmethod
    def from_value(value: String) -> Optional[COMMISSION_TYPE]:
        if value == "BY_MONEY": return Self.BY_MONEY
        elif value == "BY_VOLUME": return Self.BY_VOLUME
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("COMMISSION_TYPE.", self._name)


# ============================================================
# EXIT_CODE
# ============================================================
@fieldwise_init
struct EXIT_CODE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime EXIT_SUCCESS = EXIT_CODE("EXIT_SUCCESS", "EXIT_SUCCESS")
    comptime EXIT_USER_ERROR = EXIT_CODE("EXIT_USER_ERROR", "EXIT_USER_ERROR")
    comptime EXIT_INTERNAL_ERROR = EXIT_CODE("EXIT_INTERNAL_ERROR", "EXIT_INTERNAL_ERROR")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[EXIT_CODE]:
        if name == "EXIT_SUCCESS": return Self.EXIT_SUCCESS
        elif name == "EXIT_USER_ERROR": return Self.EXIT_USER_ERROR
        elif name == "EXIT_INTERNAL_ERROR": return Self.EXIT_INTERNAL_ERROR
        return None

    @staticmethod
    def from_value(value: String) -> Optional[EXIT_CODE]:
        if value == "EXIT_SUCCESS": return Self.EXIT_SUCCESS
        elif value == "EXIT_USER_ERROR": return Self.EXIT_USER_ERROR
        elif value == "EXIT_INTERNAL_ERROR": return Self.EXIT_INTERNAL_ERROR
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("EXIT_CODE.", self._name)


# ============================================================
# HEDGE_TYPE
# ============================================================
@fieldwise_init
struct HEDGE_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime HEDGE = HEDGE_TYPE("HEDGE", "hedge")
    comptime SPECULATION = HEDGE_TYPE("SPECULATION", "speculation")
    comptime ARBITRAGE = HEDGE_TYPE("ARBITRAGE", "arbitrage")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[HEDGE_TYPE]:
        if name == "HEDGE": return Self.HEDGE
        elif name == "SPECULATION": return Self.SPECULATION
        elif name == "ARBITRAGE": return Self.ARBITRAGE
        return None

    @staticmethod
    def from_value(value: String) -> Optional[HEDGE_TYPE]:
        if value == "hedge": return Self.HEDGE
        elif value == "speculation": return Self.SPECULATION
        elif value == "arbitrage": return Self.ARBITRAGE
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("HEDGE_TYPE.", self._name)


# ============================================================
# DAYS_CNT
# ============================================================
struct DAYS_CNT:
    comptime DAYS_A_YEAR: Int = 365
    comptime TRADING_DAYS_A_YEAR: Int = 252


# ============================================================
# EXCHANGE
# ============================================================
@fieldwise_init
struct EXCHANGE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime XSHE = EXCHANGE("XSHE", "XSHE")
    comptime XSHG = EXCHANGE("XSHG", "XSHG")
    comptime SHFE = EXCHANGE("SHFE", "SHFE")
    comptime INE = EXCHANGE("INE", "INE")
    comptime DCE = EXCHANGE("DCE", "DCE")
    comptime CZCE = EXCHANGE("CZCE", "CZCE")
    comptime CFFEX = EXCHANGE("CFFEX", "CFFEX")
    comptime SGEX = EXCHANGE("SGEX", "SGEX")
    comptime BJSE = EXCHANGE("BJSE", "BJSE")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[EXCHANGE]:
        if name == "XSHE": return Self.XSHE
        elif name == "XSHG": return Self.XSHG
        elif name == "SHFE": return Self.SHFE
        elif name == "INE": return Self.INE
        elif name == "DCE": return Self.DCE
        elif name == "CZCE": return Self.CZCE
        elif name == "CFFEX": return Self.CFFEX
        elif name == "SGEX": return Self.SGEX
        elif name == "BJSE": return Self.BJSE
        return None

    @staticmethod
    def from_value(value: String) -> Optional[EXCHANGE]:
        if value == "XSHE": return Self.XSHE
        elif value == "XSHG": return Self.XSHG
        elif value == "SHFE": return Self.SHFE
        elif value == "INE": return Self.INE
        elif value == "DCE": return Self.DCE
        elif value == "CZCE": return Self.CZCE
        elif value == "CFFEX": return Self.CFFEX
        elif value == "SGEX": return Self.SGEX
        elif value == "BJSE": return Self.BJSE
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("EXCHANGE.", self._name)


# ============================================================
# TRADING_CALENDAR_TYPE
# ============================================================
@fieldwise_init
struct TRADING_CALENDAR_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime CN_STOCK = TRADING_CALENDAR_TYPE("CN_STOCK", "CN_STOCK")
    comptime HK_STOCK = TRADING_CALENDAR_TYPE("HK_STOCK", "HK_STOCK")
    comptime SOUTHBOUND = TRADING_CALENDAR_TYPE("SOUTHBOUND", "SOUTHBOUND")
    comptime INTER_BANK = TRADING_CALENDAR_TYPE("INTER_BANK", "INTERBANK")
    comptime EXCHANGE = TRADING_CALENDAR_TYPE("CN_STOCK", "CN_STOCK")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[TRADING_CALENDAR_TYPE]:
        if name == "CN_STOCK": return Self.CN_STOCK
        elif name == "HK_STOCK": return Self.HK_STOCK
        elif name == "SOUTHBOUND": return Self.SOUTHBOUND
        elif name == "INTER_BANK": return Self.INTER_BANK
        elif name == "EXCHANGE": return Self.EXCHANGE
        return None

    @staticmethod
    def from_value(value: String) -> Optional[TRADING_CALENDAR_TYPE]:
        if value == "CN_STOCK": return Self.CN_STOCK
        elif value == "HK_STOCK": return Self.HK_STOCK
        elif value == "SOUTHBOUND": return Self.SOUTHBOUND
        elif value == "INTERBANK": return Self.INTER_BANK
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("TRADING_CALENDAR_TYPE.", self._name)


# ============================================================
# MARKET
# ============================================================
@fieldwise_init
struct MARKET(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime CN = MARKET("CN", "CN")
    comptime HK = MARKET("HK", "HK")

    def name(self) -> String:
        return self._name

    def value(self) -> String:
        return self._value

    @staticmethod
    def from_name(name: String) -> Optional[MARKET]:
        if name == "CN": return Self.CN
        elif name == "HK": return Self.HK
        return None

    @staticmethod
    def from_value(value: String) -> Optional[MARKET]:
        if value == "CN": return Self.CN
        elif value == "HK": return Self.HK
        return None

    def write_to(self, mut writer: Some[Writer]):
        writer.write("MARKET.", self._name)


comptime MARKET_CN = MARKET.CN
comptime MARKET_HK = MARKET.HK


comptime INSTRUMENT_TYPE_CS = INSTRUMENT_TYPE.CS
comptime INSTRUMENT_TYPE_ETF = INSTRUMENT_TYPE.ETF
comptime INSTRUMENT_TYPE_FUTURE = INSTRUMENT_TYPE.FUTURE
comptime INSTRUMENT_TYPE_OPTION = INSTRUMENT_TYPE.OPTION
comptime INSTRUMENT_TYPE_INDX = INSTRUMENT_TYPE.INDX
comptime INSTRUMENT_TYPE_BOND = INSTRUMENT_TYPE.BOND
comptime INSTRUMENT_TYPE_LOF = INSTRUMENT_TYPE.LOF
comptime INSTRUMENT_TYPE_CONVERTIBLE = INSTRUMENT_TYPE.CONVERTIBLE


comptime EXCHANGE_XSHE = EXCHANGE.XSHE
comptime EXCHANGE_XSHG = EXCHANGE.XSHG
comptime EXCHANGE_SHFE = EXCHANGE.SHFE
comptime EXCHANGE_DCE = EXCHANGE.DCE
comptime EXCHANGE_CZCE = EXCHANGE.CZCE
comptime EXCHANGE_CFFEX = EXCHANGE.CFFEX


comptime SIDE_BUY = SIDE.BUY
comptime SIDE_SELL = SIDE.SELL
comptime POSITION_EFFECT_OPEN = POSITION_EFFECT.OPEN
comptime POSITION_EFFECT_CLOSE = POSITION_EFFECT.CLOSE


comptime ORDER_TYPE_MARKET = ORDER_TYPE.MARKET
comptime ORDER_TYPE_LIMIT = ORDER_TYPE.LIMIT


comptime EXECUTION_PHASE_BEFORE_TRADING = EXECUTION_PHASE.BEFORE_TRADING
comptime EXECUTION_PHASE_ON_BAR = EXECUTION_PHASE.ON_BAR
comptime EXECUTION_PHASE_ON_TICK = EXECUTION_PHASE.ON_TICK
comptime EXECUTION_PHASE_AFTER_TRADING = EXECUTION_PHASE.AFTER_TRADING


comptime ORDER_STATUS_PENDING_NEW = ORDER_STATUS.PENDING_NEW
comptime ORDER_STATUS_ACTIVE = ORDER_STATUS.ACTIVE
comptime ORDER_STATUS_FILLED = ORDER_STATUS.FILLED
comptime ORDER_STATUS_REJECTED = ORDER_STATUS.REJECTED
comptime ORDER_STATUS_PENDING_CANCEL = ORDER_STATUS.PENDING_CANCEL
comptime ORDER_STATUS_CANCELLED = ORDER_STATUS.CANCELLED


comptime RUN_TYPE_BACKTEST = RUN_TYPE.BACKTEST
comptime RUN_TYPE_PAPER_TRADING = RUN_TYPE.PAPER_TRADING
comptime RUN_TYPE_LIVE_TRADING = RUN_TYPE.LIVE_TRADING
comptime DEFAULT_ACCOUNT_TYPE_STOCK = DEFAULT_ACCOUNT_TYPE.STOCK
comptime DEFAULT_ACCOUNT_TYPE_FUTURE = DEFAULT_ACCOUNT_TYPE.FUTURE
comptime MATCHING_TYPE_CURRENT_BAR_CLOSE = MATCHING_TYPE.CURRENT_BAR_CLOSE
comptime PERSIST_MODE_ON_CRASH = PERSIST_MODE.ON_CRASH
comptime PERSIST_MODE_REAL_TIME = PERSIST_MODE.REAL_TIME
comptime PERSIST_MODE_ON_NORMAL_EXIT = PERSIST_MODE.ON_NORMAL_EXIT
comptime POSITION_DIRECTION_LONG = POSITION_DIRECTION.LONG
