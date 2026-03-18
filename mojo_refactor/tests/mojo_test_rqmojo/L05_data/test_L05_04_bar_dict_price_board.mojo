# test_L05_04_bar_dict_price_board.mojo
# Module: rqmojo.data.bar_dict_price_board
# Python: rqalpha.data.bar_dict_price_board
# Level: L05 - Data Layer
# Dependencies: interface, model

from rqmojo.data.bar_dict_price_board import BarDictPriceBoard, create_bar_dict_price_board, nan_f64
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.model.instrument import create_stock_instrument
from rqmojo.const import EXECUTION_PHASE, EXCHANGE
from rqmojo.utils.datetime_func import DateTime


fn is_nan(value: Float64) -> Bool:
    return value != value


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

    fn test_create_bar_dict_price_board(mut self):
        var board = create_bar_dict_price_board()
        self.check(True, "BarDictPriceBoard created successfully")

    fn test_get_last_price_empty(mut self):
        var board = create_bar_dict_price_board()
        var price = board.get_last_price("000001.XSHE")
        self.check(price == 0.0, "BarDictPriceBoard get_last_price empty returns 0.0")

    fn test_get_limit_up_empty(mut self):
        var board = create_bar_dict_price_board()
        var price = board.get_limit_up("000001.XSHE")
        self.check(price == 0.0, "BarDictPriceBoard get_limit_up empty returns 0.0")

    fn test_get_limit_down_empty(mut self):
        var board = create_bar_dict_price_board()
        var price = board.get_limit_down("000001.XSHE")
        self.check(price == 0.0, "BarDictPriceBoard get_limit_down empty returns 0.0")

    fn test_set_bar_and_get_last_price(mut self):
        var board = create_bar_dict_price_board()
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", DateTime(1991, 4, 3, 0, 0, 0, 0), EXCHANGE.XSHE())
        var bar = create_bar_object(
            instrument=ins,
            dt=dt,
            open=10.0,
            high=10.5,
            low=9.8,
            close=10.2,
            volume=1000000.0,
            total_turnover=10200000.0,
            limit_up=11.0,
            limit_down=9.0
        )
        board.set_bar("000001.XSHE", bar)
        var price = board.get_last_price("000001.XSHE")
        self.check(price == 10.2, "BarDictPriceBoard get_last_price is 10.2")

    fn test_set_bar_and_get_limit_up(mut self):
        var board = create_bar_dict_price_board()
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", DateTime(1991, 4, 3, 0, 0, 0, 0), EXCHANGE.XSHE())
        var bar = create_bar_object(
            instrument=ins,
            dt=dt,
            open=10.0,
            high=10.5,
            low=9.8,
            close=10.2,
            volume=1000000.0,
            total_turnover=10200000.0,
            limit_up=11.0,
            limit_down=9.0
        )
        board.set_bar("000001.XSHE", bar)
        var price = board.get_limit_up("000001.XSHE")
        self.check(price == 11.0, "BarDictPriceBoard get_limit_up is 11.0")

    fn test_set_bar_and_get_limit_down(mut self):
        var board = create_bar_dict_price_board()
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", DateTime(1991, 4, 3, 0, 0, 0, 0), EXCHANGE.XSHE())
        var bar = create_bar_object(
            instrument=ins,
            dt=dt,
            open=10.0,
            high=10.5,
            low=9.8,
            close=10.2,
            volume=1000000.0,
            total_turnover=10200000.0,
            limit_up=11.0,
            limit_down=9.0
        )
        board.set_bar("000001.XSHE", bar)
        var price = board.get_limit_down("000001.XSHE")
        self.check(price == 9.0, "BarDictPriceBoard get_limit_down is 9.0")

    fn test_clear_cache(mut self):
        var board = create_bar_dict_price_board()
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", DateTime(1991, 4, 3, 0, 0, 0, 0), EXCHANGE.XSHE())
        var bar = create_bar_object(
            instrument=ins,
            dt=dt,
            open=10.0,
            high=10.5,
            low=9.8,
            close=10.2,
            volume=1000000.0,
            total_turnover=10200000.0,
            limit_up=11.0,
            limit_down=9.0
        )
        board.set_bar("000001.XSHE", bar)
        board.clear_cache()
        var price = board.get_last_price("000001.XSHE")
        self.check(price == 0.0, "BarDictPriceBoard clear_cache works")

    fn test_set_phase(mut self):
        var board = create_bar_dict_price_board()
        board.set_phase(EXECUTION_PHASE.ON_BAR())
        var phase = board.get_phase()
        self.check(phase == EXECUTION_PHASE.ON_BAR(), "BarDictPriceBoard set_phase works")

    fn test_get_a1_is_nan(mut self):
        var board = create_bar_dict_price_board()
        var price = board.get_a1("000001.XSHE")
        self.check(is_nan(price), "BarDictPriceBoard get_a1 returns NaN")

    fn test_get_b1_is_nan(mut self):
        var board = create_bar_dict_price_board()
        var price = board.get_b1("000001.XSHE")
        self.check(is_nan(price), "BarDictPriceBoard get_b1 returns NaN")

    fn run_all(mut self):
        print("=" * 60)
        print("L05_04_bar_dict_price_board Module Tests")
        print("=" * 60)
        
        self.test_create_bar_dict_price_board()
        self.test_get_last_price_empty()
        self.test_get_limit_up_empty()
        self.test_get_limit_down_empty()
        self.test_set_bar_and_get_last_price()
        self.test_set_bar_and_get_limit_up()
        self.test_set_bar_and_get_limit_down()
        self.test_clear_cache()
        self.test_set_phase()
        self.test_get_a1_is_nan()
        self.test_get_b1_is_nan()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
