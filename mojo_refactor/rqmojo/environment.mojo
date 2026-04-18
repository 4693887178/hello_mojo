"""
RQAlpha Mojo - Environment
Ported from rqalpha/environment.py
"""

from std.collections import Dict, List, Set, Optional
from std.memory import UnsafePointer
from std.python import Python, PythonObject
from rqmojo.const import (
    RUN_TYPE, DEFAULT_ACCOUNT_TYPE, INSTRUMENT_TYPE, MARKET, SIDE, EXCHANGE,
    EXECUTION_PHASE, POSITION_DIRECTION, DAYS_CNT
)
from rqmojo.model.order import Order, OrderIdGenerator, create_order_id_generator
from rqmojo.core.events import EventBus, EVENT, Event
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.utils.typing import DateTime
from rqmojo.utils.config import RQAlphaConfig
from rqmojo.data.data_proxy import DataProxy, create_data_proxy, DividendInfo
from rqmojo.portfolio.account import Account, create_stock_account, create_future_account
from rqmojo.portfolio.position import Position
from rqmojo.portfolio.portfolio_manager import Portfolio as PortfolioManager
from rqmojo.core.broker import SimulationBroker, create_broker
from rqmojo.core.event_source import SimulationEventSource, create_event_source
from rqmojo.core.strategy_loader import StrategyLoader, create_strategy_loader, FileStrategyLoader, SourceCodeStrategyLoader, UserFuncStrategyLoader


@fieldwise_init
struct Config(Copyable, Movable, ImplicitlyCopyable):
    var base__start_date: DateTime
    var base__end_date: DateTime
    var base__frequency: String
    var base__run_type: RUN_TYPE
    var account_count: Int
    var is_hold: Bool
from rqmojo.core.global_var import GlobalVars, create_global_vars


@fieldwise_init
struct FrontendValidator(Writable, Copyable, Movable, ImplicitlyCopyable):
    var name: String
    var instrument_type: INSTRUMENT_TYPE

    def write_to(self, mut writer: Some[Writer]):
        writer.write("FrontendValidator(", self.name, ")")

    def can_submit_order(self, order: Order, account_info: String) -> Bool:
        return True

    def can_cancel_order(self, order: Order, account_info: String) -> Bool:
        return True

    def validate_submission(self, order: Order, account_info: String) -> String:
        return ""

    def validate_cancellation(self, order: Order, account_info: String) -> String:
        return ""


@fieldwise_init
struct TransactionCostDecider(Writable, Copyable, Movable, ImplicitlyCopyable):
    var name: String
    var instrument_type: INSTRUMENT_TYPE
    var market: MARKET

    def write_to(self, mut writer: Some[Writer]):
        writer.write("TransactionCostDecider(", self.name, ")")

    def calc(self, order: Order, quantity: Int, price: Float64) -> Float64:
        return price * Float64(quantity) * 0.0003


@fieldwise_init
struct PersistProvider(Writable, Copyable, Movable, ImplicitlyCopyable):
    var name: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("PersistProvider(", self.name, ")")


@fieldwise_init
struct PersistHelper(Writable, Copyable, Movable, ImplicitlyCopyable):
    var name: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("PersistHelper(", self.name, ")")


@fieldwise_init
struct TransactionCostArgs(Writable, Copyable, Movable, ImplicitlyCopyable):
    var order: Order
    var instrument: Instrument
    var quantity: Int
    var price: Float64

    def write_to(self, mut writer: Some[Writer]):
        writer.write("TransactionCostArgs(order=", self.order.order_book_id, ", quantity=", String(self.quantity), ")")


@fieldwise_init
struct Portfolio(ImplicitlyCopyable, Movable):
    var _stock_account: Account
    var _future_account: Account
    var total_value: Float64
    var total_cash: Float64
    var daily_pnl: Float64
    var units: Float64
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("Portfolio(value=", String(self.total_value), ", cash=", String(self.total_cash), ")")
    
    def get_account(self, order_book_id: String) -> Account:
        # 根据 order_book_id 判断账户类型
        if order_book_id.find(".XSHG") != -1 or order_book_id.find(".XSHE") != -1:
            return self._stock_account
        return self._future_account
    
    def get_account_by_type(self, account_type: DEFAULT_ACCOUNT_TYPE) -> Account:
        if account_type == DEFAULT_ACCOUNT_TYPE.STOCK:
            return self._stock_account
        return self._future_account
    
    def get_position(self, order_book_id: String) -> Position:
        return self._stock_account.get_position(order_book_id, POSITION_DIRECTION.LONG)
    
    def get_positions(self) -> List[Position]:
        var result = List[Position]()
        for pos in self._stock_account.get_positions():
            if pos.quantity > 0:
                result.append(pos)
        return result^
    
    def get_stock_position(self, order_book_id: String) -> Position:
        return self._stock_account.get_position(order_book_id, POSITION_DIRECTION.LONG)

    def get_future_position(self, order_book_id: String) -> Position:
        return self._future_account.get_position(order_book_id, POSITION_DIRECTION.LONG)

    def total_market_value(self) -> Float64:
        return self.total_value - self.total_cash

    def start_date(self) -> DateTime:
        return DateTime(1970, 1, 1, 0, 0, 0, 0)

    def annualized_returns(self) -> Float64:
        return 0.0

    def daily_returns(self) -> Float64:
        return 0.0

    def get_daily_pnl(self) -> Float64:
        return self.daily_pnl

    def total_returns(self) -> Float64:
        return 0.0

    def unit_net_value(self) -> Float64:
        if self.units > 0:
            return self.total_value / self.units
        return 1.0

    def static_unit_net_value(self) -> Float64:
        return self.unit_net_value()


def create_portfolio(total_value: Float64 = 100000.0) -> Portfolio:
    return Portfolio(
        _stock_account=create_stock_account(total_value),
        _future_account=create_future_account(0.0),
        total_value=total_value,
        total_cash=total_value,
        daily_pnl=0.0,
        units=1.0
    )


# ============================================================
# Environment - 核心环境类（单例模式）
# ============================================================

@fieldwise_init
struct Environment(Movable):
    var _start_date: DateTime
    var _end_date: DateTime
    var _frequency: String
    var _run_type: RUN_TYPE
    var _calendar_dt: DateTime
    var _trading_dt: DateTime
    var _is_initialized: Bool
    var _event_bus: EventBus
    var _listener_count: Int
    var _data_source_name: String
    var _broker_name: String
    var _portfolio_total_value: Float64
    var _portfolio_cash: Float64
    var _is_hold: Bool
    var global_vars: GlobalVars
    var persist_provider: PersistProvider
    var persist_helper: PersistHelper
    var _frontend_validators: Dict[String, List[FrontendValidator]]
    var _default_frontend_validators: List[FrontendValidator]
    var _transaction_cost_deciders: Dict[String, TransactionCostDecider]
    var _universe: Set[String]
    var _data_proxy: DataProxy
    var _order_id_generator: OrderIdGenerator
    var portfolio: Portfolio
    var _execution_phase: EXECUTION_PHASE
    var _trading_days_a_year: Optional[Int]
    var _broker: SimulationBroker
    
    # 新增组件引用
    var _event_source: SimulationEventSource
    var _strategy_loader: FileStrategyLoader
    var _user_strategy: String
    var _profile_deco: PythonObject
    var _mod_dict: Dict[String, String]
    var _rqdatac_init: Bool

    # ============================================================
    # 配置相关方法
    # ============================================================
    
    def config(self) -> Config:
        return Config(
            base__start_date=self._start_date,
            base__end_date=self._end_date,
            base__frequency=self._frequency,
            base__run_type=self._run_type,
            account_count=0,
            is_hold=self._is_hold
        )

    # ============================================================
    # 事件系统相关方法
    # ============================================================
    
    def get_event_bus(mut self) -> ref[self._event_bus] EventBus:
        return self._event_bus
    
    def add_listener(mut self, event_type: EVENT, listener: String, priority: Int = 0) -> None:
        self._listener_count += 1

    def publish_event(mut self, event: Event) -> None:
        _ = self._event_bus.publish_event(event)

    # ============================================================
    # 时间相关方法
    # ============================================================
    
    def calendar_dt(self) -> DateTime:
        return self._calendar_dt

    def trading_dt(self) -> DateTime:
        return self._trading_dt

    def set_calendar_dt(mut self, dt: DateTime) -> None:
        self._calendar_dt = dt

    def set_trading_dt(mut self, dt: DateTime) -> None:
        self._trading_dt = dt

    def update_time(mut self, calendar_dt: DateTime, trading_dt: DateTime) -> None:
        self._calendar_dt = calendar_dt
        self._trading_dt = trading_dt

    def start_date(self) -> DateTime:
        return self._start_date

    def end_date(self) -> DateTime:
        return self._end_date

    # ============================================================
    # 运行状态相关方法
    # ============================================================
    
    def is_initialized(self) -> Bool:
        return self._is_initialized

    def set_initialized(mut self, val: Bool) -> None:
        self._is_initialized = val

    def run_type(self) -> RUN_TYPE:
        return self._run_type

    def frequency(self) -> String:
        return self._frequency

    def execution_phase(self) -> EXECUTION_PHASE:
        return self._execution_phase

    def set_execution_phase(mut self, phase: EXECUTION_PHASE) -> None:
        self._execution_phase = phase

    # ============================================================
    # 数据访问相关方法
    # ============================================================
    
    def get_bar(self, order_book_id: String, calendar_dt: DateTime, frequency: String) -> Float64:
        # TODO: Implement get_bar using data_proxy
        return 10.0

    def get_last_price(self, order_book_id: String) -> Float64:
        return self._data_proxy.get_last_price(order_book_id)

    def get_instrument(self, order_book_id: String) -> Instrument:
        return self._data_proxy.get_instrument(order_book_id)

    def get_last_price_from_proxy(self, order_book_id: String) -> Float64:
        return self._data_proxy.get_last_price(order_book_id)

    def get_all_instruments_from_proxy(self, type: String = "") -> List[Instrument]:
        return self._data_proxy.get_all_instruments(type)
    
    def is_suspended_from_proxy(self, order_book_id: String, dt: DateTime) -> Bool:
        return self._data_proxy.is_suspended(order_book_id, dt)
    
    def get_previous_trading_date(self, dt: DateTime) -> DateTime:
        return self._data_proxy.get_previous_trading_date(dt)

    def get_previous_trading_date_from_proxy(self, dt: DateTime) -> DateTime:
        return self._data_proxy.get_previous_trading_date(dt)

    def get_dividend_from_proxy(self, ins: Instrument) -> Optional[DividendInfo]:
        return self._data_proxy.get_dividend(ins)

    # ============================================================
    # 订单相关方法
    # ============================================================
    
    def submit_order(mut self, order: Order) -> Optional[Order]:
        if self.can_submit_order(order):
            var account = self.get_account(order.order_book_id)
            self._broker.submit_order(order, account)
            return order
        return None

    def can_submit_order(mut self, order: Order) -> Bool:
        var instrument = self.get_instrument(order.order_book_id)
        var instrument_type = instrument.type()
        var account = self.portfolio.get_account(order.order_book_id)
        var validators = self._get_frontend_validators(instrument_type)
        for v in validators:
            var reason = v.validate_submission(order, account.__str__())
            if reason != "":
                self.order_creation_failed(order.order_book_id, reason)
                return False
        return True

    def can_cancel_order(mut self, order: Order) -> Bool:
        var instrument = self.get_instrument(order.order_book_id)
        var instrument_type = instrument.type()
        var account = self.portfolio.get_account(order.order_book_id)
        var validators = self._get_frontend_validators(instrument_type)
        for v in validators:
            var reason = v.validate_cancellation(order, account.__str__())
            if reason != "":
                self.order_cancellation_failed(order.order_book_id, reason)
                return False
        return True

    def order_creation_failed(mut self, order_book_id: String, reason: String) -> None:
        print("WARNING: Order creation failed for " + order_book_id + ": " + reason)
        var evt = EVENT.ORDER_CREATION_REJECT()
        var event = Event(evt.value)
        _ = self._event_bus.publish_event(event)

    def order_cancellation_failed(mut self, order_book_id: String, reason: String) -> None:
        print("WARNING: Order cancellation failed for " + order_book_id + ": " + reason)
        var evt = EVENT.ORDER_CANCELLATION_REJECT()
        var event = Event(evt.value)
        _ = self._event_bus.publish_event(event)

    def get_open_orders(self, order_book_id: String = "") -> List[Order]:
        if order_book_id == "":
            # TODO: Return all open orders from broker
            var orders = List[Order]()
            return orders^
        else:
            # TODO: Return specific order_book_id open orders from broker
            var orders = List[Order]()
            return orders^

    def next_order_id(mut self) -> Int:
        return self._order_id_generator.next()

    # ============================================================
    # 验证器相关方法
    # ============================================================
    
    def add_frontend_validator(mut self, validator: FrontendValidator, instrument_type: INSTRUMENT_TYPE = INSTRUMENT_TYPE.CS) raises -> None:
        var key = instrument_type.value
        try:
            self._frontend_validators[key].append(validator)
        except:
            self._frontend_validators[key] = List[FrontendValidator]()
            self._frontend_validators[key].append(validator)

    def add_default_frontend_validator(mut self, validator: FrontendValidator) -> None:
        self._default_frontend_validators.append(validator)

    def _get_frontend_validators(self, instrument_type: INSTRUMENT_TYPE) -> List[FrontendValidator]:
        var result = List[FrontendValidator]()
        var key = instrument_type.value
        try:
            for v in self._frontend_validators[key]:
                result.append(v)
        except:
            pass
        for v in self._default_frontend_validators:
            result.append(v)
        return result^

    # ============================================================
    # 交易成本相关方法
    # ============================================================
    
    def set_transaction_cost_decider(mut self, instrument_type: INSTRUMENT_TYPE, decider: TransactionCostDecider, market: MARKET = MARKET.CN) -> None:
        var key = instrument_type.value + "_" + market.value
        self._transaction_cost_deciders[key] = decider

    def get_transaction_cost_decider(self, instrument_type: INSTRUMENT_TYPE, market: MARKET = MARKET.CN) -> TransactionCostDecider:
        var key = instrument_type.value + "_" + market.value
        try:
            return self._transaction_cost_deciders[key]
        except:
            return TransactionCostDecider(name="default", instrument_type=instrument_type, market=market)

    def calc_transaction_cost(self, args: TransactionCostArgs) -> Float64:
        var instrument = args.instrument
        var decider = self.get_transaction_cost_decider(instrument.type(), MARKET.CN)
        return decider.calc(args.order, args.quantity, args.price)

    # ============================================================
    # 投资组合相关方法
    # ============================================================
    
    def get_account_type(self, order_book_id: String) -> DEFAULT_ACCOUNT_TYPE:
        return DEFAULT_ACCOUNT_TYPE.STOCK

    def get_account(self, order_book_id: String) -> Account:
        return self.portfolio.get_account(order_book_id)

    def get_account_by_type(self, account_type: DEFAULT_ACCOUNT_TYPE) -> Account:
        return self.portfolio.get_account_by_type(account_type)

    def get_stock_account(self) -> Account:
        return self.portfolio._stock_account

    def get_future_account(self) -> Account:
        return self.portfolio._future_account

    def get_portfolio(self) -> Portfolio:
        return self.portfolio

    def get_positions(self) -> List[Position]:
        return self.portfolio.get_positions()

    def get_position(self, order_book_id: String) -> Position:
        return self.portfolio.get_position(order_book_id)

    def set_portfolio(mut self, total_value: Float64, cash: Float64) -> None:
        self._portfolio_total_value = total_value
        self._portfolio_cash = cash

    def get_portfolio_total_value(self) -> Float64:
        return self._portfolio_total_value

    def get_portfolio_cash(self) -> Float64:
        return self._portfolio_cash

    # ============================================================
    # Universe 相关方法
    # ============================================================
    
    def get_universe(self) -> Set[String]:
        var result = Set[String]()
        for item in self._universe:
            result.add(item)
        return result^

    def update_universe(mut self, var universe: Set[String]) -> None:
        self._universe = Set[String]()
        for item in universe:
            self._universe.add(item)

    # ============================================================
    # 组件设置方法
    # ============================================================
    
    def set_data_source(mut self, name: String) -> None:
        self._data_source_name = name

    def set_data_proxy(mut self, var data_proxy: DataProxy) -> None:
        self._data_proxy = data_proxy^

    def set_broker(mut self, broker: SimulationBroker) -> None:
        self._broker_name = "simulation"
        self._broker = broker

    def set_event_source(mut self, event_source: SimulationEventSource) -> None:
        self._event_source = event_source

    def set_strategy_loader(mut self, loader: FileStrategyLoader) -> None:
        self._strategy_loader = loader

    def set_user_strategy(mut self, strategy: String) -> None:
        self._user_strategy = strategy

    def set_price_board(mut self, board: String) -> None:
        pass

    def set_persist_provider(mut self, provider: PersistProvider) -> None:
        self.persist_provider = provider

    def set_persist_helper(mut self, helper: PersistHelper) -> None:
        self.persist_helper = helper

    def set_profile_deco(mut self, deco: PythonObject) -> None:
        self._profile_deco = deco

    # ============================================================
    # 持仓策略相关方法
    # ============================================================
    
    def set_hold_strategy(mut self) -> None:
        self._is_hold = True
        var evt = EVENT.STRATEGY_HOLD_SET()
        var event = Event(evt.value)
        _ = self._event_bus.publish_event(event)

    def cancel_hold_strategy(mut self) -> None:
        self._is_hold = False
        var evt = EVENT.STRATEGY_HOLD_CANCELLED()
        var event = Event(evt.value)
        _ = self._event_bus.publish_event(event)

    # ============================================================
    # 组件访问方法
    # ============================================================
    
    def data_proxy(mut self) -> ref[self._data_proxy] DataProxy:
        return self._data_proxy
    
    def data_source(mut self) -> ref[self._data_proxy] DataProxy:
        return self._data_proxy
    
    def price_board(mut self) -> ref[self._data_proxy] DataProxy:
        return self._data_proxy
    
    def broker(self) -> SimulationBroker:
        return self._broker
    
    def event_source(self) -> SimulationEventSource:
        return self._event_source
    
    def strategy_loader(self) -> FileStrategyLoader:
        return self._strategy_loader
    
    def user_strategy(self) -> String:
        return self._user_strategy

    # ============================================================
    # 组件存在检查方法
    # ============================================================
    
    def has_data_source(self) -> Bool:
        return len(self._data_source_name) > 0
    
    def has_price_board(self) -> Bool:
        return True
    
    def has_broker(self) -> Bool:
        return len(self._broker_name) > 0
    
    def has_event_source(self) -> Bool:
        return len(self._event_source) > 0
    
    def has_portfolio(self) -> Bool:
        return self._portfolio_total_value > 0
    
    def has_profile_deco(self) -> Bool:
        return True

    # ============================================================
    # 其他方法
    # ============================================================
    
    def get_profile_output(self) -> String:
        return "Profile output"

    def clear_data_proxy_cache(mut self) -> None:
        pass

    def clear_data_source_cache(mut self) -> None:
        pass

    def get_trading_dates(self, start_date: DateTime, end_date: DateTime) -> List[DateTime]:
        # TODO: Implement proper trading dates calculation
        var result = List[DateTime]()
        var current = start_date
        while current.year < end_date.year or (current.year == end_date.year and current.month < end_date.month) or (current.year == end_date.year and current.month == end_date.month and current.day <= end_date.day):
            result.append(current)
            current = DateTime(current.year, current.month, current.day + 1, 0, 0, 0, 0)
        return result^

    def get_trading_days_a_year(self) -> Int:
        if self._trading_days_a_year is None:
            # Try to get custom trading days from config, fallback to default
            return DAYS_CNT.TRADING_DAYS_A_YEAR
        return self._trading_days_a_year.value()

    def current_snapshot(self, order_book_id: String) -> Dict[String, Float64]:
        var result = Dict[String, Float64]()
        var price = self.get_last_price(order_book_id)
        result["last"] = price
        return result^

    def history_bars(
        self,
        order_book_id: String,
        bar_count: Int,
        frequency: String,
        fields: String
    ) -> List[Dict[String, Float64]]:
        var result = List[Dict[String, Float64]]()
        return result^

    def get_yield_curve(self, start_date: DateTime, end_date: DateTime, tenor: String = "") -> Dict[String, Float64]:
        return Dict[String, Float64]()


# ============================================================
# 单例模式支持 - 更接近Python版本的实现
# 由于 Mojo 0.26.2 不支持真正的全局变量，使用函数级单例 + 可选参数模式
# ============================================================

@fieldwise_init
struct EnvironmentSingleton:
    """Environment singleton manager with get_instance support."""

    var _ptr: UnsafePointer[Environment, MutExternalOrigin]
    var _initialized: Bool

    def __init__(out self):
        self._ptr = UnsafePointer[Environment, MutExternalOrigin]()
        self._initialized = False

    def get_instance(self) raises -> ref[Self] Environment:
        if not self._initialized:
            raise Error("Environment has not been created. Please create Environment first.")
        return self._ptr[]

    def set_instance(mut self, env: Environment) -> None:
        self._ptr = UnsafePointer[Environment, MutExternalOrigin].allocate()
        self._ptr.store(env)
        self._initialized = True

    def clear_instance(mut self) -> None:
        if self._initialized:
            self._ptr.free()
        self._initialized = False
        self._ptr = UnsafePointer[Environment, MutExternalOrigin]()

    def has_instance(self) -> Bool:
        return self._initialized


from std.python import Python, PythonObject

var _global_env: PythonObject = Python.none()


def get_environment() raises -> Environment:
    """获取Environment实例，与Python版本的get_instance()类似"""
    if _global_env.is_none():
        raise Error("Environment has not been created. Please create Environment first.")
    raise Error("Use env parameter instead")


def set_environment(env: Environment) -> None:
    """设置Environment实例"""
    _ensure_singleton().set_instance(env)


def clear_environment() -> None:
    """清理Environment实例"""
    try:
        _ensure_singleton().clear_instance()
    except:
        pass


def has_environment() -> Bool:
    """检查Environment实例是否存在"""
    try:
        return _ensure_singleton().has_instance()
    except:
        return False


# ============================================================
# 工厂函数
# ============================================================

def create_environment_from_config(config: RQAlphaConfig, rqdatac_initialized: Bool = False) -> Environment:
    return Environment(
        _start_date=config.base.start_date,
        _end_date=config.base.end_date,
        _frequency=config.base.frequency,
        _run_type=config.base.run_type,
        _calendar_dt=config.base.start_date,
        _trading_dt=config.base.start_date,
        _is_initialized=False,
        _event_bus=EventBus(),
        _listener_count=0,
        _data_source_name="default",
        _broker_name="simulation",
        _portfolio_total_value=config.base.initial_cash,
        _portfolio_cash=config.base.initial_cash,
        _is_hold=False,
        global_vars=create_global_vars(),
        persist_provider=PersistProvider(name=""),
        persist_helper=PersistHelper(name=""),
        _frontend_validators=Dict[String, List[FrontendValidator]](),
        _default_frontend_validators=List[FrontendValidator](),
        _transaction_cost_deciders=Dict[String, TransactionCostDecider](),
        _universe=Set[String](),
        _data_proxy=create_data_proxy(),
        _order_id_generator=create_order_id_generator(),
        portfolio=create_portfolio(config.base.initial_cash),
        _execution_phase=EXECUTION_PHASE.GLOBAL,
        _trading_days_a_year=Optional[Int](None),
        _broker=create_broker(),
        _event_source=create_event_source(config.base.start_date, config.base.end_date, config.base.frequency),
        _strategy_loader=create_file_strategy_loader(config.base.strategy_file),
        _user_strategy="user_strategy",
        _profile_deco=PythonObject(),
        _mod_dict=Dict[String, String](),
        _rqdatac_init=rqdatac_initialized
    )


def create_environment(start_date: DateTime, end_date: DateTime, run_type: RUN_TYPE = RUN_TYPE.BACKTEST) -> Environment:
    return Environment(
        _start_date=start_date,
        _end_date=end_date,
        _frequency="1d",
        _run_type=run_type,
        _calendar_dt=start_date,
        _trading_dt=start_date,
        _is_initialized=False,
        _event_bus=EventBus(listeners=Dict[String, List[EventListener]](), user_listeners=Dict[String, List[EventListener]]()),
        _listener_count=0,
        _data_source_name="default",
        _broker_name="simulation",
        _portfolio_total_value=100000.0,
        _portfolio_cash=100000.0,
        _is_hold=False,
        global_vars=create_global_vars(),
        persist_provider=PersistProvider(name=""),
        persist_helper=PersistHelper(name=""),
        _frontend_validators=Dict[String, List[FrontendValidator]](),
        _default_frontend_validators=List[FrontendValidator](),
        _transaction_cost_deciders=Dict[String, TransactionCostDecider](),
        _universe=Set[String](),
        _data_proxy=create_data_proxy(),
        _order_id_generator=create_order_id_generator(),
        portfolio=create_portfolio(100000.0),
        _execution_phase=EXECUTION_PHASE.GLOBAL,
        _trading_days_a_year=Optional[Int](None),
        _broker=create_broker(),
        _event_source=create_event_source(start_date, end_date, "1d"),
        _strategy_loader=create_file_strategy_loader(""),
        _user_strategy="user_strategy",
        _profile_deco=PythonObject(),
        _mod_dict=Dict[String, String](),
        _rqdatac_init=False
    )
