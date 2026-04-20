"""
RQAlpha Mojo - Data Proxy
Ported from rqalpha/data/data_proxy.py
"""

from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, MARKET
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.model.tick import TickObject, create_tick_object
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.utils.datetime_func import TimeRange, TimeOfDay
from rqmojo.data.trading_dates_mixin import TradingDatesMixin, create_trading_dates_mixin_with_november_2018, create_trading_dates_mixin_with_november_2024, create_trading_dates_mixin_with_multiple_months
from rqmojo.utils.exception import InstrumentNotFound


@fieldwise_init
struct DividendInfo(Copyable, Movable, Writable, ImplicitlyCopyable):
    var book_closure_date: Int
    var announcement_date: Int
    var dividend_cash_before_tax: Float64
    var ex_dividend_date: Int
    var payable_date: Int
    var round_lot: Int
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("DividendInfo(ex_date=", String(self.ex_dividend_date), ", cash=", String(self.dividend_cash_before_tax), ")")


@fieldwise_init
struct SplitInfo(Copyable, Movable, Stringable, ImplicitlyCopyable):
    var ex_date: Int
    var split_factor: Float64
    
    def __str__(self) -> String:
        return "SplitInfo(ex_date=" + String(self.ex_date) + ", factor=" + String(self.split_factor) + ")"


@fieldwise_init
struct Snapshot(Copyable, Movable, Stringable, ImplicitlyCopyable):
    var instrument: Instrument
    var datetime: DateTime
    var open: Float64
    var high: Float64
    var low: Float64
    var last: Float64
    var volume: Float64
    var total_turnover: Float64
    var prev_close: Float64
    var limit_up: Float64
    var limit_down: Float64
    var open_interest: Float64
    var prev_settlement: Float64
    
    def __str__(self) -> String:
        return "Snapshot(" + self.instrument.order_book_id + ", " + self.datetime.__str__() + ", last=" + String(self.last) + ")"


@fieldwise_init
struct OpenAuctionBar(Copyable, Movable, Stringable, ImplicitlyCopyable):
    var instrument: Instrument
    var datetime: DateTime
    var open: Float64
    var limit_up: Float64
    var limit_down: Float64
    var volume: Float64
    var total_turnover: Float64
    
    def __str__(self) -> String:
        return "OpenAuctionBar(" + self.instrument.order_book_id + ", " + self.datetime.__str__() + ")"


@fieldwise_init
struct YieldCurvePoint(Copyable, Movable, Stringable, ImplicitlyCopyable):
    var date: Int
    var tenor: String
    var rate: Float64
    
    def __str__(self) -> String:
        return "YieldCurvePoint(date=" + String(self.date) + ", tenor=" + self.tenor + ", rate=" + String(self.rate) + ")"


def create_dividend_info(
    book_closure_date: Int,
    announcement_date: Int,
    dividend_cash_before_tax: Float64,
    ex_dividend_date: Int,
    payable_date: Int,
    round_lot: Int = 10
) -> DividendInfo:
    return DividendInfo(
        book_closure_date=book_closure_date,
        announcement_date=announcement_date,
        dividend_cash_before_tax=dividend_cash_before_tax,
        ex_dividend_date=ex_dividend_date,
        payable_date=payable_date,
        round_lot=round_lot
    )


def create_split_info(ex_date: Int, split_factor: Float64) -> SplitInfo:
    return SplitInfo(ex_date=ex_date, split_factor=split_factor)


def create_snapshot(
    instrument: Instrument,
    datetime: DateTime,
    open: Float64,
    high: Float64,
    low: Float64,
    last: Float64,
    volume: Float64,
    total_turnover: Float64,
    prev_close: Float64 = 0.0,
    limit_up: Float64 = 0.0,
    limit_down: Float64 = 0.0,
    open_interest: Float64 = 0.0,
    prev_settlement: Float64 = 0.0
) -> Snapshot:
    return Snapshot(
        instrument=instrument,
        datetime=datetime,
        open=open,
        high=high,
        low=low,
        last=last,
        volume=volume,
        total_turnover=total_turnover,
        prev_close=prev_close,
        limit_up=limit_up,
        limit_down=limit_down,
        open_interest=open_interest,
        prev_settlement=prev_settlement
    )


def create_open_auction_bar(
    instrument: Instrument,
    datetime: DateTime,
    open: Float64,
    limit_up: Float64,
    limit_down: Float64,
    volume: Float64,
    total_turnover: Float64
) -> OpenAuctionBar:
    return OpenAuctionBar(
        instrument=instrument,
        datetime=datetime,
        open=open,
        limit_up=limit_up,
        limit_down=limit_down,
        volume=volume,
        total_turnover=total_turnover
    )


@fieldwise_init
struct DataProxy(Movable):
    var _data_source_name: String
    var _trading_dates_mixin: TradingDatesMixin
    var _suspended_ids: Dict[String, Bool]
    var _custom_instruments: Dict[String, Instrument]

    def get_instrument(self, order_book_id: String) raises -> Instrument:
        if order_book_id in self._custom_instruments:
            return self._custom_instruments[order_book_id]
        return create_stock_instrument(order_book_id, order_book_id, DateTime(1990, 1, 1, 0, 0, 0, 0), EXCHANGE.XSHG)

    def get_active_instrument(self, order_book_id: String, dt: DateTime) raises -> Instrument:
        var instrument = self.get_instrument(order_book_id)
        if not instrument.active_at(dt):
            raise Error(InstrumentNotFound("No instrument found at " + String(dt) + ": " + order_book_id).message)
        return instrument

    def get_last_price(self, order_book_id: String) -> Float64:
        return 10.0

    def get_limit_up(self, order_book_id: String) -> Float64:
        return 11.0

    def get_limit_down(self, order_book_id: String) -> Float64:
        return 9.0

    def get_a1(self, order_book_id: String) -> Float64:
        return 10.01

    def get_b1(self, order_book_id: String) -> Float64:
        return 9.99
    
    def get_all_instruments(self, type: String = "") -> List[Instrument]:
        var result = List[Instrument]()
        result.append(create_stock_instrument("000001.XSHE", "平安银行", DateTime(1991, 4, 3, 0, 0, 0, 0), EXCHANGE.XSHE))
        result.append(create_stock_instrument("000002.XSHE", "万科A", DateTime(1991, 1, 29, 0, 0, 0, 0), EXCHANGE.XSHE))
        result.append(create_stock_instrument("600000.XSHG", "浦发银行", DateTime(1999, 11, 10, 0, 0, 0, 0), EXCHANGE.XSHG))
        result.append(create_stock_instrument("600036.XSHG", "招商银行", DateTime(2002, 4, 9, 0, 0, 0, 0), EXCHANGE.XSHG))
        return result^
    
    def get_bar(self, order_book_id: String, dt: DateTime) -> BarObject:
        return create_bar_object(
            order_book_id=order_book_id,
            dt=dt,
            open=10.0,
            high=10.5,
            low=9.8,
            close=10.2,
            volume=1000000.0,
            total_turnover=10200000.0
        )
    
    def get_tick(self, order_book_id: String, dt: DateTime) -> TickObject:
        var ins = self.get_instrument(order_book_id)
        return create_tick_object(
            instrument=ins^,
            dt=dt,
            last=10.2,
            volume=1000000.0,
            total_turnover=10200000.0
        )
    
    def is_suspended(self, order_book_id: String, dt: DateTime) raises -> Bool:
        if order_book_id in self._suspended_ids:
            return self._suspended_ids[order_book_id]
        return False
    
    def count_trading_dates(self, start_date: DateTimeDate, end_date: DateTimeDate) -> Int:
        return self._trading_dates_mixin.count_trading_dates(
            start_date.year, start_date.month, start_date.day,
            end_date.year, end_date.month, end_date.day
        )
    
    def is_trading_date_by_ymd(self, year: Int, month: Int, day: Int) -> Bool:
        return self._trading_dates_mixin.is_trading_date(year, month, day)
    
    def is_trading_date(self, dt: DateTime) -> Bool:
        return self._trading_dates_mixin.is_trading_date(dt.year, dt.month, dt.day)
    
    def is_trading_date_from_date(self, d: DateTimeDate) -> Bool:
        return self._trading_dates_mixin.is_trading_date(d.year, d.month, d.day)
    
    def get_previous_trading_date(self, dt: DateTime) -> DateTime:
        var result = self._trading_dates_mixin.get_previous_trading_date(dt.year, dt.month, dt.day)
        return DateTime(result.year, result.month, result.day, 0, 0, 0, 0)
    
    def get_previous_trading_date_from_date(self, d: DateTimeDate) -> DateTimeDate:
        var result = self._trading_dates_mixin.get_previous_trading_date(d.year, d.month, d.day)
        return DateTimeDate(result.year, result.month, result.day)
    
    def get_next_trading_date(self, dt: DateTime) -> DateTime:
        var result = self._trading_dates_mixin.get_next_trading_date(dt.year, dt.month, dt.day)
        return DateTime(result.year, result.month, result.day, 0, 0, 0, 0)
    
    def get_next_trading_date_from_date(self, d: DateTimeDate) -> DateTimeDate:
        var result = self._trading_dates_mixin.get_next_trading_date(d.year, d.month, d.day)
        return DateTimeDate(result.year, result.month, result.day)
    
    def history_bars(
        self,
        instrument: Instrument,
        bar_count: Int,
        frequency: String,
        fields: String,
        dt: DateTime,
        skip_suspended: Bool = True,
        include_now: Bool = False,
        adjust_type: String = "pre",
        adjust_orig: DateTime = DateTime(1970, 1, 1, 0, 0, 0, 0)
    ) -> List[BarObject]:
        var result = List[BarObject]()
        var current_dt = dt
        var count = 0
        var actual_orig = adjust_orig
        if actual_orig.year == 1970 and actual_orig.month == 1 and actual_orig.day == 1:
            actual_orig = dt
        
        while count < bar_count:
            if self.is_trading_date(current_dt) or not skip_suspended:
                var bar = self._create_mock_bar_with_adjustment(
                    instrument, current_dt, adjust_type, actual_orig
                )
                result.append(bar)
                count += 1
            current_dt = self.get_previous_trading_date(current_dt)
        
        var reversed_result = List[BarObject]()
        for i in range(len(result) - 1, -1, -1):
            reversed_result.append(result[i])
        
        return reversed_result^
    
    def _create_mock_bar_with_adjustment(
        self,
        instrument: Instrument,
        dt: DateTime,
        adjust_type: String,
        adjust_orig: DateTime
    ) -> BarObject:
        var base_price = 10.0
        var adjustment_factor = 1.0
        
        if adjust_type == "pre":
            adjustment_factor = self._calculate_pre_adjustment_factor(instrument, dt, adjust_orig)
        elif adjust_type == "post":
            adjustment_factor = self._calculate_post_adjustment_factor(instrument, dt)
        
        var days_offset = Float64((dt.year - 2020) * 365 + (dt.month - 1) * 30 + dt.day)
        var price_variation = 1.0 + 0.001 * days_offset
        
        var adj_open = base_price * adjustment_factor * price_variation
        var adj_close = base_price * 1.02 * adjustment_factor * price_variation
        var adj_high = base_price * 1.05 * adjustment_factor * price_variation
        var adj_low = base_price * 0.98 * adjustment_factor * price_variation
        
        return create_bar_object(
            order_book_id=instrument.order_book_id(),
            dt=dt,
            open=adj_open,
            high=adj_high,
            low=adj_low,
            close=adj_close,
            volume=1000000.0,
            total_turnover=1000000.0 * adj_close
        )
    
    def _calculate_pre_adjustment_factor(self, instrument: Instrument, dt: DateTime, adjust_orig: DateTime) -> Float64:
        return 1.0
    
    def _calculate_post_adjustment_factor(self, instrument: Instrument, dt: DateTime) -> Float64:
        return 1.0
    
    def history_ticks(self, instrument: Instrument, count: Int, dt: DateTime) -> List[TickObject]:
        var result = List[TickObject]()
        var current_dt = dt
        var tick_count = 0
        
        while tick_count < count:
            var tick = create_tick_object(
                instrument=instrument,
                dt=current_dt,
                last=10.0 + Float64(tick_count) * 0.01,
                volume=1000.0,
                total_turnover=10000.0
            )
            result.append(tick)
            tick_count += 1
            current_dt = DateTime(
                current_dt.year, current_dt.month, current_dt.day,
                current_dt.hour, current_dt.minute - 1, current_dt.second, 0
            )
            if current_dt.minute < 0:
                current_dt = DateTime(
                    current_dt.year, current_dt.month, current_dt.day,
                    current_dt.hour - 1, 59, current_dt.second, 0
                )
        
        return result^
    
    def current_snapshot(self, instrument: Instrument, frequency: String, dt: DateTime) -> Snapshot:
        var bar = self._create_mock_bar_with_adjustment(instrument, dt, "none", dt)
        var prev_close = self._get_prev_close(instrument, dt)
        var limit_up = bar.close * 1.1
        var limit_down = bar.close * 0.9
        
        return create_snapshot(
            instrument=instrument,
            datetime=dt,
            open=bar.open,
            high=bar.high,
            low=bar.low,
            last=bar.close,
            volume=bar.volume,
            total_turnover=bar.total_turnover,
            prev_close=prev_close,
            limit_up=limit_up,
            limit_down=limit_down
        )
    
    def _get_prev_close(self, instrument: Instrument, dt: DateTime) -> Float64:
        var prev_dt = self.get_previous_trading_date(dt)
        var prev_bar = self._create_mock_bar_with_adjustment(instrument, prev_dt, "pre", dt)
        return prev_bar.close
    
    def get_trading_minutes_for(self, instrument: Instrument, trading_dt: DateTime) -> List[DateTime]:
        var result = List[DateTime]()
        
        if instrument.type == INSTRUMENT_TYPE_CS or instrument.type == INSTRUMENT_TYPE_ETF or instrument.type == INSTRUMENT_TYPE_LOF:
            for hour in range(9, 12):
                for minute in range(31, 60):
                    result.append(DateTime(trading_dt.year, trading_dt.month, trading_dt.day, hour, minute, 0, 0))
                if hour == 9:
                    for minute in range(0, 31):
                        result.append(DateTime(trading_dt.year, trading_dt.month, trading_dt.day, hour, minute, 0, 0))
            
            for hour in range(13, 15):
                for minute in range(0, 60):
                    result.append(DateTime(trading_dt.year, trading_dt.month, trading_dt.day, hour, minute, 0, 0))
                if hour == 14:
                    for minute in range(0, 1):
                        result.append(DateTime(trading_dt.year, trading_dt.month, trading_dt.day, hour, minute, 0, 0))
        elif instrument.type == INSTRUMENT_TYPE.FUTURE:
            for hour in range(9, 12):
                for minute in range(0, 60):
                    result.append(DateTime(trading_dt.year, trading_dt.month, trading_dt.day, hour, minute, 0, 0))
            for hour in range(13, 16):
                for minute in range(30, 60):
                    result.append(DateTime(trading_dt.year, trading_dt.month, trading_dt.day, hour, minute, 0, 0))
        
        return result^
    
    def get_dividend(self, instrument: Instrument) -> Optional[DividendInfo]:
        if instrument.type() != INSTRUMENT_TYPE.CS and instrument.type() != INSTRUMENT_TYPE.ETF:
            return Optional[DividendInfo](None)
        
        var dividend = create_dividend_info(
            book_closure_date=20231215,
            announcement_date=20231210,
            dividend_cash_before_tax=0.5,
            ex_dividend_date=20231216,
            payable_date=20231220,
            round_lot=10
        )
        return Optional[DividendInfo](dividend)
    
    def get_split(self, instrument: Instrument) -> Optional[SplitInfo]:
        if instrument.type != INSTRUMENT_TYPE.CS:
            return Optional[SplitInfo](None)
        
        var split = create_split_info(ex_date=20230515, split_factor=1.5)
        return Optional[SplitInfo](split)
    
    def get_yield_curve(self, start_date: DateTimeDate, end_date: DateTimeDate, tenor: String = "") -> List[YieldCurvePoint]:
        var result = List[YieldCurvePoint]()
        
        var tenors = List[String]()
        if len(tenor) > 0:
            tenors.append(tenor)
        else:
            tenors.append("1M")
            tenors.append("3M")
            tenors.append("6M")
            tenors.append("1Y")
            tenors.append("3Y")
            tenors.append("5Y")
            tenors.append("10Y")
        
        var current_date = start_date
        while current_date.year < end_date.year or (current_date.year == end_date.year and current_date.month < end_date.month) or (current_date.year == end_date.year and current_date.month == end_date.month and current_date.day <= end_date.day):
            if self.is_trading_date_from_date(current_date):
                for i in range(len(tenors)):
                    var rate = 0.02 + Float64(i) * 0.005
                    var point = YieldCurvePoint(
                        date=current_date.year * 10000 + current_date.month * 100 + current_date.day,
                        tenor=tenors[i],
                        rate=rate
                    )
                    result.append(point)
            
            current_date = DateTimeDate(current_date.year, current_date.month, current_date.day + 1)
            if current_date.day > 28:
                current_date = DateTimeDate(current_date.year, current_date.month + 1, 1)
            if current_date.month > 12:
                current_date = DateTimeDate(current_date.year + 1, 1, 1)
        
        return result^
    
    def get_settle_price(self, instrument: Instrument, trading_dt: DateTime) -> Float64:
        if instrument.type != INSTRUMENT_TYPE.FUTURE:
            return Float64(0.0)
        
        return 3500.0
    
    def get_open_auction_bar(self, instrument: Instrument, dt: DateTime) -> OpenAuctionBar:
        var open_price = 10.0
        var limit_up = open_price * 1.1
        var limit_down = open_price * 0.9
        var volume = 50000.0
        var turnover = volume * open_price
        
        return create_open_auction_bar(
            instrument=instrument,
            datetime=dt,
            open=open_price,
            limit_up=limit_up,
            limit_down=limit_down,
            volume=volume,
            total_turnover=turnover
        )
    
    def get_open_auction_volume(self, instrument: Instrument, dt: DateTime) -> Int:
        return 50000
    
    def _get_instrument_by_id(self, order_book_id: String) -> Instrument:
        if order_book_id == "RB1912":
            return create_future_instrument("RB1912", "螺纹钢1912", DateTime(2019, 1, 1, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), 10.0, EXCHANGE.SHFE, "RB", "21:1-23:0,9:1-10:15,10:31-11:30,13:31-15:0")
        elif order_book_id == "AG1912":
            return create_future_instrument("AG1912", "白银1912", DateTime(2019, 1, 1, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), 15.0, EXCHANGE.SHFE, "AG", "21:1-23:59,0:0-2:30,9:1-11:30,13:31-15:15")
        elif order_book_id == "TF1912":
            return create_future_instrument("TF1912", "五年期国债1912", DateTime(2019, 1, 1, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), 10000.0, EXCHANGE.CFFEX, "TF", "9:15-11:30,13:0-15:15")
        elif order_book_id == "000001.XSHE":
            return create_stock_instrument("000001.XSHE", "平安银行", DateTime(1991, 4, 3, 0, 0, 0, 0), EXCHANGE.XSHE)
        else:
            return create_stock_instrument(order_book_id, order_book_id, DateTime(1990, 1, 1, 0, 0, 0, 0), EXCHANGE.XSHG)
    
    def get_trading_period(self, order_book_ids: List[String], default_trading_period: List[TimeRange] = List[TimeRange]()) raises -> List[TimeRange]:
        var trading_period = List[TimeRange]()
        
        for i in range(len(default_trading_period)):
            trading_period.append(default_trading_period[i])
        
        for i in range(len(order_book_ids)):
            var ins = self._get_instrument_by_id(order_book_ids[i])
            var hours = ins.trading_hours()
            for j in range(len(hours)):
                trading_period.append(hours[j])
        
        return merge_trading_period(trading_period)
    
    def is_night_trading(self, order_book_ids: List[String]) raises -> Bool:
        for i in range(len(order_book_ids)):
            var ins = self._get_instrument_by_id(order_book_ids[i])
            if ins.trade_at_night():
                return True
        return False
    
    def available_data_range(self, frequency: String) -> Tuple[DateTime, DateTime]:
        return Tuple[DateTime, DateTime](DateTime(2020, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    def get_trading_dates(self, start_date: DateTime, end_date: DateTime) -> List[DateTime]:
        var result = List[DateTime]()
        var trading_results = self._trading_dates_mixin.get_trading_dates(start_date.year, start_date.month, start_date.day, end_date.year, end_date.month, end_date.day)
        for i in range(len(trading_results)):
            var tr = trading_results[i]
            result.append(DateTime(tr.year, tr.month, tr.day, 0, 0, 0, 0))
        return result^


def merge_trading_period(trading_period: List[TimeRange]) -> List[TimeRange]:
    var result = List[TimeRange]()
    
    var sorted_list = List[TimeRange]()
    for i in range(len(trading_period)):
        sorted_list.append(trading_period[i])
    
    for i in range(len(sorted_list)):
        for j in range(i + 1, len(sorted_list)):
            var ti = sorted_list[i]
            var tj = sorted_list[j]
            var cmp_i = ti.start.hour * 60 + ti.start.minute
            var cmp_j = tj.start.hour * 60 + tj.start.minute
            if cmp_i > cmp_j:
                sorted_list[i] = tj
                sorted_list[j] = ti
    
    for i in range(len(sorted_list)):
        var time_range = sorted_list[i]
        
        if len(result) > 0:
            var last = result[len(result) - 1]
            var last_end = last.end.hour * 60 + last.end.minute
            var current_start = time_range.start.hour * 60 + time_range.start.minute
            var current_end = time_range.end.hour * 60 + time_range.end.minute

            if last_end >= current_start:
                var new_end = max(last_end, current_end)
                result[len(result) - 1] = TimeRange(last.start, TimeOfDay(new_end // 60, new_end % 60))
            else:
                result.append(time_range)
        else:
            result.append(time_range)
    
    return result^


def create_data_proxy() -> DataProxy:
    return DataProxy(
        _data_source_name="default",
        _trading_dates_mixin=create_trading_dates_mixin_with_multiple_months(),
        _suspended_ids=Dict[String, Bool](),
        _custom_instruments=Dict[String, Instrument](),
    )


def create_data_proxy_with_name(name: String) -> DataProxy:
    return DataProxy(
        _data_source_name=name,
        _trading_dates_mixin=create_trading_dates_mixin_with_multiple_months(),
        _suspended_ids=Dict[String, Bool](),
        _custom_instruments=Dict[String, Instrument](),
    )


def create_data_proxy_from_source(var data_source: DataProxy, var price_board: DataProxy) -> DataProxy:
    return DataProxy(
        _data_source_name=data_source._data_source_name,
        _trading_dates_mixin=data_source._trading_dates_mixin,
        _suspended_ids=data_source._suspended_ids.copy(),
        _custom_instruments=data_source._custom_instruments.copy(),
    )


def get_available_data_range(data_proxy: DataProxy, frequency: String) -> Tuple[DateTime, DateTime]:
    return Tuple[DateTime, DateTime](DateTime(2020, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
