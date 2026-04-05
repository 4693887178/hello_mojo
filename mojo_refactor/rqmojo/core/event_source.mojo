"""
RQAlpha Mojo - EventSource Implementation
Ported from rqalpha/core/event_source.py
"""

from std.collections import Dict, List, Optional, Iterator
from rqmojo.interface import EventSource
from rqmojo.core.events import Event, EVENT
from rqmojo.utils.typing import DateTime


@fieldwise_init
struct SimulationEventSource(EventSource, Movable, Writable):
    var _start_date: DateTime
    var _end_date: DateTime
    var _frequency: String
    var _current_datetime: DateTime
    var _is_running: Bool
    var _events: List[Event]
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("SimulationEventSource(frequency=", self._frequency, ")")
    
    def events(mut self) -> Iterator[Event]:
        """生成事件"""
        var current = self._start_date
        while current.year < self._end_date.year or \
              (current.year == self._end_date.year and current.month < self._end_date.month) or \
              (current.year == self._end_date.year and current.month == self._end_date.month and current.day <= self._end_date.day):
            
            # 生成交易日开始事件
            var pre_before_trading_evt = EVENT.PRE_BEFORE_TRADING()
            yield Event(pre_before_trading_evt.value)
            
            var before_trading_evt = EVENT.BEFORE_TRADING()
            yield Event(before_trading_evt.value)
            
            # 生成BAR事件
            var bar_evt = EVENT.BAR()
            yield Event(bar_evt.value)
            
            # 生成交易日结束事件
            var after_trading_evt = EVENT.AFTER_TRADING()
            yield Event(after_trading_evt.value)
            
            var post_settlement_evt = EVENT.POST_SETTLEMENT()
            yield Event(post_settlement_evt.value)
            
            # 推进到下一天
            current = DateTime(current.year, current.month, current.day + 1, 0, 0, 0, 0)
    
    def start(mut self):
        """开始事件源"""
        self._is_running = True
        self._current_datetime = self._start_date
    
    def stop(mut self):
        """停止事件源"""
        self._is_running = False
    
    def is_running(self) -> Bool:
        """检查事件源是否运行中"""
        return self._is_running
    
    def current_datetime(self) -> DateTime:
        """获取当前时间"""
        return self._current_datetime
    
    def set_current_datetime(mut self, dt: DateTime):
        """设置当前时间"""
        self._current_datetime = dt


def create_simulation_event_source(start_date: DateTime, end_date: DateTime, frequency: String = "1d") -> SimulationEventSource:
    """创建模拟事件源实例"""
    return SimulationEventSource(
        _start_date=start_date,
        _end_date=end_date,
        _frequency=frequency,
        _current_datetime=start_date,
        _is_running=False,
        _events=List[Event]()
    )


def create_event_source(start_date: DateTime, end_date: DateTime, frequency: String = "1d") -> SimulationEventSource:
    """创建事件源实例"""
    return create_simulation_event_source(start_date, end_date, frequency)
