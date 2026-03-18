# test_L03_01_instrument.mojo
# Module: rqmojo.model.instrument
# Python: rqalpha.model.instrument
# Level: L03 - Data Model
# Dependencies: const, datetime_func

from rqmojo.model.instrument import (
    Instrument, create_stock_instrument, create_future_instrument,
    create_etf_instrument, create_bond_instrument, create_lof_instrument,
    create_index_instrument, create_option_instrument,
    is_instrument_type_in_stock_account
)
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, MARKET, DEFAULT_ACCOUNT_TYPE, POSITION_DIRECTION
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct TestRunner:
    var test_count: Int
    var pass_count: Int
    
    fn check(mut self, condition: Bool, test_name: String):
        self.test_count += 1
        if condition:
            self.pass_count += 1
            print("PASS: " + test_name)
        else:
            print("FAIL: " + test_name)

    fn test_create_stock_instrument(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE())
        self.check(ins.order_book_id == "000001.XSHE", "Stock order_book_id")
        self.check(ins.symbol == "平安银行", "Stock symbol")
        self.check(ins.type == INSTRUMENT_TYPE.CS(), "Stock type is CS")
        self.check(ins.round_lot == 100, "Stock round_lot is 100")

    fn test_create_future_instrument(mut self):
        var listed = DateTime(2023, 1, 1, 0, 0, 0, 0)
        var de_listed = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var maturity = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var ins = create_future_instrument("IF2401.CFFEX", "沪深2401", listed, de_listed, maturity, 300.0, EXCHANGE.CFFEX(), "IF")
        self.check(ins.order_book_id == "IF2401.CFFEX", "Future order_book_id")
        self.check(ins.type == INSTRUMENT_TYPE.FUTURE(), "Future type is FUTURE")
        self.check(ins.contract_multiplier == 300.0, "Future contract_multiplier is 300")
        self.check(ins.round_lot == 1, "Future round_lot is 1")

    fn test_create_etf_instrument(mut self):
        var listed = DateTime(2004, 1, 1, 0, 0, 0, 0)
        var ins = create_etf_instrument("510050.XSHG", "50ETF", listed, EXCHANGE.XSHG())
        self.check(ins.order_book_id == "510050.XSHG", "ETF order_book_id")
        self.check(ins.type == INSTRUMENT_TYPE.ETF(), "ETF type is ETF")

    fn test_create_bond_instrument(mut self):
        var listed = DateTime(2020, 1, 1, 0, 0, 0, 0)
        var ins = create_bond_instrument("110000.XSHG", "测试债券", listed, EXCHANGE.XSHG())
        self.check(ins.type == INSTRUMENT_TYPE.BOND(), "Bond type is BOND")
        self.check(ins.round_lot == 10, "Bond round_lot is 10")

    fn test_create_lof_instrument(mut self):
        var listed = DateTime(2010, 1, 1, 0, 0, 0, 0)
        var ins = create_lof_instrument("161725.XSHE", "测试LOF", listed, EXCHANGE.XSHE())
        self.check(ins.type == INSTRUMENT_TYPE.LOF(), "LOF type is LOF")

    fn test_create_index_instrument(mut self):
        var listed = DateTime(2000, 1, 1, 0, 0, 0, 0)
        var ins = create_index_instrument("000300.XSHG", "沪深300", listed, EXCHANGE.XSHG())
        self.check(ins.type == INSTRUMENT_TYPE.INDX(), "Index type is INDX")

    fn test_create_option_instrument(mut self):
        var listed = DateTime(2023, 1, 1, 0, 0, 0, 0)
        var de_listed = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var maturity = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var ins = create_option_instrument("10000001.SH", "测试期权", listed, de_listed, maturity, 10000.0, EXCHANGE.XSHG(), "510050")
        self.check(ins.type == INSTRUMENT_TYPE.OPTION(), "Option type is OPTION")

    fn test_instrument_tick_size_stock(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE())
        self.check(ins.tick_size() == 0.01, "Stock tick_size is 0.01")

    fn test_instrument_tick_size_etf(mut self):
        var listed = DateTime(2004, 1, 1, 0, 0, 0, 0)
        var ins = create_etf_instrument("510050.XSHG", "50ETF", listed, EXCHANGE.XSHG())
        self.check(ins.tick_size() == 0.001, "ETF tick_size is 0.001")

    fn test_instrument_tick_size_future(mut self):
        var listed = DateTime(2023, 1, 1, 0, 0, 0, 0)
        var de_listed = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var maturity = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var ins = create_future_instrument("IF2401.CFFEX", "沪深2401", listed, de_listed, maturity, 300.0, EXCHANGE.CFFEX(), "IF")
        self.check(ins.tick_size() == 1.0, "Future tick_size is 1.0")

    fn test_instrument_account_type_stock(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE())
        self.check(ins.account_type() == DEFAULT_ACCOUNT_TYPE.STOCK(), "Stock account_type is STOCK")

    fn test_instrument_account_type_future(mut self):
        var listed = DateTime(2023, 1, 1, 0, 0, 0, 0)
        var de_listed = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var maturity = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var ins = create_future_instrument("IF2401.CFFEX", "沪深2401", listed, de_listed, maturity, 300.0, EXCHANGE.CFFEX(), "IF")
        self.check(ins.account_type() == DEFAULT_ACCOUNT_TYPE.FUTURE(), "Future account_type is FUTURE")

    fn test_instrument_listed_at(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE())
        var dt1 = DateTime(2020, 1, 1, 0, 0, 0, 0)
        var dt2 = DateTime(1990, 1, 1, 0, 0, 0, 0)
        self.check(ins.listed_at(dt1) == True, "Instrument listed_at 2020 is True")
        self.check(ins.listed_at(dt2) == False, "Instrument listed_at 1990 is False")

    fn test_instrument_de_listed_at(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE())
        ins.de_listed_date = DateTime(2020, 1, 1, 0, 0, 0, 0)
        var dt1 = DateTime(2020, 1, 1, 0, 0, 0, 0)
        var dt2 = DateTime(2019, 12, 31, 0, 0, 0, 0)
        self.check(ins.de_listed_at(dt1) == True, "Instrument de_listed_at 2020-01-01 is True")
        self.check(ins.de_listed_at(dt2) == False, "Instrument de_listed_at 2019-12-31 is False")

    fn test_instrument_active_at(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE())
        var dt = DateTime(2020, 1, 1, 0, 0, 0, 0)
        self.check(ins.active_at(dt) == True, "Instrument active_at 2020 is True")

    fn test_instrument_is_future_continuous_contract_88(mut self):
        var listed = DateTime(2023, 1, 1, 0, 0, 0, 0)
        var de_listed = DateTime(2999, 12, 31, 0, 0, 0, 0)
        var maturity = DateTime(2999, 12, 31, 0, 0, 0, 0)
        var ins = create_future_instrument("IF88", "IF主力", listed, de_listed, maturity, 300.0, EXCHANGE.CFFEX(), "IF")
        self.check(ins.is_future_continuous_contract() == True, "IF88 is continuous contract")

    fn test_instrument_is_future_continuous_contract_99(mut self):
        var listed = DateTime(2023, 1, 1, 0, 0, 0, 0)
        var de_listed = DateTime(2999, 12, 31, 0, 0, 0, 0)
        var maturity = DateTime(2999, 12, 31, 0, 0, 0, 0)
        var ins = create_future_instrument("IF99", "IF指数", listed, de_listed, maturity, 300.0, EXCHANGE.CFFEX(), "IF")
        self.check(ins.is_future_continuous_contract() == True, "IF99 is continuous contract")

    fn test_instrument_is_future_continuous_contract_normal(mut self):
        var listed = DateTime(2023, 1, 1, 0, 0, 0, 0)
        var de_listed = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var maturity = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var ins = create_future_instrument("IF2401.CFFEX", "沪深2401", listed, de_listed, maturity, 300.0, EXCHANGE.CFFEX(), "IF")
        self.check(ins.is_future_continuous_contract() == False, "IF2401 is not continuous contract")

    fn test_instrument_str(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE())
        var str_repr = ins.__str__()
        self.check(str_repr.find("Instrument") >= 0, "Instrument __str__ contains Instrument")
        self.check(str_repr.find("000001.XSHE") >= 0, "Instrument __str__ contains order_book_id")

    fn test_instrument_calc_cash_occupation_stock(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE())
        var cash = ins.calc_cash_occupation(10.0, 100, POSITION_DIRECTION.LONG(), 1.0, 1.0)
        self.check(cash == 1000.0, "Stock calc_cash_occupation is price * quantity")

    fn test_instrument_calc_cash_occupation_future(mut self):
        var listed = DateTime(2023, 1, 1, 0, 0, 0, 0)
        var de_listed = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var maturity = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var ins = create_future_instrument("IF2401.CFFEX", "沪深2401", listed, de_listed, maturity, 300.0, EXCHANGE.CFFEX(), "IF")
        var cash = ins.calc_cash_occupation(4000.0, 1, POSITION_DIRECTION.LONG(), 1.0, 0.1)
        self.check(cash == 120000.0, "Future calc_cash_occupation with margin")

    fn test_is_instrument_type_in_stock_account(mut self):
        self.check(is_instrument_type_in_stock_account(INSTRUMENT_TYPE.CS()) == True, "CS is in stock account")
        self.check(is_instrument_type_in_stock_account(INSTRUMENT_TYPE.ETF()) == True, "ETF is in stock account")
        self.check(is_instrument_type_in_stock_account(INSTRUMENT_TYPE.FUTURE()) == False, "FUTURE is not in stock account")

    fn test_instrument_days_from_listed(mut self):
        var listed = DateTime(2020, 1, 1, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE())
        var dt = DateTime(2020, 1, 31, 0, 0, 0, 0)
        var days = ins.days_from_listed(dt)
        self.check(days >= 0, "Instrument days_from_listed returns non-negative")

    fn test_instrument_trade_at_night(mut self):
        var listed = DateTime(2023, 1, 1, 0, 0, 0, 0)
        var de_listed = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var maturity = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var ins = create_future_instrument("IF2401.CFFEX", "沪深2401", listed, de_listed, maturity, 300.0, EXCHANGE.CFFEX(), "IF")
        self.check(ins.trade_at_night() == False, "IF2401 trade_at_night is False for day session")

    fn run_all(mut self):
        print("=" * 60)
        print("L03_01_instrument Module Tests")
        print("=" * 60)
        
        self.test_create_stock_instrument()
        self.test_create_future_instrument()
        self.test_create_etf_instrument()
        self.test_create_bond_instrument()
        self.test_create_lof_instrument()
        self.test_create_index_instrument()
        self.test_create_option_instrument()
        self.test_instrument_tick_size_stock()
        self.test_instrument_tick_size_etf()
        self.test_instrument_tick_size_future()
        self.test_instrument_account_type_stock()
        self.test_instrument_account_type_future()
        self.test_instrument_listed_at()
        self.test_instrument_de_listed_at()
        self.test_instrument_active_at()
        self.test_instrument_is_future_continuous_contract_88()
        self.test_instrument_is_future_continuous_contract_99()
        self.test_instrument_is_future_continuous_contract_normal()
        self.test_instrument_str()
        self.test_instrument_calc_cash_occupation_stock()
        self.test_instrument_calc_cash_occupation_future()
        self.test_is_instrument_type_in_stock_account()
        self.test_instrument_days_from_listed()
        self.test_instrument_trade_at_night()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
