# Test Result: test_executor.mojo

Test Date: Thu Mar 26 17:40:24 CST 2026

## Test Output
```
Failed to initialize Crashpad.  Crash reporting will not be available.  Cause: while locating crashpad handler: unable to locate crashpad handler executable
Included from /home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_executor.mojo:6:
Included from /home/zhou/hello_mojo/trae_cn_78/mojo_refactor/./rqmojo/core/executor.mojo:8:
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/./rqmojo/core/events.mojo:14:14: warning: Stringable is being deprecated in favor of Writable
struct Event(Stringable, Movable):
             ^~~~~~~~~~
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_executor.mojo:1:1: note: 'Stringable' declared here
"""
^
Included from /home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_executor.mojo:6:
Included from /home/zhou/hello_mojo/trae_cn_78/mojo_refactor/./rqmojo/core/executor.mojo:8:
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/./rqmojo/core/events.mojo:7:6: warning: Implicit standard library imports are deprecated and will be removed in a future release; fully qualify with 'std.' instead
from utils import Variant
     ^
     std.
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_executor.mojo:21:32: warning: assignment to 'config' was never used; assign to '_' instead?
    var config = ExecutorConfig(
                               ^
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_executor.mojo:32:32: warning: assignment to 'tuple' was never used; assign to '_' instead?
    var tuple = EventSplitTuple(
                               ^
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_executor.mojo:43:31: warning: assignment to 'bus' was never used; assign to '_' instead?
    var bus = create_event_bus()
                              ^
/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06/test_executor.mojo:50:35: warning: assignment to 'executor' was never used; assign to '_' instead?
    var executor = create_executor()
                                  ^
=== Group 06 File 09: Executor Tests ===

Test: ExecutorConfig struct
  ExecutorConfig created successfully
Test: EventSplitTuple struct
  EventSplitTuple created successfully
Test: create_event_bus function
  EventBus created successfully
Test: create_executor function
  Executor created successfully
Test: Executor.get_state method
  State:  {"last_before_trading": "0-0-0"}
Test: Executor.get_event_split_map method
  Event split map has  6  entries
Test: Executor.current_phase method
  Current phase:  GLOBAL

=== Test Summary ===
Passed:  7
Failed:  0
Total:   7
```

## Result
Status: **PASSED**
