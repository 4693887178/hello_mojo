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
from std.python import PythonObject
from std.io import Writer


struct SchedulerMod(Mod, Writable, Movable):
    var name: String
    var _scheduler: Optional[Scheduler]
    var _enabled: Bool

    def __init__(out self):
        self.name = "scheduler"
        self._scheduler = Optional[Scheduler](None)
        self._enabled = False

    def write_to(self, mut writer: Some[Writer]):
        writer.write("SchedulerMod(", self.name, ")")

    def start_up(mut self, env_name: String, mod_config_name: String):
        self._enabled = True
        var scheduler = create_scheduler("1d")
        self._scheduler = Optional[Scheduler](scheduler^)

    def tear_down(self, code: EXIT_CODE, exception_msg: Optional[String]):
        pass

    def get_state(ref self) -> String:
        if self._scheduler:
            return self._scheduler.value().get_state()
        return ""

    def set_state(mut self, state: String) raises:
        if self._scheduler:
            self._scheduler.value().set_state(state)

    def has_scheduler(ref self) -> Bool:
        return self._scheduler != None

    def is_enabled(ref self) -> Bool:
        return self._enabled


def create_scheduler_mod() -> SchedulerMod:
    return SchedulerMod()
