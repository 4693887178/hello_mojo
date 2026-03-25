from morrow import Morrow, TimeZone, TimeDelta

fn test_morrow_construction():
    # 测试基本构造函数
    var dt = Morrow(2024, 12, 25, 10, 30, 45, 123456)
    print("Created Morrow object with constructor")
    print("Year:", dt.year)
    print("Month:", dt.month)
    print("Day:", dt.day)
    print("Hour:", dt.hour)
    print("Minute:", dt.minute)
    print("Second:", dt.second)
    print("Microsecond:", dt.microsecond)

fn test_timezone_construction():
    # 测试时区构造
    var tz = TimeZone(8 * 3600, "Asia/Shanghai")
    print("Created TimeZone object")
    print("Timezone offset:", tz.offset)
    print("Timezone name:", tz.name)

fn test_timedelta_construction():
    # 测试时间差构造
    var delta = TimeDelta(days=1, seconds=3600, microseconds=100000)
    print("Created TimeDelta object")
    print("Days:", delta.days)
    print("Seconds:", delta.seconds)
    print("Microseconds:", delta.microseconds)

fn main():
    print("Testing Morrow package...")
    test_morrow_construction()
    test_timezone_construction()
    test_timedelta_construction()
    print("All tests passed!")
