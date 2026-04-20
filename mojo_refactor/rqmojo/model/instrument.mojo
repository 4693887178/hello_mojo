"""
RQAlpha Mojo - Instrument Model
Ported from rqalpha/model/instrument.py
"""

from std.collections import Dict, List as StdList
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, DEFAULT_ACCOUNT_TYPE, MARKET, POSITION_DIRECTION
from rqmojo.utils.typing import DateTime
from rqmojo.utils.datetime_func import TimeRange, TimeOfDay, convert_dt_to_int, convert_date_to_int


def is_instrument_type_in_stock_account(ins_type: INSTRUMENT_TYPE) -> Bool:
    return ins_type == INSTRUMENT_TYPE.CS or ins_type == INSTRUMENT_TYPE.ETF or ins_type == INSTRUMENT_TYPE.LOF or ins_type == INSTRUMENT_TYPE.INDX or ins_type == INSTRUMENT_TYPE.BOND


def fix_date(ds: String, dflt: DateTime) raises -> DateTime:
    if len(ds) == 0 or ds == "0000-00-00":
        return dflt
    
    var year_str = ds[byte=0:4]
    var month_str = ds[byte=5:7]
    var day_str = ds[byte=8:10]
    
    var year = Int(year_str)
    var month = Int(month_str)
    var day = Int(day_str)
    
    return DateTime(year, month, day, 0, 0, 0, 0)


@fieldwise_init
struct Instrument(Writable, Movable, Copyable, ImplicitlyCopyable):
    var order_book_id_val: String
    var symbol_val: String
    var type_val: INSTRUMENT_TYPE
    var exchange_val: EXCHANGE
    var listed_date_str: String
    var de_listed_date_str: String
    var maturity_date_str: String
    var round_lot_val: Int
    var contract_multiplier_val: Float64
    var underlying_symbol_val: String
    var underlying_order_book_id_val: String
    var market_val: MARKET
    var trading_hours_str: String
    var market_tplus_val: Int
    var sector_code_val: String
    var sector_code_name_val: String
    var industry_code_val: String
    var industry_name_val: String
    var concept_names_val: String
    var board_type_val: String
    var status_val: String
    var special_type_val: String
    var settlement_method_val: String
    var trading_code_val: String
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("Instrument(", self.order_book_id(), ", ", self.symbol(), ")")
    
    def order_book_id(self) -> String:
        return self.order_book_id_val
    
    def symbol(self) -> String:
        return self.symbol_val
    
    def round_lot(self) -> Int:
        if self.type_val == INSTRUMENT_TYPE.CS and self.board_type() == "KSH":
            return 1
        return self.round_lot_val
    
    def listed_date(self) -> DateTime:
        try:
            return fix_date(self.listed_date_str, DateTime(1990, 1, 1, 0, 0, 0, 0))
        except:
            return DateTime(1990, 1, 1, 0, 0, 0, 0)
    
    def tick_size(self) -> Float64:
        if self.type_val == INSTRUMENT_TYPE.CS or self.type_val == INSTRUMENT_TYPE.INDX:
            return 0.01
        elif self.type_val == INSTRUMENT_TYPE.ETF or self.type_val == INSTRUMENT_TYPE.LOF:
            return 0.001
        elif self.type_val == INSTRUMENT_TYPE.FUTURE:
            return 0.001
        else:
            return 0.01
    
    def de_listed_date(self) -> DateTime:
        try:
            return fix_date(self.de_listed_date_str, DateTime(2999, 12, 31, 0, 0, 0, 0))
        except:
            return DateTime(2999, 12, 31, 0, 0, 0, 0)
    
    def type(self) -> INSTRUMENT_TYPE:
        return self.type_val
    
    def exchange(self) -> EXCHANGE:
        return self.exchange_val
    
    def market(self) -> MARKET:
        return self.market_val
    
    def contract_multiplier(self) -> Float64:
        if self.contract_multiplier_val != 0.0:
            return self.contract_multiplier_val
        return 1.0
    
    def underlying_symbol(self) -> String:
        return self.underlying_symbol_val
    
    def underlying_order_book_id(self) -> String:
        return self.underlying_order_book_id_val
    
    def market_tplus(self) -> Int:
        return self.market_tplus_val
    
    def maturity_date(self) -> DateTime:
        try:
            return fix_date(self.maturity_date_str, DateTime(2999, 12, 31, 0, 0, 0, 0))
        except:
            return DateTime(2999, 12, 31, 0, 0, 0, 0)
    
    def sector_code(self) -> String:
        return self.sector_code_val
    
    def sector_code_name(self) -> String:
        return self.sector_code_name_val
    
    def industry_code(self) -> String:
        return self.industry_code_val
    
    def industry_name(self) -> String:
        return self.industry_name_val
    
    def concept_names(self) -> String:
        return self.concept_names_val
    
    def board_type(self) -> String:
        if len(self.board_type_val) > 0:
            return self.board_type_val
        if self.type_val == INSTRUMENT_TYPE.CS:
            if self.order_book_id_val.startswith("688"):
                return "KSH"
            elif self.order_book_id_val.startswith("8") or self.order_book_id_val.startswith("4"):
                return "BJS"
        return ""
    
    def status(self) -> String:
        return self.status_val
    
    def special_type(self) -> String:
        return self.special_type_val
    
    def settlement_method(self) -> String:
        return self.settlement_method_val
    
    def trading_code(self) -> String:
        return self.trading_code_val
    
    def account_type(self) -> DEFAULT_ACCOUNT_TYPE:
        if is_instrument_type_in_stock_account(self.type_val):
            return DEFAULT_ACCOUNT_TYPE.STOCK
        elif self.type_val == INSTRUMENT_TYPE.FUTURE:
            return DEFAULT_ACCOUNT_TYPE.FUTURE
        else:
            return DEFAULT_ACCOUNT_TYPE.STOCK
    
    def is_future(self) -> Bool:
        return self.type_val == INSTRUMENT_TYPE.FUTURE

    def calc_cash_occupation(self, price: Float64, quantity: Int, direction: POSITION_DIRECTION, dt: DateTime) -> Float64:
        if is_instrument_type_in_stock_account(self.type_val):
            return price * Float64(quantity)
        elif self.type_val == INSTRUMENT_TYPE.FUTURE:
            var margin_rate: Float64 = 0.1
            if direction == POSITION_DIRECTION.SHORT:
                margin_rate = 0.1
            return price * Float64(quantity) * self.contract_multiplier() * margin_rate
        else:
            return price * Float64(quantity)

    def min_order_quantity(self) -> Int:
        return self.round_lot_val

    def order_step_size(self) -> Int:
        var bt = self.board_type()
        if bt == "KSH" or bt == "BJS":
            return 1
        return self.round_lot()

    def listed_at(self, dt: DateTime) -> Bool:
        return convert_dt_to_int(self.listed_date()) <= convert_dt_to_int(dt)

    def de_listed_at(self, dt: DateTime) -> Bool:
        if self.type_val == INSTRUMENT_TYPE.FUTURE or self.type_val == INSTRUMENT_TYPE.OPTION:
            return convert_date_to_int(dt) > convert_date_to_int(self.de_listed_date())
        return convert_dt_to_int(dt) >= convert_dt_to_int(self.de_listed_date())

    def active_at(self, dt: DateTime) -> Bool:
        return self.listed_at(dt) and not self.de_listed_at(dt)
    
    def trading_hours(self) -> List[TimeRange]:
        if len(self.trading_hours_str) > 0:
            return self._get_trading_hours_by_instrument()
        if is_instrument_type_in_stock_account(self.type_val):
            return self._stock_trading_period()
        return List[TimeRange]()
    
    def _get_trading_hours_by_instrument(self) -> List[TimeRange]:
        var result = List[TimeRange]()
        var obid = self.order_book_id_val
        
        if obid.startswith("RB"):
            result.append(TimeRange(TimeOfDay(21, 1), TimeOfDay(23, 0)))
            result.append(TimeRange(TimeOfDay(9, 1), TimeOfDay(10, 15)))
            result.append(TimeRange(TimeOfDay(10, 31), TimeOfDay(11, 30)))
            result.append(TimeRange(TimeOfDay(13, 31), TimeOfDay(15, 0)))
        elif obid.startswith("AG"):
            result.append(TimeRange(TimeOfDay(21, 1), TimeOfDay(23, 59)))
            result.append(TimeRange(TimeOfDay(0, 0), TimeOfDay(2, 30)))
            result.append(TimeRange(TimeOfDay(9, 1), TimeOfDay(11, 30)))
            result.append(TimeRange(TimeOfDay(13, 31), TimeOfDay(15, 15)))
        elif obid.startswith("TF") or obid.startswith("T"):
            result.append(TimeRange(TimeOfDay(9, 15), TimeOfDay(11, 30)))
            result.append(TimeRange(TimeOfDay(13, 0), TimeOfDay(15, 15)))
        else:
            result.append(TimeRange(TimeOfDay(9, 31), TimeOfDay(11, 30)))
            result.append(TimeRange(TimeOfDay(13, 1), TimeOfDay(15, 0)))
        
        return result^
    
    def _stock_trading_period(self) -> List[TimeRange]:
        var result = List[TimeRange]()
        result.append(TimeRange(TimeOfDay(9, 31), TimeOfDay(11, 30)))
        result.append(TimeRange(TimeOfDay(13, 1), TimeOfDay(15, 0)))
        return result^

    def during_continuous_auction(self, hour: Int, minute: Int) -> Bool:
        var hours = self.trading_hours()
        for i in range(len(hours)):
            var r = hours[i]
            var start_min = r.start.hour * 60 + r.start.minute
            var end_min = r.end.hour * 60 + r.end.minute
            var cur_min = hour * 60 + minute
            if start_min <= cur_min <= end_min:
                return True
        return False

    def trade_at_night(self) -> Bool:
        var hours = self.trading_hours()
        for i in range(len(hours)):
            var r = hours[i]
            if r.start.hour <= 4 or r.end.hour >= 19:
                return True
        return False

    def during_call_auction(self, hour: Int, minute: Int) -> Bool:
        var _minute = hour * 60 + minute
        if self.type_val == INSTRUMENT_TYPE.CS or self.type_val == INSTRUMENT_TYPE.ETF:
            return _minute < 570 or _minute >= 897
        elif self.type_val == INSTRUMENT_TYPE.FUTURE:
            var hours = self.trading_hours()
            if len(hours) > 0:
                var start_time = hours[0].start
                var start_minute = start_time.hour * 60 + start_time.minute - 1
                return (start_minute - 5) <= _minute < start_minute
            return False
        else:
            return False


def _pad2(n: Int) -> String:
    if n < 10:
        return "0" + String(n)
    return String(n)


def _format_date(dt: DateTime) -> String:
    return String(dt.year) + "-" + _pad2(dt.month) + "-" + _pad2(dt.day)


def create_stock_instrument(order_book_id: String, symbol: String, listed_date: DateTime, exchange: EXCHANGE) -> Instrument:
    return Instrument(
        order_book_id_val=order_book_id,
        symbol_val=symbol,
        type_val=INSTRUMENT_TYPE.CS,
        exchange_val=exchange,
        listed_date_str=_format_date(listed_date),
        de_listed_date_str="2999-12-31",
        maturity_date_str="2999-12-31",
        round_lot_val=100,
        contract_multiplier_val=1.0,
        underlying_symbol_val="",
        underlying_order_book_id_val="",
        market_val=MARKET.CN,
        trading_hours_str="",
        market_tplus_val=1,
        sector_code_val="",
        sector_code_name_val="",
        industry_code_val="",
        industry_name_val="",
        concept_names_val="",
        board_type_val="",
        status_val="Active",
        special_type_val="Normal",
        settlement_method_val="",
        trading_code_val=""
    )


def create_future_instrument(order_book_id: String, symbol: String, listed_date: DateTime, maturity_date: DateTime, de_listed_date: DateTime, contract_multiplier: Float64, exchange: EXCHANGE, underlying_symbol: String, trading_hours: String = "") -> Instrument:
    return Instrument(
        order_book_id_val=order_book_id,
        symbol_val=symbol,
        type_val=INSTRUMENT_TYPE.FUTURE,
        exchange_val=exchange,
        listed_date_str=_format_date(listed_date),
        de_listed_date_str=_format_date(de_listed_date),
        maturity_date_str=_format_date(maturity_date),
        round_lot_val=1,
        contract_multiplier_val=contract_multiplier,
        underlying_symbol_val=underlying_symbol,
        underlying_order_book_id_val="",
        market_val=MARKET.CN,
        trading_hours_str=trading_hours,
        market_tplus_val=0,
        sector_code_val="",
        sector_code_name_val="",
        industry_code_val="",
        industry_name_val="",
        concept_names_val="",
        board_type_val="",
        status_val="Active",
        special_type_val="Normal",
        settlement_method_val="PhysicalSettlementRequired",
        trading_code_val=""
    )


def create_etf_instrument(order_book_id: String, symbol: String, listed_date: DateTime, exchange: EXCHANGE) -> Instrument:
    return Instrument(
        order_book_id_val=order_book_id,
        symbol_val=symbol,
        type_val=INSTRUMENT_TYPE.ETF,
        exchange_val=exchange,
        listed_date_str=_format_date(listed_date),
        de_listed_date_str="2999-12-31",
        maturity_date_str="2999-12-31",
        round_lot_val=100,
        contract_multiplier_val=1.0,
        underlying_symbol_val="",
        underlying_order_book_id_val="",
        market_val=MARKET.CN,
        trading_hours_str="",
        market_tplus_val=0,
        sector_code_val="",
        sector_code_name_val="",
        industry_code_val="",
        industry_name_val="",
        concept_names_val="",
        board_type_val="",
        status_val="Active",
        special_type_val="Normal",
        settlement_method_val="",
        trading_code_val=""
    )
