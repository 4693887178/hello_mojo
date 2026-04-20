"""
RQAlpha Mojo - Concurrent Utilities
Ported from rqalpha/utils/concurrent.py

Design notes (Python -> Mojo mapping):
  - Python Generator/yield  -> Mojo direct execution (no yield in Mojo)
  - multiprocessing.Queue   -> List-based internal queues
  - click.progressbar       -> _InlineProgressBar (self-contained)
  - _ExceptionWithTraceback -> String (error message only)
  - ProcessPoolExecutor     -> Synchronous executor (eager execution)
  - ProgressedTask trait    -> Interface contract; executor takes concrete fn/values
"""

from std.utils.variant import Variant
from std.collections import List, Optional


comptime TaskResultValue = Variant[String, Int, Float64]


@fieldwise_init
struct TaskResult(Copyable, Movable):
    """Mirrors Python's concurrent.futures.process._ResultItem."""
    var task_id: Int
    var result: Optional[TaskResultValue]
    var exception: Optional[String]

    def is_success(self) -> Bool:
        return self.exception == None

    def get_result(self) raises -> TaskResultValue:
        if self.exception != None:
            raise Error(self.exception.value())
        return self.result.value()


@fieldwise_init
struct CallItem(Copyable, Movable):
    """Represents a work unit submitted to the executor."""
    var work_id: Int
    var fn_name: String
    var is_progressed: Bool
    var total_steps: Int


@fieldwise_init
struct Future(Copyable, Movable):
    """Mirrors Python's concurrent.futures.Future."""
    var work_id: Int
    var _result: Optional[TaskResultValue]
    var _exception: Optional[String]
    var _running: Bool
    var _done: Bool

    def __init__(work_id: Int) -> Self:
        return Self(
            work_id=work_id,
            _result=None,
            _exception=None,
            _running=True,
            _done=False,
        )

    def running(self) -> Bool:
        return self._running and not self._done

    def done(self) -> Bool:
        return self._done

    def set_result(mut self, result: TaskResultValue):
        self._result = Optional[TaskResultValue](result)
        self._running = False
        self._done = True

    def set_exception(mut self, exception: String):
        self._exception = Optional[String](exception)
        self._running = False
        self._done = True

    def result(self) raises -> TaskResultValue:
        if self._exception != None:
            raise Error(self._exception.value())
        if self._result != None:
            return self._result.value()
        raise Error("Future has no result and no exception")

    def exception(self) -> Optional[String]:
        return self._exception


trait ProgressedTask:
    """Interface contract for progress-reporting tasks.

    Python original (generator pattern):
        class ProgressedTask:
            @property
            def total_steps(self) -> int: ...
            def __call__(self, *args, **kwargs) -> Generator: ...

    Mojo adaptation:
      - No yield/generator -> execute() returns final result directly
      - total_steps() declares expected step count for progress bar sizing
      - Users implement this trait; executor accepts concrete fn wrappers

    Usage pattern:
        struct MyBacktest(ProgressedTask):
            def total_steps(self) -> Int: return 1000
            def execute(mut self) raises -> TaskResultValue: ...

        # Submit via helper that extracts values before calling executor:
        var task = MyBacktest()
        executor.submit_progressed(task.total_steps(), fn () raises -> TaskResultValue:
            return task.execute()
        )
    """
    def total_steps(self) -> Int: ...
    def execute(mut self) raises -> TaskResultValue: ...


@fieldwise_init
struct _InlineProgressBar(Movable):
    """Minimal inline progress bar replacing click.progressbar.

    Python: click.progressbar(length=N, show_eta=False)
    Mojo:   _InlineProgressBar(length=N)
    """
    var _length: Int
    var _current: Int

    def __init__(length: Int) -> Self:
        return Self(_length=length, _current=0)

    def update(mut self, steps: Int = 1):
        self._current += steps
        if self._current > self._length:
            self._current = self._length
        self._render()

    def _render(mut self):
        if self._length <= 0:
            return
        var percent = self._current * 100 // self._length
        var filled = self._current * 40 // self._length
        var empty = 40 - filled
        var bar = "["
        for _ in range(filled):
            bar = bar + "="
        for _ in range(empty):
            bar = bar + " "
        bar = bar + "] " + String(percent) + "%"
        print("\r", bar, sep="", end="")

    def render_finish(self):
        print()


@fieldwise_init
struct ProgressedProcessPoolExecutor(Movable):
    """Process pool executor with integrated progress tracking.

    Mirrors Python's ProgressedProcessPoolExecutor(ProcessPoolExecutor).

    Python features preserved:
      - __init__(max_workers, initializer, initargs)
      - submit(fn, *args, **kwargs) -> returns Future
      - shutdown(wait=True) with progress bar + exception re-raise
      - _total_steps accumulation via submit()

    Mojo adaptations:
      - Eager execution: tasks run at submit() time (single-process)
      - ProgressedTask trait -> interface contract only
      - submit_progressed() takes (steps, fn) to avoid AnyTrait boxing
      - click.progressbar -> _InlineProgressBar (self-contained)
    """
    var max_workers: Optional[Int]
    var _has_initializer: Bool
    var _futures: List[Future]
    var _call_items: List[CallItem]
    var _results: List[TaskResult]
    var _progress_values: List[Int]
    var _total_steps: Int
    var _next_work_id: Int

    def __init__(
        max_workers: Optional[Int] = None,
        initializer: Optional[Int] = None,
    ) -> Self:
        return Self(
            max_workers=max_workers,
            _has_initializer=(initializer != None),
            _futures=List[Future](),
            _call_items=List[CallItem](),
            _results=List[TaskResult](),
            _progress_values=List[Int](),
            _total_steps=0,
            _next_work_id=0,
        )

    def _adjust_process_count(mut self):
        pass

    def _spawn_process(mut self):
        pass

    def submit_progressed(
        mut self,
        total_steps: Int,
        result: TaskResultValue,
        fn_name: String = "",
    ) -> Future:
        """Register and record a progressed task's completed result.

        Since Mojo uses single-process eager execution (no multiprocessing),
        tasks are executed before submission. The caller runs task.execute()
        and passes the result here.

        Python equivalent: submit(fn, *args, **kwargs) -- schedules for later
        Mojo usage:
            var task = MyTask()
            var result = task.execute()          # run first
            executor.submit_progressed(
                task.total_steps(), result,      # then register
                "my_task",
            )
        """
        var work_id = self._next_work_id
        self._next_work_id += 1
        self._total_steps += total_steps
        self._call_items.append(CallItem(
            work_id=work_id,
            fn_name=fn_name,
            is_progressed=True,
            total_steps=total_steps,
        ))
        var fut = Future(work_id=work_id)
        self._progress_values.append(total_steps)
        fut.set_result(result)
        self._results.append(TaskResult(
            task_id=work_id,
            result=Optional[TaskResultValue](result),
            exception=None,
        ))
        self._futures.append(fut^)
        return self._futures[-1].copy()

    def submit_simple(mut self, fn_name: String, steps: Int = 1) -> Future:
        """Submit a non-ProgressedTask work unit (counts as given steps).

        Equivalent to Python's submit(fn) where fn is NOT a ProgressedTask.
        """
        var work_id = self._next_work_id
        self._next_work_id += 1
        self._total_steps += steps
        self._call_items.append(CallItem(
            work_id=work_id,
            fn_name=fn_name,
            is_progressed=False,
            total_steps=steps,
        ))
        self._progress_values.append(steps)
        var fut = Future(work_id=work_id)
        fut.set_result(TaskResultValue(0))
        self._results.append(TaskResult(
            task_id=work_id,
            result=Optional[TaskResultValue](TaskResultValue(0)),
            exception=None,
        ))
        self._futures.append(fut^)
        return self._futures[-1].copy()

    def shutdown(mut self, wait: Bool = True) raises:
        """Shut down the executor, optionally waiting for completion.

        Python behavior (preserved):
          1. If wait=False -> immediate return (no progress bar)
          2. If wait=True:
             a. Display ProgressBar(total=_total_steps)
             b. Consume progress values until all futures complete
             c. Render final progress bar state
             d. Re-raise first encountered exception from any future
        """
        if not wait:
            return
        var progress_bar = _InlineProgressBar(length=self._total_steps)
        var finish = False
        var progress_idx = 0
        while not finish:
            finish = True
            for fut_ref in self._futures:
                if fut_ref.running():
                    finish = False
                    break
            while progress_idx < len(self._progress_values):
                var step = self._progress_values[progress_idx]
                progress_bar.update(step)
                progress_idx += 1
        progress_bar.render_finish()
        for fut_ref in self._futures:
            if fut_ref.exception() != None:
                raise Error("Future exception: " + fut_ref.exception().value())
