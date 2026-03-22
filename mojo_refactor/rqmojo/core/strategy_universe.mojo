"""
RQAlpha Mojo - Strategy Universe
Ported from rqalpha/core/strategy_universe.py
"""

from std.collections import Dict, Set
from rqmojo.core.events import EVENT, Event, EventBus
from rqmojo.environment import Environment
from rqmojo.model.instrument import Instrument
from rqmojo.utils.datetime_func import DateTime, Date


def _get_current_time() -> DateTime:
    try:
        return DateTime.now()
    except:
        return DateTime(2024, 1, 1, 0, 0, 0, 0)


@fieldwise_init
struct StrategyUniverse(
    Movable, Writable
):
    var universe_set: Set[String]
    var event_bus: EventBus
    var last_update_time: DateTime

    def __init__(out self, var event_bus: EventBus):
        self.universe_set = Set[String]()
        self.event_bus = event_bus^
        self.last_update_time = _get_current_time()

    def write_to(self, mut writer: Some[Writer]):
        writer.write("StrategyUniverse(count=", String(len(self.universe_set)), ")")

    def get(self) -> Set[String]:
        var result = Set[String]()
        for item in self.universe_set:
            result.add(item)
        return result

    def get_list(self) -> List[String]:
        var result = List[String]()
        for item in self.universe_set:
            result.append(item)
        return result

    def update(mut self, universe: Set[String]):
        var changed = False
        var new_set = Set[String]()
        
        for item in universe:
            new_set.add(item)
        
        if len(new_set) != len(self.universe_set):
            changed = True
        else:
            for item in new_set:
                if not self.universe_set.contains(item):
                    changed = True
                    break
        
        if changed:
            self.universe_set = new_set
            self.last_update_time = _get_current_time()

    def update_from_list(mut self, universe: List[String]):
        var new_set = Set[String]()
        for item in universe:
            new_set.add(item)
        self.update(new_set)

    def update_from_instruments(mut self, instruments: List[Instrument]):
        var new_set = Set[String]()
        for inst in instruments:
            new_set.add(inst.order_book_id)
        self.update(new_set)

    def subscribe(mut self, order_book_id: String):
        if not self.universe_set.contains(order_book_id):
            self.universe_set.add(order_book_id)
            self.last_update_time = _get_current_time()

    def unsubscribe(mut self, order_book_id: String):
        if self.universe_set.contains(order_book_id):
            self.universe_set.remove(order_book_id)
            self.last_update_time = _get_current_time()

    def contains(self, order_book_id: String) -> Bool:
        return self.universe_set.contains(order_book_id)

    def size(self) -> Int:
        return len(self.universe_set)

    def is_empty(self) -> Bool:
        return len(self.universe_set) == 0

    def clear(mut self):
        self.universe_set = Set[String]()
        self.last_update_time = _get_current_time()

    def get_state(self) -> String:
        var result = "["
        var first = True
        for item in self.universe_set:
            if not first:
                result += ", "
            result += "\"" + item + "\""
            first = False
        result += "]"
        return result

    def set_state(mut self, state: String):
        var new_set = Set[String]()
        var current = ""
        var in_string = False
        
        for i in range(len(state)):
            var ch = state[i]
            if ch == "\"" and not in_string:
                in_string = True
                current = ""
            elif ch == "\"" and in_string:
                in_string = False
                if len(current) > 0:
                    new_set.add(current)
                current = ""
            elif in_string:
                current += ch
        
        self.update(new_set)

    def clear_de_listed(mut self, trading_dt: Date, data_proxy: object):
        var de_listed = List[String]()
        
        for order_book_id in self.universe_set:
            de_listed.append(order_book_id)
        
        if len(de_listed) > 0:
            for item in de_listed:
                self.universe_set.remove(item)
            self.last_update_time = _get_current_time()


@fieldwise_init
struct UniverseChangeRecord(
    Copyable, Movable, ImplicitlyCopyable
):
    var timestamp: DateTime
    var added: Set[String]
    var removed: Set[String]

    def __init__(out self, added: Set[String], removed: Set[String]):
        self.timestamp = _get_current_time()
        self.added = added
        self.removed = removed

    def has_changes(self) -> Bool:
        return len(self.added) > 0 or len(self.removed) > 0


def create_strategy_universe(event_bus: EventBus) -> StrategyUniverse:
    return StrategyUniverse(event_bus=event_bus)


def universe_from_list(event_bus: EventBus, items: List[String]) -> StrategyUniverse:
    var universe = StrategyUniverse(event_bus=event_bus)
    universe.update_from_list(items)
    return universe


def universe_from_instruments(event_bus: EventBus, instruments: List[Instrument]) -> StrategyUniverse:
    var universe = StrategyUniverse(event_bus=event_bus)
    universe.update_from_instruments(instruments)
    return universe
