"""
Group 5 tests - mod/rqmojo_mod_sys_transaction_cost/__init__.mojo
Tests for Mojo version of transaction cost module init exports.
"""

from rqmojo.const import INSTRUMENT_TYPE, SIDE, POSITION_EFFECT
from rqmojo.interface import TransactionCostArgs, TransactionCost
from rqmojo.mod.rqmojo_mod_sys_transaction_cost.deciders import (
    StockTransactionCostDecider, FutureTransactionCostDecider, BondTransactionCostDecider,
    create_stock_decider, create_future_decider, create_bond_decider
)
from rqmojo.mod.rqmojo_mod_sys_transaction_cost import (
    get_config, get_cli_prefix, get_cli_options, register_cli_options, load_mod
)
from rqmojo.mod.rqmojo_mod_sys_transaction_cost.mod import TransactionCostMod
from argmojo import Argument, Command

from std.testing import assert_equal, assert_true, assert_false, TestSuite


def test_get_config_keys() raises:
    """Test get_config returns all expected keys."""
    var config = get_config()
    assert_true("cn_stock_min_commission" in config)
    assert_true("stock_min_commission" in config)
    assert_true("stock_commission_multiplier" in config)
    assert_true("futures_commission_multiplier" in config)
    assert_true("tax_multiplier" in config)


def test_get_config_values() raises:
    """Test get_config returns correct default values."""
    var config = get_config()
    var cn_min = config["cn_stock_min_commission"]
    assert_equal(cn_min[Float64], -1.0)

    var stock_min = config["stock_min_commission"]
    assert_equal(stock_min[Float64], 5.0)

    var stock_cm = config["stock_commission_multiplier"]
    assert_equal(stock_cm[Float64], 1.0)

    var futures_cm = config["futures_commission_multiplier"]
    assert_equal(futures_cm[Float64], 1.0)

    var tax_m = config["tax_multiplier"]
    assert_equal(tax_m[Float64], 1.0)


def test_get_cli_prefix() raises:
    var prefix = get_cli_prefix()
    assert_equal(prefix, "mod__sys_transaction_cost__")


def test_get_cli_options_count() raises:
    var options = get_cli_options()
    assert_equal(len(options), 7)


def test_get_cli_options_names() raises:
    var options = get_cli_options()
    var names = List[String]()
    for opt in options.copy():
        names.append(opt.name)

    assert_true("commission-multiplier" in names)
    assert_true("stock-commission-multiplier" in names)
    assert_true("futures-commission-multiplier" in names)
    assert_true("cn-stock-min-commission" in names)
    assert_true("stock-min-commission" in names)
    assert_true("tax-multiplier" in names)
    assert_true("pit-tax" in names)


def test_register_cli_options() raises:
    var cmd = Command(name="run", description="test run command")
    register_cli_options(cmd)


def test_load_mod() raises:
    var mod = load_mod()
    assert_equal(mod.name, "transaction_cost")
    assert_true(mod.enabled)


def test_stock_decider_creation() raises:
    var decider = create_stock_decider(
        commission_multiplier=0.0003,
        min_commission=5.0,
        tax_multiplier=1.0,
    )
    assert_equal(decider.commission_multiplier, 0.0003)
    assert_equal(decider.min_commission, 5.0)


def test_stock_decider_calc_buy() raises:
    var decider = create_stock_decider(
        commission_multiplier=0.0003,
        min_commission=5.0,
        tax_multiplier=1.0,
    )

    var args = TransactionCostArgs(
        instrument_order_book_id="000001.XSHE",
        price=10.0,
        quantity=100,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=1,
        close_today_quantity=0,
    )

    var result = decider.calc(args)
    assert_equal(result.tax, 0.0)


def test_stock_decider_calc_sell() raises:
    var decider = create_stock_decider(
        commission_multiplier=0.0003,
        min_commission=5.0,
        tax_multiplier=1.0,
    )

    var args = TransactionCostArgs(
        instrument_order_book_id="000001.XSHE",
        price=10.0,
        quantity=100,
        side=SIDE.SELL,
        position_effect=POSITION_EFFECT.CLOSE,
        order_id=2,
        close_today_quantity=0,
    )

    var result = decider.calc(args)
    assert_true(result.tax > 0.0)


def test_future_decider_creation() raises:
    var decider = create_future_decider(commission_multiplier=0.0001)
    assert_equal(decider.commission_multiplier, 0.0001)


def test_future_decider_calc_open() raises:
    var decider = create_future_decider(commission_multiplier=0.0001)

    var args = TransactionCostArgs(
        instrument_order_book_id="IF2501",
        price=4000.0,
        quantity=1,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=3,
        close_today_quantity=0,
    )

    var result = decider.calc(args)
    assert_equal(result.tax, 0.0)


def test_future_decider_calc_close() raises:
    var decider = create_future_decider(commission_multiplier=0.0001)

    var args = TransactionCostArgs(
        instrument_order_book_id="IF2501",
        price=4000.0,
        quantity=1,
        side=SIDE.SELL,
        position_effect=POSITION_EFFECT.CLOSE,
        order_id=4,
        close_today_quantity=0,
    )

    var result = decider.calc(args)
    assert_equal(result.tax, 0.0)


def test_bond_decider_creation() raises:
    var decider = create_bond_decider(commission_multiplier=0.0001)
    assert_equal(decider.commission_multiplier, 0.0001)


def test_bond_decider_calc() raises:
    var decider = create_bond_decider(commission_multiplier=0.0002)

    var args = TransactionCostArgs(
        instrument_order_book_id="123456.SH",
        price=100.0,
        quantity=10,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=5,
        close_today_quantity=0,
    )

    var result = decider.calc(args)
    assert_equal(result.tax, 0.0)
    assert_equal(result.other_fees, 0.0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
