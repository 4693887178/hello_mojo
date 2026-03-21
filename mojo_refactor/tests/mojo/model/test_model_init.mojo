"""
Mojo Test for model/__init__.mojo
Tests the model package exports
"""

from rqmojo.model import Order, OrderStyle, Trade, Instrument, BarObject, TickObject
from rqmojo.model import MarketOrder, LimitOrder
from rqmojo.model import create_order_id_generator
from rqmojo.utils.datetime_func import DateTime


def test_order_import():
    var gen = create_order_id_generator()
    var id = gen.next()
    print("Order ID generated: " + String(id))
    assert id == 1


def test_order_style_import():
    var market = MarketOrder()
    var limit = LimitOrder(10.5)
    print("MarketOrder: " + market.__str__())
    print("LimitOrder: " + limit.__str__())
    assert True


def test_bar_object_import():
    var bar = BarObject(
        _order_book_id="000001.XSHE",
        datetime=DateTime(2024, 1, 15, 0, 0, 0, 0),
        open=10.0,
        high=10.5,
        low=9.8,
        close=10.2,
        volume=1000000.0,
        total_turnover=10200000.0,
        limit_up=0.0,
        limit_down=0.0,
        _suspended=False,
        _trading=True,
        prev_settlement=0.0,
        settlement=0.0,
        open_interest=0.0,
        prev_close=0.0
    )
    print("BarObject created: " + bar.__str__())
    assert True


def main():
    print("=== Testing model/__init__.mojo ===")
    test_order_import()
    test_order_style_import()
    test_bar_object_import()
    print("All model/__init__ tests passed!")
