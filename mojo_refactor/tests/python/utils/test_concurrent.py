# -*- coding: utf-8 -*-
"""
Test for rqalpha/utils/concurrent.py - Concurrent Utilities
Compares output with Mojo rqmojo/utils/concurrent.mojo
"""

from typing import Generator, Any
from rqalpha.utils.concurrent import ProgressedTask, ProgressedProcessPoolExecutor


class SimpleProgressedTask(ProgressedTask):
    """简单的测试任务"""
    
    def __init__(self, steps: int):
        self._steps = steps
        self._current = 0
    
    @property
    def total_steps(self) -> int:
        return self._steps
    
    def __call__(self, *args, **kwargs) -> Generator:
        for i in range(self._steps):
            self._current = i + 1
            yield i
        return self._steps


class CountingProgressedTask(ProgressedTask):
    """计数任务"""
    
    def __init__(self, count_to: int):
        self._count_to = count_to
    
    @property
    def total_steps(self) -> int:
        return self._count_to
    
    def __call__(self, *args, **kwargs) -> Generator:
        for i in range(self._count_to):
            yield i
        return self._count_to


def test_progressed_task_interface():
    """测试 ProgressedTask 接口"""
    print("=== Testing ProgressedTask interface ===")
    
    task = SimpleProgressedTask(5)
    print(f"total_steps = {task.total_steps}")
    
    assert task.total_steps == 5, "total_steps should be 5"
    
    results = list(task())
    print(f"Generator results: {results}")
    
    print("PASS: ProgressedTask interface works correctly")
    print("")


def test_progressed_task_counting():
    """测试 CountingProgressedTask"""
    print("=== Testing CountingProgressedTask ===")
    
    task = CountingProgressedTask(10)
    print(f"total_steps = {task.total_steps}")
    
    assert task.total_steps == 10, "total_steps should be 10"
    
    count = 0
    for _ in task():
        count += 1
    
    print(f"Counted {count} steps")
    assert count == 10, "Should count 10 steps"
    
    print("PASS: CountingProgressedTask works correctly")
    print("")


def test_progressed_task_multiple_instances():
    """测试多个 ProgressedTask 实例"""
    print("=== Testing multiple ProgressedTask instances ===")
    
    task1 = SimpleProgressedTask(3)
    task2 = SimpleProgressedTask(5)
    task3 = SimpleProgressedTask(7)
    
    print(f"task1.total_steps = {task1.total_steps}")
    print(f"task2.total_steps = {task2.total_steps}")
    print(f"task3.total_steps = {task3.total_steps}")
    
    assert task1.total_steps == 3
    assert task2.total_steps == 5
    assert task3.total_steps == 7
    
    print("PASS: Multiple instances work independently")
    print("")


def test_progressed_process_pool_executor_init():
    """测试 ProgressedProcessPoolExecutor 初始化"""
    print("=== Testing ProgressedProcessPoolExecutor init ===")
    
    executor = ProgressedProcessPoolExecutor(max_workers=2)
    print(f"Executor created with max_workers=2")
    
    print("PASS: ProgressedProcessPoolExecutor initialized")
    print("")


def test_progressed_process_pool_executor_submit():
    """测试 ProgressedProcessPoolExecutor submit"""
    print("=== Testing ProgressedProcessPoolExecutor submit ===")
    
    executor = ProgressedProcessPoolExecutor(max_workers=1)
    
    def simple_func():
        return 42
    
    future = executor.submit(simple_func)
    print(f"Future submitted: {future}")
    
    assert future is not None, "Future should not be None"
    
    executor.shutdown(wait=False)
    print("PASS: submit method works")
    print("")


def test_progressed_process_pool_executor_total_steps():
    """测试 ProgressedProcessPoolExecutor 总步骤计数"""
    print("=== Testing total_steps calculation ===")
    
    executor = ProgressedProcessPoolExecutor(max_workers=2)
    
    task1 = CountingProgressedTask(5)
    task2 = CountingProgressedTask(3)
    
    executor.submit(task1)
    executor.submit(task2)
    
    total = executor._total_steps
    print(f"Total steps: {total}")
    
    assert total == 8, f"Total steps should be 8, got {total}"
    
    executor.shutdown(wait=False)
    print("PASS: total_steps calculation works")
    print("")


if __name__ == "__main__":
    print("=" * 60)
    print("RQAlpha Python utils/concurrent.py Test")
    print("=" * 60)
    print("")
    
    test_progressed_task_interface()
    test_progressed_task_counting()
    test_progressed_task_multiple_instances()
    test_progressed_process_pool_executor_init()
    test_progressed_process_pool_executor_submit()
    test_progressed_process_pool_executor_total_steps()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
