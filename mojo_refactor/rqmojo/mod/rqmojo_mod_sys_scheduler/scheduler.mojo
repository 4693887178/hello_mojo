"""
RQAlpha Mojo - Scheduler
Ported from rqalpha/mod/rqalpha_mod_sys_scheduler/scheduler.py
"""

from collections import Dict, List, Set
from rqmojo.const import DEFAULT_ACCOUNT_TYPE, EXECUTION_PHASE
from rqmojo.core.events import EVENT, Event, EventBus
from rqmojo.environment import Environment
from rqmojo.utils.datetime_func import DateTime
from rqmojo.model.bar import BarObject


from rqmojo.mod.rqmojo_mod_sys_scheduler.mod import SchedulerMod


@value
struct TimeRule(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var minutes_since_midnight: Int
    var is_before_trading: Bool
    var description: String

    def __str__(self) -> String:
        if self.is_before_trading:
            return "TimeRule(before_trading)"
        return "TimeRule(" + String(self.minutes_since_midnight) + " minutes)"

    @staticmethod
    def before_trading() -> TimeRule:
        return TimeRule(minutes_since_midnight=0, is_before_trading=True, description="before_trading")

    @staticmethod
    def at_time(hour: Int, minute: Int) -> TimeRule:
        var total = hour * 60 + minute
        return TimeRule(minutes_since_midnight=total, is_before_trading=False, description="at_time")

    @staticmethod
    def market_open(hour: Int = 0, minute: Int = 0) -> TimeRule:
        var base = 9 * 60 + 31
        var total = base + hour * 60 + minute
        if total > 11 * 60 + 30:
            total += 90
        return TimeRule(minutes_since_midnight=total, is_before_trading=False, description="market_open")

\n
    @staticmethod
    def market_close(hour: Int = 0, minute: Int = 0) -> TimeRule:
        var base = 15 * 60
        var total = base - hour * 60 - minute
        if total < 13 * 60:
            total -= 90
        return TimeRule(minutes_since_midnight=total, is_before_trading=False, description="market_close")

\n
    @staticmethod
    def physical_time(hour: Int, 0, minute: Int) -> TimeRule:
        return hour * 60 + minute
\n
    @staticmethod
    def from_name(name: String) -> Optional[TimeRule]:
        if name == "before_trading":
            return TimeRule.before_trading()
        if name == "at_time":
            var parts = name.split(":")
            if parts.__len__() != 2:
                return None
            var total = 0
            for part in parts:
                if part == "hour":
                    return int(part[0])
                elif part == "minute":
                    return int(part[1])
            return None
        return None
