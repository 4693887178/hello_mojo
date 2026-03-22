"""
RQAlpha Mojo - Bar Dict Price Board
Ported from rqalpha/data/bar_dict_price_board.py
"""

from rqmojo.interface import PriceBoard
from rqmojo.model.bar import BarObject, BarData
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.utils.datetime_func import DateTime
from rqmojo.const import EXECUTION_PHASE, EXCHANGE, EXCHANGE_XSHE, EXECUTION_PHASE_BEFORE_TRADING
from std.collections import Dict


def nan_f64() -> Float64:
    return 0.0 / 0.0


def create_empty_bar() -> BarObject:
    var empty_data = BarData(
        open=0.0,
        close=0.0,
        high=0.0,
        low=0.0,
        volume=0.0,
        total_turnover=0.0,
        limit_up=0.0,
        limit_down=0.0,
        settlement=0.0,
        prev_settlement=0.0,
        open_interest=0.0,
        discount_rate=0.0,
        acc_net_value=0.0,
        unit_net_value=0.0,
        basis_spread=0.0,
        datetime_int=0,
        prev_close=0.0,
        last=0.0
    )
    return BarObject(
        _order_book_id="",
        _instrument=create_stock_instrument("", "", DateTime(1970, 1, 1, 0, 0, 0, 0), EXCHANGE_XSHE),
        _dt=DateTime(1970, 1, 1, 0, 0, 0, 0),
        _data=empty_data,
        _limit_up=0.0,
        _limit_down=0.0,
        _suspended=False,
        _trading=False
    )


@fieldwise_init
struct BarDictPriceBoard(PriceBoard, Movable):
    var _bar_cache: Dict[String, BarObject]
    var _phase: EXECUTION_PHASE

    def _get_bar(mut self, order_book_id: String) -> BarObject:
        try:
            return self._bar_cache[order_book_id]
        except:
            return create_empty_bar()

    def get_last_price(mut self, order_book_id: String) -> Float64:
        var bar = self._get_bar(order_book_id)
        return bar.last()

    def get_limit_up(mut self, order_book_id: String) -> Float64:
        var bar = self._get_bar(order_book_id)
        return bar.limit_up()

    def get_limit_down(mut self, order_book_id: String) -> Float64:
        var bar = self._get_bar(order_book_id)
        return bar.limit_down()

    def get_a1(mut self, order_book_id: String) -> Float64:
        return nan_f64()

    def get_b1(mut self, order_book_id: String) -> Float64:
        return nan_f64()

    def set_bar(mut self, order_book_id: String, bar: BarObject):
        self._bar_cache[order_book_id] = bar

    def clear_cache(mut self):
        self._bar_cache.clear()

    def set_phase(mut self, phase: EXECUTION_PHASE):
        self._phase = phase

    def get_phase(self) -> EXECUTION_PHASE:
        return self._phase


def create_bar_dict_price_board() -> BarDictPriceBoard:
    return BarDictPriceBoard(
        _bar_cache=Dict[String, BarObject](),
        _phase=EXECUTION_PHASE_BEFORE_TRADING
    )
