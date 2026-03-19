"""
RQAlpha Mojo - Constants and Enumerations
Ported from rqalpha/const.py
Mojo 0.26+ compatible
"""


@fieldwise_init
struct EXECUTION_PHASE(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    fn __repr__(self) -> String:
        return self.name
    
    @staticmethod
    fn GLOBAL() -> EXECUTION_PHASE:
        return EXECUTION_PHASE("GLOBAL", "[全局]")
    
    @staticmethod
    fn ON_INIT() -> EXECUTION_PHASE:
        return EXECUTION_PHASE("ON_INIT", "[程序初始化]")
    
    @staticmethod
    fn BEFORE_TRADING() -> EXECUTION_PHASE:
        return EXECUTION_PHASE("BEFORE_TRADING", "[日内交易前]")
    
    @staticmethod
    fn OPEN_AUCTION() -> EXECUTION_PHASE:
        return EXECUTION_PHASE("OPEN_AUCTION", "[集合竞价]")
    
    @staticmethod
    fn ON_BAR() -> EXECUTION_PHASE:
        return EXECUTION_PHASE("ON_BAR", "[盘中 handle_bar 函数]")
    
    @staticmethod
    fn ON_TICK() -> EXECUTION_PHASE:
        return EXECUTION_PHASE("ON_TICK", "[盘中 handle_tick 函数]")
    
    @staticmethod
    fn AFTER_TRADING() -> EXECUTION_PHASE:
        return EXECUTION_PHASE("AFTER_TRADING", "[日内交易后]")
    
    @staticmethod
    fn FINALIZED() -> EXECUTION_PHASE:
        return EXECUTION_PHASE("FINALIZED", "[程序结束]")
    
    @staticmethod
    fn SCHEDULED() -> EXECUTION_PHASE:
        return EXECUTION_PHASE("SCHEDULED", "[scheduler函数内]")


@fieldwise_init
struct RUN_TYPE(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn BACKTEST() -> RUN_TYPE:
        return RUN_TYPE("BACKTEST", "BACKTEST")
    
    @staticmethod
    fn PAPER_TRADING() -> RUN_TYPE:
        return RUN_TYPE("PAPER_TRADING", "PAPER_TRADING")
    
    @staticmethod
    fn LIVE_TRADING() -> RUN_TYPE:
        return RUN_TYPE("LIVE_TRADING", "LIVE_TRADING")


@fieldwise_init
struct DEFAULT_ACCOUNT_TYPE(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable, Hashable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    fn hash(self) -> UInt:
        return UInt(hash(self.value))
    
    @staticmethod
    fn STOCK() -> DEFAULT_ACCOUNT_TYPE:
        return DEFAULT_ACCOUNT_TYPE("STOCK", "STOCK")
    
    @staticmethod
    fn FUTURE() -> DEFAULT_ACCOUNT_TYPE:
        return DEFAULT_ACCOUNT_TYPE("FUTURE", "FUTURE")
    
    @staticmethod
    fn BOND() -> DEFAULT_ACCOUNT_TYPE:
        return DEFAULT_ACCOUNT_TYPE("BOND", "BOND")


@fieldwise_init
struct MATCHING_TYPE(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn CURRENT_BAR_CLOSE() -> MATCHING_TYPE:
        return MATCHING_TYPE("CURRENT_BAR_CLOSE", "CURRENT_BAR_CLOSE")
    
    @staticmethod
    fn VWAP() -> MATCHING_TYPE:
        return MATCHING_TYPE("VWAP", "VWAP")
    
    @staticmethod
    fn COUNTERPARTY_OFFER() -> MATCHING_TYPE:
        return MATCHING_TYPE("COUNTERPARTY_OFFER", "COUNTERPARTY_OFFER")
    
    @staticmethod
    fn NEXT_BAR_OPEN() -> MATCHING_TYPE:
        return MATCHING_TYPE("NEXT_BAR_OPEN", "NEXT_BAR_OPEN")
    
    @staticmethod
    fn NEXT_TICK_LAST() -> MATCHING_TYPE:
        return MATCHING_TYPE("NEXT_TICK_LAST", "NEXT_TICK_LAST")
    
    @staticmethod
    fn NEXT_TICK_BEST_OWN() -> MATCHING_TYPE:
        return MATCHING_TYPE("NEXT_TICK_BEST_OWN", "NEXT_TICK_BEST_OWN")
    
    @staticmethod
    fn NEXT_TICK_BEST_COUNTERPARTY() -> MATCHING_TYPE:
        return MATCHING_TYPE("NEXT_TICK_BEST_COUNTERPARTY", "NEXT_TICK_BEST_COUNTERPARTY")


@fieldwise_init
struct ORDER_TYPE(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn MARKET() -> ORDER_TYPE:
        return ORDER_TYPE("MARKET", "MARKET")
    
    @staticmethod
    fn LIMIT() -> ORDER_TYPE:
        return ORDER_TYPE("LIMIT", "LIMIT")
    
    @staticmethod
    fn ALGO() -> ORDER_TYPE:
        return ORDER_TYPE("ALGO", "ALGO")


@fieldwise_init
struct ALGO(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn TWAP() -> ALGO:
        return ALGO("TWAP", "TWAP")
    
    @staticmethod
    fn VWAP() -> ALGO:
        return ALGO("VWAP", "VWAP")


@fieldwise_init
struct ORDER_STATUS(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn PENDING_NEW() -> ORDER_STATUS:
        return ORDER_STATUS("PENDING_NEW", "PENDING_NEW")
    
    @staticmethod
    fn ACTIVE() -> ORDER_STATUS:
        return ORDER_STATUS("ACTIVE", "ACTIVE")
    
    @staticmethod
    fn FILLED() -> ORDER_STATUS:
        return ORDER_STATUS("FILLED", "FILLED")
    
    @staticmethod
    fn REJECTED() -> ORDER_STATUS:
        return ORDER_STATUS("REJECTED", "REJECTED")
    
    @staticmethod
    fn PENDING_CANCEL() -> ORDER_STATUS:
        return ORDER_STATUS("PENDING_CANCEL", "PENDING_CANCEL")
    
    @staticmethod
    fn CANCELLED() -> ORDER_STATUS:
        return ORDER_STATUS("CANCELLED", "CANCELLED")


@fieldwise_init
struct SIDE(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn BUY() -> SIDE:
        return SIDE("BUY", "BUY")
    
    @staticmethod
    fn SELL() -> SIDE:
        return SIDE("SELL", "SELL")
    
    @staticmethod
    fn FINANCING() -> SIDE:
        return SIDE("FINANCING", "FINANCING")
    
    @staticmethod
    fn MARGIN() -> SIDE:
        return SIDE("MARGIN", "MARGIN")
    
    @staticmethod
    fn CONVERT_STOCK() -> SIDE:
        return SIDE("CONVERT_STOCK", "CONVERT_STOCK")


@fieldwise_init
struct POSITION_EFFECT(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn OPEN() -> POSITION_EFFECT:
        return POSITION_EFFECT("OPEN", "OPEN")
    
    @staticmethod
    fn CLOSE() -> POSITION_EFFECT:
        return POSITION_EFFECT("CLOSE", "CLOSE")
    
    @staticmethod
    fn CLOSE_TODAY() -> POSITION_EFFECT:
        return POSITION_EFFECT("CLOSE_TODAY", "CLOSE_TODAY")
    
    @staticmethod
    fn EXERCISE() -> POSITION_EFFECT:
        return POSITION_EFFECT("EXERCISE", "EXERCISE")
    
    @staticmethod
    fn MATCH() -> POSITION_EFFECT:
        return POSITION_EFFECT("MATCH", "MATCH")


@fieldwise_init
struct POSITION_DIRECTION(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn LONG() -> POSITION_DIRECTION:
        return POSITION_DIRECTION("LONG", "LONG")
    
    @staticmethod
    fn SHORT() -> POSITION_DIRECTION:
        return POSITION_DIRECTION("SHORT", "SHORT")


@fieldwise_init
struct EXC_TYPE(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn USER_EXC() -> EXC_TYPE:
        return EXC_TYPE("USER_EXC", "USER_EXC")
    
    @staticmethod
    fn SYSTEM_EXC() -> EXC_TYPE:
        return EXC_TYPE("SYSTEM_EXC", "SYSTEM_EXC")
    
    @staticmethod
    fn NOTSET() -> EXC_TYPE:
        return EXC_TYPE("NOTSET", "NOTSET")


@fieldwise_init
struct INSTRUMENT_TYPE(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn CS() -> INSTRUMENT_TYPE:
        return INSTRUMENT_TYPE("CS", "CS")
    
    @staticmethod
    fn FUTURE() -> INSTRUMENT_TYPE:
        return INSTRUMENT_TYPE("FUTURE", "Future")
    
    @staticmethod
    fn OPTION() -> INSTRUMENT_TYPE:
        return INSTRUMENT_TYPE("OPTION", "Option")
    
    @staticmethod
    fn ETF() -> INSTRUMENT_TYPE:
        return INSTRUMENT_TYPE("ETF", "ETF")
    
    @staticmethod
    fn LOF() -> INSTRUMENT_TYPE:
        return INSTRUMENT_TYPE("LOF", "LOF")
    
    @staticmethod
    fn INDX() -> INSTRUMENT_TYPE:
        return INSTRUMENT_TYPE("INDX", "INDX")
    
    @staticmethod
    fn PUBLIC_FUND() -> INSTRUMENT_TYPE:
        return INSTRUMENT_TYPE("PUBLIC_FUND", "PublicFund")
    
    @staticmethod
    fn FUND() -> INSTRUMENT_TYPE:
        return INSTRUMENT_TYPE("FUND", "Fund")
    
    @staticmethod
    fn BOND() -> INSTRUMENT_TYPE:
        return INSTRUMENT_TYPE("BOND", "Bond")
    
    @staticmethod
    fn CONVERTIBLE() -> INSTRUMENT_TYPE:
        return INSTRUMENT_TYPE("CONVERTIBLE", "Convertible")
    
    @staticmethod
    fn SPOT() -> INSTRUMENT_TYPE:
        return INSTRUMENT_TYPE("SPOT", "Spot")
    
    @staticmethod
    fn REPO() -> INSTRUMENT_TYPE:
        return INSTRUMENT_TYPE("REPO", "Repo")
    
    @staticmethod
    fn REITs() -> INSTRUMENT_TYPE:
        return INSTRUMENT_TYPE("REITs", "REITs")
    
    @staticmethod
    fn FutureArbitrage() -> INSTRUMENT_TYPE:
        return INSTRUMENT_TYPE("FutureArbitrage", "FutureArbitrage")


@fieldwise_init
struct PERSIST_MODE(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn ON_CRASH() -> PERSIST_MODE:
        return PERSIST_MODE("ON_CRASH", "ON_CRASH")
    
    @staticmethod
    fn REAL_TIME() -> PERSIST_MODE:
        return PERSIST_MODE("REAL_TIME", "REAL_TIME")
    
    @staticmethod
    fn ON_NORMAL_EXIT() -> PERSIST_MODE:
        return PERSIST_MODE("ON_NORMAL_EXIT", "ON_NORMAL_EXIT")


@fieldwise_init
struct COMMISSION_TYPE(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn BY_MONEY() -> COMMISSION_TYPE:
        return COMMISSION_TYPE("BY_MONEY", "BY_MONEY")
    
    @staticmethod
    fn BY_VOLUME() -> COMMISSION_TYPE:
        return COMMISSION_TYPE("BY_VOLUME", "BY_VOLUME")


@fieldwise_init
struct EXIT_CODE(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn EXIT_SUCCESS() -> EXIT_CODE:
        return EXIT_CODE("EXIT_SUCCESS", "EXIT_SUCCESS")
    
    @staticmethod
    fn EXIT_USER_ERROR() -> EXIT_CODE:
        return EXIT_CODE("EXIT_USER_ERROR", "EXIT_USER_ERROR")
    
    @staticmethod
    fn EXIT_INTERNAL_ERROR() -> EXIT_CODE:
        return EXIT_CODE("EXIT_INTERNAL_ERROR", "EXIT_INTERNAL_ERROR")


@fieldwise_init
struct HEDGE_TYPE(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn HEDGE() -> HEDGE_TYPE:
        return HEDGE_TYPE("HEDGE", "hedge")
    
    @staticmethod
    fn SPECULATION() -> HEDGE_TYPE:
        return HEDGE_TYPE("SPECULATION", "speculation")
    
    @staticmethod
    fn ARBITRAGE() -> HEDGE_TYPE:
        return HEDGE_TYPE("ARBITRAGE", "arbitrage")


struct DAYS_CNT:
    comptime DAYS_A_YEAR: Int = 365
    comptime TRADING_DAYS_A_YEAR: Int = 252


@fieldwise_init
struct EXCHANGE(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn XSHE() -> EXCHANGE:
        return EXCHANGE("XSHE", "XSHE")
    
    @staticmethod
    fn XSHG() -> EXCHANGE:
        return EXCHANGE("XSHG", "XSHG")
    
    @staticmethod
    fn SHFE() -> EXCHANGE:
        return EXCHANGE("SHFE", "SHFE")
    
    @staticmethod
    fn INE() -> EXCHANGE:
        return EXCHANGE("INE", "INE")
    
    @staticmethod
    fn DCE() -> EXCHANGE:
        return EXCHANGE("DCE", "DCE")
    
    @staticmethod
    fn CZCE() -> EXCHANGE:
        return EXCHANGE("CZCE", "CZCE")
    
    @staticmethod
    fn CFFEX() -> EXCHANGE:
        return EXCHANGE("CFFEX", "CFFEX")
    
    @staticmethod
    fn SGEX() -> EXCHANGE:
        return EXCHANGE("SGEX", "SGEX")
    
    @staticmethod
    fn BJSE() -> EXCHANGE:
        return EXCHANGE("BJSE", "BJSE")


@fieldwise_init
struct TRADING_CALENDAR_TYPE(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn CN_STOCK() -> TRADING_CALENDAR_TYPE:
        return TRADING_CALENDAR_TYPE("CN_STOCK", "CN_STOCK")
    
    @staticmethod
    fn HK_STOCK() -> TRADING_CALENDAR_TYPE:
        return TRADING_CALENDAR_TYPE("HK_STOCK", "HK_STOCK")
    
    @staticmethod
    fn SOUTHBOUND() -> TRADING_CALENDAR_TYPE:
        return TRADING_CALENDAR_TYPE("SOUTHBOUND", "SOUTHBOUND")
    
    @staticmethod
    fn INTER_BANK() -> TRADING_CALENDAR_TYPE:
        return TRADING_CALENDAR_TYPE("INTER_BANK", "INTERBANK")
    
    @staticmethod
    fn EXCHANGE() -> TRADING_CALENDAR_TYPE:
        return TRADING_CALENDAR_TYPE("CN_STOCK", "CN_STOCK")


@fieldwise_init
struct MARKET(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String
    
    fn __str__(self) -> String:
        return self.value
    
    @staticmethod
    fn CN() -> MARKET:
        return MARKET("CN", "CN")
    
    @staticmethod
    fn HK() -> MARKET:
        return MARKET("HK", "HK")


fn main():
    """Test main function for const module."""
    print("const.mojo - Constants module loaded successfully")
