"""
Test for model/instrument.mojo
Group 09 - File 8
Comprehensive tests for Instrument struct and all methods.
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from rqmojo.model.instrument import (
    Instrument, create_stock_instrument, create_future_instrument,
    create_etf_instrument, is_instrument_type_in_stock_account
)
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, DEFAULT_ACCOUNT_TYPE, MARKET
from rqmojo.utils.typing import DateTime


def test_instrument_struct_exists() raises:
    print("Test: Instrument struct exists")
    var inst = create_stock_instrument(
        order_book_id="000001.XSHE",
        symbol="PingAnBank",
        listed_date=DateTime(1991, 4, 3, 0, 0, 0, 0),
        exchange=EXCHANGE.XSHE
    )
    print("  PASSED")


def test_order_book_id() raises:
    print("Test: order_book_id property")
    var inst = create_stock_instrument(
        order_book_id="000001.XSHE", symbol="PA", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE
    )
    assert_equal(inst.order_book_id(), "000001.XSHE")
    print("  PASSED")


def test_symbol() raises:
    print("Test: symbol property")
    var inst = create_stock_instrument(
        order_book_id="600000.XSHG", symbol="PFYC", listed_date=DateTime(1990, 12, 19), exchange=EXCHANGE.XSHG
    )
    assert_equal(inst.symbol(), "PFYC")
    print("  PASSED")


def test_type_cs() raises:
    print("Test: type property - CS")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_equal(inst.type(), INSTRUMENT_TYPE.CS)
    print("  PASSED")


def test_type_future() raises:
    print("Test: type property - Future")
    var fut = create_future_instrument(
        order_book_id="IF2405", symbol="IF2405",
        listed_date=DateTime(2024, 1, 15),
        maturity_date=DateTime(2024, 5, 17),
        de_listed_date=DateTime(2024, 5, 17),
        contract_multiplier=300.0, exchange=EXCHANGE.CFFEX, underlying_symbol="IF"
    )
    assert_equal(fut.type(), INSTRUMENT_TYPE.FUTURE)
    print("  PASSED")


def test_type_etf() raises:
    print("Test: type property - ETF")
    var etf = create_etf_instrument(
        order_book_id="159919.XSHE", symbol="SZ300ETF", listed_date=DateTime(2012, 5, 28), exchange=EXCHANGE.XSHE
    )
    assert_equal(etf.type(), INSTRUMENT_TYPE.ETF)
    print("  PASSED")


def test_exchange() raises:
    print("Test: exchange property")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_equal(inst.exchange(), EXCHANGE.XSHE)

    var inst2 = create_stock_instrument(order_book_id="600000.XSHG", symbol="B", listed_date=DateTime(1990, 12, 19), exchange=EXCHANGE.XSHG)
    assert_equal(inst2.exchange(), EXCHANGE.XSHG)
    print("  PASSED")


def test_round_lot_default() raises:
    print("Test: round_lot default (100)")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_equal(inst.round_lot(), 100)
    print("  PASSED")


def test_round_lot_ksh() raises:
    print("Test: round_lot KSH board type returns 1")
    var inst = create_stock_instrument(order_book_id="688001.XSHG", symbol="KSHStock", listed_date=DateTime(2019, 7, 22), exchange=EXCHANGE.XSHG)
    assert_equal(inst.round_lot(), 1, "KSH board should have round_lot=1")
    print("  PASSED")


def test_listed_date() raises:
    print("Test: listed_date property")
    var dt = DateTime(2005, 6, 7, 0, 0, 0, 0)
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=dt, exchange=EXCHANGE.XSHE)
    var ld = inst.listed_date()
    assert_equal(ld.year, 2005)
    assert_equal(ld.month, 6)
    assert_equal(ld.day, 7)
    print("  PASSED")


def test_de_listed_date_default() raises:
    print("Test: de_listed_date default")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    var dld = inst.de_listed_date()
    assert_equal(dld.year, 2999)
    assert_equal(dld.month, 12)
    assert_equal(dld.day, 31)
    print("  PASSED")


def test_tick_size_cs() raises:
    print("Test: tick_size for CS type")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_true(abs(inst.tick_size() - 0.01) < 1e-10)
    print("  PASSED")


def test_tick_size_etf() raises:
    print("Test: tick_size for ETF type")
    var etf = create_etf_instrument(order_book_id="159919.XSHE", symbol="ETF", listed_date=DateTime(2012, 5, 28), exchange=EXCHANGE.XSHE)
    assert_true(abs(etf.tick_size() - 0.001) < 1e-10)
    print("  PASSED")


def test_contract_multiplier() raises:
    print("Test: contract_multiplier")
    var fut = create_future_instrument(
        order_book_id="IF2405", symbol="IF2405",
        listed_date=DateTime(2024, 1, 15),
        maturity_date=DateTime(2024, 5, 17),
        de_listed_date=DateTime(2024, 5, 17),
        contract_multiplier=300.0, exchange=EXCHANGE.CFFEX, underlying_symbol="IF"
    )
    assert_true(abs(fut.contract_multiplier() - 300.0) < 1e-10)
    print("  PASSED")


def test_contract_multiplier_default() raises:
    print("Test: contract_multiplier defaults to 1.0")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_true(abs(inst.contract_multiplier() - 1.0) < 1e-10)
    print("  PASSED")


def test_market_tplus() raises:
    print("Test: market_tplus")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_equal(inst.market_tplus(), 1)
    print("  PASSED")


def test_status() raises:
    print("Test: status property")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_equal(inst.status(), "Active")
    print("  PASSED")


def test_special_type() raises:
    print("Test: special_type property")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_equal(inst.special_type(), "Normal")
    print("  PASSED")


def test_board_type_mainboard() raises:
    print("Test: board_type mainboard")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_equal(inst.board_type(), "")
    print("  PASSED")


def test_board_type_ksh() raises:
    print("Test: board_type KSH (688 prefix)")
    var inst = create_stock_instrument(order_book_id="688001.XSHG", symbol="KSH", listed_date=DateTime(2019, 7, 22), exchange=EXCHANGE.XSHG)
    assert_equal(inst.board_type(), "KSH")
    print("  PASSED")


def test_account_type_stock() raises:
    print("Test: account_type for stock")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_equal(inst.account_type(), DEFAULT_ACCOUNT_TYPE.STOCK)
    print("  PASSED")


def test_account_type_future() raises:
    print("Test: account_type for future")
    var fut = create_future_instrument(
        order_book_id="IF2405", symbol="IF2405",
        listed_date=DateTime(2024, 1, 15),
        maturity_date=DateTime(2024, 5, 17),
        de_listed_date=DateTime(2024, 5, 17),
        contract_multiplier=300.0, exchange=EXCHANGE.CFFEX, underlying_symbol="IF"
    )
    assert_equal(fut.account_type(), DEFAULT_ACCOUNT_TYPE.FUTURE)
    print("  PASSED")


def test_is_future() raises:
    print("Test: is_future method")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_false(inst.is_future())

    var fut = create_future_instrument(
        order_book_id="IF2405", symbol="IF2405",
        listed_date=DateTime(2024, 1, 15),
        maturity_date=DateTime(2024, 5, 17),
        de_listed_date=DateTime(2024, 5, 17),
        contract_multiplier=300.0, exchange=EXCHANGE.CFFEX, underlying_symbol="IF"
    )
    assert_true(fut.is_future())
    print("  PASSED")


def test_listed_at_before() raises:
    print("Test: listed_at before listing date")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(2000, 1, 1), exchange=EXCHANGE.XSHE)
    assert_false(inst.listed_at(DateTime(1999, 12, 31, 0, 0, 0, 0)))
    print("  PASSED")


def test_listed_at_after() raises:
    print("Test: listed_at after listing date")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(2000, 1, 1), exchange=EXCHANGE.XSHE)
    assert_true(inst.listed_at(DateTime(2000, 1, 1, 0, 0, 0, 0)))
    assert_true(inst.listed_at(DateTime(2020, 1, 1, 0, 0, 0, 0)))
    print("  PASSED")


def test_de_listed_at_not_delisted() raises:
    print("Test: de_listed_at not delisted yet")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_false(inst.de_listed_at(DateTime(2020, 1, 1, 0, 0, 0, 0)))
    print("  PASSED")


def test_de_listed_at_on_date() raises:
    print("Test: de_listed_at on de_listed date (stock)")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_true(inst.de_listed_at(DateTime(2999, 12, 31, 0, 0, 0, 0)))
    print("  PASSED")


def test_active_at_active() raises:
    print("Test: active_at when active")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_true(inst.active_at(DateTime(2020, 6, 1, 0, 0, 0, 0)))
    print("  PASSED")


def test_active_at_inactive() raises:
    print("Test: active_at when not yet listed")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(2030, 1, 1), exchange=EXCHANGE.XSHE)
    assert_false(inst.active_at(DateTime(2020, 6, 1, 0, 0, 0, 0)))
    print("  PASSED")


def test_trading_hours_stock() raises:
    print("Test: trading_hours for stock")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    var hours = inst.trading_hours()
    assert_equal(len(hours), 2)
    print("  PASSED")


def test_during_continuous_auction_inside() raises:
    print("Test: during_continuous_auction inside hours")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_true(inst.during_continuous_auction(10, 30))
    assert_true(inst.during_continuous_auction(14, 0))
    print("  PASSED")


def test_during_continuous_auction_outside() raises:
    print("Test: during_continuous_auction outside hours")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_false(inst.during_continuous_auction(8, 0))
    assert_false(inst.during_continuous_auction(16, 0))
    print("  PASSED")


def test_trade_at_night_stock() raises:
    print("Test: trade_at_night for stock (no night trading)")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_false(inst.trade_at_night())
    print("  PASSED")


def test_during_call_auction_morning() raises:
    print("Test: during_call_auction morning (before 9:30)")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_true(inst.during_call_auction(9, 29))
    assert_false(inst.during_call_auction(9, 31))
    print("  PASSED")


def test_during_call_auction_afternoon() raises:
    print("Test: during_call_auction afternoon (after 14:57)")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_true(inst.during_call_auction(14, 58))
    assert_false(inst.during_call_auction(14, 56))
    print("  PASSED")


def test_min_order_quantity() raises:
    print("Test: min_order_quantity")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_equal(inst.min_order_quantity(), 100)
    print("  PASSED")


def test_order_step_size_normal() raises:
    print("Test: order_step_size normal board")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_equal(inst.order_step_size(), 100)
    print("  PASSED")


def test_settlement_method() raises:
    print("Test: settlement_method")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    assert_equal(inst.settlement_method(), "")

    var fut = create_future_instrument(
        order_book_id="IF2405", symbol="IF2405",
        listed_date=DateTime(2024, 1, 15),
        maturity_date=DateTime(2024, 5, 17),
        de_listed_date=DateTime(2024, 5, 17),
        contract_multiplier=300.0, exchange=EXCHANGE.CFFEX, underlying_symbol="IF"
    )
    assert_equal(fut.settlement_method(), "PhysicalSettlementRequired")
    print("  PASSED")


def test_write_to() raises:
    print("Test: write_to / Writable")
    var inst = create_stock_instrument(order_book_id="000001.XSHE", symbol="A", listed_date=DateTime(1991, 4, 3), exchange=EXCHANGE.XSHE)
    var s = String.write(inst)
    assert_true(len(s) > 0)
    print("  PASSED")


def test_is_instrument_type_in_stock_account() raises:
    print("Test: is_instrument_type_in_stock_account helper")
    assert_true(is_instrument_type_in_stock_account(INSTRUMENT_TYPE.CS))
    assert_true(is_instrument_type_in_stock_account(INSTRUMENT_TYPE.ETF))
    assert_true(is_instrument_type_in_stock_account(INSTRUMENT_TYPE.LOF))
    assert_true(is_instrument_type_in_stock_account(INSTRUMENT_TYPE.INDX))
    assert_true(is_instrument_type_in_stock_account(INSTRUMENT_TYPE.BOND))
    assert_false(is_instrument_type_in_stock_account(INSTRUMENT_TYPE.FUTURE))
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
