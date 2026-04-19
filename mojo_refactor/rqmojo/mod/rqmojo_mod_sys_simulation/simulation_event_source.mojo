"""
RQAlpha Mojo - Simulation Event Source
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/simulation_event_source.py

Fidelity design vs Python original:
  - SimEvent carries calendar_dt, trading_dt (PythonObject), tick (Optional[PythonObject])
    to match Python Event(calendar_dt=..., trading_dt=..., tick=...) semantics
  - Universe change callback via set_universe_changed() / _on_universe_changed(mut self)
  - All datetime operations use Python datetime module (consistent with data source)
  - Generator pattern → list accumulation (_generated_events)
"""

from std.collections import List, Dict, Optional
from std.python import Python, PythonObject


@fieldwise_init
struct DateTimeCopy(Copyable, Movable):
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var minute: Int
    var second: Int


trait EventSource:
    def events(mut self, start_date: DateTimeCopy, end_date: DateTimeCopy, frequency: String) raises:
        ...


@fieldwise_init
struct SimEvent(Copyable, Movable):
    var event_type: String
    var calendar_dt: PythonObject
    var trading_dt: PythonObject
    var tick: Optional[PythonObject]

    def write_to(self, mut writer: Some[Writer]) raises:
        var cal_str: String = "None"
        var tdt_str: String = "None"
        if self.calendar_dt != Python.none():
            cal_str = String(py=self.calendar_dt)
        if self.trading_dt != Python.none():
            tdt_str = String(py=self.trading_dt)
        writer.write("SimEvent(type=", self.event_type, ", calendar=", cal_str,
                     ", trading=", tdt_str, ")")


@fieldwise_init
struct SimulationEventSource(EventSource, Movable):
    var _env: PythonObject
    var _config: PythonObject
    var _universe_changed: Bool
    var _generated_events: List[SimEvent]

    def __init__(out self, env: PythonObject) raises:
        self._env = env
        self._config = env.config
        self._universe_changed = False
        self._generated_events = List[SimEvent]()

    def _on_universe_changed(mut self, _event: PythonObject) -> None:
        self._universe_changed = True

    def set_universe_changed(mut self) -> None:
        self._universe_changed = True

    @staticmethod
    def _py_datetime() raises -> PythonObject:
        return Python.import_module("datetime")

    @staticmethod
    def _py_builtins() raises -> PythonObject:
        return Python.import_module("builtins")

    @staticmethod
    def _py_set() raises -> PythonObject:
        return Python.evaluate("set()")

    def _get_universe(self) raises -> PythonObject:
        var universe = self._env.get_universe()
        if len(universe) == 0:
            var accounts = self._config.base.accounts
            var has_stock = False
            for acct in accounts:
                var acct_name = String(py=acct)
                if acct_name == "STOCK":
                    has_stock = True
                    break
            if not has_stock:
                raise Error(
                    "Current universe is empty. Please use subscribe function before trade"
                )
        return universe

    def _get_day_bar_dt(self, date: PythonObject) raises -> PythonObject:
        return date.replace(hour=15, minute=0)

    def _get_after_trading_dt(self, date: PythonObject) raises -> PythonObject:
        return date.replace(hour=15, minute=30)

    def _get_stock_trading_minutes(self, trading_date: PythonObject) raises -> PythonObject:
        var py_dt = Self._py_datetime()
        var trading_minutes = Self._py_set()
        var t931 = py_dt.time(9, 31)
        var current_dt = trading_date.combine(t931)
        var am_end_dt = current_dt.replace(hour=11, minute=30)
        var pm_start_dt = current_dt.replace(hour=13, minute=1)
        var pm_end_dt = current_dt.replace(hour=15, minute=0)
        var delta_minute = py_dt.timedelta(minutes=1)
        while current_dt <= am_end_dt:
            trading_minutes.add(current_dt)
            current_dt += delta_minute
        current_dt = pm_start_dt
        while current_dt <= pm_end_dt:
            trading_minutes.add(current_dt)
            current_dt += delta_minute
        return trading_minutes

    def _get_future_trading_minutes(self, trading_date: PythonObject) raises -> PythonObject:
        var py_dt = Self._py_datetime()
        var trading_minutes = Self._py_set()
        var universe = self._get_universe()
        var data_proxy = self._env.data_proxy
        for order_book_id in universe:
            var account_type = String(py=self._env.get_account_type(order_book_id))
            if account_type == "STOCK":
                continue
            var minutes = data_proxy.get_trading_minutes_for(order_book_id, trading_date)
            trading_minutes.update(minutes)
        var result = Self._py_set()
        for minute in trading_minutes:
            var minute_int = Int(py=minute)
            var year = minute_int // 10000000000
            var r1 = minute_int % 10000000000
            var month = r1 // 100000000
            var r2 = r1 % 100000000
            var day = r2 // 1000000
            var r3 = r2 % 1000000
            var hour = r3 // 10000
            var r4 = r3 % 10000
            var minute_val = r4 // 100
            var second = r4 % 100
            var dt = py_dt.datetime(year, month, day, hour, minute_val, second)
            result.add(dt)
        return result

    def _get_trading_minutes(self, trading_date: PythonObject) raises -> PythonObject:
        var trading_minutes = Self._py_set()
        var accounts = self._config.base.accounts
        for account_type in accounts:
            var acct_name = String(py=account_type)
            if acct_name == "STOCK":
                var stock_mins = self._get_stock_trading_minutes(trading_date)
                trading_minutes.update(stock_mins)
            elif acct_name == "FUTURE":
                var future_mins = self._get_future_trading_minutes(trading_date)
                trading_minutes.update(future_mins)
        var py_builtins = Self._py_builtins()
        return py_builtins.sorted(trading_minutes)

    def events(mut self, start_date: DateTimeCopy, end_date: DateTimeCopy, frequency: String) raises:
        self._generated_events.clear()
        if frequency == "1d":
            self._events_daily(start_date, end_date)
        elif frequency == "1m":
            self._events_minute(start_date, end_date)
        elif frequency == "tick":
            self._events_tick(start_date, end_date)
        else:
            raise Error("Frequency " + frequency + " is not supported.")

    def _events_daily(mut self, start_date: DateTimeCopy, end_date: DateTimeCopy) raises:
        var data_proxy = self._env.data_proxy
        var py_dt = Self._py_datetime()
        var py_start = py_dt.datetime(start_date.year, start_date.month, start_date.day, 0, 0, 0)
        var py_end = py_dt.datetime(end_date.year, end_date.month, end_date.day, 23, 59, 59)
        var trading_dates = data_proxy.get_trading_dates(py_start, py_end)
        for day in trading_dates:
            var date = day.to_pydatetime()
            var dt_before_trading = date.replace(hour=0, minute=0)
            var dt_bar = self._get_day_bar_dt(date)
            var dt_after_trading = self._get_after_trading_dt(date)

            self._generated_events.append(SimEvent(
                event_type="before_trading",
                calendar_dt=dt_before_trading,
                trading_dt=dt_before_trading,
                tick=None,
            ))
            self._generated_events.append(SimEvent(
                event_type="open_auction",
                calendar_dt=dt_before_trading,
                trading_dt=dt_before_trading,
                tick=None,
            ))
            self._generated_events.append(SimEvent(
                event_type="bar",
                calendar_dt=dt_bar,
                trading_dt=dt_bar,
                tick=None,
            ))
            self._generated_events.append(SimEvent(
                event_type="after_trading",
                calendar_dt=dt_after_trading,
                trading_dt=dt_after_trading,
                tick=None,
            ))

    def _events_minute(mut self, start_date: DateTimeCopy, end_date: DateTimeCopy) raises:
        var data_proxy = self._env.data_proxy
        var py_dt = Self._py_datetime()
        var py_start = py_dt.datetime(start_date.year, start_date.month, start_date.day, 0, 0, 0)
        var py_end = py_dt.datetime(end_date.year, end_date.month, end_date.day, 23, 59, 59)
        var trading_dates = data_proxy.get_trading_dates(py_start, py_end)
        var timedelta_3min = py_dt.timedelta(minutes=3)
        var timedelta_30min = py_dt.timedelta(minutes=30)
        for day in trading_dates:
            var before_trading_flag = True
            var date = day.to_pydatetime()
            var last_dt: Optional[PythonObject] = None
            var done = False
            var dt_before_day_trading = date.replace(hour=8, minute=30)
            while True:
                if done:
                    break
                var exit_loop = True
                var trading_minutes = self._get_trading_minutes(date)
                for calendar_dt in trading_minutes:
                    var trading_dt: PythonObject
                    if last_dt is not None:
                        if calendar_dt < last_dt.value():
                            continue
                    if calendar_dt < dt_before_day_trading:
                        trading_dt = calendar_dt.replace(
                            year=Int(py=date.year),
                            month=Int(py=date.month),
                            day=Int(py=date.day),
                        )
                    else:
                        trading_dt = calendar_dt
                    if before_trading_flag:
                        before_trading_flag = False
                        self._generated_events.append(SimEvent(
                            event_type="before_trading",
                            calendar_dt=calendar_dt - timedelta_30min,
                            trading_dt=trading_dt - timedelta_30min,
                            tick=None,
                        ))
                        self._generated_events.append(SimEvent(
                            event_type="open_auction",
                            calendar_dt=calendar_dt - timedelta_3min,
                            trading_dt=trading_dt - timedelta_3min,
                            tick=None,
                        ))
                    if self._universe_changed:
                        self._universe_changed = False
                        last_dt = calendar_dt
                        exit_loop = False
                        break
                    self._generated_events.append(SimEvent(
                        event_type="bar",
                        calendar_dt=calendar_dt,
                        trading_dt=trading_dt,
                        tick=None,
                    ))
                if exit_loop:
                    done = True
            var dt_after = self._get_after_trading_dt(date)
            self._generated_events.append(SimEvent(
                event_type="after_trading",
                calendar_dt=dt_after,
                trading_dt=dt_after,
                tick=None,
            ))

    def _events_tick(mut self, start_date: DateTimeCopy, end_date: DateTimeCopy) raises:
        var data_proxy = self._env.data_proxy
        var py_dt = Self._py_datetime()
        var py_start = py_dt.datetime(start_date.year, start_date.month, start_date.day, 0, 0, 0)
        var py_end = py_dt.datetime(end_date.year, end_date.month, end_date.day, 23, 59, 59)
        var trading_dates = data_proxy.get_trading_dates(py_start, py_end)
        var timedelta_15min = py_dt.timedelta(minutes=15)
        var timedelta_30min = py_dt.timedelta(minutes=30)
        for day in trading_dates:
            var date = day.to_pydatetime()
            var last_tick: Optional[PythonObject] = None
            var last_dt: Optional[PythonObject] = None
            var dt_before_day_trading = date.replace(hour=8, minute=30)
            while True:
                var last_dt_arg: PythonObject
                if last_dt is not None:
                    last_dt_arg = last_dt.value()
                else:
                    last_dt_arg = Python.none()
                var ticks = data_proxy.get_merge_ticks(self._get_universe(), date, last_dt_arg)
                var found_any = False
                var universe_just_changed = False
                for tick in ticks:
                    found_any = True
                    var calendar_dt = tick.datetime
                    var trading_dt: PythonObject
                    if calendar_dt < dt_before_day_trading:
                        trading_dt = calendar_dt.replace(
                            year=Int(py=date.year),
                            month=Int(py=date.month),
                            day=Int(py=date.day),
                        )
                    else:
                        trading_dt = calendar_dt
                    if last_tick is None:
                        last_tick = tick
                        var instrument = self._env.get_instrument(tick.order_book_id)
                        var inst_type = String(py=instrument.type)
                        if inst_type == "Future":
                            self._generated_events.append(SimEvent(
                                event_type="before_trading",
                                calendar_dt=calendar_dt - timedelta_30min,
                                trading_dt=trading_dt - timedelta_30min,
                                tick=None,
                            ))
                        else:
                            self._generated_events.append(SimEvent(
                                event_type="before_trading",
                                calendar_dt=calendar_dt - timedelta_15min,
                                trading_dt=trading_dt - timedelta_15min,
                                tick=None,
                            ))
                    if self._universe_changed:
                        self._universe_changed = False
                        universe_just_changed = True
                        break
                    last_dt = calendar_dt
                    self._generated_events.append(SimEvent(
                        event_type="tick",
                        calendar_dt=calendar_dt,
                        trading_dt=trading_dt,
                        tick=tick,
                    ))
                if universe_just_changed:
                    continue
                if not found_any:
                    break
            var dt_after = self._get_after_trading_dt(date)
            self._generated_events.append(SimEvent(
                event_type="after_trading",
                calendar_dt=dt_after,
                trading_dt=dt_after,
                tick=None,
            ))

    def get_generated_events(self) -> List[SimEvent]:
        return self._generated_events.copy()

    def get_event_count(self) -> Int:
        return len(self._generated_events)


def create_simulation_event_source(env: PythonObject) raises -> SimulationEventSource:
    return SimulationEventSource(env=env)
