"""
RQAlpha Mojo - Constants and Enumerations
Ported from rqalpha/const.py
Mojo 0.26+ compatible - Simplified version
"""


@fieldwise_init
struct EXECUTION_PHASE(Equatable, ImplicitlyCopyable, Writable):
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

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct RUN_TYPE(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String
    
    comptime BACKTEST = RUN_TYPE("BACKTEST", "BACKTEST")
    comptime PAPER_TRADING = RUN_TYPE("PAPER_TRADING", "PAPER_TRADING")
    comptime LIVE_TRADING = RUN_TYPE("LIVE_TRADING", "LIVE_TRADING")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct DEFAULT_ACCOUNT_TYPE(Equatable, ImplicitlyCopyable, Writable, Hashable):
    var name: String
    var value: String
    
    comptime STOCK = DEFAULT_ACCOUNT_TYPE("STOCK", "STOCK")
    comptime FUTURE = DEFAULT_ACCOUNT_TYPE("FUTURE", "FUTURE")
    comptime BOND = DEFAULT_ACCOUNT_TYPE("BOND", "BOND")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)
    
    fn hash(self) -> UInt:
        return UInt(hash(self.value))


@fieldwise_init
struct MATCHING_TYPE(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String
    
    comptime CURRENT_BAR_CLOSE = MATCHING_TYPE("CURRENT_BAR_CLOSE", "CURRENT_BAR_CLOSE")
    comptime VWAP = MATCHING_TYPE("VWAP", "VWAP")
    comptime COUNTERPARTY_OFFER = MATCHING_TYPE("COUNTERPARTY_OFFER", "COUNTERPARTY_OFFER")
    comptime NEXT_BAR_OPEN = MATCHING_TYPE("NEXT_BAR_OPEN", "NEXT_BAR_OPEN")
    comptime NEXT_TICK_LAST = MATCHING_TYPE("NEXT_TICK_LAST", "NEXT_TICK_LAST")
    comptime NEXT_TICK_BEST_OWN = MATCHING_TYPE("NEXT_TICK_BEST_OWN", "NEXT_TICK_BEST_OWN")
    comptime NEXT_TICK_BEST_COUNTERPARTY = MATCHING_TYPE("NEXT_TICK_BEST_COUNTERPARTY", "NEXT_TICK_BEST_COUNTERPARTY")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct ORDER_TYPE(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String
    
    comptime MARKET = ORDER_TYPE("MARKET", "MARKET")
    comptime LIMIT = ORDER_TYPE("LIMIT", "LIMIT")
    comptime ALGO = ORDER_TYPE("ALGO", "ALGO")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct ALGO(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String
    
    comptime TWAP = ALGO("TWAP", "TWAP")
    comptime VWAP = ALGO("VWAP", "VWAP")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct ORDER_STATUS(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String
    
    comptime PENDING_NEW = ORDER_STATUS("PENDING_NEW", "PENDING_NEW")
    comptime ACTIVE = ORDER_STATUS("ACTIVE", "ACTIVE")
    comptime FILLED = ORDER_STATUS("FILLED", "FILLED")
    comptime REJECTED = ORDER_STATUS("REJECTED", "REJECTED")
    comptime PENDING_CANCEL = ORDER_STATUS("PENDING_CANCEL", "PENDING_CANCEL")
    comptime CANCELLED = ORDER_STATUS("CANCELLED", "CANCELLED")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct SIDE(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String
    
    comptime BUY = SIDE("BUY", "BUY")
    comptime SELL = SIDE("SELL", "SELL")
    comptime FINANCING = SIDE("FINANCING", "FINANCING")
    comptime MARGIN = SIDE("MARGIN", "MARGIN")
    comptime CONVERT_STOCK = SIDE("CONVERT_STOCK", "CONVERT_STOCK")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct POSITION_EFFECT(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String
    
    comptime OPEN = POSITION_EFFECT("OPEN", "OPEN")
    comptime CLOSE = POSITION_EFFECT("CLOSE", "CLOSE")
    comptime CLOSE_TODAY = POSITION_EFFECT("CLOSE_TODAY", "CLOSE_TODAY")
    comptime EXERCISE = POSITION_EFFECT("EXERCISE", "EXERCISE")
    comptime MATCH = POSITION_EFFECT("MATCH", "MATCH")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct POSITION_DIRECTION(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String
    
    comptime LONG = POSITION_DIRECTION("LONG", "LONG")
    comptime SHORT = POSITION_DIRECTION("SHORT", "SHORT")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct EXC_TYPE(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String
    
    comptime USER_EXC = EXC_TYPE("USER_EXC", "USER_EXC")
    comptime SYSTEM_EXC = EXC_TYPE("SYSTEM_EXC", "SYSTEM_EXC")
    comptime NOTSET = EXC_TYPE("NOTSET", "NOTSET")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct INSTRUMENT_TYPE(Equatable, ImplicitlyCopyable, Writable):
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

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct PERSIST_MODE(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String
    
    comptime ON_CRASH = PERSIST_MODE("ON_CRASH", "ON_CRASH")
    comptime REAL_TIME = PERSIST_MODE("REAL_TIME", "REAL_TIME")
    comptime ON_NORMAL_EXIT = PERSIST_MODE("ON_NORMAL_EXIT", "ON_NORMAL_EXIT")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct COMMISSION_TYPE(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String
    
    comptime BY_MONEY = COMMISSION_TYPE("BY_MONEY", "BY_MONEY")
    comptime BY_VOLUME = COMMISSION_TYPE("BY_VOLUME", "BY_VOLUME")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct EXIT_CODE(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String
    
    comptime EXIT_SUCCESS = EXIT_CODE("EXIT_SUCCESS", "EXIT_SUCCESS")
    comptime EXIT_USER_ERROR = EXIT_CODE("EXIT_USER_ERROR", "EXIT_USER_ERROR")
    comptime EXIT_INTERNAL_ERROR = EXIT_CODE("EXIT_INTERNAL_ERROR", "EXIT_INTERNAL_ERROR")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct HEDGE_TYPE(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String
    
    comptime HEDGE = HEDGE_TYPE("HEDGE", "hedge")
    comptime SPECULATION = HEDGE_TYPE("SPECULATION", "speculation")
    comptime ARBITRAGE = HEDGE_TYPE("ARBITRAGE", "arbitrage")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


struct DAYS_CNT:
    comptime DAYS_A_YEAR: Int = 365
    comptime TRADING_DAYS_A_YEAR: Int = 252


@fieldwise_init
struct EXCHANGE(Equatable, ImplicitlyCopyable, Writable):
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

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct TRADING_CALENDAR_TYPE(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String
    
    comptime CN_STOCK = TRADING_CALENDAR_TYPE("CN_STOCK", "CN_STOCK")
    comptime HK_STOCK = TRADING_CALENDAR_TYPE("HK_STOCK", "HK_STOCK")
    comptime SOUTHBOUND = TRADING_CALENDAR_TYPE("SOUTHBOUND", "SOUTHBOUND")
    comptime INTER_BANK = TRADING_CALENDAR_TYPE("INTER_BANK", "INTERBANK")
    comptime EXCHANGE = TRADING_CALENDAR_TYPE("CN_STOCK", "CN_STOCK")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)


@fieldwise_init
struct MARKET(Equatable, ImplicitlyCopyable, Writable):
    var name: String
    var value: String
    
    comptime CN = MARKET("CN", "CN")
    comptime HK = MARKET("HK", "HK")

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)
