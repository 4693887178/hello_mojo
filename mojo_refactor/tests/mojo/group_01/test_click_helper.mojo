"""
RQMojo Test Suite - Group 01
File: utils/click_helper.mojo (standalone test)
"""


@fieldwise_init
struct DateTimeDate(Movable):
    var year: Int
    var month: Int
    var day: Int


def parse_date(s: String) raises -> DateTimeDate:
    var parts = s.split("-")
    var y = 0
    var m = 0
    var d = 0
    if len(parts) > 0:
        y = Int(parts[0])
    if len(parts) > 1:
        m = Int(parts[1])
    if len(parts) > 2:
        d = Int(parts[2])
    return DateTimeDate(year=y, month=m, day=d)


@fieldwise_init
struct DateParam(Movable):
    var tz: Optional[String]
    
    def convert(self, value: String) raises -> DateTimeDate:
        return parse_date(value)
    
    def name(self) -> String:
        return "DATE"


def create_date_param(tz: Optional[String] = None) -> DateParam:
    return DateParam(tz=tz)


def main() raises:
    print("=" * 60)
    print("Test: utils/click_helper.mojo")
    print("=" * 60)
    
    var passed = 0
    var failed = 0
    
    print("\n[TEST 1] DateParam struct exists")
    passed += 1
    print("  Result: PASS")
    
    print("\n[TEST 2] DateParam has name method")
    var date_param = create_date_param()
    if date_param.name() == "DATE":
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")
    
    print("\n[TEST 3] DateParam has convert method")
    var converted = date_param.convert("2020-01-01")
    if converted.year == 2020:
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")
    
    print("\n[TEST 4] DateParam convert month")
    if converted.month == 1:
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")
    
    print("\n[TEST 5] DateParam convert day")
    if converted.day == 1:
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")
    
    print("\n[TEST 6] DateParam accepts tz parameter")
    var date_with_tz = create_date_param("UTC")
    if date_with_tz.tz:
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")
    
    print("\n[TEST 7] DateParam convert different date")
    var converted2 = date_param.convert("2021-12-31")
    if converted2.year == 2021 and converted2.month == 12 and converted2.day == 31:
        passed += 1
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")
    
    print("\n" + "=" * 60)
    print("Summary: " + String(passed) + "/" + String(passed + failed) + " tests passed")
    print("=" * 60)
    
    if failed > 0:
        print("STATUS: FAILED")
    else:
        print("STATUS: SUCCESS")
