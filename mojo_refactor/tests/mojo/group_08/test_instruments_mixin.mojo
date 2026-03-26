"""
Test for data/instruments_mixin.mojo
Group 08 - File 3
"""

from rqmojo.data.instruments_mixin import InstrumentsMixin
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE
from rqmojo.utils.typing import DateTime


fn test_instruments_mixin_init() -> Bool:
    print("Test: InstrumentsMixin init")
    var mixin = InstrumentsMixin()
    print("  PASSED")
    return True


fn test_instruments_mixin_get_instrument() -> Bool:
    print("Test: InstrumentsMixin get_instrument")
    var mixin = InstrumentsMixin()
    var ins = mixin.get_instrument("000001.XSHE")
    print("  PASSED")
    return True


fn test_instruments_mixin_all_instruments() -> Bool:
    print("Test: InstrumentsMixin all_instruments")
    var mixin = InstrumentsMixin()
    var all = mixin.all_instruments()
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 08 File 3: Instruments Mixin Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_instruments_mixin_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_instruments_mixin_get_instrument():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_instruments_mixin_all_instruments():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
