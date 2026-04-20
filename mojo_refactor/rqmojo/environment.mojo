"""
RQAlpha Mojo - Environment
Ported from rqalpha/environment.py
"""

from std.collections import Dict, List, Set, Optional
from std.python import Python, PythonObject
from rqmojo.const import (
    RUN_TYPE, DEFAULT_ACCOUNT_TYPE, INSTRUMENT_TYPE, MARKET, SIDE, EXCHANGE,
    EXECUTION_PHASE, POSITION_DIRECTION, DAYS_CNT
)
from rqmojo.model.order import Order, OrderIdGenerator, create_order_id_generator
from rqmojo.core.events import EventBus, EVENT, Event, EventListener
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.utils.typing import DateTime
from rqmojo.utils.config import RQAlphaConfig
from rqmojo.data.data_proxy import DataProxy, create_data_proxy, DividendInfo
from rqmojo.portfolio.account import Account, create_stock_account, create_future_account
from rqmojo.portfolio.position import Position
from rqmojo.portfolio.portfolio_manager import Portfolio as PortfolioManager
from rqmojo.core.broker import SimulationBroker, create_broker
from rqmojo.core.event_source import SimulationEventSource, create_event_source
from rqmojo.core.strategy_loader import StrategyLoader, FileStrategyLoader, SourceCodeStrategyLoader, UserFuncStrategyLoader, create_file_strategy_loader


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

    def can_submit_order(self, order: Order, account: Optional[Account]) -> Bool:
        return True

    def can_cancel_order(self, order: Order, account: Optional[Account]) -> Bool:
        return True

    def validate_submission(self, order: Order, account: Optional[Account]) -> Optional[String]:
        return Optional[String](None)

    def validate_cancellation(self, order: Order, account: Optional[Account]) -> Optional[String]:
        return Optional[String](None)


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
struct TransactionCostArgs(Writable, Copyable, Movable):
    var order: Order
    var instrument: Instrument
    var quantity: Int
    var price: Float64

    def write_to(self, mut writer: Some[Writer]):
        writer.write("TransactionCostArgs(order=", self.order.order_book_id, ", quantity=", String(self.quantity), ")")


@fieldwise_init
struct EnvPortfolio(ImplicitlyCopyable, Movable):
    var _stock_account: Account
    var _future_account: Account
    var total_value: Float64
    var total_cash: Float64
    var daily_pnl: Float64
    var units: Float64
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("EnvPortfolio(value=", String(self.total_value), ", cash=", String(self.total_cash), ")")
    
    def get_account(self, order_book_id: String) -> Account:
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


def create_env_portfolio(total_value: Float64 = 100000.0) -> EnvPortfolio:
    return EnvPortfolio(
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
    var portfolio: EnvPortfolio
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

    def publish_event(mut self, event: Event) raises -> None:
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

    def get_instrument(self, order_book_id: String) raises -> Instrument:
        return self._data_proxy.get_instrument(order_book_id)

    def get_last_price_from_proxy(self, order_book_id: String) -> Float64:
        return self._data_proxy.get_last_price(order_book_id)

    def get_all_instruments_from_proxy(self, type: String = "") raises -> List[Instrument]:
        return self._data_proxy.get_all_instruments(type)
    
    def is_suspended_from_proxy(self, order_book_id: String, dt: DateTime) raises -> Bool:
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
    
    def submit_order(mut self, mut order: Order) raises -> Optional[Order]:
        if self.can_submit_order(order):
            var account = self.get_account(order.order_book_id)
            self._broker.set_account(account)
            self._broker.submit_order(order)
            return order.copy()
        return None

    def can_submit_order(mut self, order: Order) raises -> Bool:
        var instrument = self.get_instrument(order.order_book_id)
        var instrument_type = instrument.type()
        var account = self.portfolio.get_account(order.order_book_id)
        var validators = self._get_frontend_validators(instrument_type)
        for v in validators:
            var result = v.validate_submission(order, Optional[Account](account))
            if result is not None and result.value() != "":
                self.order_creation_failed(order.order_book_id, result.value())
                return False
        return True

    def can_cancel_order(mut self, order: Order) raises -> Bool:
        var instrument = self.get_instrument(order.order_book_id)
        var instrument_type = instrument.type()
        var account = self.portfolio.get_account(order.order_book_id)
        var validators = self._get_frontend_validators(instrument_type)
        for v in validators:
            var result = v.validate_cancellation(order, Optional[Account](account))
            if result is not None and result.value() != "":
                self.order_cancellation_failed(order.order_book_id, result.value())
                return False
        return True

    def order_creation_failed(mut self, order_book_id: String, reason: String) raises -> None:
        print("WARNING: Order creation failed for " + order_book_id + ": " + reason)
        var evt = EVENT.ORDER_CREATION_REJECT
        var event = Event(evt.value)
        _ = self._event_bus.publish_event(event)

    def order_cancellation_failed(mut self, order_book_id: String, reason: String) raises -> None:
        print("WARNING: Order cancellation failed for " + order_book_id + ": " + reason)
        var event = Event(EVENT.ORDER_CANCELLATION_REJECT.value)
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

    def get_portfolio(self) -> EnvPortfolio:
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

    def set_broker(mut self, var broker: SimulationBroker) -> None:
        self._broker_name = "simulation"
        self._broker = broker^

    def set_event_source(mut self, var event_source: SimulationEventSource) -> None:
        self._event_source = event_source^

    def set_strategy_loader(mut self, var loader: FileStrategyLoader) -> None:
        self._strategy_loader = loader^

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
    
    def set_hold_strategy(mut self) raises -> None:
        self._is_hold = True
        var event = Event(EVENT.STRATEGY_HOLD_SET.value)
        _ = self._event_bus.publish_event(event)

    def cancel_hold_strategy(mut self) raises -> None:
        self._is_hold = False
        var event = Event(EVENT.STRATEGY_HOLD_CANCELLED.value)
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
        return self._event_source._start_date.year > 1970
    
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
# Single instance support via Python object backend.
# Mojo 0.26.2 does not support module-level global variables,
# so we use Python's evaluate() as a global state store,
# matching Python's class-level _env pattern.
# ============================================================


def _get_env_store() raises -> PythonObject:
    """Get or create the environment storage dict via Python."""
    var store = Python.evaluate("_env_store", file=True)
    if Bool(py=store is None):
        store = Python.evaluate("_env_store = {}", file=True)
    return store


def get_environment() raises -> PythonObject:
    """Get the Environment instance, equivalent to Python's Environment.get_instance()."""
    var store = _get_env_store()
    var py_env = store.get("_env", Python.none())
    if Bool(py=py_env is None):
        raise Error("Environment has not been created. Please create Environment first.")
    return py_env


def set_environment(var env: Environment) raises -> None:
    """Set the Environment instance as the global singleton."""
    var store = _get_env_store()
    store["_env"] = PythonObject(alloc=env^)


def clear_environment() raises -> None:
    """Clear the Environment singleton."""
    var store = _get_env_store()
    if Bool(py="_env" in store):
        _ = store.pop("_env", Python.none())


def has_environment() raises -> Bool:
    """Check whether an Environment instance exists."""
    var store = _get_env_store()
    return Bool(py="_env" in store)


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
        portfolio=create_env_portfolio(config.base.initial_cash),
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
        _event_bus=EventBus(),
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
        portfolio=create_env_portfolio(100000.0),
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
