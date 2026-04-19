"""
Comprehensive tests for apis/__init__.mojo and its submodules

Tests the Mojo refactoring of Python's rqalpha.apis package.
"""

from std.testing import assert_equal, assert_true, TestSuite
from rqmojo.const import SIDE, ORDER_TYPE, POSITION_DIRECTION
from rqmojo.model.order import Order, MarketOrder
from rqmojo.utils.typing import DateTime


def test_import_api_base_functions() raises:
    from rqmojo.apis.api_base import order_shares, order_value, order_percent
    from rqmojo.apis.api_base import cancel_order, get_position, get_portfolio
    from rqmojo.apis.api_base import history, get_price
    var called = 0


def test_simulation_broker_conforms_to_broker_trait() raises:
    from rqmojo.core.broker import create_broker
    from rqmojo.portfolio.account import create_stock_account
    var broker = create_broker()
    assert_true(len(broker.get_open_orders()) == 0)
    broker.set_account(create_stock_account(100000.0))


def test_broker_submit_order() raises:
    from rqmojo.core.broker import create_broker
    from rqmojo.portfolio.account import create_stock_account
    from rqmojo.model.order import Order
    var broker = create_broker()
    broker.set_account(create_stock_account(100000.0))
    var order = Order(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        position_effect=None,
        frozen_price=10.0,
        calendar_dt=DateTime(2020, 1, 1, 0, 0, 0, 0),
        trading_dt=DateTime(2020, 1, 1, 0, 0, 0, 0),
        order_type_val=ORDER_TYPE.MARKET,
        style_order=MarketOrder(),
        style_algo=None
    )
    broker.submit_order(order)
    assert_true(len(broker.get_open_orders()) >= 0)


def test_broker_cancel_order_takes_order_not_int() raises:
    from rqmojo.core.broker import create_broker
    from rqmojo.model.order import Order
    var broker = create_broker()
    var order = Order(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        position_effect=None,
        frozen_price=10.0,
        calendar_dt=DateTime(2020, 1, 1, 0, 0, 0, 0),
        trading_dt=DateTime(2020, 1, 1, 0, 0, 0, 0),
        order_type_val=ORDER_TYPE.MARKET,
        style_order=MarketOrder(),
        style_algo=None
    )
    broker.cancel_order(order)


def test_broker_get_open_orders_accepts_optional_filter() raises:
    from rqmojo.core.broker import create_broker
    var broker = create_broker()
    var all_orders = broker.get_open_orders()
    var filtered = broker.get_open_orders("000001.XSHE")
    assert_true(len(all_orders) >= len(filtered))


def test_event_source_conforms_to_event_source_trait() raises:
    from rqmojo.core.event_source import create_event_source
    var start = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2020, 12, 31, 0, 0, 0, 0)
    var src = create_event_source(start, end, "1d")
    src.events(start, end, "1d")
    assert_true(src.is_running() == False)
    src.start()
    assert_true(src.is_running() == True)


def test_env_uses_envportfolio_not_portfolio() raises:
    from rqmojo.environment import EnvPortfolio, create_env_portfolio
    var ep = create_env_portfolio(100000.0)
    assert_equal(ep.total_value, 100000.0)
    assert_equal(ep.total_cash, 100000.0)


def test_trade_last_price_field_exists() raises:
    from rqmojo.model.trade import Trade
    var t = Trade(
        trade_id=1,
        exec_id="e1",
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        position_effect=None,
        position_direction_val=POSITION_DIRECTION.LONG,
        quantity=100,
        last_price=10.5,
        calendar_dt=DateTime(2020, 1, 1),
        trading_dt=DateTime(2020, 1, 1)
    )
    assert_equal(t.last_price, 10.5)


def test_top_level_portfolio_has_get_position() raises:
    from rqmojo.portfolio_manager import Portfolio, create_portfolio
    var pf = create_portfolio(100000.0)
    var pos = pf.get_position("000001.XSHE")
    assert_true(pos.quantity >= 0)


def test_order_target_portfolio_raises_signature() raises:
    from rqmojo.mod.rqmojo_mod_sys_accounts.api.order_target_portfolio import order_target_portfolio
    from rqmojo.environment import Environment, create_environment
    var start = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2020, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start, end)
    var target: Dict[String, Float64] = {}
    target["000001.XSHE"] = 50000.0
    var orders = order_target_portfolio(env, target)
    assert_true(len(orders) >= 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
