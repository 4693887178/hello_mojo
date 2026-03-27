"""
RQAlpha Mojo - Strategy Universe
Ported from rqalpha/core/strategy_universe.py
"""

from std.collections import Dict, Set, List
from rqmojo.core.events import EVENT, Event, EventBus
from rqmojo.environment import Environment
from rqmojo.model.instrument import Instrument
from rqmojo.utils.typing import DateTime, DateTimeDate


def _get_current_time() -> DateTime:
    try:
        return DateTime.now()
    except:
        return DateTime(2024, 1, 1, 0, 0, 0, 0)


@fieldwise_init
struct StrategyUniverse(Movable, Writable):
    var universe_set: Set[String]
    var event_bus: EventBus
    var last_update_time: DateTime

    def __init__(out self, var event_bus: EventBus):
        self.universe_set = Set[String]()
        self.event_bus = event_bus^
        self.last_update_time = _get_current_time()

    def write_to(self, mut writer: Some[Writer]):
        writer.write("StrategyUniverse(count=", String(len(self.universe_set)), ")")

    def get(ref self) -> Set[String]:
        var result = Set[String]()
        for item in self.universe_set:
            result.add(item)
        return result^

    def get_list(ref self) -> List[String]:
        var result = List[String]()
        for item in self.universe_set:
            result.append(item)
        return result^

    def update(mut self, universe: Set[String]):
        var old_len = len(self.universe_set)
        self.universe_set.clear()
        for item in universe:
            self.universe_set.add(item)
        var new_len = len(self.universe_set)
        if new_len != old_len:
            self.last_update_time = _get_current_time()

    def subscribe(mut self, order_book_id: String) raises:
        if order_book_id not in self.universe_set:
            self.universe_set.add(order_book_id)
            self.last_update_time = _get_current_time()

    def unsubscribe(mut self, order_book_id: String) raises:
        if order_book_id in self.universe_set:
            self.universe_set.remove(order_book_id)
            self.last_update_time = _get_current_time()

    def contains(ref self, order_book_id: String) -> Bool:
        return order_book_id in self.universe_set

    def clear(mut self):
        self.universe_set.clear()
        self.last_update_time = _get_current_time()

    def get_state(ref self) -> String:
        var items = self.get_list()
        var result = "["
        for i in range(len(items)):
            if i > 0:
                result += ", "
            result += "\"" + items[i] + "\""
        result += "]"
        return result

    def set_state(mut self, state: String):
        var new_set = Set[String]()
        var in_string = False
        var current_item = ""
        
        for i in range(len(state)):
            var ch = state[byte=i]
            if ch == "\"" and not in_string:
                in_string = True
            elif ch == "\"" and in_string:
                in_string = False
                if len(current_item) > 0:
                    new_set.add(current_item)
                    current_item = ""
            elif in_string:
                current_item += String(ch)
        
        self.universe_set = new_set^
        self.last_update_time = _get_current_time()


@fieldwise_init
struct UniverseChangeRecord(Movable):
    var timestamp: DateTime
    var added: Set[String]
    var removed: Set[String]

    def __init__(out self, var added: Set[String], var removed: Set[String]):
        self.timestamp = _get_current_time()
        self.added = added^
        self.removed = removed^

    def has_changes(self) -> Bool:
        return len(self.added) > 0 or len(self.removed) > 0


def create_strategy_universe(var event_bus: EventBus) -> StrategyUniverse:
    return StrategyUniverse(event_bus=event_bus^)
