from std.testing import assert_equal, assert_true, TestSuite
from rqmojo.interface import (
    ExchangeRate, TransactionCostArgs, TransactionCost,
    FuturesTradingParameters, Snapshot, PositionInterface, StrategyLoader, EventSource,
    PriceBoard, DataSource, Broker, ModInterface, PersistProviderInterface,
    FrontendValidatorInterface, TransactionCostDeciderInterface
)
from rqmojo.const import SIDE, POSITION_EFFECT
from rqmojo.utils.typing import DateTime
from morrow import Morrow


def test_exchange_rate_struct() raises:
    """Test ExchangeRate struct initialization and fields."""
    rate = ExchangeRate(
        bid_reference=6.5,
        ask_reference=6.6,
        bid_settlement_sh=6.55,
        ask_settlement_sh=6.65,
        bid_settlement_sz=0.85,
        ask_settlement_sz=0.86
    )
    
    assert_equal(rate.bid_reference, 6.5)
    assert_equal(rate.ask_reference, 6.6)
    assert_equal(rate.bid_settlement_sh, 6.55)
    assert_equal(rate.ask_settlement_sh, 6.65)
    assert_equal(rate.bid_settlement_sz, 0.85)
    assert_equal(rate.ask_settlement_sz, 0.86)


def test_transaction_cost_args_struct() raises:
    """Test TransactionCostArgs struct with optional order_id."""
    args_with_order = TransactionCostArgs(
        instrument_order_book_id="000001.XSHE",
        price=10.5,
        quantity=1000,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=12345,
        close_today_quantity=0
    )
    
    assert_equal(args_with_order.instrument_order_book_id, "000001.XSHE")
    assert_equal(args_with_order.price, 10.5)
    assert_equal(args_with_order.quantity, 1000)
    
    args_without_order = TransactionCostArgs(
        instrument_order_book_id="000001.XSHE",
        price=10.5,
        quantity=1000,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=None,
        close_today_quantity=0
    )
    
    assert_true(args_without_order.order_id == None)


def test_transaction_cost_struct() raises:
    """Test TransactionCost struct with total method and zero static."""
    cost = TransactionCost(commission=7.5, tax=10.0, other_fees=1.0)
    
    assert_equal(cost.commission, 7.5)
    assert_equal(cost.tax, 10.0)
    assert_equal(cost.other_fees, 1.0)
    assert_equal(cost.total(), 18.5)
    
    zero_cost = TransactionCost.zero()
    assert_equal(zero_cost.commission, 0.0)
    assert_equal(zero_cost.tax, 0.0)
    assert_equal(zero_cost.other_fees, 0.0)
    assert_equal(zero_cost.total(), 0.0)


def test_futures_trading_parameters_struct() raises:
    """Test FuturesTradingParameters struct."""
    params = FuturesTradingParameters(
        open_commission_ratio=0.0001,
        close_commission_ratio=0.0001,
        close_commission_ratio_today=0.0003,
        margin_ratio=0.1
    )
    
    assert_equal(params.open_commission_ratio, 0.0001)
    assert_equal(params.close_commission_ratio, 0.0001)
    assert_equal(params.close_commission_ratio_today, 0.0003)
    assert_equal(params.margin_ratio, 0.1)


def test_snapshot_struct() raises:
    """Test Snapshot struct with all fields."""
    var dt = Morrow(2024, 1, 15, 10, 30, 0)
    snapshot = Snapshot(
        order_book_id="000001.XSHE",
        datetime=dt,
        open=10.0,
        high=11.0,
        low=9.5,
        last=10.5,
        volume=1000000,
        total_turnover=10500000.0,
        prev_close=9.8,
        limit_up=10.78,
        limit_down=8.82
    )
    
    assert_equal(snapshot.order_book_id, "000001.XSHE")
    assert_equal(snapshot.open, 10.0)
    assert_equal(snapshot.high, 11.0)
    assert_equal(snapshot.low, 9.5)
    assert_equal(snapshot.last, 10.5)
    assert_equal(snapshot.volume, 1000000)
    assert_equal(snapshot.total_turnover,10500000.0)
    assert_equal(snapshot.prev_close, 9.8)
    assert_equal(snapshot.limit_up, 10.78)
    assert_equal(snapshot.limit_down, 8.82)


def test_trait_definitions_exist() raises:
    """Test that all trait definitions are properly defined."""
    from rqmojo.interface import (
        Persistable as P,
        PositionInterface as PI,
        StrategyLoader as SL,
        EventSource as ES,
        PriceBoard as PB,
        DataSource as DS,
        Broker as BK,
        ModInterface as MI,
        PersistProviderInterface as PPI,
        FrontendValidatorInterface as FVI,
        TransactionCostDeciderInterface as TCDI
    )
    
    assert_true(True)


def test_mod_alias() raises:
    """Test that Mod alias is properly defined."""
    from rqmojo.interface import Mod
    assert_true(True)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
