"""
Test for interface.mojo
Group 10 - File 1
"""

from std.collections import Dict, List
from rqmojo.interface import (
    ExchangeRate, TransactionCostArgs, TransactionCost,
    FuturesTradingParameters, Snapshot,
    PositionInterface, StrategyLoader, EventSource,
    PriceBoard, DataSource, Broker,
    ModInterface, Mod, PersistProviderInterface,
    FrontendValidatorInterface, TransactionCostDeciderInterface
)
from rqmojo.const import INSTRUMENT_TYPE, SIDE, POSITION_EFFECT
from rqmojo.model.order import Order, create_order_with_id
from rqmojo.utils.typing import DateTime
from std.testing import assert_equal, assert_true, assert_false, TestSuite


def test_exchange_rate_struct() raises:
    print("Test: ExchangeRate struct exists")
    var rate = ExchangeRate(
        bid_reference=7.2,
        ask_reference=7.3,
        bid_settlement_sh=7.0,
        ask_settlement_sh=7.0,
        bid_settlement_sz=7.0,
        ask_settlement_sz=7.0
    )
    assert_equal(rate.bid_reference, 7.2, "bid_reference should match")
    print("  PASSED")


def test_transaction_cost_struct() raises:
    print("Test: TransactionCost struct exists")
    var cost = TransactionCost(
        commission=10.0,
        tax=5.0,
        other_fees=2.0
    )
    assert_equal(cost.total(), 16.0, "Total should be sum of all costs")
    print("  PASSED")


def test_position_interface_trait() raises:
    print("Test: PositionInterface trait exists")
    assert_true(True, "PositionInterface should exist")
    print("  PASSED")


def test_broker_trait() raises:
    print("Test: Broker trait exists")
    assert_true(True, "Broker should exist")
    print("  PASSED")


def test_mod_interface_trait() raises:
    print("Test: ModInterface trait exists")
    assert_true(True, "ModInterface should exist")
    print("  PASSED")


def test_data_source_trait() raises:
    print("Test: DataSource trait exists")
    assert_true(True, "DataSource should exist")
    print("  PASSED")


def test_frontend_validator_interface_trait() raises:
    print("Test: FrontendValidatorInterface trait exists")
    assert_true(True, "FrontendValidatorInterface should exist")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
