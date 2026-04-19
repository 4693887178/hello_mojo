"""
RQAlpha Mojo - Simulation Event Source (Fully Optimized)
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/simulation_event_source.py

Compilation optimizations applied:
1. Local minimal types: EventSource trait, SimEvent struct, DateTimeCopy
   - Eliminates interface.mojo (324 lines + ~20 transitive files)
   - Eliminates events.mojo ArcPointer/Variant system (294 lines)
   - Eliminates const.mojo EnumHelper reflection (669 lines)
   - Eliminates typing.mojo -> morrow chain (1347 lines)
2. String-based SimEvent avoids Variant/Dict monomorphization
3. Split events() into _events_daily/_events_minute/_events_tick
4. Cached Python module references via @staticmethod helpers
5. Removed all dead code variables
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
    var order_book_id: String


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
            try:
                var accounts = self._config.base.accounts
                _ = accounts["STOCK"]
            except:
                raise Error("Current universe is empty. Please use subscribe function before trade")
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
        var trading_minutes = Self._py_set()
        var universe = self._get_universe()
        var data_proxy = self._env.data_proxy
        for order_book_id in universe:
            var account_type = self._env.get_account_type(order_book_id)
            if account_type == "STOCK":
                continue
            var minutes = data_proxy.get_trading_minutes_for(order_book_id, trading_date)
            trading_minutes.update(minutes)
        var result = Self._py_set()
        for minute in trading_minutes:
            result.add(minute)
        return result

    def _get_trading_minutes(self, trading_date: PythonObject) raises -> PythonObject:
        var trading_minutes = Self._py_set()
        var accounts = self._config.base.accounts
        for account_type in accounts:
            if account_type == "STOCK":
                var stock_mins = self._get_stock_trading_minutes(trading_date)
                trading_minutes.update(stock_mins)
            elif account_type == "FUTURE":
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
        for _ in trading_dates:
            self._generated_events.append(SimEvent(event_type="before_trading", order_book_id=""))
            self._generated_events.append(SimEvent(event_type="open_auction", order_book_id=""))
            self._generated_events.append(SimEvent(event_type="bar", order_book_id=""))
            self._generated_events.append(SimEvent(event_type="after_trading", order_book_id=""))

    def _events_minute(mut self, start_date: DateTimeCopy, end_date: DateTimeCopy) raises:
        var data_proxy = self._env.data_proxy
        var py_dt = Self._py_datetime()
        var py_start = py_dt.datetime(start_date.year, start_date.month, start_date.day, 0, 0, 0)
        var py_end = py_dt.datetime(end_date.year, end_date.month, end_date.day, 23, 59, 59)
        var trading_dates = data_proxy.get_trading_dates(py_start, py_end)
        for day in trading_dates:
            var before_trading_flag = True
            var date = day.to_pydatetime()
            var last_dt: Optional[PythonObject] = None
            var done = False
            while True:
                if done:
                    break
                var exit_loop = True
                var trading_minutes = self._get_trading_minutes(date)
                for calendar_dt in trading_minutes:
                    if last_dt is not None:
                        if calendar_dt < last_dt.value():
                            continue
                    if before_trading_flag:
                        before_trading_flag = False
                        self._generated_events.append(SimEvent(event_type="before_trading", order_book_id=""))
                        self._generated_events.append(SimEvent(event_type="open_auction", order_book_id=""))
                    if self._universe_changed:
                        self._universe_changed = False
                        last_dt = calendar_dt
                        exit_loop = False
                        break
                    self._generated_events.append(SimEvent(event_type="bar", order_book_id=""))
                if exit_loop:
                    done = True
            self._generated_events.append(SimEvent(event_type="after_trading", order_book_id=""))

    def _events_tick(mut self, start_date: DateTimeCopy, end_date: DateTimeCopy) raises:
        var data_proxy = self._env.data_proxy
        var py_dt = Self._py_datetime()
        var py_start = py_dt.datetime(start_date.year, start_date.month, start_date.day, 0, 0, 0)
        var py_end = py_dt.datetime(end_date.year, end_date.month, end_date.day, 23, 59, 59)
        var trading_dates = data_proxy.get_trading_dates(py_start, py_end)
        for day in trading_dates:
            var date = day.to_pydatetime()
            var last_tick: Optional[PythonObject] = None
            var last_dt: Optional[PythonObject] = None
            var before_trading_generated = False
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
                    if last_tick is None:
                        last_tick = tick
                    if not before_trading_generated:
                        before_trading_generated = True
                        self._generated_events.append(SimEvent(event_type="before_trading", order_book_id=""))
                    if self._universe_changed:
                        self._universe_changed = False
                        universe_just_changed = True
                        break
                    last_dt = calendar_dt
                    var obid = String(py=tick.order_book_id)
                    self._generated_events.append(SimEvent(event_type="tick", order_book_id=obid))
                if universe_just_changed:
                    continue
                if not found_any:
                    break
            self._generated_events.append(SimEvent(event_type="after_trading", order_book_id=""))

    def get_generated_events(self) -> List[SimEvent]:
        return self._generated_events.copy()

    def get_event_count(self) -> Int:
        return len(self._generated_events)


def create_simulation_event_source(env: PythonObject) raises -> SimulationEventSource:
    return SimulationEventSource(env=env)
