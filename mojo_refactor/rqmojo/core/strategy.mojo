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


struct StrategyCallbacks(Copyable, Movable, ImplicitlyCopyable, Writable):
    var has_init: Bool
    var has_before_trading: Bool
    var has_handle_bar: Bool
    var has_handle_tick: Bool
    var has_after_trading: Bool
    var has_open_auction: Bool

    def __init__(out self):
        self.has_init = False
        self.has_before_trading = False
        self.has_handle_bar = False
        self.has_handle_tick = False
        self.has_after_trading = False
        self.has_open_auction = False

    def __init__(out self, *, copy: Self):
        self.has_init = copy.has_init
        self.has_before_trading = copy.has_before_trading
        self.has_handle_bar = copy.has_handle_bar
        self.has_handle_tick = copy.has_handle_tick
        self.has_after_trading = copy.has_after_trading
        self.has_open_auction = copy.has_open_auction

    def __init__(out self, *, deinit take: Self):
        self.has_init = take.has_init
        self.has_before_trading = take.has_before_trading
        self.has_handle_bar = take.has_handle_bar
        self.has_handle_tick = take.has_handle_tick
        self.has_after_trading = take.has_after_trading
        self.has_open_auction = take.has_open_auction

    def write_to(self, mut writer: Some[Writer]):
        writer.write("StrategyCallbacks()")


def create_strategy_callbacks() -> StrategyCallbacks:
    return StrategyCallbacks()


struct BaseStrategy(Movable, Writable):
    var current_universe: Set[String]
    var callbacks: StrategyCallbacks
    var event_bus: EventBus
    var strategy_name: String

    def __init__(
        out self,
        event_bus: EventBus,
        current_universe: Set[String],
        callbacks: StrategyCallbacks,
        strategy_name: String,
    ):
        self.event_bus = event_bus^
        self.current_universe = current_universe^
        self.callbacks = callbacks
        self.strategy_name = strategy_name

    def __init__(out self, *, deinit take: Self):
        self.event_bus = take.event_bus^
        self.current_universe = take.current_universe^
        self.callbacks = take.callbacks
        self.strategy_name = take.strategy_name

    def write_to(self, mut writer: Some[Writer]):
        writer.write("Strategy(", self.strategy_name, ")")

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


struct StrategyEventWrapper(Copyable, Movable, ImplicitlyCopyable, Writable):
    var strategy: BaseStrategy
    var registered_events: List[EVENT]

    def __init__(out self, strategy: BaseStrategy):
        self.strategy = strategy^
        self.registered_events = List[EVENT]()

    def __init__(out self, *, copy: Self):
        self.strategy = copy.strategy
        self.registered_events = copy.registered_events

    def __init__(out self, *, deinit take: Self):
        self.strategy = take.strategy^
        self.registered_events = take.registered_events^

    def write_to(self, mut writer: Some[Writer]):
        writer.write("StrategyEventWrapper()")

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
    owned event_bus: EventBus,
    name: String = "BaseStrategy"
) -> BaseStrategy:
    return BaseStrategy(
        event_bus=event_bus,
        current_universe=Set[String](),
        callbacks=create_strategy_callbacks(),
        strategy_name=name
    )


def run_when_strategy_not_hold[T](func: fn() -> T, env: Environment) -> Optional[T]:
    if not env.config.extra.is_hold:
        return Optional[T](func())
    return Optional[T](None)
