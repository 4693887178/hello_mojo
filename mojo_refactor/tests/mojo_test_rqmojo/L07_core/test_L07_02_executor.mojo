# test_L07_02_executor.mojo
# Module: rqmojo.core.executor
# Python: rqalpha.core.executor
# Level: L07 - Core Implementation
# Dependencies: events, environment

from rqmojo.core.executor import (
    Executor, ExecutorConfig, EventSplitTuple,
    create_executor, create_executor_with_config
)
from rqmojo.core.events import EVENT, EventBus, create_event_bus
from rqmojo.const import EXECUTION_PHASE
from rqmojo.utils.datetime_func import DateTime


fn create_executor_config(start: DateTime, end: DateTime, frequency: String) -> ExecutorConfig:
    return ExecutorConfig(start_date=start, end_date=end, frequency=frequency)


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

    fn test_executor_config_creation(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var config = create_executor_config(start, end, "1d")
        self.check(config.start_date.year == 2024, "ExecutorConfig start_date year is 2024")
        self.check(config.end_date.year == 2024, "ExecutorConfig end_date year is 2024")
        self.check(config.frequency == "1d", "ExecutorConfig frequency is 1d")

    fn test_executor_creation(mut self):
        var executor = create_executor()
        self.check(True, "Executor created successfully")

    fn test_executor_current_phase(mut self):
        var executor = create_executor()
        var phase = executor.current_phase()
        self.check(phase == EXECUTION_PHASE.GLOBAL(), "Executor current_phase is GLOBAL")

    fn test_executor_set_phase(mut self):
        var executor = create_executor()
        executor.set_phase(EXECUTION_PHASE.ON_BAR())
        self.check(executor._current_phase_name == "ON_BAR", "Executor set_phase works")

    fn test_executor_get_state(mut self):
        var executor = create_executor()
        var state = executor.get_state()
        self.check(state.find("last_before_trading") >= 0, "Executor get_state contains last_before_trading")

    fn test_event_split_tuple(mut self):
        var split = EventSplitTuple(
            pre=EVENT.PRE_BAR(),
            main=EVENT.BAR(),
            post=EVENT.POST_BAR()
        )
        self.check(split.pre == EVENT.PRE_BAR(), "EventSplitTuple pre is PRE_BAR")
        self.check(split.main == EVENT.BAR(), "EventSplitTuple main is BAR")
        self.check(split.post == EVENT.POST_BAR(), "EventSplitTuple post is POST_BAR")

    fn test_get_event_split_map_exists(mut self):
        var split_map = Executor.get_event_split_map()
        self.check("BAR" in split_map, "EventSplitMap contains BAR")
        self.check("TICK" in split_map, "EventSplitMap contains TICK")
        self.check("BEFORE_TRADING" in split_map, "EventSplitMap contains BEFORE_TRADING")

    fn run_all(mut self):
        print("=" * 60)
        print("L07_02_executor Module Tests")
        print("=" * 60)
        
        self.test_executor_config_creation()
        self.test_executor_creation()
        self.test_executor_current_phase()
        self.test_executor_set_phase()
        self.test_executor_get_state()
        self.test_event_split_tuple()
        self.test_get_event_split_map_exists()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
