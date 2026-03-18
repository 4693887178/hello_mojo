"""
RQAlpha Mojo - Abstract Interfaces
Ported from rqalpha/interface.py
"""

from rqmojo.const import (
    INSTRUMENT_TYPE, SIDE, POSITION_EFFECT, ORDER_STATUS, EXCHANGE,
    POSITION_DIRECTION, EXIT_CODE, MARKET, TRADING_CALENDAR_TYPE
)
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct ExchangeRate(Copyable, Movable):
    var bid_reference: Float64
    var ask_reference: Float64
    var bid_settlement_sh: Float64
    var ask_settlement_sh: Float64
    var bid_settlement_sz: Float64
    var ask_settlement_sz: Float64


@fieldwise_init
struct TransactionCostArgs(Copyable, Movable):
    var instrument: Instrument
    var price: Float64
    var quantity: Int
    var side: SIDE
    var position_effect: POSITION_EFFECT
    var order_id: Int
    var close_today_quantity: Int


@fieldwise_init
struct TransactionCost(Copyable, Movable):
    var commission: Float64
    var tax: Float64
    var other_fees: Float64

    fn total(self) -> Float64:
        return self.commission + self.tax + self.other_fees

    @staticmethod
    fn zero() -> TransactionCost:
        return TransactionCost(commission=0.0, tax=0.0, other_fees=0.0)


@fieldwise_init
struct FuturesTradingParameters(Copyable, Movable):
    var open_commission_ratio: Float64
    var close_commission_ratio: Float64
    var close_commission_ratio_today: Float64
    var margin_ratio: Float64


@fieldwise_init
struct Snapshot(Copyable, Movable):
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
    fn set_state(inout self, state: String):
        ...


trait Position(Persistable):
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
    fn get_state(self) -> String:
        ...
    fn set_state(inout self, state: String):
        ...


trait StrategyLoader:
    fn load(inout self):
        ...
    fn init(inout self):
        ...
    fn handle_bar(inout self, bar: BarObject):
        ...
    fn handle_tick(inout self, tick: TickObject):
        ...
    fn before_trading(inout self):
        ...
    fn after_trading(inout self):
        ...


trait EventSource:
    fn events(inout self):
        ...
    fn start(inout self):
        ...
    fn stop(inout self):
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
    fn get_instrument(self, order_book_id: String) -> Instrument:
        ...
    fn get_instruments(
        self, id_or_syms: Optional[List[String]], types: Optional[List[INSTRUMENT_TYPE]]
    ) -> List[Instrument]:
        ...
    fn get_bar(self, order_book_id: String, dt: DateTime) -> BarObject:
        ...
    fn get_tick(self, order_book_id: String, dt: DateTime) -> TickObject:
        ...
    fn get_trading_dates(self, start_date: DateTime, end_date: DateTime) -> List[DateTime]:
        ...
    fn get_trading_calendars(self) -> Dict[TRADING_CALENDAR_TYPE, List[DateTime]]:
        ...
    fn get_yield_curve(self, start_date: DateTime, end_date: DateTime, tenor: String) -> Dict:
        ...
    fn get_dividend(self, instrument: Instrument) -> Optional[Dict]:
        ...
    fn get_split(self, instrument: Instrument) -> Optional[Dict]:
        ...
    fn get_open_auction_bar(self, instrument: Instrument, dt: DateTime) -> Dict:
        ...
    fn get_open_auction_volume(self, instrument: Instrument, dt: DateTime) -> Int:
        ...
    fn get_settle_price(self, instrument: Instrument, date: DateTime) -> Float64:
        ...
    fn history_bars(
        self,
        instrument: Instrument,
        bar_count: Int,
        frequency: String,
        fields: String,
        dt: DateTime,
        skip_suspended: Bool = True,
        include_now: Bool = False,
        adjust_type: String = "pre",
        adjust_orig: Optional[DateTime] = None,
    ) -> Optional[List[BarObject]]:
        ...
    fn history_ticks(self, instrument: Instrument, count: Int, dt: DateTime) -> List[TickObject]:
        ...
    fn current_snapshot(self, instrument: Instrument, frequency: String, dt: DateTime) -> Snapshot:
        ...
    fn get_trading_minutes_for(self, instrument: Instrument, trading_dt: DateTime) -> List[DateTime]:
        ...
    fn available_data_range(self, frequency: String) -> Tuple[DateTime, DateTime]:
        ...
    fn get_futures_trading_parameters(
        self, instrument: Instrument, dt: DateTime
    ) -> FuturesTradingParameters:
        ...
    fn get_merge_ticks(
        self, order_book_id_list: List[String], trading_date: DateTime, last_dt: Optional[DateTime]
    ) -> List[TickObject]:
        ...
    fn get_share_transformation(self, order_book_id: String) -> Tuple[String, Float64]:
        ...
    fn is_suspended(self, order_book_id: String, dt: DateTime) -> Bool:
        ...
    fn is_st_stock(self, order_book_id: String, dt: DateTime) -> Bool:
        ...
    fn get_algo_bar(
        self, id_or_ins: String, start_min: Int, end_min: Int, dt: DateTime
    ) -> Optional[Dict]:
        ...
    fn get_exchange_rate(
        self, trading_date: DateTime, local: MARKET, settlement: MARKET
    ) -> ExchangeRate:
        ...


trait Broker:
    fn submit_order(inout self, order: Order):
        ...
    fn cancel_order(inout self, order_id: Int):
        ...
    fn get_open_orders(self) -> List[Order]:
        ...


trait Mod:
    fn start_up(inout self, env: object, mod_config: object):
        ...
    fn tear_down(self, code: EXIT_CODE, exception: Optional[object]):
        ...


trait PersistProvider:
    fn store(inout self, key: String, value: String):
        ...
    fn load(self, key: String) -> Optional[String]:
        ...
    fn remove(inout self, key: String):
        ...
    fn should_resume(self) -> Bool:
        ...
    fn should_run_init(self) -> Bool:
        ...


trait FrontendValidator:
    fn validate_order(self, order: Order) -> Bool:
        ...
    fn can_submit_order(self, order: Order) -> Bool:
        ...
    fn can_cancel_order(self, order_id: Int) -> Bool:
        ...
    fn validate_submission(self, order: Order, account: Optional[object]) -> Optional[String]:
        ...
    fn validate_cancellation(self, order: Order, account: Optional[object]) -> Optional[String]:
        ...


trait TransactionCostDecider:
    fn get_transaction_cost(self, order: Order, trade: Trade) -> Float64:
        ...
    fn calc(self, args: TransactionCostArgs) -> TransactionCost:
        ...
