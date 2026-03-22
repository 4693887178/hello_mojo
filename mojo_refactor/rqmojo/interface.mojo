"""
RQAlpha Mojo - Abstract Interfaces
Ported from rqalpha/interface.py
"""

from std.collections import Dict, List, Optional
from rqmojo.const import (
    INSTRUMENT_TYPE, SIDE, POSITION_EFFECT, ORDER_STATUS, EXCHANGE,
    POSITION_DIRECTION, EXIT_CODE, MARKET
)
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct ExchangeRate(Copyable, Movable, ImplicitlyCopyable):
    var bid_reference: Float64
    var ask_reference: Float64
    var bid_settlement_sh: Float64
    var ask_settlement_sh: Float64
    var bid_settlement_sz: Float64
    var ask_settlement_sz: Float64


@fieldwise_init
struct TransactionCostArgs(Movable):
    var instrument_order_book_id: String
    var price: Float64
    var quantity: Int
    var side: SIDE
    var position_effect: POSITION_EFFECT
    var order_id: Int
    var close_today_quantity: Int


@fieldwise_init
struct TransactionCost(Copyable, Movable, ImplicitlyCopyable):
    var commission: Float64
    var tax: Float64
    var other_fees: Float64

    fn total(self) -> Float64:
        return self.commission + self.tax + self.other_fees

    @staticmethod
    fn zero() -> TransactionCost:
        return TransactionCost(commission=0.0, tax=0.0, other_fees=0.0)


@fieldwise_init
struct FuturesTradingParameters(Copyable, Movable, ImplicitlyCopyable):
    var open_commission_ratio: Float64
    var close_commission_ratio: Float64
    var close_commission_ratio_today: Float64
    var margin_ratio: Float64


@fieldwise_init
struct Snapshot(Copyable, Movable, ImplicitlyCopyable):
    var order_book_id: String
    var datetime: DateTime
    var open: Float64
    var high: Float64
    var low: Float64
    var last: Float64
    var volume: Int
    var total_turnover: Float64
    var prev_close: Float64
    var limit_up: Float64
    var limit_down: Float64


trait Persistable:
    fn get_state(self) -> String:
        ...
    fn set_state(mut self, state: String):
        ...


trait PositionInterface(Persistable):
    fn order_book_id(self) -> String:
        ...
    fn quantity(self) -> Int:
        ...
    fn avg_price(self) -> Float64:
        ...
    fn market_value(self) -> Float64:
        ...
    fn pnl(self) -> Float64:
        ...
    fn direction(self) -> POSITION_DIRECTION:
        ...
    fn transaction_cost(self) -> Float64:
        ...
    fn position_pnl(self) -> Float64:
        ...
    fn trading_pnl(self) -> Float64:
        ...
    fn closable(self) -> Int:
        ...
    fn today_closable(self) -> Int:
        ...
    fn equity(self) -> Float64:
        ...
    fn prev_close(self) -> Float64:
        ...
    fn last_price(self) -> Float64:
        ...


trait StrategyLoader:
    fn load(mut self):
        ...
    fn init(mut self):
        ...
    fn handle_bar(mut self, bar: BarObject):
        ...
    fn handle_tick(mut self, tick: TickObject):
        ...
    fn before_trading(mut self):
        ...
    fn after_trading(mut self):
        ...


trait EventSource:
    fn events(mut self):
        ...
    fn start(mut self):
        ...
    fn stop(mut self):
        ...


trait PriceBoard:
    fn get_last_price(mut self, order_book_id: String) -> Float64:
        ...
    fn get_limit_up(mut self, order_book_id: String) -> Float64:
        ...
    fn get_limit_down(mut self, order_book_id: String) -> Float64:
        ...
    fn get_a1(mut self, order_book_id: String) -> Float64:
        ...
    fn get_b1(mut self, order_book_id: String) -> Float64:
        ...


trait DataSource:
    fn get_instrument_order_book_id(self, order_book_id: String) -> String:
        ...
    fn get_instrument_order_book_ids(
        self, id_or_syms: Optional[List[String]]
    ) -> List[String]:
        ...
    fn get_bar(self, order_book_id: String, dt: DateTime) -> BarObject:
        ...
    fn get_tick(self, order_book_id: String, dt: DateTime) -> TickObject:
        ...
    fn get_trading_dates(self, start_date: DateTime, end_date: DateTime) -> List[DateTime]:
        ...
    fn history_bars(
        self,
        order_book_id: String,
        bar_count: Int,
        frequency: String,
        fields: String,
        dt: DateTime,
        skip_suspended: Bool,
        include_now: Bool,
        adjust_type: String
    ) -> Optional[List[BarObject]]:
        ...
    fn history_ticks(self, order_book_id: String, count: Int, dt: DateTime) -> List[TickObject]:
        ...
    fn current_snapshot(self, order_book_id: String, frequency: String, dt: DateTime) -> Snapshot:
        ...
    fn available_data_range(self, frequency: String) -> Tuple[DateTime, DateTime]:
        ...
    fn is_suspended(self, order_book_id: String, dt: DateTime) -> Bool:
        ...
    fn is_st_stock(self, order_book_id: String, dt: DateTime) -> Bool:
        ...


trait Broker:
    fn submit_order(mut self, order: Order):
        ...
    fn cancel_order(mut self, order_id: Int):
        ...
    fn get_open_orders(self) -> List[Order]:
        ...


trait ModInterface:
    fn start_up(mut self, env_name: String, mod_config_name: String):
        ...
    fn tear_down(self, code: EXIT_CODE, exception_msg: Optional[String]):
        ...


trait PersistProviderInterface:
    fn store(mut self, key: String, value: String):
        ...
    fn load(self, key: String) -> Optional[String]:
        ...
    fn remove(mut self, key: String):
        ...
    fn should_resume(self) -> Bool:
        ...
    fn should_run_init(self) -> Bool:
        ...


trait FrontendValidatorInterface:
    fn validate_order(self, order: Order) -> Bool:
        ...
    fn can_submit_order(self, order: Order) -> Bool:
        ...
    fn can_cancel_order(self, order_id: Int) -> Bool:
        ...
    fn validate_submission(self, order: Order, account_name: String) -> Optional[String]:
        ...
    fn validate_cancellation(self, order: Order, account_name: String) -> Optional[String]:
        ...


trait TransactionCostDeciderInterface:
    fn get_transaction_cost(self, order: Order, trade: Trade) -> Float64:
        ...
    fn calc(self, args: TransactionCostArgs) -> TransactionCost:
        ...
