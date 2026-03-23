"""
RQAlpha Mojo - Environment
Ported from rqalpha/environment.py
"""

from std.collections import Dict, List, Set, Optional
from rqmojo.const import (
    RUN_TYPE, DEFAULT_ACCOUNT_TYPE, INSTRUMENT_TYPE, MARKET, SIDE, EXCHANGE,
    EXECUTION_PHASE
)
from rqmojo.core.events import EventBus, EVENT, Event, EventListener
from rqmojo.model.order import Order, OrderIdGenerator, create_order_id_generator
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.utils.typing import DateTime
from rqmojo.data.data_proxy import DataProxy, create_data_proxy, DividendInfo
from rqmojo.portfolio.account import Account, create_stock_account, create_future_account
from rqmojo.portfolio.position import Position
from rqmojo.portfolio.portfolio_manager import Portfolio as PortfolioManager


@fieldwise_init
struct Config(Copyable, Movable, ImplicitlyCopyable):
    var base__start_date: DateTime
    var base__end_date: DateTime
    var base__frequency: String
    var base__run_type: RUN_TYPE
    var account_count: Int
    var is_hold: Bool


@fieldwise_init
struct GlobalVars(Stringable, Movable, ImplicitlyCopyable):
    var data_string: String

    def __str__(self) -> String:
        return "GlobalVars(" + self.data_string + ")"

    def get(self, key: String, default: String = "") -> String:
        return default

    def set(mut self, key: String, value: String) -> None:
        pass

    def contains(self, key: String) -> Bool:
        return False


@fieldwise_init
struct FrontendValidator(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var name: String
    var instrument_type: INSTRUMENT_TYPE

    def __str__(self) -> String:
        return "FrontendValidator(" + self.name + ")"

    def can_submit_order(self, order: Order, account_info: String) -> Bool:
        return True

    def can_cancel_order(self, order: Order, account_info: String) -> Bool:
        return True

    def validate_submission(self, order: Order, account_info: String) -> String:
        return ""

    def validate_cancellation(self, order: Order, account_info: String) -> String:
        return ""


@fieldwise_init
struct TransactionCostDecider(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var name: String
    var instrument_type: INSTRUMENT_TYPE
    var market: MARKET

    def __str__(self) -> String:
        return "TransactionCostDecider(" + self.name + ")"

    def calc(self, order: Order, quantity: Int, price: Float64) -> Float64:
        return price * Float64(quantity) * 0.0003


@fieldwise_init
struct PersistProvider(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var name: String

    def __str__(self) -> String:
        return "PersistProvider(" + self.name + ")"


@fieldwise_init
struct PersistHelper(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var name: String

    def __str__(self) -> String:
        return "PersistHelper(" + self.name + ")"


@fieldwise_init
struct Portfolio(Movable):
    var _stock_account: Account
    var _future_account: Account
    var total_value: Float64
    var total_cash: Float64
    var daily_pnl: Float64
    var units: Float64
    
    def __str__(self) -> String:
        return "Portfolio(value=" + String(self.total_value) + ", cash=" + String(self.total_cash) + ")"
    
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
    var _broker: String

    def config(self) -> Config:
        return Config(
            base__start_date=self._start_date,
            base__end_date=self._end_date,
            base__frequency=self._frequency,
            base__run_type=self._run_type,
            account_count=0,
            is_hold=self._is_hold
        )

    def get_event_bus(mut self) -> EventBus:
        return self._event_bus^
    
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

    def is_initialized(self) -> Bool:
        return self._is_initialized

    def set_initialized(mut self, val: Bool) -> None:
        self._is_initialized = val

    def start_date(self) -> DateTime:
        return self._start_date

    def end_date(self) -> DateTime:
        return self._end_date

    def run_type(self) -> RUN_TYPE:
        return self._run_type

    def frequency(self) -> String:
        return self._frequency

    def execution_phase(self) -> EXECUTION_PHASE:
        return self._execution_phase

    def set_execution_phase(mut self, phase: EXECUTION_PHASE) -> None:
        self._execution_phase = phase

    def add_listener(mut self, event_type: EVENT, listener: String, priority: Int = 0) -> None:
        self._listener_count += 1

    def publish_event(mut self, event: Event) -> None:
        _ = self._event_bus.publish_event(event)

    def submit_order(mut self, order: Order) -> Order:
        return order

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

    def can_submit_order(mut self, order: Order) -> Bool:
        var instrument_type = INSTRUMENT_TYPE.CS
        var validators = self._get_frontend_validators(instrument_type)
        for v in validators:
            var reason = v.validate_submission(order, "")
            if reason != "":
                self.order_creation_failed(order.order_book_id, reason)
                return False
            if not v.can_submit_order(order, ""):
                return False
        return True

    def can_cancel_order(mut self, order: Order) -> Bool:
        var instrument_type = INSTRUMENT_TYPE.CS
        var validators = self._get_frontend_validators(instrument_type)
        for v in validators:
            var reason = v.validate_cancellation(order, "")
            if reason != "":
                self.order_cancellation_failed(order.order_book_id, reason)
                return False
            if not v.can_cancel_order(order, ""):
                return False
        return True

    def order_creation_failed(mut self, order_book_id: String, reason: String) -> None:
        var event = Event(EVENT.ORDER_CREATION_REJECT.value)
        _ = self._event_bus.publish_event(event)

    def order_cancellation_failed(mut self, order_book_id: String, reason: String) -> None:
        var event = Event(EVENT.ORDER_CANCELLATION_REJECT.value)
        _ = self._event_bus.publish_event(event)

    def get_last_price(self, order_book_id: String) -> Float64:
        return self._data_proxy.get_last_price(order_book_id)

    def get_bar(self, order_book_id: String) -> Float64:
        return 10.0

    def get_instrument(self, order_book_id: String) -> Instrument:
        return self._data_proxy.get_instrument(order_book_id)
    
    def get_last_price_from_proxy(self, order_book_id: String) -> Float64:
        return self._data_proxy.get_last_price(order_book_id)
    
    def get_all_instruments_from_proxy(self, type: String = "") -> List[Instrument]:
        return self._data_proxy.get_all_instruments(type)
    
    def is_suspended_from_proxy(self, order_book_id: String, dt: DateTime) -> Bool:
        return self._data_proxy.is_suspended(order_book_id, dt)
    
    def get_previous_trading_date_from_proxy(self, dt: DateTime) -> DateTime:
        return self._data_proxy.get_previous_trading_date(dt)
    
    def get_dividend_from_proxy(self, ins: Instrument) -> Optional[DividendInfo]:
        return self._data_proxy.get_dividend(ins)

    def get_account_type(self, order_book_id: String) -> DEFAULT_ACCOUNT_TYPE:
        return DEFAULT_ACCOUNT_TYPE.STOCK

    def get_open_orders(self) -> List[Order]:
        var orders = List[Order]()
        return orders^

    def set_transaction_cost_decider(mut self, instrument_type: INSTRUMENT_TYPE, decider: TransactionCostDecider, market: MARKET = MARKET.CN) -> None:
        var key = instrument_type.value + "_" + market.value
        self._transaction_cost_deciders[key] = decider

    def get_transaction_cost_decider(self, instrument_type: INSTRUMENT_TYPE, market: MARKET = MARKET.CN) -> TransactionCostDecider:
        var key = instrument_type.value + "_" + market.value
        try:
            return self._transaction_cost_deciders[key]
        except:
            return TransactionCostDecider(name="default", instrument_type=instrument_type, market=market)

    def calc_transaction_cost(self, order: Order, quantity: Int, price: Float64) -> Float64:
        var instrument = self.get_instrument(order.order_book_id)
        var decider = self.get_transaction_cost_decider(instrument.instrument_type, MARKET_CN)
        return decider.calc(order, quantity, price)

    def get_universe(self) -> Set[String]:
        var result = Set[String]()
        for item in self._universe:
            result.add(item)
        return result^

    def update_universe(mut self, var universe: Set[String]) -> None:
        self._universe = Set[String]()
        for item in universe:
            self._universe.add(item)

    def set_data_source(mut self, name: String) -> None:
        self._data_source_name = name

    def set_data_proxy(mut self, var data_proxy: DataProxy) -> None:
        self._data_proxy = data_proxy^

    def set_broker(mut self, name: String) -> None:
        self._broker_name = name
        self._broker = name

    def set_portfolio(mut self, total_value: Float64, cash: Float64) -> None:
        self._portfolio_total_value = total_value
        self._portfolio_cash = cash

    def get_portfolio_total_value(self) -> Float64:
        return self._portfolio_total_value

    def get_portfolio_cash(self) -> Float64:
        return self._portfolio_cash

    def set_persist_provider(mut self, provider: PersistProvider) -> None:
        self.persist_provider = provider

    def set_persist_helper(mut self, helper: PersistHelper) -> None:
        self.persist_helper = helper

    def set_hold_strategy(mut self) -> None:
        self._is_hold = True
        var event = Event(EVENT.STRATEGY_HOLD_SET.value)
        _ = self._event_bus.publish_event(event)

    def cancel_hold_strategy(mut self) -> None:
        self._is_hold = False
        var event = Event(EVENT.STRATEGY_HOLD_CANCELLED.value)
        _ = self._event_bus.publish_event(event)

    def next_order_id(mut self) -> Int:
        return self._order_id_generator.next()

    def get_stock_account(self) -> Account:
        return self._stock_account

    def get_future_account(self) -> Account:
        return self._future_account

    def get_account(self, account_type: DEFAULT_ACCOUNT_TYPE) -> Optional[Account]:
        if account_type == DEFAULT_ACCOUNT_TYPE.STOCK:
            return self._stock_account
        return None

    def get_portfolio(self) -> Portfolio:
        return self.portfolio

    def get_positions(self) -> List[Position]:
        return self.portfolio.get_positions()

    def get_position(self, order_book_id: String) -> Position:
        return self.portfolio.get_position(order_book_id)

    def current_snapshot(self, order_book_id: String) -> Dict[String, Float64]:
        var result = Dict[String, Float64]()
        var price = self.get_last_price(order_book_id)
        result["last"] = price
        return result

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
    
    def data_proxy(self) -> DataProxy:
        return self._data_proxy
    
    def data_source(self) -> DataProxy:
        return self._data_proxy
    
    def price_board(self) -> DataProxy:
        return self._data_proxy
    
    def has_data_source(self) -> Bool:
        return len(self._data_source_name) > 0
    
    def has_price_board(self) -> Bool:
        return True
    
    def has_broker(self) -> Bool:
        return len(self._broker_name) > 0
    
    def has_event_source(self) -> Bool:
        return True
    
    def has_portfolio(self) -> Bool:
        return self._portfolio_total_value > 0
    
    def set_strategy_loader(mut self, loader: String) -> None:
        pass
    
    def strategy_loader(self) -> String:
        return "file"
    
    def set_user_strategy(mut self, strategy: String) -> None:
        pass
    
    def user_strategy(self) -> String:
        return "user_strategy"
    
    def set_price_board(mut self, board: String) -> None:
        pass
    
    def set_profile_deco(mut self, deco: PythonObject) -> None:
        self._profile_deco = deco
    
    def has_profile_deco(self) -> Bool:
        return True
    
    def get_profile_output(self) -> String:
        return "Profile output"
    
    def clear_data_proxy_cache(mut self) -> None:
        pass
    
    def clear_data_source_cache(mut self) -> None:
        pass
    
    def get_trading_dates(self, start_date: DateTime, end_date: DateTime) -> List[DateTime]:
        var result = List[DateTime]()
        var current = start_date
        while current.year < end_date.year or (current.year == end_date.year and current.month < end_date.month) or (current.year == end_date.year and current.month == end_date.month and current.day <= end_date.day):
            result.append(current)
            current = DateTime(current.year, current.month, current.day + 1, 0, 0, 0, 0)
        return result^


def create_environment_from_config(config: RQAlphaConfig, rqdatac_initialized: Bool = False) -> Environment:
    return Environment(
        _start_date=config.base.start_date,
        _end_date=config.base.end_date,
        _frequency=config.base.frequency,
        _run_type=config.base.run_type,
        _calendar_dt=config.base.start_date,
        _trading_dt=config.base.start_date,
        _is_initialized=False,
        _event_bus=EventBus(listeners=Dict[String, List[EventListener]](), user_listeners=Dict[String, List[EventListener]]()),
        _listener_count=0,
        _data_source_name="default",
        _broker_name="simulation",
        _portfolio_total_value=config.base.initial_cash,
        _portfolio_cash=config.base.initial_cash,
        _is_hold=False,
        global_vars=GlobalVars(data_string=""),
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
        _broker="simulation"
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
        global_vars=GlobalVars(data_string=""),
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
        _broker="simulation"
    )
