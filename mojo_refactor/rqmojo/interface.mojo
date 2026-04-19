"""
RQAlpha Mojo - Abstract Interfaces
Ported from rqalpha/interface.py
Complete implementation matching Python original
"""

from std.collections import Dict, List, Optional
from std.python import Python, PythonObject
from rqmojo.const import (
    INSTRUMENT_TYPE, SIDE, POSITION_EFFECT, ORDER_STATUS, EXCHANGE,
    POSITION_DIRECTION, EXIT_CODE, MARKET, TRADING_CALENDAR_TYPE
)
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.model.instrument import Instrument
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
    var order_id: Optional[Int]
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
    def get_state(self) -> PythonObject:
        ...
    def set_state(mut self, state: PythonObject):
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
    def events(mut self, start_date: DateTime, end_date: DateTime, frequency: String):
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
    def get_instruments(
        self,
        id_or_syms: Optional[List[String]] = None,
        types: Optional[List[INSTRUMENT_TYPE]] = None
    ) -> List[Instrument]:
        ...

    def get_trading_calendars(self) -> Dict[TRADING_CALENDAR_TYPE, PythonObject]:
        ...

    def get_yield_curve(
        self,
        start_date: DateTime,
        end_date: DateTime,
        tenor: Optional[String] = None
    ) -> PythonObject:
        ...

    def get_dividend(self, instrument: Instrument) -> Optional[PythonObject]:
        ...

    def get_split(self, instrument: Instrument) -> Optional[PythonObject]:
        ...

    def get_bar(
        self,
        order_book_id: String,
        dt: DateTime,
        frequency: String
    ) -> PythonObject:
        ...

    def get_open_auction_bar(self, instrument: Instrument, dt: DateTime) -> Dict[String, PythonObject]:
        ...

    def get_open_auction_volume(self, instrument: Instrument, dt: DateTime) -> Float64:
        ...

    def get_settle_price(self, instrument: Instrument, date: DateTime) -> String:
        ...

    def history_bars(
        self,
        order_book_id: String,
        bar_count: Optional[Int],
        frequency: String,
        fields: String,
        dt: DateTime,
        skip_suspended: Bool = True,
        include_now: Bool = False,
        adjust_type: String = 'pre',
        adjust_orig: Optional[DateTime] = None
    ) -> Optional[PythonObject]:
        ...

    def history_ticks(
        self,
        order_book_id: String,
        count: Int,
        dt: DateTime
    ) -> List[TickObject]:
        ...

    def current_snapshot(
        self,
        instrument: Instrument,
        frequency: String,
        dt: DateTime
    ) -> Snapshot:
        ...

    def get_trading_minutes_for(
        self,
        instrument: Instrument,
        trading_dt: DateTime
    ) -> List[DateTime]:
        ...

    def available_data_range(self, frequency: String) -> Tuple[DateTime, DateTime]:
        ...

    def get_futures_trading_parameters(
        self,
        instrument: Instrument,
        dt: DateTime
    ) -> FuturesTradingParameters:
        ...

    def get_merge_ticks(
        self,
        order_book_id_list: List[String],
        trading_date: DateTime,
        last_dt: Optional[DateTime] = None
    ) -> PythonObject:
        ...

    def get_share_transformation(self, order_book_id: String) -> Tuple[String, Float64]:
        ...

    def is_suspended(
        self,
        order_book_id: String,
        dates: List[DateTime]
    ) -> List[Bool]:
        ...

    def is_st_stock(
        self,
        order_book_id: String,
        dates: List[DateTime]
    ) -> List[Bool]:
        ...

    def get_algo_bar(
        self,
        id_or_ins: String,
        start_min: Int,
        end_min: Int,
        dt: DateTime
    ) -> Optional[PythonObject]:
        ...

    def get_exchange_rate(
        self,
        trading_date: DateTime,
        local: MARKET,
        settlement: MARKET = MARKET.CN
    ) -> ExchangeRate:
        ...


trait Broker:
    def submit_order(mut self, mut order: Order):
        ...
    def cancel_order(mut self, order: Order):
        ...
    def get_open_orders(self, order_book_id: Optional[String] = None) -> List[Order]:
        ...


trait ModInterface:
    def start_up(mut self, env_name: PythonObject, mod_config: PythonObject):
        ...
    def tear_down(
        mut self,
        code: EXIT_CODE,
        exception_msg: Optional[PythonObject] = None
    ):
        ...


comptime Mod = ModInterface


trait PersistProviderInterface:
    def store(mut self, key: String, value: PythonObject):
        ...
    def load(self, key: String) -> Optional[PythonObject]:
        ...
    def should_resume(self) -> Bool:
        ...
    def should_run_init(self) -> Bool:
        ...


trait FrontendValidatorInterface:
    def validate_submission(
        self,
        order: Order,
        account: Optional[Account] = None
    ) -> Optional[String]:
        ...
    def validate_cancellation(
        self,
        order: Order,
        account: Optional[Account] = None
    ) -> Optional[String]:
        ...


trait TransactionCostDeciderInterface:
    def calc(self, args: TransactionCostArgs) -> TransactionCost:
        ...
