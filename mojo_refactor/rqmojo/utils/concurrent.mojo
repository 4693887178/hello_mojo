"""
RQAlpha Mojo - Concurrent Utilities
Ported from rqalpha/utils/concurrent.py
"""

from std.collections import Queue
from utils import Variant


comptime TaskResultValue = Variant[String, Int, Float64]


@fieldwise_init
struct TaskResult(Movable):
    var task_id: Int
    var result: Optional[TaskResultValue]
    var exception: Optional[String]


trait ProgressedTask:
    def total_steps(self) -> Int: ...
    def execute(self) -> TaskResultValue: ...
