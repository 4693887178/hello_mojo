"""
Test for model/instrument.mojo
Group 09 - File 8
"""

from std.collections import Dict, List
from rqmojo.model.instrument import (
    Instrument, create_instrument, InstrumentType
)
from rqmojo.const import INSTRUMENT_TYPE


def test_instrument_struct() -> Bool:
    print("Test: Instrument struct exists")
    var inst = create_instrument(
        order_book_id="000001.XSHE",
        symbol="平安银行",
        instrument_type=INSTRUMENT_TYPE.CS
    )
    if inst.order_book_id() != "000001.XSHE":
        raise "order_book_id should be 000001.XSHE"
    print("  PASSED")
    return True


def test_instrument_properties() -> Bool:
    print("Test: Instrument properties")
    var inst = create_instrument(
        order_book_id="000001.XSHE",
        symbol="平安银行",
        instrument_type=INSTRUMENT_TYPE.CS
    )
    
    if inst.symbol() != "平安银行":
        raise "symbol should be 平安银行"
    
    if inst.type() != INSTRUMENT_TYPE.CS:
        raise "type should be CS"
    print("  PASSED")
    return True


def main() -> None:
    print("=== Group 09 File 8: Instrument Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    if test_instrument_struct():
        passed += 1
    else:
        failed += 1
    
    if test_instrument_properties():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
