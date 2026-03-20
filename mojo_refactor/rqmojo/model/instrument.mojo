"""
RQAlpha Mojo - Instrument Model
Ported from rqalpha/model/instrument.py
"""

from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, DEFAULT_ACCOUNT_TYPE, MARKET, POSITION_DIRECTION, INSTRUMENT_TYPE_CS, INSTRUMENT_TYPE_ETF, INSTRUMENT_TYPE_LOF, INSTRUMENT_TYPE_INDX, INSTRUMENT_TYPE_BOND, INSTRUMENT_TYPE_FUTURE, INSTRUMENT_TYPE_OPTION, INSTRUMENT_TYPE_CONVERTIBLE, EXCHANGE_XSHG, EXCHANGE_XSHE, EXCHANGE_SHFE, EXCHANGE_DCE, EXCHANGE_CZCE, EXCHANGE_CFFEX, EXCHANGE_INE, DEFAULT_ACCOUNT_TYPE_STOCK, DEFAULT_ACCOUNT_TYPE_FUTURE, POSITION_DIRECTION_SHORT, MARKET_CN
from rqmojo.utils.datetime_func import DateTime, Date, TimeRange
from collections import Dict


fn is_instrument_type_in_stock_account(ins_type: INSTRUMENT_TYPE) -> Bool:
    return ins_type == INSTRUMENT_TYPE_CS or ins_type == INSTRUMENT_TYPE_ETF or ins_type == INSTRUMENT_TYPE_LOF or ins_type == INSTRUMENT_TYPE_INDX or ins_type == INSTRUMENT_TYPE_BOND


fn fix_date(ds: String, dflt: DateTime) raises -> DateTime:
    if len(ds) == 0 or ds == "0000-00-00":
        return dflt
    
    var year_str = ds[0:4]
    var month_str = ds[5:7]
    var day_str = ds[8:10]
    
    var year = Int(year_str)
    var month = Int(month_str)
    var day = Int(day_str)
    
    return DateTime(year, month, day, 0, 0, 0, 0)


@fieldwise_init
struct Instrument(Stringable, Movable, Equatable, Hashable):
    var _dict: Dict[String, String]
    var _futures_tick_size_getter_result: Float64
    var market: MARKET
    
    fn __str__(self) -> String:
        return "Instrument(" + self.order_book_id() + ", " + self.symbol() + ")"
    
    fn __hash__(self) -> Int:
        return Int(hash(self.order_book_id()))
    
    fn order_book_id(self) -> String:
        return self._dict.get("order_book_id", "")
    
    fn symbol(self) -> String:
        return self._dict.get("symbol", "")
    
    fn round_lot(self) raises -> Int:
        var type_str = self._dict.get("type", "")
        var board_type = self._dict.get("board_type", "")
        if type_str == "CS" and board_type == "KSH":
            return 1
        var round_lot_str = self._dict.get("round_lot", "100")
        return Int(round_lot_str)
    
    fn listed_date(self) raises -> DateTime:
        var ds = self._dict.get("listed_date", "1990-01-01")
        return fix_date(ds, DateTime(1990, 1, 1, 0, 0, 0, 0))
    
    fn de_listed_date(self) raises -> DateTime:
        var ds = self._dict.get("de_listed_date", "2999-12-31")
        return fix_date(ds, DateTime(2999, 12, 31, 0, 0, 0, 0))
    
    fn type(self) -> INSTRUMENT_TYPE:
        var type_str = self._dict.get("type", "CS")
        if type_str == "CS":
            return INSTRUMENT_TYPE_CS
        elif type_str == "INDX":
            return INSTRUMENT_TYPE_INDX
        elif type_str == "ETF":
            return INSTRUMENT_TYPE_ETF
        elif type_str == "LOF":
            return INSTRUMENT_TYPE_LOF
        elif type_str == "Future":
            return INSTRUMENT_TYPE_FUTURE
        elif type_str == "Option":
            return INSTRUMENT_TYPE_OPTION
        elif type_str == "Bond":
            return INSTRUMENT_TYPE_BOND
        elif type_str == "Convertible":
            return INSTRUMENT_TYPE_CONVERTIBLE
        else:
            return INSTRUMENT_TYPE_CS
    
    fn exchange(self) -> EXCHANGE:
        var exchange_str = self._dict.get("exchange", "XSHE")
        if exchange_str == "XSHG":
            return EXCHANGE_XSHG
        elif exchange_str == "XSHE":
            return EXCHANGE_XSHE
        elif exchange_str == "SHFE":
            return EXCHANGE_SHFE
        elif exchange_str == "DCE":
            return EXCHANGE_DCE
        elif exchange_str == "CZCE":
            return EXCHANGE_CZCE
        elif exchange_str == "CFFEX":
            return EXCHANGE_CFFEX
        elif exchange_str == "INE":
            return EXCHANGE_INE
        else:
            return EXCHANGE_XSHE
    
    fn market_tplus(self) raises -> Int:
        var market_tplus_str = self._dict.get("market_tplus", "0")
        return Int(market_tplus_str)
    
    fn sector_code(self) -> String:
        return self._dict.get("sector_code", "")
    
    fn sector_code_name(self) -> String:
        return self._dict.get("sector_code_name", "")
    
    fn industry_code(self) -> String:
        return self._dict.get("industry_code", "")
    
    fn industry_name(self) -> String:
        return self._dict.get("industry_name", "")
    
    fn concept_names(self) -> String:
        return self._dict.get("concept_names", "")
    
    fn board_type(self) -> String:
        return self._dict.get("board_type", "MainBoard")
    
    fn status(self) -> String:
        return self._dict.get("status", "Active")
    
    fn special_type(self) -> String:
        return self._dict.get("special_type", "Normal")
    
    fn contract_multiplier(self) raises -> Float64:
        var cm_str = self._dict.get("contract_multiplier", "1.0")
        return Float64(cm_str)
    
    fn underlying_order_book_id(self) -> String:
        return self._dict.get("underlying_order_book_id", "")
    
    fn underlying_symbol(self) -> String:
        return self._dict.get("underlying_symbol", "")
    
    fn maturity_date(self) raises -> DateTime:
        var ds = self._dict.get("maturity_date", "2999-12-31")
        return fix_date(ds, DateTime(2999, 12, 31, 0, 0, 0, 0))
    
    fn settlement_method(self) -> String:
        return self._dict.get("settlement_method", "")
    
    fn account_type(self) -> DEFAULT_ACCOUNT_TYPE:
        if is_instrument_type_in_stock_account(self.type()):
            return DEFAULT_ACCOUNT_TYPE_STOCK
        elif self.type() == INSTRUMENT_TYPE_FUTURE:
            return DEFAULT_ACCOUNT_TYPE_FUTURE
        else:
            return DEFAULT_ACCOUNT_TYPE_STOCK
    
    fn active_at(self, dt: DateTime) raises -> Bool:
        return self.listed_at(dt) and not self.de_listed_at(dt)
    
    fn listed_at(self, dt: DateTime) raises -> Bool:
        var listed_cmp = self.listed_date().year * 10000 + self.listed_date().month * 100 + self.listed_date().day
        var dt_cmp = dt.year * 10000 + dt.month * 100 + dt.day
        return listed_cmp <= dt_cmp
    
    fn de_listed_at(self, dt: DateTime) raises -> Bool:
        var de_listed_cmp = self.de_listed_date().year * 10000 + self.de_listed_date().month * 100 + self.de_listed_date().day
        var dt_cmp = dt.year * 10000 + dt.month * 100 + dt.day
        if self.type() == INSTRUMENT_TYPE_FUTURE or self.type() == INSTRUMENT_TYPE_OPTION:
            return dt_cmp > de_listed_cmp
        else:
            return dt_cmp >= de_listed_cmp
    
    fn trading_hours(self) raises -> List[TimeRange]:
        var trading_hours_str = self._dict.get("trading_hours", "")
        
        if len(trading_hours_str) == 0:
            if is_instrument_type_in_stock_account(self.type()):
                var result = List[TimeRange]()
                result.append(TimeRange(9, 31, 11, 30))
                result.append(TimeRange(13, 1, 15, 0))
                return result^
            return List[TimeRange]()
        
        var trading_period = List[TimeRange]()
        var hours_str = trading_hours_str
        
        var parts = List[String]()
        var current = ""
        
        for i in range(len(hours_str)):
            if hours_str[i:i+1] == ",":
                if len(current) > 0:
                    parts.append(current)
                    current = ""
            else:
                current = current + hours_str[i:i+1]
        if len(current) > 0:
            parts.append(current)
        
        for i in range(len(parts)):
            var part = parts[i]
            var num_str = ""
            var numbers = List[Int]()
            
            for j in range(len(part)):
                var c = part[j:j+1]
                if c == ":" or c == "-":
                    if len(num_str) > 0:
                        numbers.append(Int(num_str))
                        num_str = ""
                else:
                    num_str = num_str + c
            
            if len(num_str) > 0:
                numbers.append(Int(num_str))
            
            if len(numbers) >= 4:
                var start_h = numbers[0]
                var start_m = numbers[1]
                var end_h = numbers[2]
                var end_m = numbers[3]
                
                if start_h > end_h or (start_h == end_h and start_m > end_m):
                    trading_period.append(TimeRange(start_h, start_m, 23, 59))
                    trading_period.append(TimeRange(0, 0, end_h, end_m))
                else:
                    trading_period.append(TimeRange(start_h, start_m, end_h, end_m))
        
        return trading_period^
    
    fn during_continuous_auction(self, hour: Int, minute: Int) raises -> Bool:
        var trading_hours = self.trading_hours()
        for i in range(len(trading_hours)):
            var time_range = trading_hours[i]
            var start_minutes = time_range.start_hour * 60 + time_range.start_minute
            var end_minutes = time_range.end_hour * 60 + time_range.end_minute
            var current_minutes = hour * 60 + minute
            
            if start_minutes <= current_minutes and current_minutes <= end_minutes:
                return True
        return False
    
    fn trading_code(self) -> String:
        return self._dict.get("trading_code", self.order_book_id())
    
    fn trade_at_night(self) raises -> Bool:
        var trading_hours = self.trading_hours()
        for i in range(len(trading_hours)):
            var r = trading_hours[i]
            if r.start_hour < 4 or r.end_hour >= 19:
                return True
        return False
    
    fn min_order_quantity(self) raises -> Int:
        return self.round_lot()
    
    fn order_step_size(self) raises -> Int:
        var board_type = self.board_type()
        if board_type == "KSH" or board_type == "BJS":
            return 1
        return self.round_lot()
    
    fn during_call_auction(self, dt: DateTime) raises -> Bool:
        var _minute = dt.hour * 60 + dt.minute
        
        if self.type() == INSTRUMENT_TYPE_CS or self.type() == INSTRUMENT_TYPE_ETF:
            return _minute < 9 * 60 + 30 or _minute >= 14 * 60 + 57
        elif self.type() == INSTRUMENT_TYPE_FUTURE:
            var trading_hours = self.trading_hours()
            if len(trading_hours) > 0:
                var start_time = trading_hours[0]
                var start_minute = start_time.start_hour * 60 + start_time.start_minute - 1
                return start_minute - 5 <= _minute and _minute < start_minute
            return False
        else:
            return False
    
    fn days_from_listed(self, trading_dt: DateTime) raises -> Int:
        var listed_date = self.listed_date()
        if listed_date.year == 1990 and listed_date.month == 1 and listed_date.day == 1:
            return -1
        
        var de_listed_cmp = self.de_listed_date().year * 10000 + self.de_listed_date().month * 100 + self.de_listed_date().day
        var dt_cmp = trading_dt.year * 10000 + trading_dt.month * 100 + trading_dt.day
        
        if dt_cmp > de_listed_cmp:
            return -1
        
        var ipo_days = (trading_dt.year - listed_date.year) * 365 + (trading_dt.month - listed_date.month) * 30 + (trading_dt.day - listed_date.day)
        return ipo_days if ipo_days >= 0 else -1
    
    fn days_to_expire(self, trading_dt: DateTime) raises -> Int:
        if self.type() != INSTRUMENT_TYPE_FUTURE:
            return -1
        
        if is_future_continuous_contract(self.order_book_id()):
            return -1
        
        var maturity_cmp = self.maturity_date().year * 10000 + self.maturity_date().month * 100 + self.maturity_date().day
        var dt_cmp = trading_dt.year * 10000 + trading_dt.month * 100 + trading_dt.day
        
        var days = (self.maturity_date().year - trading_dt.year) * 365 + (self.maturity_date().month - trading_dt.month) * 30 + (self.maturity_date().day - trading_dt.day)
        return days if days >= 0 else -1
    
    fn tick_size(self) -> Float64:
        if self.type() == INSTRUMENT_TYPE_CS or self.type() == INSTRUMENT_TYPE_INDX:
            return 0.01
        elif self.type() == INSTRUMENT_TYPE_ETF or self.type() == INSTRUMENT_TYPE_LOF:
            return 0.001
        elif self.type() == INSTRUMENT_TYPE_FUTURE:
            return self._futures_tick_size_getter_result
        else:
            return 0.01
    
    fn get_long_margin_ratio(self) raises -> Float64:
        var ratio_str = self._dict.get("long_margin_ratio", "0.1")
        return Float64(ratio_str)
    
    fn get_short_margin_ratio(self) raises -> Float64:
        var ratio_str = self._dict.get("short_margin_ratio", "0.1")
        return Float64(ratio_str)
    
    fn calc_cash_occupation(self, price: Float64, quantity: Int, direction: POSITION_DIRECTION, margin_multiplier: Float64) raises -> Float64:
        if is_instrument_type_in_stock_account(self.type()):
            return price * quantity
        elif self.type() == INSTRUMENT_TYPE_FUTURE:
            var margin_rate = self.get_long_margin_ratio()
            if direction == POSITION_DIRECTION_SHORT:
                margin_rate = self.get_short_margin_ratio()
            return price * quantity * self.contract_multiplier() * margin_rate * margin_multiplier
        else:
            return price * quantity


fn is_future_continuous_contract(order_book_id: String) -> Bool:
    if len(order_book_id) < 3:
        return False
    
    var last_two = order_book_id[len(order_book_id)-2:len(order_book_id)]
    if last_two == "88" or last_two == "99":
        return True
    
    if len(order_book_id) >= 3:
        var last_three = order_book_id[len(order_book_id)-3:len(order_book_id)]
        if last_three == "888" or last_three == "889":
            return True
    
    return False


fn create_instrument_from_dict(var data: Dict[String, String], futures_tick_size_getter_result: Float64 = 1.0, market: MARKET = MARKET_CN) -> Instrument:
    return Instrument(
        _dict=data^,
        _futures_tick_size_getter_result=futures_tick_size_getter_result,
        market=market
    )
