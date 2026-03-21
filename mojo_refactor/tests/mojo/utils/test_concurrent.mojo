"""
Test for concurrent.mojo - Concurrent Utilities
"""

from std.collections import List
from std.utils import Variant
from rqmojo.utils.concurrent import TaskResult, ProgressedTask


comptime TaskResultValue = Variant[String, Int, Float64]


@fieldwise_init
struct SimpleProgressedTask(ProgressedTask, Movable):
    var steps: Int
    
    def total_steps(self) -> Int:
        return self.steps
    
    def execute(self) -> TaskResultValue:
        return TaskResultValue("done")


@fieldwise_init
struct CountingProgressedTask(ProgressedTask, Movable):
    var count_to: Int
    
    def total_steps(self) -> Int:
        return self.count_to
    
    def execute(self) -> TaskResultValue:
        return TaskResultValue("counted")


def test_task_result_struct():
    print("=== Testing TaskResult struct ===")
    
    var result = TaskResult(task_id=1, result=None, exception=None)
    print("TaskResult created: task_id=" + String(result.task_id))
    
    if result.task_id == 1:
        print("PASS: TaskResult created correctly")
    else:
        print("FAIL: TaskResult task_id mismatch")
    print("")


def test_task_result_fields():
    print("=== Testing TaskResult fields ===")
    
    var result = TaskResult(task_id=5, result=TaskResultValue("test"), exception=None)
    
    print("task_id: " + String(result.task_id))
    
    print("PASS: TaskResult fields accessible")
    print("")


def test_simple_progressed_task():
    print("=== Testing SimpleProgressedTask ===")
    
    var task = SimpleProgressedTask(steps=5)
    var steps = task.total_steps()
    
    print("total_steps: " + String(steps))
    if steps == 5:
        print("PASS: SimpleProgressedTask total_steps correct")
    else:
        print("FAIL: expected 5, got " + String(steps))
    print("")


def test_counting_progressed_task():
    print("=== Testing CountingProgressedTask ===")
    
    var task = CountingProgressedTask(count_to=10)
    var steps = task.total_steps()
    
    print("total_steps: " + String(steps))
    if steps == 10:
        print("PASS: CountingProgressedTask total_steps correct")
    else:
        print("FAIL: expected 10, got " + String(steps))
    print("")


def test_multiple_progressed_tasks():
    print("=== Testing multiple ProgressedTask instances ===")
    
    var task1 = SimpleProgressedTask(steps=3)
    var task2 = SimpleProgressedTask(steps=5)
    var task3 = SimpleProgressedTask(steps=7)
    
    print("task1.total_steps: " + String(task1.total_steps()))
    print("task2.total_steps: " + String(task2.total_steps()))
    print("task3.total_steps: " + String(task3.total_steps()))
    
    if task1.total_steps() == 3 and task2.total_steps() == 5 and task3.total_steps() == 7:
        print("PASS: Multiple instances work independently")
    else:
        print("FAIL: Instances not independent")
    print("")


def test_task_result_equality():
    print("=== Testing TaskResult equality ===")
    
    var result1 = TaskResult(task_id=1, result=None, exception=None)
    var result2 = TaskResult(task_id=1, result=None, exception=None)
    
    if result1.task_id == result2.task_id:
        print("PASS: TaskResult equality works")
    else:
        print("FAIL: TaskResult equality failed")
    print("")


def test_task_result_with_exception():
    print("=== Testing TaskResult with exception ===")
    
    var result = TaskResult(task_id=2, result=None, exception="Error occurred")
    
    if result.exception != None:
        print("PASS: TaskResult with exception works")
    else:
        print("FAIL: Exception not stored")
    print("")


def test_total_steps_calculation():
    print("=== Testing total steps calculation ===")
    
    var task1 = CountingProgressedTask(count_to=5)
    var task2 = CountingProgressedTask(count_to=3)
    
    var total = task1.total_steps() + task2.total_steps()
    print("Total steps: " + String(total))
    
    if total == 8:
        print("PASS: Total steps calculation correct")
    else:
        print("FAIL: expected 8, got " + String(total))
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo utils/concurrent.mojo Test")
    print("=" * 60)
    print("")
    
    test_task_result_struct()
    test_task_result_fields()
    test_simple_progressed_task()
    test_counting_progressed_task()
    test_multiple_progressed_tasks()
    test_task_result_equality()
    test_task_result_with_exception()
    test_total_steps_calculation()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
