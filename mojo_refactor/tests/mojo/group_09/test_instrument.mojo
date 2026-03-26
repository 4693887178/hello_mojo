"""
Test for model/instrument.mojo
Group 09 - File 8
"""

from std.collections import Dict, List
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE
from rqmojo.utils.typing import DateTime


fn test_instrument_struct() -> Bool:
    print("Test: Instrument struct exists")
    var inst = create_stock_instrument(
        order_book_id="000001.XSHE",
        symbol="平安银行",
        listed_date=DateTime(1991, 4, 3, 0, 0, 0, 0),
        exchange=EXCHANGE.XSHE
    )
    if inst.order_book_id() != "000001.XSHE":
        return False
    print("  PASSED")
    return True


fn test_instrument_properties() -> Bool:
    print("Test: Instrument properties")
    var inst = create_stock_instrument(
        order_book_id="000001.XSHE",
        symbol="平安银行",
        listed_date=DateTime(1991, 4, 3, 0, 0, 0, 0),
        exchange=EXCHANGE.XSHE
    )
    
    if inst.symbol() != "平安银行":
        return False
    
    if inst.type() != INSTRUMENT_TYPE.CS:
        return False
    print("  PASSED")
    return True


fn test_instrument_exchange() -> Bool:
    print("Test: Instrument exchange")
    var inst = create_stock_instrument(
        order_book_id="000001.XSHE",
        symbol="平安银行",
        listed_date=DateTime(1991, 4, 3, 0, 0, 0, 0),
        exchange=EXCHANGE.XSHE
    )
    
    if inst.exchange() != EXCHANGE.XSHE:
        return False
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 8: Instrument Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_instrument_struct():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_instrument_properties():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_instrument_exchange():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
