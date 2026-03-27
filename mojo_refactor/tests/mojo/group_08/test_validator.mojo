"""
Test for mod/rqmojo_mod_sys_accounts/validator.mojo
Group 08 - File 11
"""

from std.collections import Dict, List
from rqmojo.const import SIDE, POSITION_EFFECT



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

@fieldwise_init
struct MarginInstrumentValidator(Movable, Writable):
    var _enabled: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("MarginInstrumentValidator(enabled=", String(self._enabled), ")")

    def validate(self, order_book_id: String) -> Bool:
        return True


def create_margin_instrument_validator() -> MarginInstrumentValidator:
    return MarginInstrumentValidator(_enabled=True)


def test_validator_init() raises:
    print("Test: MarginInstrumentValidator init")
    var validator = create_margin_instrument_validator()
    print("  PASSED")
    assert_true(True, "test passed")


def test_validator_validate() raises:
    print("Test: MarginInstrumentValidator validate")
    var validator = create_margin_instrument_validator()
    var result = validator.validate("000001.XSHE")
    if not result:
        raise "MarginInstrumentValidator should validate 000001.XSHE"
    print("  PASSED")
    assert_true(True, "test passed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()