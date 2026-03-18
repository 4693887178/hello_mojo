# test_L00_05_rq_json.mojo
# Module: rqmojo.utils.rq_json
# Python: rqalpha.utils.rq_json
# Level: L00 - Leaf module
# Dependencies: simplejson, datetime, rqalpha.const

from python import Python, PythonObject
from rqmojo.utils.rq_json import convert_dict_to_json, convert_json_to_dict


fn py_bool_to_bool(obj: PythonObject) raises -> Bool:
    var _ = Python()
    var s = Python().import_module("builtins").str(obj)
    return String(s) == "True"


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

    fn test_simple_dict_to_json(mut self) raises:
        var _ = Python()
        var test_dict = Python().dict()
        test_dict["name"] = "test"
        test_dict["value"] = 123
        
        var json_str = convert_dict_to_json(test_dict)
        self.check(json_str.__len__() > 0, "Simple dict to JSON conversion")

    fn test_simple_json_to_dict(mut self) raises:
        var json_str = "{\"name\": \"test\", \"value\": 123}"
        var result = convert_json_to_dict(json_str)
        var name = result["name"]
        self.check(String(name) == "test", "Simple JSON to dict conversion")

    fn test_datetime_to_json(mut self) raises:
        var _ = Python()
        var datetime_module = Python().import_module("datetime")
        
        var test_dict = Python().dict()
        test_dict["dt"] = datetime_module.datetime(2024, 1, 15, 14, 30, 45, 123456)
        
        var json_str = convert_dict_to_json(test_dict)
        self.check(json_str.__contains__("__datetime__"), "Datetime to JSON conversion")

    fn test_date_to_json(mut self) raises:
        var _ = Python()
        var datetime_module = Python().import_module("datetime")
        
        var test_dict = Python().dict()
        test_dict["date"] = datetime_module.date(2024, 1, 15)
        
        var json_str = convert_dict_to_json(test_dict)
        self.check(json_str.__contains__("__date__"), "Date to JSON conversion")

    fn test_json_to_datetime(mut self) raises:
        var json_str = "{\"dt\": {\"__datetime__\": true, \"as_str\": \"20240115T14:30:45.123456\"}}"
        var result = convert_json_to_dict(json_str)
        var dt = result["dt"]
        var _ = Python()
        var builtins = Python().import_module("builtins")
        self.check(py_bool_to_bool(builtins.hasattr(dt, "year")), "JSON to datetime conversion")

    fn test_json_to_date(mut self) raises:
        var json_str = "{\"date\": {\"__date__\": true, \"as_str\": \"20240115\"}}"
        var result = convert_json_to_dict(json_str)
        var date = result["date"]
        var _ = Python()
        var builtins = Python().import_module("builtins")
        self.check(py_bool_to_bool(builtins.hasattr(date, "year")), "JSON to date conversion")

    fn test_nested_dict_to_json(mut self) raises:
        var _ = Python()
        var inner_dict = Python().dict()
        inner_dict["inner_key"] = "inner_value"
        
        var test_dict = Python().dict()
        test_dict["outer"] = inner_dict
        
        var json_str = convert_dict_to_json(test_dict)
        self.check(json_str.__len__() > 0, "Nested dict to JSON conversion")

    fn test_roundtrip_simple(mut self) raises:
        var _ = Python()
        var test_dict = Python().dict()
        test_dict["name"] = "test"
        test_dict["value"] = 123
        
        var json_str = convert_dict_to_json(test_dict)
        var result = convert_json_to_dict(json_str)
        var name = result["name"]
        self.check(String(name) == "test", "Roundtrip simple dict")

    fn test_roundtrip_datetime(mut self) raises:
        var _ = Python()
        var datetime_module = Python().import_module("datetime")
        
        var test_dict = Python().dict()
        test_dict["dt"] = datetime_module.datetime(2024, 1, 15, 14, 30, 45, 123456)
        
        var json_str = convert_dict_to_json(test_dict)
        var result = convert_json_to_dict(json_str)
        var dt = result["dt"]
        var builtins = Python().import_module("builtins")
        self.check(py_bool_to_bool(builtins.hasattr(dt, "year")), "Roundtrip datetime")

    fn test_roundtrip_date(mut self) raises:
        var _ = Python()
        var datetime_module = Python().import_module("datetime")
        
        var test_dict = Python().dict()
        test_dict["date"] = datetime_module.date(2024, 1, 15)
        
        var json_str = convert_dict_to_json(test_dict)
        var result = convert_json_to_dict(json_str)
        var date = result["date"]
        var builtins = Python().import_module("builtins")
        self.check(py_bool_to_bool(builtins.hasattr(date, "year")), "Roundtrip date")

    fn test_multiple_fields(mut self) raises:
        var _ = Python()
        var datetime_module = Python().import_module("datetime")
        
        var test_dict = Python().dict()
        test_dict["name"] = "multi_test"
        test_dict["dt"] = datetime_module.datetime(2024, 1, 15, 14, 30, 45, 123456)
        test_dict["date"] = datetime_module.date(2024, 1, 15)
        test_dict["count"] = 42
        
        var json_str = convert_dict_to_json(test_dict)
        var result = convert_json_to_dict(json_str)
        var name = result["name"]
        self.check(String(name) == "multi_test", "Multiple fields roundtrip")

    fn run_all(mut self) raises:
        print("=" * 60)
        print("L00_05_rq_json Module Tests")
        print("=" * 60)
        
        self.test_simple_dict_to_json()
        self.test_simple_json_to_dict()
        self.test_datetime_to_json()
        self.test_date_to_json()
        self.test_json_to_datetime()
        self.test_json_to_date()
        self.test_nested_dict_to_json()
        self.test_roundtrip_simple()
        self.test_roundtrip_datetime()
        self.test_roundtrip_date()
        self.test_multiple_fields()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main() raises:
    var runner = TestRunner(0, 0)
    runner.run_all()
