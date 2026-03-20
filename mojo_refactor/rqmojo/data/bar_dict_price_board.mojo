"""
RQAlpha Mojo - Bar Dict Price Board
Ported from rqalpha/data/bar_dict_price_board.py
"""

from rqmojo.interface import PriceBoard
from rqmojo.model.bar import BarObject
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.utils.datetime_func import DateTime
from rqmojo.const import EXECUTION_PHASE, EXCHANGE, EXCHANGE_XSHE, EXECUTION_PHASE_BEFORE_TRADING, EXCHANGE_XSHE, EXECUTION_PHASE_BEFORE_TRADING
from collections import Dict


fn nan_f64() -> Float64:
    return 0.0 / 0.0


fn create_empty_bar() -> BarObject:
    var ins = create_stock_instrument("", "", DateTime(1970, 1, 1, 0, 0, 0, 0), EXCHANGE_XSHE)
    return BarObject(
        instrument=ins,
        datetime=DateTime(1970, 1, 1, 0, 0, 0, 0),
        open=0.0,
        high=0.0,
        low=0.0,
        close=0.0,
        volume=0.0,
        total_turnover=0.0,
        limit_up=0.0,
        limit_down=0.0,
        _suspended=False,
        _trading=False,
        prev_settlement=0.0,
        settlement=0.0,
        open_interest=0.0,
        prev_close=0.0
    )


@fieldwise_init
struct BarDictPriceBoard(PriceBoard, Movable):
    var _bar_cache: Dict[String, BarObject]
    var _phase: EXECUTION_PHASE

    fn _get_bar(mut self, order_book_id: String) -> BarObject:
        try:
            return self._bar_cache[order_book_id]
        except:
            return create_empty_bar()

    fn get_last_price(mut self, order_book_id: String) -> Float64:
        var bar = self._get_bar(order_book_id)
        return bar.last()

    fn get_limit_up(mut self, order_book_id: String) -> Float64:
        var bar = self._get_bar(order_book_id)
        return bar.limit_up

    fn get_limit_down(mut self, order_book_id: String) -> Float64:
        var bar = self._get_bar(order_book_id)
        return bar.limit_down

    fn get_a1(mut self, order_book_id: String) -> Float64:
        return nan_f64()

    fn get_b1(mut self, order_book_id: String) -> Float64:
        return nan_f64()

    fn set_bar(mut self, order_book_id: String, bar: BarObject) -> None:
        self._bar_cache[order_book_id] = bar

    fn clear_cache(mut self) -> None:
        self._bar_cache.clear()

    fn set_phase(mut self, phase: EXECUTION_PHASE) -> None:
        self._phase = phase

    fn get_phase(self) -> EXECUTION_PHASE:
        return self._phase


fn create_bar_dict_price_board() -> BarDictPriceBoard:
    return BarDictPriceBoard(
        _bar_cache=Dict[String, BarObject](),
        _phase=EXECUTION_PHASE_BEFORE_TRADING
    )
