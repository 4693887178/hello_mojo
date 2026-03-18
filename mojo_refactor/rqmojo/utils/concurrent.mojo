"""
RQAlpha Mojo - Concurrent Utilities
Ported from rqalpha/utils/concurrent.py
"""

from collections import Queue


@value
struct TaskResult:
    var task_id: Int
    var result: Optional[object]
    var exception: Optional[String]


trait ProgressedTask:
    fn total_steps(self) -> Int:
        ...
    fn execute(self) -> object:
        ...
