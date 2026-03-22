"""
RQAlpha Mojo - Environment
Ported from rqalpha/environment.py
"""

from collections import Dict, List, Set, Optional
from rqmojo.const import (
    RUN_TYPE, DEFAULT_ACCOUNT_TYPE, INSTRUMENT_TYPE, MARKET, SIDE, EXCHANGE,
    RUN_TYPE_BACKTEST, DEFAULT_ACCOUNT_TYPE_STOCK, INSTRUMENT_TYPE_CS, MARKET_CN,
    POSITION_DIRECTION_LONG, EXECUTION_PHASE
)
from rqmojo.core.events import EventBus, EVENT, Event, EventListener
from rqmojo.model.order import Order, OrderIdGenerator, create_order_id_generator
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.utils.datetime_func import DateTime
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

    fn __str__(self) -> String:
        return "GlobalVars(" + self.data_string + ")"

    fn get(self, key: String, default: String = "") -> String:
        return default

    fn set(mut self, key: String, value: String) -> None:
        pass

    fn contains(self, key: String) -> Bool:
        return False


@fieldwise_init
struct FrontendValidator(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var name: String
    var instrument_type: INSTRUMENT_TYPE

    fn __str__(self) -> String:
        return "FrontendValidator(" + self.name + ")"

    fn can_submit_order(self, order: Order, account_info: String) -> Bool:
        return True

    fn can_cancel_order(self, order: Order, account_info: String) -> Bool:
        return True

    fn validate_submission(self, order: Order, account_info: String) -> String:
        return ""

    fn validate_cancellation(self, order: Order, account_info: String) -> String:
        return ""


@fieldwise_init
struct TransactionCostDecider(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var name: String
    var instrument_type: INSTRUMENT_TYPE
    var market: MARKET

    fn __str__(self) -> String:
        return "TransactionCostDecider(" + self.name + ")"

    fn calc(self, order: Order, quantity: Int, price: Float64) -> Float64:
        return price * Float64(quantity) * 0.0003


@fieldwise_init
struct PersistProvider(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var name: String

    fn __str__(self) -> String:
        return "PersistProvider(" + self.name + ")"


@fieldwise_init
struct PersistHelper(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var name: String

    fn __str__(self) -> String:
        return "PersistHelper(" + self.name + ")"


@fieldwise_init
struct Portfolio(Movable):
    var _stock_account: Account
    var _future_account: Account
    var total_value: Float64
    var total_cash: Float64
    var daily_pnl: Float64
    var units: Float64
    
    fn __str__(self) -> String:
        return "Portfolio(value=" + String(self.total_value) + ", cash=" + String(self.total_cash) + ")"
    
    fn get_position(self, order_book_id: String) -> Position:
        return self._stock_account.get_position(order_book_id, POSITION_DIRECTION_LONG)
    
    fn get_positions(self) -> List[Position]:
        var result = List[Position]()
        for pos in self._stock_account.get_positions():
            if pos.quantity > 0:
                result.append(pos)
        return result^
    
    fn get_stock_position(self, order_book_id: String) -> Position:
        return self._stock_account.get_position(order_book_id, POSITION_DIRECTION_LONG)

    fn get_future_position(self, order_book_id: String) -> Position:
        return self._future_account.get_position(order_book_id, POSITION_DIRECTION_LONG)

    fn total_market_value(self) -> Float64:
        return self.total_value - self.total_cash

    fn start_date(self) -> DateTime:
        return DateTime(1970, 1, 1, 0, 0, 0, 0)

    fn annualized_returns(self) -> Float64:
        return 0.0

    fn daily_returns(self) -> Float64:
        return 0.0

    fn get_daily_pnl(self) -> Float64:
        return self.daily_pnl

    fn total_returns(self) -> Float64:
        return 0.0

    fn unit_net_value(self) -> Float64:
        if self.units > 0:
            return self.total_value / self.units
        return 1.0

    fn static_unit_net_value(self) -> Float64:
        return self.unit_net_value()


fn create_portfolio(total_value: Float64 = 100000.0) -> Portfolio:
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

    fn config(self) -> Config:
        return Config(
            base__start_date=self._start_date,
            base__end_date=self._end_date,
            base__frequency=self._frequency,
            base__run_type=self._run_type,
            account_count=0,
            is_hold=self._is_hold
        )

    fn get_event_bus[origin: Origin](ref[origin] self) -> ref[origin] EventBus:
        return self._event_bus

    fn calendar_dt(self) -> DateTime:
        return self._calendar_dt

    fn trading_dt(self) -> DateTime:
        return self._trading_dt

    fn set_calendar_dt(mut self, dt: DateTime) -> None:
        self._calendar_dt = dt

    fn set_trading_dt(mut self, dt: DateTime) -> None:
        self._trading_dt = dt

    fn update_time(mut self, calendar_dt: DateTime, trading_dt: DateTime) -> None:
        self._calendar_dt = calendar_dt
        self._trading_dt = trading_dt

    fn is_initialized(self) -> Bool:
        return self._is_initialized

    fn set_initialized(mut self, val: Bool) -> None:
        self._is_initialized = val

    fn start_date(self) -> DateTime:
        return self._start_date

    fn end_date(self) -> DateTime:
        return self._end_date

    fn run_type(self) -> RUN_TYPE:
        return self._run_type

    fn frequency(self) -> String:
        return self._frequency

    fn execution_phase(self) -> EXECUTION_PHASE:
        return self._execution_phase

    fn set_execution_phase(mut self, phase: EXECUTION_PHASE) -> None:
        self._execution_phase = phase

    fn add_listener(mut self, event_type: EVENT, listener: String, priority: Int = 0) -> None:
        self._listener_count += 1

    fn publish_event(mut self, event: Event) -> None:
        _ = self._event_bus.publish_event(event)

    fn submit_order(mut self, order: Order) -> Order:
        return order

    fn add_frontend_validator(mut self, validator: FrontendValidator, instrument_type: INSTRUMENT_TYPE = INSTRUMENT_TYPE_CS) raises -> None:
        var key = instrument_type.value
        try:
            self._frontend_validators[key].append(validator)
        except:
            self._frontend_validators[key] = List[FrontendValidator]()
            self._frontend_validators[key].append(validator)

    fn add_default_frontend_validator(mut self, validator: FrontendValidator) -> None:
        self._default_frontend_validators.append(validator)

    fn _get_frontend_validators(self, instrument_type: INSTRUMENT_TYPE) -> List[FrontendValidator]:
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

    fn can_submit_order(mut self, order: Order) -> Bool:
        var instrument_type = INSTRUMENT_TYPE_CS
        var validators = self._get_frontend_validators(instrument_type)
        for v in validators:
            var reason = v.validate_submission(order, "")
            if reason != "":
                self.order_creation_failed(order.order_book_id, reason)
                return False
            if not v.can_submit_order(order, ""):
                return False
        return True

    fn can_cancel_order(mut self, order: Order) -> Bool:
        var instrument_type = INSTRUMENT_TYPE_CS
        var validators = self._get_frontend_validators(instrument_type)
        for v in validators:
            var reason = v.validate_cancellation(order, "")
            if reason != "":
                self.order_cancellation_failed(order.order_book_id, reason)
                return False
            if not v.can_cancel_order(order, ""):
                return False
        return True

    fn order_creation_failed(mut self, order_book_id: String, reason: String) -> None:
        var event = Event(EVENT.ORDER_CREATION_REJECT.value)
        _ = self._event_bus.publish_event(event)

    fn order_cancellation_failed(mut self, order_book_id: String, reason: String) -> None:
        var event = Event(EVENT.ORDER_CANCELLATION_REJECT.value)
        _ = self._event_bus.publish_event(event)

    fn get_last_price(self, order_book_id: String) -> Float64:
        return self._data_proxy.get_last_price(order_book_id)

    fn get_bar(self, order_book_id: String) -> Float64:
        return 10.0

    fn get_instrument(self, order_book_id: String) -> Instrument:
        return self._data_proxy.get_instrument(order_book_id)
    
    fn get_last_price_from_proxy(self, order_book_id: String) -> Float64:
        return self._data_proxy.get_last_price(order_book_id)
    
    fn get_all_instruments_from_proxy(self, type: String = "") -> List[Instrument]:
        return self._data_proxy.get_all_instruments(type)
    
    fn is_suspended_from_proxy(self, order_book_id: String, dt: DateTime) -> Bool:
        return self._data_proxy.is_suspended(order_book_id, dt)
    
    fn get_previous_trading_date_from_proxy(self, dt: DateTime) -> DateTime:
        return self._data_proxy.get_previous_trading_date(dt)
    
    fn get_dividend_from_proxy(self, ins: Instrument) -> Optional[DividendInfo]:
        return self._data_proxy.get_dividend(ins)

    fn get_account_type(self, order_book_id: String) -> DEFAULT_ACCOUNT_TYPE:
        return DEFAULT_ACCOUNT_TYPE_STOCK

    fn get_open_orders(self) -> List[Order]:
        var orders = List[Order]()
        return orders^

    fn set_transaction_cost_decider(mut self, instrument_type: INSTRUMENT_TYPE, decider: TransactionCostDecider, market: MARKET = MARKET_CN) -> None:
        var key = instrument_type.value + "_" + market.value
        self._transaction_cost_deciders[key] = decider

    fn get_transaction_cost_decider(self, instrument_type: INSTRUMENT_TYPE, market: MARKET = MARKET_CN) -> TransactionCostDecider:
        var key = instrument_type.value + "_" + market.value
        try:
            return self._transaction_cost_deciders[key]
        except:
            return TransactionCostDecider(name="default", instrument_type=instrument_type, market=market)

    fn calc_transaction_cost(self, order: Order, quantity: Int, price: Float64) -> Float64:
        var instrument = self.get_instrument(order.order_book_id)
        var decider = self.get_transaction_cost_decider(instrument.instrument_type, MARKET_CN)
        return decider.calc(order, quantity, price)

    fn get_universe(self) -> Set[String]:
        var result = Set[String]()
        for item in self._universe:
            result.add(item)
        return result^

    fn update_universe(mut self, var universe: Set[String]) -> None:
        self._universe = Set[String]()
        for item in universe:
            self._universe.add(item)

    fn set_data_source(mut self, name: String) -> None:
        self._data_source_name = name

    fn set_data_proxy(mut self, var data_proxy: DataProxy) -> None:
        self._data_proxy = data_proxy^

    fn set_broker(mut self, name: String) -> None:
        self._broker_name = name
        self._broker = name

    fn set_portfolio(mut self, total_value: Float64, cash: Float64) -> None:
        self._portfolio_total_value = total_value
        self._portfolio_cash = cash

    fn get_portfolio_total_value(self) -> Float64:
        return self._portfolio_total_value

    fn get_portfolio_cash(self) -> Float64:
        return self._portfolio_cash

    fn set_persist_provider(mut self, provider: PersistProvider) -> None:
        self.persist_provider = provider

    fn set_persist_helper(mut self, helper: PersistHelper) -> None:
        self.persist_helper = helper

    fn set_hold_strategy(mut self) -> None:
        self._is_hold = True
        var event = Event(EVENT.STRATEGY_HOLD_SET.value)
        _ = self._event_bus.publish_event(event)

    fn cancel_hold_strategy(mut self) -> None:
        self._is_hold = False
        var event = Event(EVENT.STRATEGY_HOLD_CANCELLED.value)
        _ = self._event_bus.publish_event(event)

    fn next_order_id(mut self) -> Int:
        return self._order_id_generator.next()

    fn get_stock_account(self) -> Account:
        return self._stock_account

    fn get_future_account(self) -> Account:
        return self._future_account

    fn get_account(self, account_type: DEFAULT_ACCOUNT_TYPE) -> Optional[Account]:
        if account_type == DEFAULT_ACCOUNT_TYPE_STOCK:
            return self._stock_account
        return None

    fn get_portfolio(self) -> Portfolio:
        return self.portfolio

    fn get_positions(self) -> List[Position]:
        return self.portfolio.get_positions()

    fn get_position(self, order_book_id: String) -> Position:
        return self.portfolio.get_position(order_book_id)

    fn current_snapshot(self, order_book_id: String) -> Dict[String, Float64]:
        var result = Dict[String, Float64]()
        var price = self.get_last_price(order_book_id)
        result["last"] = price
        return result

    fn history_bars(
        self,
        order_book_id: String,
        bar_count: Int,
        frequency: String,
        fields: String
    ) -> List[Dict[String, Float64]]:
        var result = List[Dict[String, Float64]]()
        return result^

    fn get_yield_curve(self, start_date: DateTime, end_date: DateTime, tenor: String = "") -> Dict[String, Float64]:
        return Dict[String, Float64]()


fn create_environment(start_date: DateTime, end_date: DateTime, run_type: RUN_TYPE = RUN_TYPE_BACKTEST) -> Environment:
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
        _execution_phase=EXECUTION_PHASE.GLOBAL(),
        _broker="simulation"
    )
