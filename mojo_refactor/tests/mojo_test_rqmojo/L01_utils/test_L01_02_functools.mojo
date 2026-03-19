# test_L01_02_functools.mojo
# Module: rqmojo.utils.functools
# Python: rqalpha.utils.functools
# Level: L01 - Utils module
# Dependencies: const

from rqmojo.utils.functools import CachedFunc, LazyProperty
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

    fn test_cached_func_struct(mut self):
        var cache = Dict[String, String]()
        var cf = CachedFunc(cache^, 128)
        self.check(cf.max_size == 128, "CachedFunc max_size field")
        self.check(len(cf.cache) == 0, "CachedFunc cache empty initially")

    fn test_cached_func_with_entries(mut self):
        var cache = Dict[String, String]()
        cache["key1"] = "value1"
        cache["key2"] = "value2"
        var cf = CachedFunc(cache^, 256)
        self.check(cf.max_size == 256, "CachedFunc max_size 256")
        self.check(len(cf.cache) == 2, "CachedFunc cache with 2 entries")

    fn test_lazy_property_struct(mut self):
        var lp = LazyProperty("test_prop", False)
        self.check(lp.name == "test_prop", "LazyProperty name field")
        self.check(lp.cached == False, "LazyProperty cached field False")

    fn test_lazy_property_cached(mut self):
        var lp = LazyProperty("cached_prop", True)
        self.check(lp.name == "cached_prop", "LazyProperty name cached_prop")
        self.check(lp.cached == True, "LazyProperty cached field True")

    fn test_cached_func_zero_size(mut self):
        var cache = Dict[String, String]()
        var cf = CachedFunc(cache^, 0)
        self.check(cf.max_size == 0, "CachedFunc max_size zero")

    fn test_cached_func_large_size(mut self):
        var cache = Dict[String, String]()
        var cf = CachedFunc(cache^, 10000)
        self.check(cf.max_size == 10000, "CachedFunc max_size large")

    fn test_lazy_property_empty_name(mut self):
        var lp = LazyProperty("", False)
        self.check(lp.name == "", "LazyProperty empty name")
        self.check(lp.cached == False, "LazyProperty empty name cached")

    fn run_all(mut self):
        print("=" * 60)
        print("L01_02_functools Module Tests")
        print("=" * 60)
        
        self.test_cached_func_struct()
        self.test_cached_func_with_entries()
        self.test_lazy_property_struct()
        self.test_lazy_property_cached()
        self.test_cached_func_zero_size()
        self.test_cached_func_large_size()
        self.test_lazy_property_empty_name()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
