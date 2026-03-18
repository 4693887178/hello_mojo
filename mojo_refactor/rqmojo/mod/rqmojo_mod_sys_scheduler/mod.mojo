"""
RQAlpha Mojo - Scheduler Mod
Ported from rqalpha/mod/rqalpha_mod_sys_scheduler/mod.py
"""

from rqmojo.const import DEFAULT_ACCOUNT_TYPE, EXIT_CODE
from rqmojo.interface import Mod
from rqmojo.core.events import EVENT
from rqmojo.environment import Environment
from rqmojo.mod.rqmojo_mod_sys_scheduler.scheduler import (
    Scheduler, TimeRule, create_scheduler,
    market_open_minutes, market_close_minutes, physical_time_minutes
)


@fieldwise_init
struct SchedulerMod(Mod, Stringable, Movable):
    var name: String
    var _scheduler: Optional[Scheduler]
    var _enabled: Bool

    fn __str__(self) -> String:
        return "SchedulerMod(" + self.name + ")"

    fn __init__(ref self) -> Self:
        return Self(
            name="scheduler",
            _scheduler=Optional[Scheduler](None),
            _enabled=False
        )

    fn start_up(mut self, env: object, mod_config: object) -> None:
        self._enabled = True
        var scheduler = create_scheduler("1d")
        self._scheduler = Optional[Scheduler](scheduler)

    fn tear_down(self, code: EXIT_CODE, exception: Optional[object]) -> None:
        pass

    fn get_scheduler(self) -> Optional[Scheduler]:
        return self._scheduler

    fn get_state(self) -> String:
        if var scheduler = self._scheduler.value():
            return scheduler.get_state()
        return ""

    fn set_state(mut self, state: String) -> None:
        if var scheduler = self._scheduler.value():
            scheduler.set_state(state)


fn create_scheduler_mod() -> SchedulerMod:
    return SchedulerMod(
        name="scheduler",
        _scheduler=Optional[Scheduler](None),
        _enabled=False
    )
