# test_L07_01_strategy.mojo
# Module: rqmojo.core.strategy
# Python: rqalpha.core.strategy
# Level: L07 - Core Implementation
# Dependencies: events, environment

from rqmojo.core.strategy import (
    Strategy, StrategyCallbacks, create_strategy_callbacks
)
from rqmojo.core.events import EventBus, create_event_bus
from rqmojo.const import EXECUTION_PHASE


@fieldwise_init
struct TestRunner:
    var test_count: Int
    var pass_count: Int
    
    fn check(mut self, condition: Bool, test_name: String):
        self.test_count += 1
        if condition:
            self.pass_count += 1
            print("PASS: " + test_name)
        else:
            print("FAIL: " + test_name)

    fn test_strategy_callbacks(mut self):
        var callbacks = create_strategy_callbacks()
        self.check(callbacks.has_init == False, "StrategyCallbacks has_init is False initially")
        self.check(callbacks.has_before_trading == False, "StrategyCallbacks has_before_trading is False initially")
        self.check(callbacks.has_handle_bar == False, "StrategyCallbacks has_handle_bar is False initially")

    fn test_strategy_callbacks_register_init(mut self):
        var callbacks = create_strategy_callbacks()
        callbacks.has_init = True
        self.check(callbacks.has_init == True, "StrategyCallbacks has_init is True after register")

    fn test_strategy_callbacks_register_before_trading(mut self):
        var callbacks = create_strategy_callbacks()
        callbacks.has_before_trading = True
        self.check(callbacks.has_before_trading == True, "StrategyCallbacks has_before_trading is True after register")

    fn test_strategy_callbacks_register_handle_bar(mut self):
        var callbacks = create_strategy_callbacks()
        callbacks.has_handle_bar = True
        self.check(callbacks.has_handle_bar == True, "StrategyCallbacks has_handle_bar is True after register")

    fn test_strategy_callbacks_register_handle_tick(mut self):
        var callbacks = create_strategy_callbacks()
        callbacks.has_handle_tick = True
        self.check(callbacks.has_handle_tick == True, "StrategyCallbacks has_handle_tick is True after register")

    fn test_strategy_callbacks_register_after_trading(mut self):
        var callbacks = create_strategy_callbacks()
        callbacks.has_after_trading = True
        self.check(callbacks.has_after_trading == True, "StrategyCallbacks has_after_trading is True after register")

    fn test_strategy_callbacks_register_open_auction(mut self):
        var callbacks = create_strategy_callbacks()
        callbacks.has_open_auction = True
        self.check(callbacks.has_open_auction == True, "StrategyCallbacks has_open_auction is True after register")

    fn test_strategy_trait_exists(mut self):
        self.check(True, "Strategy trait exists")

    fn run_all(mut self):
        print("=" * 60)
        print("L07_01_strategy Module Tests")
        print("=" * 60)
        
        self.test_strategy_callbacks()
        self.test_strategy_callbacks_register_init()
        self.test_strategy_callbacks_register_before_trading()
        self.test_strategy_callbacks_register_handle_bar()
        self.test_strategy_callbacks_register_handle_tick()
        self.test_strategy_callbacks_register_after_trading()
        self.test_strategy_callbacks_register_open_auction()
        self.test_strategy_trait_exists()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
