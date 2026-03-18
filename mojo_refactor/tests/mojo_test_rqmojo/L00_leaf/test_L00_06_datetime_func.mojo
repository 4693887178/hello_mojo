# test_L00_06_datetime_func.mojo
# Module: rqmojo.utils.datetime_func
# Python: rqalpha.utils.datetime_func
# Level: L00 - Leaf module
# Dependencies: functools, exception

from rqmojo.utils.datetime_func import (
    TimeRange, Date, DateTime, convert_date_to_date_int,
    convert_date_to_int, convert_dt_to_int, convert_int_to_date,
    convert_int_to_datetime, convert_ms_int_to_datetime,
    convert_date_time_ms_int_to_datetime
)


@fieldwise_init
struct TestRunner:
    var test_count: Int
    var pass_count: Int
    
    fn check(mut self, condition: Bool, test_name: String):
        self.test_count += 1
        if condition:
            self.pass_count += 1
            print("PASS: " + test_name)
        else:
            print("FAIL: " + test_name)

    fn test_time_range(mut self):
        var tr = TimeRange(9, 30, 15, 0)
        self.check(tr.start_hour == 9, "TimeRange start_hour")
        self.check(tr.start_minute == 30, "TimeRange start_minute")
        self.check(tr.end_hour == 15, "TimeRange end_hour")
        self.check(tr.end_minute == 0, "TimeRange end_minute")

    fn test_date(mut self):
        var d = Date(2023, 1, 15)
        self.check(d.year == 2023, "Date year")
        self.check(d.month == 1, "Date month")
        self.check(d.day == 15, "Date day")

    fn test_date_str(mut self):
        var d = Date(2023, 1, 15)
        var result = d.__str__()
        self.check(len(result) > 0, "Date __str__ returns non-empty")

    fn test_datetime(mut self):
        var dt = DateTime(2023, 1, 15, 14, 30, 45, 0)
        self.check(dt.year == 2023, "DateTime year")
        self.check(dt.month == 1, "DateTime month")
        self.check(dt.day == 15, "DateTime day")
        self.check(dt.hour == 14, "DateTime hour")
        self.check(dt.minute == 30, "DateTime minute")
        self.check(dt.second == 45, "DateTime second")

    fn test_datetime_date(mut self):
        var dt = DateTime(2023, 1, 15, 14, 30, 45, 0)
        var d = dt.date()
        self.check(d.year == 2023, "DateTime.date() year")
        self.check(d.month == 1, "DateTime.date() month")
        self.check(d.day == 15, "DateTime.date() day")

    fn test_datetime_replace(mut self):
        var dt = DateTime(2023, 1, 15, 14, 30, 45, 0)
        var new_dt = dt.replace(hour=16, minute=0)
        self.check(new_dt.hour == 16, "DateTime.replace hour")
        self.check(new_dt.minute == 0, "DateTime.replace minute")

    fn test_convert_date_to_date_int(mut self):
        var d = Date(2023, 1, 15)
        var result = convert_date_to_date_int(d)
        self.check(result == 20230115, "convert_date_to_date_int")

    fn test_convert_date_to_int(mut self):
        var d = Date(2023, 1, 15)
        var result = convert_date_to_int(d)
        self.check(result == 20230115000000000, "convert_date_to_int")

    fn test_convert_dt_to_int(mut self):
        var dt = DateTime(2023, 1, 15, 14, 30, 45, 0)
        var result = convert_dt_to_int(dt)
        self.check(result == 20230115143045000, "convert_dt_to_int")

    fn test_convert_int_to_date(mut self):
        var result = convert_int_to_date(20230115)
        self.check(result.year == 2023, "convert_int_to_date year")
        self.check(result.month == 1, "convert_int_to_date month")
        self.check(result.day == 15, "convert_int_to_date day")

    fn test_convert_int_to_datetime(mut self):
        var result = convert_int_to_datetime(20230115143045000)
        self.check(result.year == 2023, "convert_int_to_datetime year")
        self.check(result.month == 1, "convert_int_to_datetime month")
        self.check(result.day == 15, "convert_int_to_datetime day")
        self.check(result.hour == 14, "convert_int_to_datetime hour")
        self.check(result.minute == 30, "convert_int_to_datetime minute")
        self.check(result.second == 45, "convert_int_to_datetime second")

    fn test_convert_ms_int_to_datetime(mut self):
        var result = convert_ms_int_to_datetime(20230115143045123)
        self.check(result.year == 2023, "convert_ms_int_to_datetime year")
        self.check(result.microsecond == 123000, "convert_ms_int_to_datetime microsecond")

    fn test_convert_date_time_ms_int_to_datetime(mut self):
        var result = convert_date_time_ms_int_to_datetime(20230115, 143045123)
        self.check(result.year == 2023, "convert_date_time_ms_int_to_datetime year")
        self.check(result.hour == 14, "convert_date_time_ms_int_to_datetime hour")

    fn run_all(mut self):
        print("=" * 60)
        print("L00_06_datetime_func Module Tests")
        print("=" * 60)
        
        self.test_time_range()
        self.test_date()
        self.test_date_str()
        self.test_datetime()
        self.test_datetime_date()
        self.test_datetime_replace()
        self.test_convert_date_to_date_int()
        self.test_convert_date_to_int()
        self.test_convert_dt_to_int()
        self.test_convert_int_to_date()
        self.test_convert_int_to_datetime()
        self.test_convert_ms_int_to_datetime()
        self.test_convert_date_time_ms_int_to_datetime()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main() raises:
    var runner = TestRunner(0, 0)
    runner.run_all()
