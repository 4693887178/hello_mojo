"""
RQAlpha Mojo - Strategy Base
Ported from rqalpha/core/strategy.py

Python Original Design:
- Strategy class: receives event_bus, scope(dict of user functions), ucontext(StrategyContext)
- Registers lifecycle handlers on event_bus based on which functions exist in scope
- Each lifecycle method decorated with @run_when_strategy_not_hold (checks config.extra.is_hold)
- wrap_user_event_handler: wraps user handler to inject user_context automatically
- init(): calls user's init func, then publishes POST_USER_INIT event

Mojo Adaptation:
- trait Strategy: defines lifecycle interface for user strategy implementations
- BaseStrategy: concrete base with callback tracking, event registration, universe management
- StrategyCallbacks: tracks which lifecycle methods are registered
- StrategyEventWrapper: encapsulates event registration logic
- run_when_strategy_not_hold: checks env.config.is_hold before executing
"""

from std.collections import Dict, Set, List
from rqmojo.core.events import EVENT, Event, EventBus
from rqmojo.core.strategy_context import StrategyContext, create_strategy_context
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.environment import Environment, create_environment
from rqmojo.data.data_proxy import create_data_proxy
from rqmojo.utils.typing import DateTime


trait Strategy:
    def init(ref self, context: StrategyContext) -> None: ...
    def before_trading(ref self, context: StrategyContext) -> None: ...
    def handle_bar(ref self, context: StrategyContext, bar: BarObject) -> None: ...
    def handle_tick(ref self, context: StrategyContext, tick: TickObject) -> None: ...
    def after_trading(ref self, context: StrategyContext) -> None: ...
    def open_auction(ref self, context: StrategyContext, bar: BarObject) -> None: ...


@fieldwise_init
struct StrategyCallbacks(Copyable, Movable, ImplicitlyCopyable, Writable):
    var has_init: Bool
    var has_before_trading: Bool
    var has_handle_bar: Bool
    var has_handle_tick: Bool
    var has_after_trading: Bool
    var has_open_auction: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("StrategyCallbacks(init=", String(self.has_init),
            ", before_trading=", String(self.has_before_trading),
            ", handle_bar=", String(self.has_handle_bar),
            ", handle_tick=", String(self.has_handle_tick),
            ", after_trading=", String(self.has_after_trading),
            ", open_auction=", String(self.has_open_auction), ")")


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
struct BaseStrategy(Movable, Writable):
    var current_universe: Set[String]
    var callbacks: StrategyCallbacks
    var event_bus: EventBus
    var strategy_name: String
    var _user_context_set: Bool

    def __init__(
        out self,
        var event_bus: EventBus,
        var current_universe: Set[String],
        callbacks: StrategyCallbacks,
        strategy_name: String,
    ):
        self.event_bus = event_bus^
        self.current_universe = current_universe^
        self.callbacks = callbacks
        self.strategy_name = strategy_name
        self._user_context_set = False

    def __init__(out self, *, deinit take: Self):
        self.event_bus = take.event_bus^
        self.current_universe = take.current_universe^
        self.callbacks = take.callbacks
        self.strategy_name = take.strategy_name
        self._user_context_set = take._user_context_set

    def write_to(self, mut writer: Some[Writer]):
        writer.write("BaseStrategy(", self.strategy_name, ")")

    def user_context(self) -> StrategyContext:
        var env = create_environment(
            DateTime(2020, 1, 1, 0, 0, 0, 0),
            DateTime(2020, 12, 31, 0, 0, 0, 0)
        )
        var dp = create_data_proxy()
        return create_strategy_context(env^, dp^)

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
        return self.current_universe.copy()

    def update_universe(mut self, var universe: Set[String]) -> None:
        self.current_universe = universe^

    def wrap_user_event_handler(self, handler_name: String) -> String:
        return "wrapped_" + handler_name


@fieldwise_init
struct StrategyEventWrapper(Movable, Writable):
    var strategy: BaseStrategy
    var registered_events: List[EVENT]

    def __init__(out self, var strategy: BaseStrategy):
        self.strategy = strategy^
        self.registered_events = List[EVENT]()

    def __init__(out self, *, deinit take: Self):
        self.strategy = take.strategy^
        self.registered_events = take.registered_events^

    def write_to(self, mut writer: Some[Writer]):
        writer.write("StrategyEventWrapper(registered_count=",
            String(len(self.registered_events)), ")")

    def register_events(mut self, event_bus: EventBus) -> None:
        if self.strategy.callbacks.has_before_trading:
            self.registered_events.append(EVENT.BEFORE_TRADING)

        if self.strategy.callbacks.has_handle_bar:
            self.registered_events.append(EVENT.BAR)

        if self.strategy.callbacks.has_handle_tick:
            self.registered_events.append(EVENT.TICK)

        if self.strategy.callbacks.has_after_trading:
            self.registered_events.append(EVENT.AFTER_TRADING)

        if self.strategy.callbacks.has_open_auction:
            self.registered_events.append(EVENT.OPEN_AUCTION)


def run_when_strategy_not_hold(func: fn() raises, env: Environment) raises -> Bool:
    var cfg = env.config()
    if not cfg.is_hold:
        func()
        return True
    return False


def create_base_strategy(
    var event_bus: EventBus,
    name: String = "BaseStrategy"
) -> BaseStrategy:
    var universe = Set[String]()
    return BaseStrategy(
        event_bus=event_bus^,
        current_universe=universe^,
        callbacks=create_strategy_callbacks(),
        strategy_name=name
    )
