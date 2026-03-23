"""
RQAlpha Mojo - Instrument Model
Ported from rqalpha/model/instrument.py
"""

from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, DEFAULT_ACCOUNT_TYPE, MARKET, POSITION_DIRECTION
from rqmojo.utils.typing import DateTime
from rqmojo.utils.datetime_func import TimeRange


def is_instrument_type_in_stock_account(ins_type: INSTRUMENT_TYPE) -> Bool:
    return ins_type == INSTRUMENT_TYPE_CS or ins_type == INSTRUMENT_TYPE_ETF or ins_type == INSTRUMENT_TYPE_LOF or ins_type == INSTRUMENT_TYPE_INDX or ins_type == INSTRUMENT_TYPE_BOND


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
struct Instrument(Writable, Movable, Copyable, ImplicitlyCopyable, Equatable, Hashable):
    var order_book_id_val: String
    var symbol_val: String
    var type_val: INSTRUMENT_TYPE
    var exchange_val: EXCHANGE
    var listed_date_str: String
    var de_listed_date_str: String
    var round_lot_val: Int
    var contract_multiplier_val: Float64
    var underlying_symbol_val: String
    var market_val: MARKET
    var trading_hours_str: String
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("Instrument(", self.order_book_id(), ", ", self.symbol(), ")")
    
    def __hash__(self) -> Int:
        return Int(hash(self.order_book_id()))
    
    def order_book_id(self) -> String:
        return self.order_book_id_val
    
    def symbol(self) -> String:
        return self.symbol_val
    
    def round_lot(self) -> Int:
        return self.round_lot_val
    
    def listed_date(self) -> DateTime:
        try:
            return fix_date(self.listed_date_str, DateTime(1990, 1, 1, 0, 0, 0, 0))
        except:
            return DateTime(1990, 1, 1, 0, 0, 0, 0)
    
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
        return self.contract_multiplier_val
    
    def underlying_symbol(self) -> String:
        return self.underlying_symbol_val
    
    def board_type(self) -> String:
        if self.type_val == INSTRUMENT_TYPE_CS:
            if self.order_book_id_val.startswith("688"):
                return "KSH"
            elif self.order_book_id_val.startswith("8") or self.order_book_id_val.startswith("4"):
                return "BJS"
        return ""
    
    def account_type(self) -> DEFAULT_ACCOUNT_TYPE:
        if is_instrument_type_in_stock_account(self.type_val):
            return DEFAULT_ACCOUNT_TYPE.STOCK
        return DEFAULT_ACCOUNT_TYPE.FUTURE
    
    def is_future(self) -> Bool:
        return self.type_val == INSTRUMENT_TYPE_FUTURE
    
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
            result.append(TimeRange(21, 1, 23, 0))
            result.append(TimeRange(9, 1, 10, 15))
            result.append(TimeRange(10, 31, 11, 30))
            result.append(TimeRange(13, 31, 15, 0))
        elif obid.startswith("AG"):
            result.append(TimeRange(21, 1, 23, 59))
            result.append(TimeRange(0, 0, 2, 30))
            result.append(TimeRange(9, 1, 11, 30))
            result.append(TimeRange(13, 31, 15, 15))
        elif obid.startswith("TF") or obid.startswith("T"):
            result.append(TimeRange(9, 15, 11, 30))
            result.append(TimeRange(13, 0, 15, 15))
        else:
            result.append(TimeRange(9, 31, 11, 30))
            result.append(TimeRange(13, 1, 15, 0))
        
        return result^
    
    def _stock_trading_period(self) -> List[TimeRange]:
        var result = List[TimeRange]()
        result.append(TimeRange(9, 31, 11, 30))
        result.append(TimeRange(13, 1, 15, 0))
        return result^
    
    def trade_at_night(self) -> Bool:
        var hours = self.trading_hours()
        for i in range(len(hours)):
            var r = hours[i]
            if r.start_hour <= 4 or r.end_hour >= 19:
                return True
        return False


def create_stock_instrument(order_book_id: String, symbol: String, listed_date: DateTime, exchange: EXCHANGE) -> Instrument:
    return Instrument(
        order_book_id_val=order_book_id,
        symbol_val=symbol,
        type_val=INSTRUMENT_TYPE.CS,
        exchange_val=exchange,
        listed_date_str=String(listed_date.year) + "-" + String(listed_date.month) + "-" + String(listed_date.day),
        de_listed_date_str="2999-12-31",
        round_lot_val=100,
        contract_multiplier_val=1.0,
        underlying_symbol_val="",
        market_val=MARKET.CN,
        trading_hours_str=""
    )


def create_future_instrument(order_book_id: String, symbol: String, listed_date: DateTime, maturity_date: DateTime, de_listed_date: DateTime, contract_multiplier: Float64, exchange: EXCHANGE, underlying_symbol: String, trading_hours: String = "") -> Instrument:
    return Instrument(
        order_book_id_val=order_book_id,
        symbol_val=symbol,
        type_val=INSTRUMENT_TYPE.FUTURE,
        exchange_val=exchange,
        listed_date_str=String(listed_date.year) + "-" + String(listed_date.month) + "-" + String(listed_date.day),
        de_listed_date_str=String(de_listed_date.year) + "-" + String(de_listed_date.month) + "-" + String(de_listed_date.day),
        round_lot_val=1,
        contract_multiplier_val=contract_multiplier,
        underlying_symbol_val=underlying_symbol,
        market_val=MARKET.CN,
        trading_hours_str=trading_hours
    )
