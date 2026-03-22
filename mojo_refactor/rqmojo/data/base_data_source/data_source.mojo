"""
RQAlpha Mojo - Base Data Source
Ported from rqalpha/data/base_data_source/data_source.py
"""

from std.collections import Dict, List
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, MARKET, TRADING_CALENDAR_TYPE
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.model.tick import TickObject, create_tick_object
from rqmojo.utils.datetime_func import DateTime, Date, convert_int_to_datetime


@fieldwise_init
struct FuturesTradingParameters(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var long_margin_ratio: Float64
    var short_margin_ratio: Float64
    
    def __str__(self) -> String:
        return "FuturesTradingParameters(long=" + String(self.long_margin_ratio) + ", short=" + String(self.short_margin_ratio) + ")"


@fieldwise_init
struct ExchangeRate(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var bid_reference: Float64
    var ask_reference: Float64
    var bid_settlement_sh: Float64
    var ask_settlement_sh: Float64
    var bid_settlement_sz: Float64
    var ask_settlement_sz: Float64
    
    def __str__(self) -> String:
        return "ExchangeRate(bid=" + String(self.bid_reference) + ", ask=" + String(self.ask_reference) + ")"


@fieldwise_init
struct BaseDataSource(Movable):
    var _instruments: Dict[String, Instrument]
    var _trading_dates: List[Int]
    var _initialized: Bool

    def load_bundle(mut self, path: String) -> None:
        self._initialized = True
        self._load_default_instruments()
        self._load_default_trading_dates()

    def _load_default_instruments(mut self) -> None:
        self.register_instrument(create_stock_instrument("000001.XSHE", "平安银行", DateTime(1991, 4, 3, 0, 0, 0, 0), EXCHANGE.XSHE))
        self.register_instrument(create_stock_instrument("000002.XSHE", "万科A", DateTime(1991, 1, 29, 0, 0, 0, 0), EXCHANGE.XSHE))
        self.register_instrument(create_stock_instrument("600000.XSHG", "浦发银行", DateTime(1999, 11, 10, 0, 0, 0, 0), EXCHANGE.XSHG))
        self.register_instrument(create_future_instrument("IF1912", "沪深300股指1912", DateTime(2019, 1, 1, 0, 0, 0, 0), DateTime(2019, 12, 20, 0, 0, 0, 0), DateTime(2019, 12, 20, 0, 0, 0, 0), 300.0, EXCHANGE.CFFEX, "IF"))

    def _load_default_trading_dates(mut self) -> None:
        var year = 2019
        var month = 11
        for day in range(1, 30):
            if day % 7 != 0 and day % 7 != 6:
                var dt_int = year * 10000 + month * 100 + day
                self._trading_dates.append(dt_int)

    def register_instrument(mut self, instrument: Instrument) -> None:
        self._instruments[instrument.order_book_id()] = instrument

    def get_instrument(self, order_book_id: String) -> Instrument:
        try:
            return self._instruments[order_book_id]
        except:
            return create_stock_instrument(order_book_id, order_book_id, DateTime(1990, 1, 1, 0, 0, 0, 0), EXCHANGE.XSHG)

    def get_all_instruments(self) -> List[Instrument]:
        var result = List[Instrument]()
        for key in self._instruments.keys():
            try:
                result.append(self._instruments[key])
            except:
                pass
        return result^

    def get_bar(self, order_book_id: String, dt: DateTime) -> BarObject:
        var ins = self.get_instrument(order_book_id)
        return create_bar_object(
            instrument=ins,
            dt=dt,
            open=10.0,
            high=10.5,
            low=9.8,
            close=10.2,
            volume=1000000.0,
            total_turnover=10200000.0
        )

    def history_bars(self, order_book_id: String, bar_count: Int, dt: DateTime) -> List[BarObject]:
        var result = List[BarObject]()
        var ins = self.get_instrument(order_book_id)
        for i in range(bar_count):
            var bar_dt = DateTime(dt.year, dt.month, dt.day - i, 0, 0, 0, 0)
            result.append(create_bar_object(
                instrument=ins,
                dt=bar_dt,
                open=10.0 + i * 0.1,
                high=10.5 + i * 0.1,
                low=9.8 + i * 0.1,
                close=10.2 + i * 0.1,
                volume=1000000.0,
                total_turnover=10200000.0
            ))
        return result^

    def get_tick(self, order_book_id: String, dt: DateTime) -> TickObject:
        var ins = self.get_instrument(order_book_id)
        return create_tick_object(
            instrument=ins,
            dt=dt,
            last=10.2,
            volume=1000000.0,
            total_turnover=10200000.0
        )

    def get_trading_dates(self, start_date: Date, end_date: Date) -> List[DateTime]:
        var result = List[DateTime]()
        var start_int = start_date.year * 10000 + start_date.month * 100 + start_date.day
        var end_int = end_date.year * 10000 + end_date.month * 100 + end_date.day
        for dt_int in self._trading_dates:
            if dt_int >= start_int and dt_int <= end_int:
                result.append(convert_int_to_datetime(dt_int))
        return result^

    def is_trading_date(self, year: Int, month: Int, day: Int) -> Bool:
        var dt_int = year * 10000 + month * 100 + day
        for trading_dt in self._trading_dates:
            if trading_dt == dt_int:
                return True
        return False

    def get_previous_trading_date(self, year: Int, month: Int, day: Int) -> DateTime:
        var dt_int = year * 10000 + month * 100 + day
        var prev_dt = dt_int
        for trading_dt in self._trading_dates:
            if trading_dt < dt_int:
                prev_dt = trading_dt
            else:
                break
        return convert_int_to_datetime(prev_dt)

    def get_next_trading_date(self, year: Int, month: Int, day: Int) -> DateTime:
        var dt_int = year * 10000 + month * 100 + day
        for trading_dt in self._trading_dates:
            if trading_dt > dt_int:
                return convert_int_to_datetime(trading_dt)
        return convert_int_to_datetime(dt_int)

    def is_suspended(self, order_book_id: String, dt: DateTime) -> Bool:
        return False

    def get_dividend(self, order_book_id: String) -> Float64:
        return 0.0

    def get_split(self, order_book_id: String) -> Float64:
        return 1.0

    def get_ex_cum_factor(self, order_book_id: String) -> Float64:
        return 1.0

    def get_yield_curve(self, start_date: Date, end_date: Date) -> List[Float64]:
        var result = List[Float64]()
        return result^

    def get_futures_trading_parameters(self, order_book_id: String, dt: DateTime) -> FuturesTradingParameters:
        return FuturesTradingParameters(long_margin_ratio=0.1, short_margin_ratio=0.1)

    def get_exchange_rate(self, trading_date: Date, local: MARKET, settlement: MARKET) -> ExchangeRate:
        return ExchangeRate(bid_reference=1.0, ask_reference=1.0, bid_settlement_sh=1.0, ask_settlement_sh=1.0, bid_settlement_sz=1.0, ask_settlement_sz=1.0)


def create_base_data_source() -> BaseDataSource:
    return BaseDataSource(
        _instruments=Dict[String, Instrument](),
        _trading_dates=List[Int](),
        _initialized=False
    )


def create_base_data_source_with_path(bundle_path: String) -> BaseDataSource:
    var ds = BaseDataSource(
        _instruments=Dict[String, Instrument](),
        _trading_dates=List[Int](),
        _initialized=False
    )
    ds.load_bundle(bundle_path)
    return ds^
