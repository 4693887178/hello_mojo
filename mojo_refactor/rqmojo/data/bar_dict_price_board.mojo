"""
RQAlpha Mojo - Bar Dict Price Board
Ported from rqalpha/data/bar_dict_price_board.py

Design Note (vs Python original):
  Python: Dynamic bar lookup via Environment.get_instance() and _get_bar()
          which checks EXECUTION_PHASE.OPEN_AUCTION for special handling.
  Mojo:  Uses pre-populated Dict caches since Environment/ExecutionContext
          infrastructure may not be fully available. set_bar() is called
          externally to populate price data before queries.
          Phase tracking (_phase) is maintained but not used in lookup logic
          to match Python's eventual integration pattern.
"""

from rqmojo.interface import PriceBoard
from rqmojo.model.bar import BarObject
from rqmojo.const import EXECUTION_PHASE
from std.collections import Dict


comptime NAN_VALUE: Float64 = 0.0 / 0.0


@fieldwise_init
struct BarDictPriceBoard(PriceBoard, Writable, Movable):
    var _last_prices: Dict[String, Float64]
    var _limit_ups: Dict[String, Float64]
    var _limit_downs: Dict[String, Float64]
    var _phase: EXECUTION_PHASE

    def write_to(self, mut writer: Some[Writer]):
        writer.write("BarDictPriceBoard()")

    def get_last_price(mut self, order_book_id: String) -> Float64:
        try:
            return self._last_prices[order_book_id]
        except:
            return NAN_VALUE

    def get_limit_up(mut self, order_book_id: String) -> Float64:
        try:
            return self._limit_ups[order_book_id]
        except:
            return NAN_VALUE

    def get_limit_down(mut self, order_book_id: String) -> Float64:
        try:
            return self._limit_downs[order_book_id]
        except:
            return NAN_VALUE

    def get_a1(mut self, order_book_id: String) -> Float64:
        return NAN_VALUE

    def get_b1(mut self, order_book_id: String) -> Float64:
        return NAN_VALUE

    def set_bar(mut self, order_book_id: String, var bar: BarObject):
        self._last_prices[order_book_id] = bar.last()
        self._limit_ups[order_book_id] = bar.limit_up()
        self._limit_downs[order_book_id] = bar.limit_down()

    def clear_cache(mut self):
        self._last_prices.clear()
        self._limit_ups.clear()
        self._limit_downs.clear()

    def set_phase(mut self, phase: EXECUTION_PHASE):
        self._phase = phase

    def get_phase(self) -> EXECUTION_PHASE:
        return self._phase


def create_bar_dict_price_board() -> BarDictPriceBoard:
    return BarDictPriceBoard(
        _last_prices=Dict[String, Float64](),
        _limit_ups=Dict[String, Float64](),
        _limit_downs=Dict[String, Float64](),
        _phase=EXECUTION_PHASE.BEFORE_TRADING
    )
