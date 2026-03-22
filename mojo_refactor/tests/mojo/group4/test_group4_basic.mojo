"""
Test Group 4 files compilation
"""

from rqmojo.utils.logger import user_log, system_log, user_system_log, init_logger, user_print
from rqmojo.utils.arg_checker import check_string, check_int, check_float, check_percentage, check_order_book_id
from rqmojo.utils.class_helper import cached_property, property_repr, make_cached_property
from rqmojo.utils.functools import CachedFunc, memoize, LazyProperty, lazy_property
from rqmojo.model.tick import TickObject, create_tick_object
from rqmojo.model.instrument import Instrument, create_instrument_from_dict
from rqmojo.utils.datetime_func import DateTime
from rqmojo.const import MARKET, MARKET_CN
from std.collections import Dict


def test_logger():
    print("Testing logger module...")
    var log = user_log()
    log.info("Logger test passed")
    print("PASS: test_logger")


def test_arg_checker() raises:
    print("Testing arg_checker module...")
    var result1 = check_string("test", "name")
    print("check_string passed: " + String(result1))
    
    var result2 = check_int(10, "count", 0, 100)
    print("check_int passed: " + String(result2))
    
    var result3 = check_float(5.5, "value", 0.0, 10.0)
    print("check_float passed: " + String(result3))
    
    var result4 = check_percentage(0.5, "ratio")
    print("check_percentage passed: " + String(result4))
    
    var result5 = check_order_book_id("000001.XSHE", "order_book_id")
    print("check_order_book_id passed: " + String(result5))
    print("PASS: test_arg_checker")


def test_class_helper():
    print("Testing class_helper module...")
    var cp = cached_property("test_prop")
    print("cached_property created: " + cp.get_name())
    
    var props = Dict[String, String]()
    props["name"] = "test"
    props["value"] = "123"
    var repr = property_repr("TestObj", props)
    print("property_repr: " + repr)
    print("PASS: test_class_helper")


def test_functools():
    print("Testing functools module...")
    var cf = memoize("test_func", 128)
    print("CachedFunc created with max_size: " + String(cf.max_size))
    
    var lp = lazy_property("lazy_prop")
    print("LazyProperty created: " + lp.name)
    print("PASS: test_functools")


def test_tick():
    print("Testing tick module...")
    var data = Dict[String, String]()
    data["order_book_id"] = "000001.XSHE"
    data["symbol"] = "平安银行"
    data["type"] = "CS"
    data["exchange"] = "XSHE"
    
    var instrument = create_instrument_from_dict(data^, 0.01, MARKET_CN)
    
    var tick = create_tick_object(
        instrument=instrument^,
        dt=DateTime(2024, 1, 15, 10, 30, 0, 0),
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
        open=10.0,
        high=10.8,
        low=9.9,
        prev_close=10.2,
        limit_up=11.22,
        limit_down=9.18
    )
    
    print("TickObject: " + tick.__str__())
    print("order_book_id: " + tick.order_book_id())
    print("last: " + String(tick.last))
    print("close: " + String(tick.close()))
    print("limit_up: " + String(tick.limit_up))
    print("limit_down: " + String(tick.limit_down))
    print("PASS: test_tick")


def main() raises:
    print("=== Testing Group 4 Modules ===")
    test_logger()
    test_arg_checker()
    test_class_helper()
    test_functools()
    test_tick()
    print("=== All Group 4 tests passed! ===")
