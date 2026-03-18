"""
RQAlpha Mojo - Strategy Universe
Ported from rqalpha/core/strategy_universe.py
"""

from collections import Dict, Set
from rqmojo.core.events import EVENT, Event, EventBus
from rqmojo.environment import Environment
from rqmojo.model.instrument import Instrument
from rqmojo.utils.datetime_func import DateTime, Date


fn _get_current_time() -> DateTime:
    try:
        return DateTime.now()
    except:
        return DateTime(2024, 1, 1, 0, 0, 0, 0)


@fieldwise_init
struct StrategyUniverse(
    Copyable, Movable, Stringable, ImplicitlyCopyable
):
    var universe_set: Set[String]
    var event_bus: EventBus
    var last_update_time: DateTime

    fn __init__(self, event_bus: EventBus) -> Self:
        return Self(
            universe_set=Set[String](),
            event_bus=event_bus,
            last_update_time=_get_current_time()
        )

    fn __str__(self) -> String:
        return "StrategyUniverse(count=" + String(self.universe_set.__len__()) + ")"

    fn get(self) -> Set[String]:
        var result = Set[String]()
        for item in self.universe_set:
            result.add(item)
        return result

    fn get_list(self) -> DynamicVector[String]:
        var result = DynamicVector[String]()
        for item in self.universe_set:
            result.append(item)
        return result

    fn update(mut self, universe: Set[String]) -> None:
        var changed = False
        var new_set = Set[String]()
        
        for item in universe:
            new_set.add(item)
        
        if new_set.__len__() != self.universe_set.__len__():
            changed = True
        else:
            for item in new_set:
                if not self.universe_set.contains(item):
                    changed = True
                    break
        
        if changed:
            self.universe_set = new_set
            self.last_update_time = _get_current_time()

    fn update_from_list(mut self, universe: DynamicVector[String]) -> None:
        var new_set = Set[String]()
        for item in universe:
            new_set.add(item)
        self.update(new_set)

    fn update_from_instruments(mut self, instruments: DynamicVector[Instrument]) -> None:
        var new_set = Set[String]()
        for inst in instruments:
            new_set.add(inst.order_book_id)
        self.update(new_set)

    fn subscribe(mut self, order_book_id: String) -> None:
        if not self.universe_set.contains(order_book_id):
            self.universe_set.add(order_book_id)
            self.last_update_time = _get_current_time()

    fn unsubscribe(mut self, order_book_id: String) -> None:
        if self.universe_set.contains(order_book_id):
            self.universe_set.remove(order_book_id)
            self.last_update_time = _get_current_time()

    fn contains(self, order_book_id: String) -> Bool:
        return self.universe_set.contains(order_book_id)

    fn size(self) -> Int:
        return self.universe_set.__len__()

    fn is_empty(self) -> Bool:
        return self.universe_set.__len__() == 0

    fn clear(mut self) -> None:
        self.universe_set = Set[String]()
        self.last_update_time = _get_current_time()

    fn get_state(self) -> String:
        var result = "["
        var first = True
        for item in self.universe_set:
            if not first:
                result += ", "
            result += "\"" + item + "\""
            first = False
        result += "]"
        return result

    fn set_state(mut self, state: String) -> None:
        var new_set = Set[String]()
        var current = ""
        var in_string = False
        
        for i in range(state.__len__()):
            var ch = state[i]
            if ch == "\"" and not in_string:
                in_string = True
                current = ""
            elif ch == "\"" and in_string:
                in_string = False
                if current.__len__() > 0:
                    new_set.add(current)
                current = ""
            elif in_string:
                current += ch
        
        self.update(new_set)

    fn clear_de_listed(mut self, trading_dt: Date, data_proxy: object) -> None:
        var de_listed = DynamicVector[String]()
        
        for order_book_id in self.universe_set:
            de_listed.append(order_book_id)
        
        if de_listed.__len__() > 0:
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

    fn __init__(self, added: Set[String], removed: Set[String]) -> Self:
        return Self(
            timestamp=_get_current_time(),
            added=added,
            removed=removed
        )

    fn has_changes(self) -> Bool:
        return self.added.__len__() > 0 or self.removed.__len__() > 0


fn create_strategy_universe(event_bus: EventBus) -> StrategyUniverse:
    return StrategyUniverse(event_bus=event_bus)


fn universe_from_list(event_bus: EventBus, items: DynamicVector[String]) -> StrategyUniverse:
    var universe = StrategyUniverse(event_bus=event_bus)
    universe.update_from_list(items)
    return universe


fn universe_from_instruments(event_bus: EventBus, instruments: DynamicVector[Instrument]) -> StrategyUniverse:
    var universe = StrategyUniverse(event_bus=event_bus)
    universe.update_from_instruments(instruments)
    return universe
