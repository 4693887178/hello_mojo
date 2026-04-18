"""
Group 5 tests - mod/rqmojo_mod_sys_transaction_cost/__init__.mojo
Tests for Mojo version of transaction cost module.
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
    assert_true("cn_stock_min_commission" in config, "config should contain cn_stock_min_commission")
    assert_true("stock_min_commission" in config, "config should contain stock_min_commission")
    assert_true("stock_commission_multiplier" in config, "config should contain stock_commission_multiplier")
    assert_true("futures_commission_multiplier" in config, "config should contain futures_commission_multiplier")
    assert_true("tax_multiplier" in config, "config should contain tax_multiplier")
    assert_true("pit_tax" in config, "config should contain pit_tax")


def test_get_config_values() raises:
    """Test get_config returns correct default values."""
    var config = get_config()
    var cn_min = config["cn_stock_min_commission"]
    assert_equal(cn_min[Float64], -1.0, "cn_stock_min_commission should be -1.0")

    var stock_min = config["stock_min_commission"]
    assert_equal(stock_min[Float64], 5.0, "stock_min_commission should be 5.0")

    var stock_cm = config["stock_commission_multiplier"]
    assert_equal(stock_cm[Float64], 1.0, "stock_commission_multiplier should be 1.0")

    var futures_cm = config["futures_commission_multiplier"]
    assert_equal(futures_cm[Float64], 1.0, "futures_commission_multiplier should be 1.0")

    var tax_m = config["tax_multiplier"]
    assert_equal(tax_m[Float64], 1.0, "tax_multiplier should be 1.0")

    var pit_tax = config["pit_tax"]
    assert_equal(pit_tax[Bool], False, "pit_tax should be False")


def test_get_cli_prefix() raises:
    """Test get_cli_prefix returns correct prefix string."""
    var prefix = get_cli_prefix()
    assert_equal(prefix, "mod__sys_transaction_cost__", "cli_prefix should match")


def test_get_cli_options_count() raises:
    """Test get_cli_options returns 7 CLI options matching Python version."""
    var options = get_cli_options()
    assert_equal(len(options), 7, "should have 7 CLI options like Python version")


def test_get_cli_options_names() raises:
    """Test get_cli_options returns options with correct names."""
    var options = get_cli_options()
    var names = List[String]()
    for opt in options:
        names.append(opt.name)

    assert_true("commission-multiplier" in names, "should have commission-multiplier option")
    assert_true("stock-commission-multiplier" in names, "should have stock-commission-multiplier option")
    assert_true("futures-commission-multiplier" in names, "should have futures-commission-multiplier option")
    assert_true("cn-stock-min-commission" in names, "should have cn-stock-min-commission option")
    assert_true("stock-min-commission" in names, "should have stock-min-commission option")
    assert_true("tax-multiplier" in names, "should have tax-multiplier option")
    assert_true("pit-tax" in names, "should have pit-tax option")


def test_get_cli_options_long_names() raises:
    """Test CLI options have correct long names."""
    var options = get_cli_options()
    var long_names = List[String]()
    for opt in options:
        if opt._long_name != "":
            long_names.append(opt._long_name)

    assert_true("commission-multiplier" in long_names, "should have --commission-multiplier")
    assert_true("stock-commission-multiplier" in long_names, "should have --stock-commission-multiplier")
    assert_true("futures-commission-multiplier" in long_names, "should have --futures-commission-multiplier")
    assert_true("cn-stock-min-commission" in long_names, "should have --cn-stock-min-commission")
    assert_true("stock-min-commission" in long_names, "should have --stock-min-commission")
    assert_true("tax-multiplier" in long_names, "should have --tax-multiplier")
    assert_true("pit-tax" in long_names, "should have --pit-tax")


def test_pit_tax_is_flag() raises:
    """Test that pit-tax option is a flag (boolean)."""
    var options = get_cli_options()
    for opt in options:
        if opt.name == "pit-tax":
            assert_true(opt._is_flag, "pit-tax should be a flag")
            break


def test_register_cli_options() raises:
    """Test register_cli_options successfully adds arguments to a command."""
    var cmd = Command(name="run", description="test run command")
    register_cli_options(cmd)


def test_load_mod() raises:
    """Test load_mod returns a valid TransactionCostMod instance."""
    var mod = load_mod()
    assert_equal(mod.name, "transaction_cost", "mod name should be transaction_cost")
    assert_true(mod.enabled, "mod should be enabled by default")


def test_stock_decider_creation() raises:
    var decider = create_stock_decider(
        commission_multiplier=0.0003,
        min_commission=5.0,
        stamp_tax_rate=0.001,
        transfer_fee_rate=0.00002
    )
    assert_equal(decider.commission_multiplier, 0.0003, "commission_multiplier should match")
    assert_equal(decider.min_commission, 5.0, "min_commission should match")


def test_stock_decider_calc_buy() raises:
    var decider = create_stock_decider(
        commission_multiplier=0.0003,
        min_commission=5.0,
        stamp_tax_rate=0.001,
        transfer_fee_rate=0.00002
    )

    var args = TransactionCostArgs(
        instrument_order_book_id="000001.XSHE",
        price=10.0,
        quantity=100,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=1,
        close_today_quantity=0
    )

    var result = decider.calc(args)
    assert_equal(result.commission, 5.0, "commission should be 5.0")
    assert_equal(result.tax, 0.0, "tax should be 0.0")


def test_stock_decider_calc_sell() raises:
    var decider = create_stock_decider(
        commission_multiplier=0.0003,
        min_commission=5.0,
        stamp_tax_rate=0.001,
        transfer_fee_rate=0.00002
    )

    var args = TransactionCostArgs(
        instrument_order_book_id="000001.XSHE",
        price=10.0,
        quantity=100,
        side=SIDE.SELL,
        position_effect=POSITION_EFFECT.CLOSE,
        order_id=2,
        close_today_quantity=0
    )

    var result = decider.calc(args)
    assert_equal(result.commission, 5.0, "commission should be 5.0")
    assert_equal(result.tax, 1.0, "tax should be 1.0")


def test_future_decider_creation() raises:
    var decider = create_future_decider(
        commission_multiplier=0.0001,
        close_commission_multiplier=0.0001
    )
    assert_equal(decider.commission_multiplier, 0.0001, "commission_multiplier should match")


def test_future_decider_calc_open() raises:
    var decider = create_future_decider(
        commission_multiplier=0.0001,
        close_commission_multiplier=0.00005
    )

    var args = TransactionCostArgs(
        instrument_order_book_id="IF2501",
        price=4000.0,
        quantity=1,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=3,
        close_today_quantity=0
    )

    var result = decider.calc(args)
    assert_equal(result.commission, 0.4, "commission should be 0.4")
    assert_equal(result.tax, 0.0, "tax should be 0.0")


def test_future_decider_calc_close() raises:
    var decider = create_future_decider(
        commission_multiplier=0.0001,
        close_commission_multiplier=0.00005
    )

    var args = TransactionCostArgs(
        instrument_order_book_id="IF2501",
        price=4000.0,
        quantity=1,
        side=SIDE.SELL,
        position_effect=POSITION_EFFECT.CLOSE,
        order_id=4,
        close_today_quantity=0
    )

    var result = decider.calc(args)
    assert_equal(result.commission, 0.2, "commission should be 0.2")
    assert_equal(result.tax, 0.0, "tax should be 0.0")


def test_bond_decider_creation() raises:
    var decider = create_bond_decider(commission_multiplier=0.0001)
    assert_equal(decider.commission_multiplier, 0.0001, "commission_multiplier should match")


def test_bond_decider_calc() raises:
    var decider = create_bond_decider(commission_multiplier=0.0002)

    var args = TransactionCostArgs(
        instrument_order_book_id="123456.SH",
        price=100.0,
        quantity=10,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=5,
        close_today_quantity=0
    )

    var result = decider.calc(args)
    assert_equal(result.commission, 0.2, "commission should be 0.2")
    assert_equal(result.tax, 0.0, "tax should be 0.0")
    assert_equal(result.other_fees, 0.0, "other_fees should be 0.0")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
