"""
Test for mod/rqmojo_mod_sys_risk/validators/price_validator.mojo
Group 09 - File 2
"""

from rqmojo.mod.rqmojo_mod_sys_risk.validators.price_validator import PriceValidator, create_price_validator
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.portfolio.account import Account

from std.testing import assert_true, TestSuite
from std.collections import Optional

from rqmojo.const import SIDE
from rqmojo.model.order import LimitOrder, MarketOrder, create_order_with_id


def test_price_validator_init() raises:
    var dp = create_data_proxy()
    var _ = create_price_validator(dp^)
    assert_true(True, "PriceValidator init succeeded")


def test_price_validator_validate_submission_market_order() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = create_order_with_id(1, "000001.XSHE", SIDE.BUY, 100, MarketOrder())
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Market order should return None")


def test_price_validator_validate_cancellation() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = create_order_with_id(1, "000001.XSHE", SIDE.BUY, 100, LimitOrder(10.0))
    var result = validator.validate_cancellation(order, Optional[Account](None))
    assert_true(result is None, "validate_cancellation should return None")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
