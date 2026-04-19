"""
RQAlpha Mojo - Scheduler Mod
Ported from rqalpha/mod/rqalpha_mod_sys_scheduler/mod.py

Key differences from Python version:
  - Python uses AbstractMod base class; Mojo implements Mod trait
  - Python uses export_as_api to expose scheduler/market_open/close/physical_time
  - Mojo stores scheduler as Optional[Scheduler] with direct method access
  - Python checks env.config.base.accounts for STOCK/FUTURE; Mojo accepts account_types list
  - Python reads frequency from env.config.base.frequency; Mojo accepts frequency parameter
"""

from rqmojo.const import DEFAULT_ACCOUNT_TYPE, EXIT_CODE
from rqmojo.interface import ModInterface
from rqmojo.mod.rqmojo_mod_sys_scheduler.scheduler import (
    Scheduler, TimeRule, create_scheduler,
    market_open_minutes, market_close_minutes, physical_time_minutes
)
from std.io import Writer


struct SchedulerMod(ModInterface, Writable, Movable):
    var name: String
    var _scheduler: Optional[Scheduler]
    var _enabled: Bool
    var _frequency: String
    var _account_types: List[DEFAULT_ACCOUNT_TYPE]

    def __init__(out self):
        self.name = "scheduler"
        self._scheduler = Optional[Scheduler](None)
        self._enabled = False
        self._frequency = "1d"
        self._account_types = List[DEFAULT_ACCOUNT_TYPE]()

    def write_to(self, mut writer: Some[Writer]):
        writer.write("SchedulerMod(", self.name, ")")

    def start_up(mut self, env_name: String, mod_config_name: String):
        if not self._should_enable():
            return

        self._enabled = True
        var scheduler = create_scheduler(self._frequency)
        self._scheduler = Optional[Scheduler](scheduler^)

    def tear_down(mut self, code: EXIT_CODE, exception_msg: Optional[String]):
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

    def _should_enable(ref self) -> Bool:
        if len(self._account_types) == 0:
            return True
        for at in self._account_types:
            if at == DEFAULT_ACCOUNT_TYPE.STOCK or at == DEFAULT_ACCOUNT_TYPE.FUTURE:
                return True
        return False

    def set_frequency(mut self, frequency: String) -> None:
        self._frequency = frequency

    def set_account_types(mut self, account_types: List[DEFAULT_ACCOUNT_TYPE]) -> None:
        self._account_types = account_types.copy()

    def get_scheduler(ref self) -> Optional[Scheduler]:
        if self._scheduler:
            var s = Scheduler(self._scheduler.value()._frequency)
            return Optional[Scheduler](s^)
        return Optional[Scheduler](None)


def create_scheduler_mod() -> SchedulerMod:
    return SchedulerMod()
