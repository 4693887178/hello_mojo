# test_L02_01_execution_context.mojo
# Module: rqmojo.core.execution_context
# Python: rqalpha.core.execution_context
# Level: L02 - Core Base
# Dependencies: const, datetime_func

from rqmojo.core.execution_context import (
    ContextStack, ExecutionContext,
    create_execution_context, create_bar_execution_context, create_tick_execution_context
)
from rqmojo.const import EXECUTION_PHASE
from rqmojo.utils.datetime_func import DateTime


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

    fn test_context_stack_init(mut self):
        var stack = ContextStack(List[EXECUTION_PHASE]())
        self.check(stack.is_empty(), "ContextStack init empty")

    fn test_context_stack_push(mut self):
        var stack = ContextStack(List[EXECUTION_PHASE]())
        stack.push(EXECUTION_PHASE.ON_BAR())
        self.check(stack.size() == 1, "ContextStack push size 1")

    fn test_context_stack_pop(mut self):
        var stack = ContextStack(List[EXECUTION_PHASE]())
        stack.push(EXECUTION_PHASE.ON_BAR())
        var result = stack.pop()
        self.check(result == EXECUTION_PHASE.ON_BAR(), "ContextStack pop returns ON_BAR")

    fn test_context_stack_top(mut self):
        var stack = ContextStack(List[EXECUTION_PHASE]())
        stack.push(EXECUTION_PHASE.ON_BAR())
        stack.push(EXECUTION_PHASE.ON_TICK())
        self.check(stack.top() == EXECUTION_PHASE.ON_TICK(), "ContextStack top returns ON_TICK")

    fn test_context_stack_multiple(mut self):
        var stack = ContextStack(List[EXECUTION_PHASE]())
        stack.push(EXECUTION_PHASE.ON_BAR())
        stack.push(EXECUTION_PHASE.BEFORE_TRADING())
        stack.push(EXECUTION_PHASE.AFTER_TRADING())
        self.check(stack.size() == 3, "ContextStack multiple push size 3")
        stack.pop()
        self.check(stack.size() == 2, "ContextStack after pop size 2")

    fn test_context_stack_clear(mut self):
        var stack = ContextStack(List[EXECUTION_PHASE]())
        stack.push(EXECUTION_PHASE.ON_BAR())
        stack.push(EXECUTION_PHASE.ON_TICK())
        stack.clear()
        self.check(stack.is_empty(), "ContextStack clear empty")

    fn test_execution_context_init(mut self):
        var ctx = create_execution_context(EXECUTION_PHASE.ON_BAR())
        self.check(ctx.phase == EXECUTION_PHASE.ON_BAR(), "ExecutionContext init phase ON_BAR")

    fn test_execution_context_str(mut self):
        var ctx = create_execution_context(EXECUTION_PHASE.ON_BAR())
        var str_repr = ctx.__str__()
        self.check(str_repr.find("ExecutionContext") >= 0, "ExecutionContext __str__ contains class name")

    fn test_execution_context_with_datetime(mut self):
        var ctx = create_execution_context(EXECUTION_PHASE.ON_BAR())
        var dt = DateTime(2024, 1, 1, 10, 0, 0, 0)
        ctx.set_datetime(dt)
        self.check(ctx.current_datetime.year == 2024, "ExecutionContext set_datetime year 2024")

    fn test_execution_context_get_phase(mut self):
        var ctx = create_execution_context(EXECUTION_PHASE.ON_TICK())
        self.check(ctx.get_phase() == EXECUTION_PHASE.ON_TICK(), "ExecutionContext get_phase returns ON_TICK")

    fn test_execution_context_is_on_bar(mut self):
        var ctx = create_execution_context(EXECUTION_PHASE.ON_BAR())
        self.check(ctx.is_on_bar(), "ExecutionContext is_on_bar returns True")

    fn test_execution_context_is_on_tick(mut self):
        var ctx = create_execution_context(EXECUTION_PHASE.ON_TICK())
        self.check(ctx.is_on_tick(), "ExecutionContext is_on_tick returns True")

    fn test_execution_context_is_before_trading(mut self):
        var ctx = create_execution_context(EXECUTION_PHASE.BEFORE_TRADING())
        self.check(ctx.is_before_trading(), "ExecutionContext is_before_trading returns True")

    fn test_execution_context_is_after_trading(mut self):
        var ctx = create_execution_context(EXECUTION_PHASE.AFTER_TRADING())
        self.check(ctx.is_after_trading(), "ExecutionContext is_after_trading returns True")

    fn test_execution_context_is_on_init(mut self):
        var ctx = create_execution_context(EXECUTION_PHASE.ON_INIT())
        self.check(ctx.is_on_init(), "ExecutionContext is_on_init returns True")

    fn test_execution_context_is_global(mut self):
        var ctx = create_execution_context(EXECUTION_PHASE.GLOBAL())
        self.check(ctx.is_global(), "ExecutionContext is_global returns True")

    fn test_create_bar_execution_context(mut self):
        var dt = DateTime(2024, 6, 15, 9, 30, 0, 0)
        var ctx = create_bar_execution_context(dt)
        self.check(ctx.phase == EXECUTION_PHASE.ON_BAR(), "create_bar_execution_context phase ON_BAR")
        self.check(ctx.current_datetime.month == 6, "create_bar_execution_context month 6")

    fn test_create_tick_execution_context(mut self):
        var dt = DateTime(2024, 6, 15, 9, 30, 0, 0)
        var ctx = create_tick_execution_context(dt)
        self.check(ctx.phase == EXECUTION_PHASE.ON_TICK(), "create_tick_execution_context phase ON_TICK")
        self.check(ctx.current_datetime.day == 15, "create_tick_execution_context day 15")

    fn run_all(mut self):
        print("=" * 60)
        print("L02_01_execution_context Module Tests")
        print("=" * 60)
        
        self.test_context_stack_init()
        self.test_context_stack_push()
        self.test_context_stack_pop()
        self.test_context_stack_top()
        self.test_context_stack_multiple()
        self.test_context_stack_clear()
        self.test_execution_context_init()
        self.test_execution_context_str()
        self.test_execution_context_with_datetime()
        self.test_execution_context_get_phase()
        self.test_execution_context_is_on_bar()
        self.test_execution_context_is_on_tick()
        self.test_execution_context_is_before_trading()
        self.test_execution_context_is_after_trading()
        self.test_execution_context_is_on_init()
        self.test_execution_context_is_global()
        self.test_create_bar_execution_context()
        self.test_create_tick_execution_context()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
