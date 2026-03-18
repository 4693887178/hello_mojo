# test_L01_01_class_helper.mojo
# Module: rqmojo.utils.class_helper
# Python: rqalpha.utils.class_helper
# Level: L01 - Utils module
# Dependencies: logger, i18n

from rqmojo.utils.class_helper import CachedProperty, cached_property, PropertyRepr, property_repr
from collections import Dict


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

    fn test_cached_property_struct(mut self):
        var cp = CachedProperty("test_prop", False, "")
        self.check(cp.name == "test_prop", "CachedProperty name field")
        self.check(cp.cached == False, "CachedProperty cached field")
        self.check(cp.value == "", "CachedProperty value field")

    fn test_cached_property_function(mut self):
        var result = cached_property("test")
        self.check(result == "", "cached_property returns empty string")

    fn test_property_repr_struct(mut self):
        var props = List[String]()
        props.append("name")
        props.append("value")
        var pr = PropertyRepr(props^)
        self.check(len(pr.properties) == 2, "PropertyRepr properties length")

    fn test_property_repr_empty(mut self) raises:
        var props = Dict[String, String]()
        var result = property_repr("TestClass", props)
        self.check(result == "TestClass()", "property_repr with empty properties")

    fn test_property_repr_single(mut self) raises:
        var props = Dict[String, String]()
        props["name"] = "test"
        var result = property_repr("TestClass", props)
        self.check(result == "TestClass(name=test)", "property_repr with single property")

    fn test_property_repr_multiple(mut self) raises:
        var props = Dict[String, String]()
        props["name"] = "test"
        props["value"] = "123"
        var result = property_repr("TestClass", props)
        self.check(len(result) > 0, "property_repr with multiple properties returns non-empty")
        self.check(result.find("name=test") >= 0, "property_repr contains name property")
        self.check(result.find("value=123") >= 0, "property_repr contains value property")

    fn run_all(mut self) raises:
        print("=" * 60)
        print("L01_01_class_helper Module Tests")
        print("=" * 60)
        
        self.test_cached_property_struct()
        self.test_cached_property_function()
        self.test_property_repr_struct()
        self.test_property_repr_empty()
        self.test_property_repr_single()
        self.test_property_repr_multiple()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main() raises:
    var runner = TestRunner(0, 0)
    runner.run_all()
