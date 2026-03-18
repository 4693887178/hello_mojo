# test_L00_09_repr.mojo
# Module: rqmojo.utils.repr
# Python: rqalpha.utils.repr
# Level: L00 - Leaf module
# Dependencies: class_helper

from rqmojo.utils.repr import (
    ReprPropertyItem,
    ReprBuilder,
    _repr,
    property_repr,
    dict_repr,
    dict_repr_from_dict,
    properties,
    iter_properties_of_class,
    truncate_string,
    format_float,
    make_repr_builder,
    Reprable,
)
from rqmojo.utils.class_helper import cached_property
from collections import Dict, List


@fieldwise_init
struct TestClass(Reprable):
    var name: String
    var value: Int
    var _private: String
    
    fn __repr_properties__(self) -> List[ReprPropertyItem]:
        var props = List[ReprPropertyItem]()
        props.append(ReprPropertyItem("name", self.name))
        props.append(ReprPropertyItem("value", String(self.value)))
        return props^
    
    fn __repr_cached_properties__(self) -> List[cached_property]:
        return List[cached_property]()
    
    fn __class_name__(self) -> String:
        return "TestClass"
    
    fn __abandon_properties__(self) -> List[String]:
        return List[String]()


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

    fn test_repr_property_item(mut self):
        var item = ReprPropertyItem("test_name", "test_value")
        self.check(item.get_name() == "test_name", "ReprPropertyItem get_name")
        self.check(item.get_value() == "test_value", "ReprPropertyItem get_value")

    fn test_repr(mut self):
        var prop_names = List[String]()
        prop_names.append("name")
        prop_names.append("value")
        var result = _repr("TestClass", prop_names)
        self.check(result == "TestClass(name={}, value={})", "_repr format string")

    fn test_dict_repr_from_dict(mut self):
        var d = Dict[String, String]()
        d["name"] = "test"
        d["value"] = "123"
        d["_private"] = "hidden"
        var result = dict_repr_from_dict("TestClass", d)
        self.check(result.__contains__("name=test"), "dict_repr_from_dict includes name")
        self.check(not result.__contains__("_private"), "dict_repr_from_dict excludes private")

    fn test_property_repr(mut self):
        var obj = TestClass("test_name", 42, "private_value")
        var result = property_repr(obj)
        self.check(result.__contains__("TestClass"), "property_repr contains class name")
        self.check(result.__contains__("name"), "property_repr contains name")

    fn test_dict_repr(mut self):
        var obj = TestClass("test_name", 42, "private_value")
        var result = dict_repr(obj)
        self.check(result.__contains__("TestClass"), "dict_repr contains class name")

    fn test_properties(mut self):
        var obj = TestClass("test_name", 42, "private_value")
        var props = properties(obj)
        self.check(props.__contains__("name"), "properties contains name")
        self.check(props.__contains__("value"), "properties contains value")
        self.check(not props.__contains__("_private"), "properties excludes private")

    fn test_iter_properties_of_class(mut self):
        var obj = TestClass("test_name", 42, "private_value")
        var prop_names = iter_properties_of_class(obj)
        self.check(prop_names.__len__() == 2, "iter_properties_of_class returns 2 properties")

    fn test_truncate_string(mut self):
        var short_str = "hello"
        var truncated_short = truncate_string(short_str, 100)
        self.check(truncated_short == "hello", "truncate_string short string unchanged")
        
        var long_str = "a" * 150
        var truncated_long = truncate_string(long_str, 100)
        self.check(truncated_long.__len__() == 100, "truncate_string long string truncated")

    fn test_format_float(mut self):
        var value: Float64 = 3.14159
        var formatted = format_float(value, 4)
        self.check(formatted.__len__() <= 6, "format_float precision")

    fn test_repr_builder(mut self):
        var prop_names = List[String]()
        prop_names.append("name")
        prop_names.append("value")
        var builder = make_repr_builder("TestClass", prop_names^)
        var built = builder.build()
        self.check(built == "TestClass(name={}, value={})", "ReprBuilder build")

    fn run_all(mut self) raises:
        print("=" * 60)
        print("L00_09_repr Module Tests")
        print("=" * 60)
        
        self.test_repr_property_item()
        self.test_repr()
        self.test_dict_repr_from_dict()
        self.test_property_repr()
        self.test_dict_repr()
        self.test_properties()
        self.test_iter_properties_of_class()
        self.test_truncate_string()
        self.test_format_float()
        self.test_repr_builder()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main() raises:
    var runner = TestRunner(0, 0)
    runner.run_all()
