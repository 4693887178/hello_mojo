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
struct SchedulerMod(Mod, Writable, Movable):
    var name: String
    var _scheduler: Optional[Scheduler]
    var _enabled: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("SchedulerMod(", self.name, ")")

    def __init__(out self):
        self.name = "scheduler"
        self._scheduler = Optional[Scheduler](None)
        self._enabled = False

    def start_up(mut self, env: object, mod_config: object):
        self._enabled = True
        var scheduler = create_scheduler("1d")
        self._scheduler = Optional[Scheduler](scheduler)

    def tear_down(self, code: EXIT_CODE, exception: Optional[object]):
        pass

    def get_scheduler(self) -> Optional[Scheduler]:
        return self._scheduler

    def get_state(self) -> String:
        if var scheduler = self._scheduler.value():
            return scheduler.get_state()
        return ""

    def set_state(mut self, state: String):
        if var scheduler = self._scheduler.value():
            scheduler.set_state(state)


def create_scheduler_mod() -> SchedulerMod:
    return SchedulerMod(
        name="scheduler",
        _scheduler=Optional[Scheduler](None),
        _enabled=False
    )
