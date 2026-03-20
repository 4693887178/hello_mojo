"""
RQAlpha Mojo - Constants and Enumerations (精简版)
Ported from rqalpha/const.py
Mojo 0.26+ compatible - 使用全局字典 + reversed 消除 if-elif 链
"""

from collections import List, Dict
from sys import exit

trait EnumTrait:
    fn name(self) -> String: ...
    fn value(self) -> String: ...

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

    fn name(self) -> String:
        return self._name

    fn value(self) -> String:
        return self._value

    fn write_to(self, mut writer: Some[Writer]):
        writer.write("EXECUTION_PHASE.", self._name)

var _EXECUTION_PHASE_BY_NAME = Dict[String, EXECUTION_PHASE]()
var _ALL_EXECUTION_PHASES = List[EXECUTION_PHASE]()

fn _fill_execution_phase():
    _ALL_EXECUTION_PHASES.append(EXECUTION_PHASE.GLOBAL)
    _ALL_EXECUTION_PHASES.append(EXECUTION_PHASE.ON_INIT)
    _ALL_EXECUTION_PHASES.append(EXECUTION_PHASE.BEFORE_TRADING)
    _ALL_EXECUTION_PHASES.append(EXECUTION_PHASE.OPEN_AUCTION)
    _ALL_EXECUTION_PHASES.append(EXECUTION_PHASE.ON_BAR)
    _ALL_EXECUTION_PHASES.append(EXECUTION_PHASE.ON_TICK)
    _ALL_EXECUTION_PHASES.append(EXECUTION_PHASE.AFTER_TRADING)
    _ALL_EXECUTION_PHASES.append(EXECUTION_PHASE.FINALIZED)
    _ALL_EXECUTION_PHASES.append(EXECUTION_PHASE.SCHEDULED)

    _EXECUTION_PHASE_BY_NAME["GLOBAL"] = EXECUTION_PHASE.GLOBAL
    _EXECUTION_PHASE_BY_NAME["ON_INIT"] = EXECUTION_PHASE.ON_INIT
    _EXECUTION_PHASE_BY_NAME["BEFORE_TRADING"] = EXECUTION_PHASE.BEFORE_TRADING
    _EXECUTION_PHASE_BY_NAME["OPEN_AUCTION"] = EXECUTION_PHASE.OPEN_AUCTION
    _EXECUTION_PHASE_BY_NAME["ON_BAR"] = EXECUTION_PHASE.ON_BAR
    _EXECUTION_PHASE_BY_NAME["ON_TICK"] = EXECUTION_PHASE.ON_TICK
    _EXECUTION_PHASE_BY_NAME["AFTER_TRADING"] = EXECUTION_PHASE.AFTER_TRADING
    _EXECUTION_PHASE_BY_NAME["FINALIZED"] = EXECUTION_PHASE.FINALIZED
    _EXECUTION_PHASE_BY_NAME["SCHEDULED"] = EXECUTION_PHASE.SCHEDULED

fn execution_phase_from_name(name: String) -> Optional[EXECUTION_PHASE]:
    return _EXECUTION_PHASE_BY_NAME.get(name)

fn execution_phase_from_value(value: String) -> Optional[EXECUTION_PHASE]:
    for v in reversed(_ALL_EXECUTION_PHASES):
        if v.value() == value:
            return v
    return None


@fieldwise_init
struct RUN_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime BACKTEST = RUN_TYPE("BACKTEST", "BACKTEST")
    comptime PAPER_TRADING = RUN_TYPE("PAPER_TRADING", "PAPER_TRADING")
    comptime LIVE_TRADING = RUN_TYPE("LIVE_TRADING", "LIVE_TRADING")

    fn name(self) -> String:
        return self._name

    fn value(self) -> String:
        return self._value

    fn write_to(self, mut writer: Some[Writer]):
        writer.write("RUN_TYPE.", self._name)

var _RUN_TYPE_BY_NAME = Dict[String, RUN_TYPE]()
var _ALL_RUN_TYPES = List[RUN_TYPE]()

fn _fill_run_type():
    _ALL_RUN_TYPES.append(RUN_TYPE.BACKTEST)
    _ALL_RUN_TYPES.append(RUN_TYPE.PAPER_TRADING)
    _ALL_RUN_TYPES.append(RUN_TYPE.LIVE_TRADING)

    _RUN_TYPE_BY_NAME["BACKTEST"] = RUN_TYPE.BACKTEST
    _RUN_TYPE_BY_NAME["PAPER_TRADING"] = RUN_TYPE.PAPER_TRADING
    _RUN_TYPE_BY_NAME["LIVE_TRADING"] = RUN_TYPE.LIVE_TRADING

fn run_type_from_name(name: String) -> Optional[RUN_TYPE]:
    return _RUN_TYPE_BY_NAME.get(name)

fn run_type_from_value(value: String) -> Optional[RUN_TYPE]:
    for v in reversed(_ALL_RUN_TYPES):
        if v.value() == value:
            return v
    return None


@fieldwise_init
struct DEFAULT_ACCOUNT_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime STOCK = DEFAULT_ACCOUNT_TYPE("STOCK", "STOCK")
    comptime FUTURE = DEFAULT_ACCOUNT_TYPE("FUTURE", "FUTURE")
    comptime BOND = DEFAULT_ACCOUNT_TYPE("BOND", "BOND")

    fn name(self) -> String:
        return self._name

    fn value(self) -> String:
        return self._value

    fn write_to(self, mut writer: Some[Writer]):
        writer.write("DEFAULT_ACCOUNT_TYPE.", self._name)

var _DEFAULT_ACCOUNT_TYPE_BY_NAME = Dict[String, DEFAULT_ACCOUNT_TYPE]()
var _ALL_DEFAULT_ACCOUNT_TYPES = List[DEFAULT_ACCOUNT_TYPE]()

fn _fill_default_account_type():
    _ALL_DEFAULT_ACCOUNT_TYPES.append(DEFAULT_ACCOUNT_TYPE.STOCK)
    _ALL_DEFAULT_ACCOUNT_TYPES.append(DEFAULT_ACCOUNT_TYPE.FUTURE)
    _ALL_DEFAULT_ACCOUNT_TYPES.append(DEFAULT_ACCOUNT_TYPE.BOND)

    _DEFAULT_ACCOUNT_TYPE_BY_NAME["STOCK"] = DEFAULT_ACCOUNT_TYPE.STOCK
    _DEFAULT_ACCOUNT_TYPE_BY_NAME["FUTURE"] = DEFAULT_ACCOUNT_TYPE.FUTURE
    _DEFAULT_ACCOUNT_TYPE_BY_NAME["BOND"] = DEFAULT_ACCOUNT_TYPE.BOND

fn default_account_type_from_name(name: String) -> Optional[DEFAULT_ACCOUNT_TYPE]:
    return _DEFAULT_ACCOUNT_TYPE_BY_NAME.get(name)

fn default_account_type_from_value(value: String) -> Optional[DEFAULT_ACCOUNT_TYPE]:
    for v in reversed(_ALL_DEFAULT_ACCOUNT_TYPES):
        if v.value() == value:
            return v
    return None


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

    fn name(self) -> String:
        return self._name

    fn value(self) -> String:
        return self._value

    fn write_to(self, mut writer: Some[Writer]):
        writer.write("MATCHING_TYPE.", self._name)

var _MATCHING_TYPE_BY_NAME = Dict[String, MATCHING_TYPE]()
var _ALL_MATCHING_TYPES = List[MATCHING_TYPE]()

fn _fill_matching_type():
    _ALL_MATCHING_TYPES.append(MATCHING_TYPE.CURRENT_BAR_CLOSE)
    _ALL_MATCHING_TYPES.append(MATCHING_TYPE.VWAP)
    _ALL_MATCHING_TYPES.append(MATCHING_TYPE.COUNTERPARTY_OFFER)
    _ALL_MATCHING_TYPES.append(MATCHING_TYPE.NEXT_BAR_OPEN)
    _ALL_MATCHING_TYPES.append(MATCHING_TYPE.NEXT_TICK_LAST)
    _ALL_MATCHING_TYPES.append(MATCHING_TYPE.NEXT_TICK_BEST_OWN)
    _ALL_MATCHING_TYPES.append(MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY)

    _MATCHING_TYPE_BY_NAME["CURRENT_BAR_CLOSE"] = MATCHING_TYPE.CURRENT_BAR_CLOSE
    _MATCHING_TYPE_BY_NAME["VWAP"] = MATCHING_TYPE.VWAP
    _MATCHING_TYPE_BY_NAME["COUNTERPARTY_OFFER"] = MATCHING_TYPE.COUNTERPARTY_OFFER
    _MATCHING_TYPE_BY_NAME["NEXT_BAR_OPEN"] = MATCHING_TYPE.NEXT_BAR_OPEN
    _MATCHING_TYPE_BY_NAME["NEXT_TICK_LAST"] = MATCHING_TYPE.NEXT_TICK_LAST
    _MATCHING_TYPE_BY_NAME["NEXT_TICK_BEST_OWN"] = MATCHING_TYPE.NEXT_TICK_BEST_OWN
    _MATCHING_TYPE_BY_NAME["NEXT_TICK_BEST_COUNTERPARTY"] = MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY

fn matching_type_from_name(name: String) -> Optional[MATCHING_TYPE]:
    return _MATCHING_TYPE_BY_NAME.get(name)

fn matching_type_from_value(value: String) -> Optional[MATCHING_TYPE]:
    for v in reversed(_ALL_MATCHING_TYPES):
        if v.value() == value:
            return v
    return None


@fieldwise_init
struct ORDER_TYPE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime MARKET = ORDER_TYPE("MARKET", "MARKET")
    comptime LIMIT = ORDER_TYPE("LIMIT", "LIMIT")
    comptime ALGO = ORDER_TYPE("ALGO", "ALGO")

    fn name(self) -> String:
        return self._name

    fn value(self) -> String:
        return self._value

    fn write_to(self, mut writer: Some[Writer]):
        writer.write("ORDER_TYPE.", self._name)

var _ORDER_TYPE_BY_NAME = Dict[String, ORDER_TYPE]()
var _ALL_ORDER_TYPES = List[ORDER_TYPE]()

fn _fill_order_type():
    _ALL_ORDER_TYPES.append(ORDER_TYPE.MARKET)
    _ALL_ORDER_TYPES.append(ORDER_TYPE.LIMIT)
    _ALL_ORDER_TYPES.append(ORDER_TYPE.ALGO)

    _ORDER_TYPE_BY_NAME["MARKET"] = ORDER_TYPE.MARKET
    _ORDER_TYPE_BY_NAME["LIMIT"] = ORDER_TYPE.LIMIT
    _ORDER_TYPE_BY_NAME["ALGO"] = ORDER_TYPE.ALGO

fn order_type_from_name(name: String) -> Optional[ORDER_TYPE]:
    return _ORDER_TYPE_BY_NAME.get(name)

fn order_type_from_value(value: String) -> Optional[ORDER_TYPE]:
    for v in reversed(_ALL_ORDER_TYPES):
        if v.value() == value:
            return v
    return None


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

    fn name(self) -> String:
        return self._name

    fn value(self) -> String:
        return self._value

    fn write_to(self, mut writer: Some[Writer]):
        writer.write("ORDER_STATUS.", self._name)

var _ORDER_STATUS_BY_NAME = Dict[String, ORDER_STATUS]()
var _ALL_ORDER_STATUSES = List[ORDER_STATUS]()

fn _fill_order_status():
    _ALL_ORDER_STATUSES.append(ORDER_STATUS.PENDING_NEW)
    _ALL_ORDER_STATUSES.append(ORDER_STATUS.ACTIVE)
    _ALL_ORDER_STATUSES.append(ORDER_STATUS.FILLED)
    _ALL_ORDER_STATUSES.append(ORDER_STATUS.REJECTED)
    _ALL_ORDER_STATUSES.append(ORDER_STATUS.PENDING_CANCEL)
    _ALL_ORDER_STATUSES.append(ORDER_STATUS.CANCELLED)

    _ORDER_STATUS_BY_NAME["PENDING_NEW"] = ORDER_STATUS.PENDING_NEW
    _ORDER_STATUS_BY_NAME["ACTIVE"] = ORDER_STATUS.ACTIVE
    _ORDER_STATUS_BY_NAME["FILLED"] = ORDER_STATUS.FILLED
    _ORDER_STATUS_BY_NAME["REJECTED"] = ORDER_STATUS.REJECTED
    _ORDER_STATUS_BY_NAME["PENDING_CANCEL"] = ORDER_STATUS.PENDING_CANCEL
    _ORDER_STATUS_BY_NAME["CANCELLED"] = ORDER_STATUS.CANCELLED

fn order_status_from_name(name: String) -> Optional[ORDER_STATUS]:
    return _ORDER_STATUS_BY_NAME.get(name)

fn order_status_from_value(value: String) -> Optional[ORDER_STATUS]:
    for v in reversed(_ALL_ORDER_STATUSES):
        if v.value() == value:
            return v
    return None


@fieldwise_init
struct SIDE(Equatable, ImplicitlyCopyable, Hashable, Writable, EnumTrait):
    var _name: String
    var _value: String

    comptime BUY = SIDE("BUY", "BUY")
    comptime SELL = SIDE("SELL", "SELL")
    comptime FINANCING = SIDE("FINANCING", "FINANCING")
    comptime MARGIN = SIDE("MARGIN", "MARGIN")
    comptime CONVERT_STOCK = SIDE("CONVERT_STOCK", "CONVERT_STOCK")

    fn name(self) -> String:
        return self._name

    fn value(self) -> String:
        return self._value

    fn write_to(self, mut writer: Some[Writer]):
        writer.write("SIDE.", self._name)

var _SIDE_BY_NAME = Dict[String, SIDE]()
var _ALL_SIDES = List[SIDE]()

fn _fill_side():
    _ALL_SIDES.append(SIDE.BUY)
    _ALL_SIDES.append(SIDE.SELL)
    _ALL_SIDES.append(SIDE.FINANCING)
    _ALL_SIDES.append(SIDE.MARGIN)
    _ALL_SIDES.append(SIDE.CONVERT_STOCK)

    _SIDE_BY_NAME["BUY"] = SIDE.BUY
    _SIDE_BY_NAME["SELL"] = SIDE.SELL
    _SIDE_BY_NAME["FINANCING"] = SIDE.FINANCING
    _SIDE_BY_NAME["MARGIN"] = SIDE.MARGIN
    _SIDE_BY_NAME["CONVERT_STOCK"] = SIDE.CONVERT_STOCK

fn side_from_name(name: String) -> Optional[SIDE]:
    return _SIDE_BY_NAME.get(name)

fn side_from_value(value: String) -> Optional[SIDE]:
    for v in reversed(_ALL_SIDES):
        if v.value() == value:
            return v
    return None


fn _fill_all():
    _fill_execution_phase()
    _fill_run_type()
    _fill_default_account_type()
    _fill_matching_type()
    _fill_order_type()
    _fill_order_status()
    _fill_side()


fn main():
    _fill_all()

    print("=== Testing EXECUTION_PHASE ===")
    print("GLOBAL.name():", EXECUTION_PHASE.GLOBAL.name())
    print("GLOBAL.value():", EXECUTION_PHASE.GLOBAL.value())

    var phase = execution_phase_from_name("ON_BAR")
    if phase:
        var p = phase.value()
        print("from_name('ON_BAR').value():", p.value())

    var phase2 = execution_phase_from_value("[全局]")
    if phase2:
        var p2 = phase2.value()
        print("from_value('[全局]').name():", p2.name())

    print("\n=== Testing RUN_TYPE ===")
    print("BACKTEST.name():", RUN_TYPE.BACKTEST.name())
    print("BACKTEST.value():", RUN_TYPE.BACKTEST.value())

    var rt = run_type_from_name("PAPER_TRADING")
    if rt:
        print("from_name('PAPER_TRADING').value():", rt.value().value())

    print("\n=== Testing ORDER_STATUS ===")
    print("FILLED.name():", ORDER_STATUS.FILLED.name())
    print("FILLED.value():", ORDER_STATUS.FILLED.value())

    print("\n=== Testing SIDE ===")
    print("BUY.name():", SIDE.BUY.name())
    print("BUY.value():", SIDE.BUY.value())

    print("\n=== All tests passed! ===")
