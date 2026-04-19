"""
RQAlpha Mojo - Strategy Universe
Ported from rqalpha/core/strategy_universe.py
"""

from std.collections import Dict, Set, List
from rqmojo.core.events import EVENT, Event, EventBus
from rqmojo.environment import Environment
from rqmojo.model.instrument import Instrument
from rqmojo.utils.typing import DateTime
from emberjson import Value, Array, parse
from emberjson._serialize import serialize


@fieldwise_init
struct StrategyUniverse(Movable, Writable):
    var _set: Set[String]
    var _event_bus: EventBus

    def __init__(out self, var event_bus: EventBus):
        self._set = Set[String]()
        self._event_bus = event_bus^

    def write_to(self, mut writer: Some[Writer]):
        writer.write("StrategyUniverse(count=", String(len(self._set)), ")")

    def get_state(ref self) -> String:
        var items = self._sorted_list()
        var arr = Array()
        for item in items:
            arr.append(Value(item))
        var json_val = Value(arr^)
        var result: String = ""
        serialize(json_val, result)
        return result

    def set_state(mut self, state: String) raises:
        var json_val = Value(parse_string=state)
        if json_val.is_array():
            var new_items = List[String]()
            for item in json_val.array():
                if item.is_string():
                    new_items.append(item.string())
            self.update(new_items)

    def update(mut self, universe: List[String]) raises:
        var new_set = Set[String]()
        for item in universe:
            new_set.add(item)
        if new_set != self._set:
            self._set = new_set^
            var event = Event(EVENT.POST_UNIVERSE_CHANGED.value)
            _ = self._event_bus.publish_event(event)

    def update_single(mut self, order_book_id: String) raises:
        var universe = List[String]()
        universe.append(order_book_id)
        self.update(universe)

    def get(ref self) -> Set[String]:
        var result = Set[String]()
        for item in self._set:
            result.add(item)
        return result^

    def _clear_de_listed(mut self, env: Environment) raises:
        var de_listed = Set[String]()
        var trading_ordinal = env.trading_dt().toordinal()
        for order_book_id in self._set:
            var instrument = env.get_instrument(order_book_id)
            if instrument.de_listed_date().toordinal() <= trading_ordinal:
                de_listed.add(order_book_id)
        if len(de_listed) > 0:
            var new_set = Set[String]()
            for item in self._set:
                if item not in de_listed:
                    new_set.add(item)
            self._set = new_set^
            var event = Event(EVENT.POST_UNIVERSE_CHANGED.value)
            _ = self._event_bus.publish_event(event)

    def _sorted_list(ref self) -> List[String]:
        var items = List[String]()
        for item in self._set:
            items.append(item)
        _bubble_sort(items)
        return items^


def _bubble_sort(mut items: List[String]):
    var n = len(items)
    if n < 2:
        return
    for i in range(n):
        for j in range(0, n - i - 1):
            if items[j] > items[j + 1]:
                var tmp = items[j]
                items[j] = items[j + 1]
                items[j + 1] = tmp


def create_strategy_universe(var event_bus: EventBus) -> StrategyUniverse:
    return StrategyUniverse(event_bus=event_bus^)
