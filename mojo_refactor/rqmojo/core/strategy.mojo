"""
RQAlpha Mojo - Strategy Base
Ported from rqalpha/core/strategy.py
"""

from std.collections import Dict, Set
from rqmojo.const import EXECUTION_PHASE, EXC_TYPE
from rqmojo.core.events import EVENT, Event, EventBus
from rqmojo.core.strategy_context import StrategyContext
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.environment import Environment


trait Strategy:
    def init(ref self, context: StrategyContext) -> None:
        ...
    def before_trading(ref self, context: StrategyContext) -> None:
        ...
    def handle_bar(ref self, context: StrategyContext, bar: BarObject) -> None:
        ...
    def handle_tick(ref self, context: StrategyContext, tick: TickObject) -> None:
        ...
    def after_trading(ref self, context: StrategyContext) -> None:
        ...
    def open_auction(ref self, context: StrategyContext, bar: BarObject) -> None:
        ...


@fieldwise_init
struct StrategyCallbacks(
    Copyable, Movable, ImplicitlyCopyable
):
    var has_init: Bool
    var has_before_trading: Bool
    var has_handle_bar: Bool
    var has_handle_tick: Bool
    var has_after_trading: Bool
    var has_open_auction: Bool


def create_strategy_callbacks() -> StrategyCallbacks:
    return StrategyCallbacks(
        has_init=False,
        has_before_trading=False,
        has_handle_bar=False,
        has_handle_tick=False,
        has_after_trading=False,
        has_open_auction=False
    )


@fieldwise_init
struct BaseStrategy(
    Movable, Stringable
):
    var current_universe: Set[String]
    var callbacks: StrategyCallbacks
    var event_bus: EventBus
    var strategy_name: String

    def __str__(self) -> String:
        return "Strategy(" + self.strategy_name + ")"

    def register_init(mut self) -> None:
        self.callbacks.has_init = True

    def register_before_trading(mut self) -> None:
        self.callbacks.has_before_trading = True

    def register_handle_bar(mut self) -> None:
        self.callbacks.has_handle_bar = True

    def register_handle_tick(mut self) -> None:
        self.callbacks.has_handle_tick = True

    def register_after_trading(mut self) -> None:
        self.callbacks.has_after_trading = True

    def register_open_auction(mut self) -> None:
        self.callbacks.has_open_auction = True

    def call_init(mut self) -> None:
        pass

    def call_before_trading(mut self) -> None:
        pass

    def call_handle_bar(mut self, bar: BarObject) -> None:
        pass

    def call_handle_tick(mut self, tick: TickObject) -> None:
        pass

    def call_after_trading(mut self) -> None:
        pass

    def call_open_auction(mut self, bar: BarObject) -> None:
        pass

    def get_universe(self) -> Set[String]:
        return self.current_universe

    def update_universe(mut self, universe: Set[String]) -> None:
        self.current_universe = universe


@fieldwise_init
struct StrategyEventWrapper(
    Copyable, Movable, ImplicitlyCopyable
):
    var strategy: BaseStrategy
    var registered_events: List[EVENT]

    def register_events(mut self, event_bus: EventBus) -> None:
        if self.strategy.callbacks.has_before_trading:
            self.registered_events.append(EVENT.BEFORE_TRADING())

        if self.strategy.callbacks.has_handle_bar:
            self.registered_events.append(EVENT.BAR())

        if self.strategy.callbacks.has_handle_tick:
            self.registered_events.append(EVENT.TICK())

        if self.strategy.callbacks.has_after_trading:
            self.registered_events.append(EVENT.AFTER_TRADING())

        if self.strategy.callbacks.has_open_auction:
            self.registered_events.append(EVENT.OPEN_AUCTION())


def create_base_strategy(
    var event_bus: EventBus,
    name: String = "BaseStrategy"
) -> BaseStrategy:
    return BaseStrategy(
        event_bus=event_bus^,
        current_universe=Set[String](),
        callbacks=create_strategy_callbacks(),
        strategy_name=name
    )


def run_when_strategy_not_hold[T](func: fn() -> T, env: Environment) -> Optional[T]:
    if not env.config.extra.is_hold:
        return Optional[T](func())
    return Optional[T](None)
