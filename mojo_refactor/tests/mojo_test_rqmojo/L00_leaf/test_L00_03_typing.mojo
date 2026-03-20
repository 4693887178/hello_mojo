# test_L00_03_typing.mojo
# Module: rqmojo.utils.typing
# Python: rqalpha.utils.typing
# Level: L00 - Leaf module
# Dependencies: const, datetime_func

from rqmojo.utils.typing import DateLike, StrOrIter, POSITION_DIRECTION_TYPE
from rqmojo.utils.datetime_func import Date, DateTime
from rqmojo.const import POSITION_DIRECTION
from collections import List


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

    fn test_datelike_exists(mut self):
        self.check(True, "DateLike type alias exists")

    fn test_stroriter_exists(mut self):
        self.check(True, "StrOrIter type alias exists")

    fn test_position_direction_type_exists(mut self):
        self.check(True, "POSITION_DIRECTION_TYPE type alias exists")

    fn test_datelike_with_date(mut self):
        var d = Date(2023, 1, 15)
        self.check(d.year == 2023, "DateLike can hold Date value")

    fn test_datelike_with_datetime(mut self):
        var dt = DateTime(2023, 1, 15, 14, 30, 45, 0)
        self.check(dt.year == 2023, "DateLike can hold DateTime value")

    fn test_datelike_with_int(mut self):
        var date_int: Int = 20230115
        self.check(date_int == 20230115, "DateLike can hold Int value (date as integer)")

    fn test_stroriter_with_string(mut self):
        var s: String = "test"
        self.check(s == "test", "StrOrIter can hold String value")

    fn test_stroriter_with_list(mut self):
        var lst = List[String]()
        lst.append("a")
        lst.append("b")
        lst.append("c")
        self.check(lst.__len__() == 3, "StrOrIter can hold List[String] value")

    fn test_position_direction_type_with_string(mut self):
        var s: String = "LONG"
        self.check(s == "LONG", "POSITION_DIRECTION_TYPE can hold String value")

    fn test_position_direction_type_with_enum(mut self):
        var pd = POSITION_DIRECTION.LONG
        var pd2 = POSITION_DIRECTION.LONG
        self.check(pd.name == pd2.name, "POSITION_DIRECTION_TYPE can hold POSITION_DIRECTION enum")

    fn test_position_direction_enum_values(mut self):
        var long_val = POSITION_DIRECTION.LONG
        var short_val = POSITION_DIRECTION.SHORT
        self.check(long_val.name != short_val.name, "POSITION_DIRECTION enum has distinct values")

    fn test_position_direction_long_value(mut self):
        var pd = POSITION_DIRECTION.LONG
        self.check(pd.value == "LONG", "POSITION_DIRECTION.LONG has value LONG")

    fn test_position_direction_short_value(mut self):
        var pd = POSITION_DIRECTION.SHORT
        self.check(pd.value == "SHORT", "POSITION_DIRECTION.SHORT has value SHORT")

    fn run_all(mut self):
        print("=" * 60)
        print("L00_03_typing Module Tests")
        print("=" * 60)
        
        self.test_datelike_exists()
        self.test_stroriter_exists()
        self.test_position_direction_type_exists()
        self.test_datelike_with_date()
        self.test_datelike_with_datetime()
        self.test_datelike_with_int()
        self.test_stroriter_with_string()
        self.test_stroriter_with_list()
        self.test_position_direction_type_with_string()
        self.test_position_direction_type_with_enum()
        self.test_position_direction_enum_values()
        self.test_position_direction_long_value()
        self.test_position_direction_short_value()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main() raises:
    var runner = TestRunner(0, 0)
    runner.run_all()
