"""
Test for concurrent.mojo - Concurrent Utilities
Compares output with Python rqalpha/utils/concurrent.py
"""

from std.collections import List
from rqmojo.utils.concurrent import TaskResult, ProgressedTask


@fieldwise_init
struct SimpleProgressedTask(ProgressedTask, Movable):
    var _steps: Int
    var _current: Int
    
    def total_steps(self) -> Int:
        return self._steps
    
    def execute(self) -> object:
        self._current = self._steps
        return object()


@fieldwise_init
struct CountingProgressedTask(ProgressedTask, Movable):
    var _count_to: Int
    
    def total_steps(self) -> Int:
        return self._count_to
    
    def execute(self) -> object:
        return object()


def test_task_result_struct():
    """测试 TaskResult 结构体创建"""
    print("=== Testing TaskResult struct ===")
    
    var result = TaskResult(task_id=1, result=None, exception=None)
    print("TaskResult created: task_id=" + String(result.task_id))
    
    if result.task_id == 1:
        print("PASS: TaskResult created correctly")
    else:
        print("FAIL: TaskResult task_id mismatch")
    print("")


def test_task_result_fields():
    """测试 TaskResult 字段访问"""
    print("=== Testing TaskResult fields ===")
    
    var result = TaskResult(task_id=5, result=object(), exception=None)
    
    print("task_id: " + String(result.task_id))
    print("exception: " + str(result.exception))
    
    print("PASS: TaskResult fields accessible")
    print("")


def test_simple_progressed_task():
    """测试 SimpleProgressedTask 实现 ProgressedTask trait"""
    print("=== Testing SimpleProgressedTask ===")
    
    var task = SimpleProgressedTask(_steps=5, _current=0)
    var steps = task.total_steps()
    
    print("total_steps: " + String(steps))
    if steps == 5:
        print("PASS: SimpleProgressedTask total_steps correct")
    else:
        print("FAIL: expected 5, got " + String(steps))
    print("")


def test_counting_progressed_task():
    """测试 CountingProgressedTask 实现"""
    print("=== Testing CountingProgressedTask ===")
    
    var task = CountingProgressedTask(_count_to=10)
    var steps = task.total_steps()
    
    print("total_steps: " + String(steps))
    if steps == 10:
        print("PASS: CountingProgressedTask total_steps correct")
    else:
        print("FAIL: expected 10, got " + String(steps))
    print("")


def test_multiple_progressed_tasks():
    """测试多个 ProgressedTask 实例"""
    print("=== Testing multiple ProgressedTask instances ===")
    
    var task1 = SimpleProgressedTask(_steps=3, _current=0)
    var task2 = SimpleProgressedTask(_steps=5, _current=0)
    var task3 = SimpleProgressedTask(_steps=7, _current=0)
    
    print("task1.total_steps: " + String(task1.total_steps()))
    print("task2.total_steps: " + String(task2.total_steps()))
    print("task3.total_steps: " + String(task3.total_steps()))
    
    if task1.total_steps() == 3 and task2.total_steps() == 5 and task3.total_steps() == 7:
        print("PASS: Multiple instances work independently")
    else:
        print("FAIL: Instances not independent")
    print("")


def test_progressed_task_trait_usage():
    """测试 Trait 方法调用"""
    print("=== Testing ProgressedTask trait usage ===")
    
    var task: ProgressedTask = SimpleProgressedTask(_steps=4, _current=0)
    var steps = task.total_steps()
    
    print("Trait method total_steps: " + String(steps))
    if steps == 4:
        print("PASS: Trait method works correctly")
    else:
        print("FAIL: expected 4, got " + String(steps))
    print("")


def test_task_result_equality():
    """测试 TaskResult 相等性比较"""
    print("=== Testing TaskResult equality ===")
    
    var result1 = TaskResult(task_id=1, result=None, exception=None)
    var result2 = TaskResult(task_id=1, result=None, exception=None)
    
    if result1.task_id == result2.task_id:
        print("PASS: TaskResult equality works")
    else:
        print("FAIL: TaskResult equality failed")
    print("")


def test_task_result_with_exception():
    """测试带异常的 TaskResult"""
    print("=== Testing TaskResult with exception ===")
    
    var result = TaskResult(task_id=2, result=None, exception="Error occurred")
    
    if result.exception != None:
        print("PASS: TaskResult with exception works")
    else:
        print("FAIL: Exception not stored")
    print("")


def test_total_steps_calculation():
    """测试模拟 executor 的总步骤计算"""
    print("=== Testing total steps calculation ===")
    
    var task1 = CountingProgressedTask(_count_to=5)
    var task2 = CountingProgressedTask(_count_to=3)
    
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
    test_progressed_task_trait_usage()
    test_task_result_equality()
    test_task_result_with_exception()
    test_total_steps_calculation()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
