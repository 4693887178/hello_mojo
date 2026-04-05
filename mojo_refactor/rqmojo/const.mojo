"""
RQAlpha Mojo - Constants and Enumerations
Ported from rqalpha/const.py

Design (vs Python original):
  Python: CustomEnum(str, Enum) + CustomEnumMeta metaclass
  Mojo:  Independent structs + EnumHelper(reflection-driven)

Python metaclass features replicated here:
  - __new__      → _reverse_map() builds {name|value: member} via iteration
  - __getitem__  → __getitem__(s) returns Optional[T] (safe lookup by name or value)
  - __contains__ → contains(s) checks name OR value membership
  - list(Enum)   → members() returns all members
  - repr()       → Writable trait (TypeName.MEMBER_NAME)
"""

from std.reflection import get_base_type_name, struct_field_index_by_name


struct EnumHelper:
    @staticmethod
    def _reflect_name[T: Copyable](instance: T) -> String:
        comptime idx = struct_field_index_by_name[T, "name"]()
        ref r = __struct_field_ref(idx, instance)
        return rebind[String](r)

    @staticmethod
    def _reflect_value[T: Copyable](instance: T) -> String:
        comptime idx = struct_field_index_by_name[T, "value"]()
        ref r = __struct_field_ref(idx, instance)
        return rebind[String](r)

    @staticmethod
    def find_member[T: Copyable & ImplicitlyDestructible](
        members: List[T], target: String
    ) -> Optional[T]:
        for m in members:
            if Self._reflect_name[T](m) == target or Self._reflect_value[T](m) == target:
                return m.copy()
        return None

    @staticmethod
    def build_reverse_map[T: Copyable & ImplicitlyDestructible](
        members: List[T]
    ) -> Dict[String, T]:
        var m = Dict[String, T]()
        for member in members:
            m[Self._reflect_name[T](member)] = member.copy()
            m[Self._reflect_value[T](member)] = member.copy()
        return m^


@fieldwise_init
struct EXECUTION_PHASE(Equatable, ImplicitlyCopyable, Hashable, Writable):
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

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[EXECUTION_PHASE]:
        return EnumHelper.find_member[EXECUTION_PHASE](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[EXECUTION_PHASE]:
        return [Self.GLOBAL, Self.ON_INIT, Self.BEFORE_TRADING, Self.OPEN_AUCTION,
                Self.ON_BAR, Self.ON_TICK, Self.AFTER_TRADING, Self.FINALIZED,
                Self.SCHEDULED]

    @staticmethod
    def _reverse_map() -> Dict[String, EXECUTION_PHASE]:
        return EnumHelper.build_reverse_map[EXECUTION_PHASE](Self.members())


@fieldwise_init
struct RUN_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime BACKTEST = RUN_TYPE("BACKTEST", "BACKTEST")
    comptime PAPER_TRADING = RUN_TYPE("PAPER_TRADING", "PAPER_TRADING")
    comptime LIVE_TRADING = RUN_TYPE("LIVE_TRADING", "LIVE_TRADING")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[RUN_TYPE]:
        return EnumHelper.find_member[RUN_TYPE](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[RUN_TYPE]:
        return [Self.BACKTEST, Self.PAPER_TRADING, Self.LIVE_TRADING]

    @staticmethod
    def _reverse_map() -> Dict[String, RUN_TYPE]:
        return EnumHelper.build_reverse_map[RUN_TYPE](Self.members())


@fieldwise_init
struct DEFAULT_ACCOUNT_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime STOCK = DEFAULT_ACCOUNT_TYPE("STOCK", "STOCK")
    comptime FUTURE = DEFAULT_ACCOUNT_TYPE("FUTURE", "FUTURE")
    comptime BOND = DEFAULT_ACCOUNT_TYPE("BOND", "BOND")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[DEFAULT_ACCOUNT_TYPE]:
        return EnumHelper.find_member[DEFAULT_ACCOUNT_TYPE](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[DEFAULT_ACCOUNT_TYPE]:
        return [Self.STOCK, Self.FUTURE, Self.BOND]

    @staticmethod
    def _reverse_map() -> Dict[String, DEFAULT_ACCOUNT_TYPE]:
        return EnumHelper.build_reverse_map[DEFAULT_ACCOUNT_TYPE](Self.members())


@fieldwise_init
struct MATCHING_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime CURRENT_BAR_CLOSE = MATCHING_TYPE("CURRENT_BAR_CLOSE", "CURRENT_BAR_CLOSE")
    comptime VWAP = MATCHING_TYPE("VWAP", "VWAP")
    comptime COUNTERPARTY_OFFER = MATCHING_TYPE("COUNTERPARTY_OFFER", "COUNTERPARTY_OFFER")
    comptime NEXT_BAR_OPEN = MATCHING_TYPE("NEXT_BAR_OPEN", "NEXT_BAR_OPEN")
    comptime NEXT_TICK_LAST = MATCHING_TYPE("NEXT_TICK_LAST", "NEXT_TICK_LAST")
    comptime NEXT_TICK_BEST_OWN = MATCHING_TYPE("NEXT_TICK_BEST_OWN", "NEXT_TICK_BEST_OWN")
    comptime NEXT_TICK_BEST_COUNTERPARTY = MATCHING_TYPE("NEXT_TICK_BEST_COUNTERPARTY", "NEXT_TICK_BEST_COUNTERPARTY")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[MATCHING_TYPE]:
        return EnumHelper.find_member[MATCHING_TYPE](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[MATCHING_TYPE]:
        return [Self.CURRENT_BAR_CLOSE, Self.VWAP, Self.COUNTERPARTY_OFFER,
                Self.NEXT_BAR_OPEN, Self.NEXT_TICK_LAST, Self.NEXT_TICK_BEST_OWN,
                Self.NEXT_TICK_BEST_COUNTERPARTY]

    @staticmethod
    def _reverse_map() -> Dict[String, MATCHING_TYPE]:
        return EnumHelper.build_reverse_map[MATCHING_TYPE](Self.members())


@fieldwise_init
struct ORDER_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime MARKET = ORDER_TYPE("MARKET", "MARKET")
    comptime LIMIT = ORDER_TYPE("LIMIT", "LIMIT")
    comptime ALGO = ORDER_TYPE("ALGO", "ALGO")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[ORDER_TYPE]:
        return EnumHelper.find_member[ORDER_TYPE](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[ORDER_TYPE]:
        return [Self.MARKET, Self.LIMIT, Self.ALGO]

    @staticmethod
    def _reverse_map() -> Dict[String, ORDER_TYPE]:
        return EnumHelper.build_reverse_map[ORDER_TYPE](Self.members())


@fieldwise_init
struct ALGO(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime TWAP = ALGO("TWAP", "TWAP")
    comptime VWAP = ALGO("VWAP", "VWAP")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[ALGO]:
        return EnumHelper.find_member[ALGO](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[ALGO]:
        return [Self.TWAP, Self.VWAP]

    @staticmethod
    def _reverse_map() -> Dict[String, ALGO]:
        return EnumHelper.build_reverse_map[ALGO](Self.members())


@fieldwise_init
struct ORDER_STATUS(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime PENDING_NEW = ORDER_STATUS("PENDING_NEW", "PENDING_NEW")
    comptime ACTIVE = ORDER_STATUS("ACTIVE", "ACTIVE")
    comptime FILLED = ORDER_STATUS("FILLED", "FILLED")
    comptime REJECTED = ORDER_STATUS("REJECTED", "REJECTED")
    comptime PENDING_CANCEL = ORDER_STATUS("PENDING_CANCEL", "PENDING_CANCEL")
    comptime CANCELLED = ORDER_STATUS("CANCELLED", "CANCELLED")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[ORDER_STATUS]:
        return EnumHelper.find_member[ORDER_STATUS](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[ORDER_STATUS]:
        return [Self.PENDING_NEW, Self.ACTIVE, Self.FILLED, Self.REJECTED,
                Self.PENDING_CANCEL, Self.CANCELLED]

    @staticmethod
    def _reverse_map() -> Dict[String, ORDER_STATUS]:
        return EnumHelper.build_reverse_map[ORDER_STATUS](Self.members())


@fieldwise_init
struct SIDE(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime BUY = SIDE("BUY", "BUY")
    comptime SELL = SIDE("SELL", "SELL")
    comptime FINANCING = SIDE("FINANCING", "FINANCING")
    comptime MARGIN = SIDE("MARGIN", "MARGIN")
    comptime CONVERT_STOCK = SIDE("CONVERT_STOCK", "CONVERT_STOCK")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[SIDE]:
        return EnumHelper.find_member[SIDE](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[SIDE]:
        return [Self.BUY, Self.SELL, Self.FINANCING, Self.MARGIN,
                Self.CONVERT_STOCK]

    @staticmethod
    def _reverse_map() -> Dict[String, SIDE]:
        return EnumHelper.build_reverse_map[SIDE](Self.members())


@fieldwise_init
struct POSITION_EFFECT(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime OPEN = POSITION_EFFECT("OPEN", "OPEN")
    comptime CLOSE = POSITION_EFFECT("CLOSE", "CLOSE")
    comptime CLOSE_TODAY = POSITION_EFFECT("CLOSE_TODAY", "CLOSE_TODAY")
    comptime EXERCISE = POSITION_EFFECT("EXERCISE", "EXERCISE")
    comptime MATCH = POSITION_EFFECT("MATCH", "MATCH")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[POSITION_EFFECT]:
        return EnumHelper.find_member[POSITION_EFFECT](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[POSITION_EFFECT]:
        return [Self.OPEN, Self.CLOSE, Self.CLOSE_TODAY, Self.EXERCISE,
                Self.MATCH]

    @staticmethod
    def _reverse_map() -> Dict[String, POSITION_EFFECT]:
        return EnumHelper.build_reverse_map[POSITION_EFFECT](Self.members())


@fieldwise_init
struct POSITION_DIRECTION(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime LONG = POSITION_DIRECTION("LONG", "LONG")
    comptime SHORT = POSITION_DIRECTION("SHORT", "SHORT")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[POSITION_DIRECTION]:
        return EnumHelper.find_member[POSITION_DIRECTION](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[POSITION_DIRECTION]:
        return [Self.LONG, Self.SHORT]

    @staticmethod
    def _reverse_map() -> Dict[String, POSITION_DIRECTION]:
        return EnumHelper.build_reverse_map[POSITION_DIRECTION](Self.members())


@fieldwise_init
struct EXC_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime USER_EXC = EXC_TYPE("USER_EXC", "USER_EXC")
    comptime SYSTEM_EXC = EXC_TYPE("SYSTEM_EXC", "SYSTEM_EXC")
    comptime NOTSET = EXC_TYPE("NOTSET", "NOTSET")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[EXC_TYPE]:
        return EnumHelper.find_member[EXC_TYPE](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[EXC_TYPE]:
        return [Self.USER_EXC, Self.SYSTEM_EXC, Self.NOTSET]

    @staticmethod
    def _reverse_map() -> Dict[String, EXC_TYPE]:
        return EnumHelper.build_reverse_map[EXC_TYPE](Self.members())


@fieldwise_init
struct INSTRUMENT_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable):
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

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[INSTRUMENT_TYPE]:
        return EnumHelper.find_member[INSTRUMENT_TYPE](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[INSTRUMENT_TYPE]:
        return [Self.CS, Self.FUTURE, Self.OPTION, Self.ETF, Self.LOF,
                Self.INDX, Self.PUBLIC_FUND, Self.FUND, Self.BOND,
                Self.CONVERTIBLE, Self.SPOT, Self.REPO, Self.REITs,
                Self.FutureArbitrage]

    @staticmethod
    def _reverse_map() -> Dict[String, INSTRUMENT_TYPE]:
        return EnumHelper.build_reverse_map[INSTRUMENT_TYPE](Self.members())


@fieldwise_init
struct PERSIST_MODE(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime ON_CRASH = PERSIST_MODE("ON_CRASH", "ON_CRASH")
    comptime REAL_TIME = PERSIST_MODE("REAL_TIME", "REAL_TIME")
    comptime ON_NORMAL_EXIT = PERSIST_MODE("ON_NORMAL_EXIT", "ON_NORMAL_EXIT")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[PERSIST_MODE]:
        return EnumHelper.find_member[PERSIST_MODE](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[PERSIST_MODE]:
        return [Self.ON_CRASH, Self.REAL_TIME, Self.ON_NORMAL_EXIT]

    @staticmethod
    def _reverse_map() -> Dict[String, PERSIST_MODE]:
        return EnumHelper.build_reverse_map[PERSIST_MODE](Self.members())


@fieldwise_init
struct COMMISSION_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime BY_MONEY = COMMISSION_TYPE("BY_MONEY", "BY_MONEY")
    comptime BY_VOLUME = COMMISSION_TYPE("BY_VOLUME", "BY_VOLUME")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[COMMISSION_TYPE]:
        return EnumHelper.find_member[COMMISSION_TYPE](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[COMMISSION_TYPE]:
        return [Self.BY_MONEY, Self.BY_VOLUME]

    @staticmethod
    def _reverse_map() -> Dict[String, COMMISSION_TYPE]:
        return EnumHelper.build_reverse_map[COMMISSION_TYPE](Self.members())


@fieldwise_init
struct EXIT_CODE(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime EXIT_SUCCESS = EXIT_CODE("EXIT_SUCCESS", "EXIT_SUCCESS")
    comptime EXIT_USER_ERROR = EXIT_CODE("EXIT_USER_ERROR", "EXIT_USER_ERROR")
    comptime EXIT_INTERNAL_ERROR = EXIT_CODE("EXIT_INTERNAL_ERROR", "EXIT_INTERNAL_ERROR")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[EXIT_CODE]:
        return EnumHelper.find_member[EXIT_CODE](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[EXIT_CODE]:
        return [Self.EXIT_SUCCESS, Self.EXIT_USER_ERROR, Self.EXIT_INTERNAL_ERROR]

    @staticmethod
    def _reverse_map() -> Dict[String, EXIT_CODE]:
        return EnumHelper.build_reverse_map[EXIT_CODE](Self.members())


@fieldwise_init
struct HEDGE_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime HEDGE = HEDGE_TYPE("HEDGE", "hedge")
    comptime SPECULATION = HEDGE_TYPE("SPECULATION", "speculation")
    comptime ARBITRAGE = HEDGE_TYPE("ARBITRAGE", "arbitrage")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[HEDGE_TYPE]:
        return EnumHelper.find_member[HEDGE_TYPE](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[HEDGE_TYPE]:
        return [Self.HEDGE, Self.SPECULATION, Self.ARBITRAGE]

    @staticmethod
    def _reverse_map() -> Dict[String, HEDGE_TYPE]:
        return EnumHelper.build_reverse_map[HEDGE_TYPE](Self.members())


struct DAYS_CNT:
    comptime DAYS_A_YEAR: Int = 365
    comptime TRADING_DAYS_A_YEAR: Int = 252


@fieldwise_init
struct EXCHANGE(Equatable, ImplicitlyCopyable, Hashable, Writable):
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

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[EXCHANGE]:
        return EnumHelper.find_member[EXCHANGE](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[EXCHANGE]:
        return [Self.XSHE, Self.XSHG, Self.SHFE, Self.INE, Self.DCE,
                Self.CZCE, Self.CFFEX, Self.SGEX, Self.BJSE]

    @staticmethod
    def _reverse_map() -> Dict[String, EXCHANGE]:
        return EnumHelper.build_reverse_map[EXCHANGE](Self.members())


@fieldwise_init
struct TRADING_CALENDAR_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime CN_STOCK = TRADING_CALENDAR_TYPE("CN_STOCK", "CN_STOCK")
    comptime HK_STOCK = TRADING_CALENDAR_TYPE("HK_STOCK", "HK_STOCK")
    comptime SOUTHBOUND = TRADING_CALENDAR_TYPE("SOUTHBOUND", "SOUTHBOUND")
    comptime INTER_BANK = TRADING_CALENDAR_TYPE("INTER_BANK", "INTERBANK")
    comptime EXCHANGE = TRADING_CALENDAR_TYPE("CN_STOCK", "CN_STOCK")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[TRADING_CALENDAR_TYPE]:
        return EnumHelper.find_member[TRADING_CALENDAR_TYPE](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[TRADING_CALENDAR_TYPE]:
        return [Self.CN_STOCK, Self.HK_STOCK, Self.SOUTHBOUND,
                Self.INTER_BANK, Self.EXCHANGE]

    @staticmethod
    def _reverse_map() -> Dict[String, TRADING_CALENDAR_TYPE]:
        return EnumHelper.build_reverse_map[TRADING_CALENDAR_TYPE](Self.members())


@fieldwise_init
struct MARKET(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime CN = MARKET("CN", "CN")
    comptime HK = MARKET("HK", "HK")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[MARKET]:
        return EnumHelper.find_member[MARKET](Self.members(), s)

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None


    @staticmethod
    def members() -> List[MARKET]:
        return [Self.CN, Self.HK]

    @staticmethod
    def _reverse_map() -> Dict[String, MARKET]:
        return EnumHelper.build_reverse_map[MARKET](Self.members())
