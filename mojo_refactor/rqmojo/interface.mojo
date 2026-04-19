"""
RQAlpha Mojo - Abstract Interfaces
Ported from rqalpha/interface.py
"""

from std.collections import Dict, List, Optional
from std.python import Python, PythonObject
from rqmojo.const import (
    INSTRUMENT_TYPE, SIDE, POSITION_EFFECT, ORDER_STATUS, EXCHANGE,
    POSITION_DIRECTION, EXIT_CODE, MARKET
)
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.portfolio.account import Account
from rqmojo.utils.typing import DateTime


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

    def total(self) -> Float64:
        return self.commission + self.tax + self.other_fees

    @staticmethod
    def zero() -> TransactionCost:
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
    def get_state(self) -> String:
        ...
    def set_state(mut self, state: String):
        ...


trait PositionInterface(Persistable):
    def order_book_id(self) -> String:
        ...
    def quantity(self) -> Int:
        ...
    def avg_price(self) -> Float64:
        ...
    def market_value(self) -> Float64:
        ...
    def pnl(self) -> Float64:
        ...
    def direction(self) -> POSITION_DIRECTION:
        ...
    def transaction_cost(self) -> Float64:
        ...
    def position_pnl(self) -> Float64:
        ...
    def trading_pnl(self) -> Float64:
        ...
    def closable(self) -> Int:
        ...
    def today_closable(self) -> Int:
        ...
    def equity(self) -> Float64:
        ...
    def prev_close(self) -> Float64:
        ...
    def last_price(self) -> Float64:
        ...


trait StrategyLoader:
    def load(mut self, scope: PythonObject) raises -> PythonObject:
        ...


trait EventSource:
    def events(mut self):
        ...
    def start(mut self):
        ...
    def stop(mut self):
        ...


trait PriceBoard:
    def get_last_price(mut self, order_book_id: String) -> Float64:
        ...
    def get_limit_up(mut self, order_book_id: String) -> Float64:
        ...
    def get_limit_down(mut self, order_book_id: String) -> Float64:
        ...
    def get_a1(mut self, order_book_id: String) -> Float64:
        ...
    def get_b1(mut self, order_book_id: String) -> Float64:
        ...


trait DataSource:
    def get_instrument_order_book_id(self, order_book_id: String) -> String:
        ...
    def get_instrument_order_book_ids(
        self, id_or_syms: Optional[List[String]]
    ) -> List[String]:
        ...
    def get_bar(self, order_book_id: String, dt: DateTime) -> BarObject:
        ...
    def get_tick(self, order_book_id: String, dt: DateTime) -> TickObject:
        ...
    def get_trading_dates(self, start_date: DateTime, end_date: DateTime) -> List[DateTime]:
        ...
    def history_bars(
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
    def history_ticks(self, order_book_id: String, count: Int, dt: DateTime) -> List[TickObject]:
        ...
    def current_snapshot(self, order_book_id: String, frequency: String, dt: DateTime) -> Snapshot:
        ...
    def available_data_range(self, frequency: String) -> Tuple[DateTime, DateTime]:
        ...
    def is_suspended(self, order_book_id: String, dt: DateTime) -> Bool:
        ...
    def is_st_stock(self, order_book_id: String, dt: DateTime) -> Bool:
        ...


trait Broker:
    def submit_order(mut self, mut order: Order, mut account: Account):
        ...
    def cancel_order(mut self, order_id: Int):
        ...
    def get_open_orders(self) -> List[Order]:
        ...


trait ModInterface:
    def start_up(mut self, env_name: String, mod_config_name: String):
        ...
    def tear_down(mut self, code: EXIT_CODE, exception_msg: Optional[String]):
        ...


comptime Mod = ModInterface


trait PersistProviderInterface:
    def store(mut self, key: String, value: String):
        ...
    def load(self, key: String) -> Optional[String]:
        ...
    def remove(mut self, key: String):
        ...
    def should_resume(self) -> Bool:
        ...
    def should_run_init(self) -> Bool:
        ...


trait FrontendValidatorInterface:
    def validate_order(self, order: Order) -> Bool:
        ...
    def can_submit_order(self, order: Order) -> Bool:
        ...
    def can_cancel_order(self, order_id: Int) -> Bool:
        ...
    def validate_submission(self, order: Order, account: Optional[Account]) -> Optional[String]:
        ...
    def validate_cancellation(self, order: Order, account: Optional[Account]) -> Optional[String]:
        ...


trait TransactionCostDeciderInterface:
    def get_transaction_cost(self, order: Order, trade: Trade) -> Float64:
        ...
    def calc(self, args: TransactionCostArgs) -> TransactionCost:
        ...
