"""
RQAlpha Mojo - Strategy Base
Ported from rqalpha/core/strategy.py
"""

from collections import Dict, Set
from rqmojo.const import EXECUTION_PHASE, EXC_TYPE
from rqmojo.core.events import EVENT, Event, EventBus
from rqmojo.core.strategy_context import StrategyContext
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.environment import Environment


trait Strategy:
    fn init(ref self, context: StrategyContext) -> None:
        ...
    fn before_trading(ref self, context: StrategyContext) -> None:
        ...
    fn handle_bar(ref self, context: StrategyContext, bar: BarObject) -> None:
        ...
    fn handle_tick(ref self, context: StrategyContext, tick: TickObject) -> None:
        ...
    fn after_trading(ref self, context: StrategyContext) -> None:
        ...
    fn open_auction(ref self, context: StrategyContext, bar: BarObject) -> None:
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


fn create_strategy_callbacks() -> StrategyCallbacks:
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

    fn __str__(self) -> String:
        return "Strategy(" + self.strategy_name + ")"

    fn register_init(mut self) -> None:
        self.callbacks.has_init = True

    fn register_before_trading(mut self) -> None:
        self.callbacks.has_before_trading = True

    fn register_handle_bar(mut self) -> None:
        self.callbacks.has_handle_bar = True

    fn register_handle_tick(mut self) -> None:
        self.callbacks.has_handle_tick = True

    fn register_after_trading(mut self) -> None:
        self.callbacks.has_after_trading = True

    fn register_open_auction(mut self) -> None:
        self.callbacks.has_open_auction = True

    fn call_init(mut self) -> None:
        pass

    fn call_before_trading(mut self) -> None:
        pass

    fn call_handle_bar(mut self, bar: BarObject) -> None:
        pass

    fn call_handle_tick(mut self, tick: TickObject) -> None:
        pass

    fn call_after_trading(mut self) -> None:
        pass

    fn call_open_auction(mut self, bar: BarObject) -> None:
        pass

    fn get_universe(self) -> Set[String]:
        return self.current_universe

    fn update_universe(mut self, universe: Set[String]) -> None:
        self.current_universe = universe


@fieldwise_init
struct StrategyEventWrapper(
    Copyable, Movable, ImplicitlyCopyable
):
    var strategy: BaseStrategy
    var registered_events: DynamicVector[EVENT]

    fn register_events(mut self, event_bus: EventBus) -> None:
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


fn run_when_strategy_not_hold[T](func: fn() -> T, env: Environment) -> Optional[T]:
    if not env.config.extra.is_hold:
        return Optional[T](func())
    return Optional[T](None)
