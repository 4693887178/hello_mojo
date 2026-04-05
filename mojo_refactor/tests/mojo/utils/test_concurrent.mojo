"""
Test for concurrent.mojo - Concurrent Utilities

Uses Mojo standard library testing framework (std.testing).
Tests cover: TaskResult, CallItem, Future, ProgressedTask,
           _InlineProgressBar, ProgressedProcessPoolExecutor.
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from rqmojo.utils.concurrent import (
    TaskResult,
    TaskResultValue,
    CallItem,
    Future,
    ProgressedTask,
    _InlineProgressBar,
    ProgressedProcessPoolExecutor,
)


@fieldwise_init
struct SimpleProgressedTask(ProgressedTask, Movable):
    var _steps: Int
    var _result_value: Int

    def total_steps(self) -> Int:
        return self._steps

    def execute(mut self) raises -> TaskResultValue:
        return TaskResultValue(self._result_value)


@fieldwise_init
struct FailingProgressedTask(ProgressedTask, Movable):
    var _steps: Int
    var _error_msg: String

    def total_steps(self) -> Int:
        return self._steps

    def execute(mut self) raises -> TaskResultValue:
        raise Error(self._error_msg)


def test_task_result_creation() raises:
    var r = TaskResult(task_id=42, result=None, exception=None)
    assert_equal(r.task_id, 42)
    assert_true(r.exception == None)
    assert_true(r.result == None)
    assert_true(r.is_success())


def test_task_result_with_result() raises:
    var r = TaskResult(
        task_id=1,
        result=Optional[TaskResultValue](TaskResultValue(99)),
        exception=None,
    )
    assert_equal(r.task_id, 1)
    assert_true(r.is_success())
    var val = r.get_result()
    assert_true(val.isa[Int]())


def test_task_result_with_exception() raises:
    var r = TaskResult(
        task_id=3,
        result=None,
        exception=Optional[String]("something went wrong"),
    )
    assert_false(r.is_success())


def test_call_item_creation() raises:
    var item = CallItem(work_id=10, fn_name="test_fn", is_progressed=True, total_steps=50)
    assert_equal(item.work_id, 10)
    assert_equal(item.fn_name, "test_fn")
    assert_true(item.is_progressed)
    assert_equal(item.total_steps, 50)


def test_future_initial_state() raises:
    var fut = Future(work_id=7)
    assert_equal(fut.work_id, 7)
    assert_true(fut.running())
    assert_false(fut.done())


def test_future_set_result() raises:
    var fut = Future(work_id=1)
    fut.set_result(TaskResultValue(42))
    assert_false(fut.running())
    assert_true(fut.done())
    var res = fut.result()
    assert_true(res.isa[Int]())
    assert_true(fut.exception() == None)


def test_future_set_exception() raises:
    var fut = Future(work_id=2)
    fut.set_exception("boom")
    assert_false(fut.running())
    assert_true(fut.done())
    assert_true(fut.exception() != None)


def test_progressed_task_trait() raises:
    var task = SimpleProgressedTask(_steps=100, _result_value=77)
    assert_equal(task.total_steps(), 100)
    var result = task.execute()
    assert_true(result.isa[Int]())


def test_failing_progressed_task() raises:
    var task = FailingProgressedTask(_steps=5, _error_msg="test error")
    assert_equal(task.total_steps(), 5)
    var caught = False
    try:
        _ = task.execute()
    except e:
        caught = True
    assert_true(caught)


def test_inline_progress_bar() raises:
    var bar = _InlineProgressBar(length=100)
    bar.update(50)
    bar.update(50)
    bar.render_finish()


def test_inline_progress_bar_zero_length() raises:
    var bar = _InlineProgressBar(length=0)
    bar.update(10)
    bar.render_finish()


def test_executor_init() raises:
    var executor = ProgressedProcessPoolExecutor()
    assert_true(executor._total_steps == 0)
    assert_true(executor._next_work_id == 0)


def test_executor_submit_simple() raises:
    var executor = ProgressedProcessPoolExecutor()
    _ = executor.submit_simple("task_a", steps=5)
    assert_equal(executor._total_steps, 5)


def test_executor_submit_multiple_simple() raises:
    var executor = ProgressedProcessPoolExecutor()
    _ = executor.submit_simple("t1", steps=3)
    _ = executor.submit_simple("t2", steps=7)
    _ = executor.submit_simple("t3", steps=10)
    assert_equal(executor._total_steps, 20)


def test_executor_submit_progressed_success() raises:
    var executor = ProgressedProcessPoolExecutor()
    var task = SimpleProgressedTask(_steps=50, _result_value=123)
    var result = task.execute()

    var fut = executor.submit_progressed(
        task.total_steps(),
        result,
        "backtest",
    )

    assert_equal(executor._total_steps, 50)
    assert_true(fut.done())
    var res = fut.result()
    assert_true(res.isa[Int]())


def test_executor_submit_progressed_failure_case() raises:
    var executor = ProgressedProcessPoolExecutor()
    var bad_task = FailingProgressedTask(_steps=10, _error_msg="calculation failed")

    var caught_error = False
    try:
        _ = bad_task.execute()
    except e:
        caught_error = True

    assert_true(caught_error)

    var fut = executor.submit_progressed(
        bad_task.total_steps(),
        TaskResultValue(-1),
        "bad_task_recorded",
    )

    assert_true(fut.done())
    var res = fut.result()
    assert_true(res.isa[Int]())


def test_executor_shutdown_no_wait() raises:
    var executor = ProgressedProcessPoolExecutor()
    _ = executor.submit_simple("quick", steps=1)
    executor.shutdown(wait=False)


def test_executor_shutdown_with_wait() raises:
    var executor = ProgressedProcessPoolExecutor()
    var task1 = SimpleProgressedTask(_steps=30, _result_value=1)
    var task2 = SimpleProgressedTask(_steps=70, _result_value=2)

    var result1 = task1.execute()
    var result2 = task2.execute()

    _ = executor.submit_progressed(
        task1.total_steps(),
        result1,
        "task1",
    )
    _ = executor.submit_progressed(
        task2.total_steps(),
        result2,
        "task2",
    )
    _ = executor.submit_simple("cleanup", steps=5)

    assert_equal(executor._total_steps, 105)
    executor.shutdown(wait=True)


def test_executor_mixed_submit() raises:
    var executor = ProgressedProcessPoolExecutor()
    var main_task = SimpleProgressedTask(_steps=25, _result_value=99)
    var main_result = main_task.execute()

    _ = executor.submit_progressed(
        main_task.total_steps(),
        main_result,
        "main_task",
    )
    _ = executor.submit_simple("subtask_1", steps=5)
    _ = executor.submit_simple("subtask_2", steps=10)

    assert_equal(executor._total_steps, 40)
    assert_equal(len(executor._futures), 3)
    assert_equal(len(executor._call_items), 3)

    executor.shutdown(wait=True)


def test_task_result_value_variant_int() raises:
    var v = TaskResultValue(42)
    assert_true(v.isa[Int]())

def test_task_result_value_variant_float() raises:
    var v = TaskResultValue(3.14)
    assert_true(v.isa[Float64]())

def test_task_result_value_variant_string() raises:
    var v = TaskResultValue("hello")
    assert_true(v.isa[String]())


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
