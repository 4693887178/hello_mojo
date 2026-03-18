# test_L00_05_repr.mojo
# Module: rqmojo.utils.repr
# Python: rqalpha.utils.repr
# Level: L00 - Leaf module
# Dependencies: class_helper

from rqmojo.utils.repr import property_repr, truncate_string, format_float


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

    fn test_property_repr_empty(mut self):
        var result = property_repr("TestClass", List[Tuple[String, String]]())
        self.check(result == "TestClass()", "property_repr with empty properties")

    fn test_property_repr_single(mut self):
        var props = List[Tuple[String, String]]()
        props.append(Tuple("name", "test"))
        var result = property_repr("TestClass", props)
        self.check(result == "TestClass(name=test)", "property_repr with single property")

    fn test_property_repr_multiple(mut self):
        var props = List[Tuple[String, String]]()
        props.append(Tuple("name", "test"))
        props.append(Tuple("value", "123"))
        var result = property_repr("TestClass", props)
        self.check(result == "TestClass(name=test, value=123)", "property_repr with multiple properties")

    fn test_truncate_string_short(mut self):
        var result = truncate_string("short", 100)
        self.check(result == "short", "truncate_string with short string")

    fn test_truncate_string_long(mut self):
        var long_string = "a" * 150
        var result = truncate_string(long_string, 100)
        self.check(len(result) == 100, "truncate_string with long string")
        self.check(result.endswith("..."), "truncate_string ends with ...")

    fn test_format_float(mut self):
        var result = format_float(3.14159265, 4)
        self.check(len(result) > 0, "format_float returns non-empty string")

    fn test_format_float_zero(mut self):
        var result = format_float(0.0, 4)
        self.check(len(result) > 0, "format_float with zero")

    fn run_all(mut self):
        print("=" * 60)
        print("L00_05_repr Module Tests")
        print("=" * 60)
        
        self.test_property_repr_empty()
        self.test_property_repr_single()
        self.test_property_repr_multiple()
        self.test_truncate_string_short()
        self.test_truncate_string_long()
        self.test_format_float()
        self.test_format_float_zero()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main() raises:
    var runner = TestRunner(0, 0)
    runner.run_all()
