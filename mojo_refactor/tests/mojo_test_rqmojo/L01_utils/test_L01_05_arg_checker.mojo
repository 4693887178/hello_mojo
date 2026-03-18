# test_L01_05_arg_checker.mojo
# Module: rqmojo.utils.arg_checker
# Python: rqalpha.utils.arg_checker
# Level: L01 - Utils module
# Dependencies: exception


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

    fn test_check_string_valid(mut self) raises:
        from rqmojo.utils.arg_checker import check_string
        var result = check_string("hello", "test_arg")
        self.check(result, "check_string valid string")

    fn test_check_int_valid(mut self) raises:
        from rqmojo.utils.arg_checker import check_int
        var result = check_int(10, "test_arg")
        self.check(result, "check_int valid int")

    fn test_check_int_with_min(mut self) raises:
        from rqmojo.utils.arg_checker import check_int
        var result = check_int(50, "test_arg", 0, 100)
        self.check(result, "check_int with min and max")

    fn test_check_int_at_min(mut self) raises:
        from rqmojo.utils.arg_checker import check_int
        var result = check_int(0, "test_arg", 0, 100)
        self.check(result, "check_int at min boundary")

    fn test_check_int_at_max(mut self) raises:
        from rqmojo.utils.arg_checker import check_int
        var result = check_int(100, "test_arg", 0, 100)
        self.check(result, "check_int at max boundary")

    fn test_check_float_valid(mut self) raises:
        from rqmojo.utils.arg_checker import check_float
        var result = check_float(10.5, "test_arg")
        self.check(result, "check_float valid float")

    fn test_check_float_with_range(mut self) raises:
        from rqmojo.utils.arg_checker import check_float
        var result = check_float(50.5, "test_arg", 0.0, 100.0)
        self.check(result, "check_float with range")

    fn test_check_float_at_min(mut self) raises:
        from rqmojo.utils.arg_checker import check_float
        var result = check_float(0.0, "test_arg", 0.0, 100.0)
        self.check(result, "check_float at min boundary")

    fn test_check_float_at_max(mut self) raises:
        from rqmojo.utils.arg_checker import check_float
        var result = check_float(100.0, "test_arg", 0.0, 100.0)
        self.check(result, "check_float at max boundary")

    fn test_check_percentage_valid(mut self) raises:
        from rqmojo.utils.arg_checker import check_percentage
        var result = check_percentage(0.5, "test_arg")
        self.check(result, "check_percentage valid 0.5")

    fn test_check_percentage_zero(mut self) raises:
        from rqmojo.utils.arg_checker import check_percentage
        var result = check_percentage(0.0, "test_arg")
        self.check(result, "check_percentage at 0")

    fn test_check_percentage_one(mut self) raises:
        from rqmojo.utils.arg_checker import check_percentage
        var result = check_percentage(1.0, "test_arg")
        self.check(result, "check_percentage at 1")

    fn test_check_order_book_id_valid(mut self) raises:
        from rqmojo.utils.arg_checker import check_order_book_id
        var result = check_order_book_id("000001.XSHE", "test_arg")
        self.check(result, "check_order_book_id valid format")

    fn test_check_order_book_id_with_exchange(mut self) raises:
        from rqmojo.utils.arg_checker import check_order_book_id
        var result = check_order_book_id("IF2301.CFFEX", "test_arg")
        self.check(result, "check_order_book_id with futures exchange")

    fn test_check_int_negative(mut self) raises:
        from rqmojo.utils.arg_checker import check_int
        var result = check_int(-5, "test_arg", -10, 10)
        self.check(result, "check_int negative value")

    fn test_check_float_negative(mut self) raises:
        from rqmojo.utils.arg_checker import check_float
        var result = check_float(-5.5, "test_arg", -10.0, 10.0)
        self.check(result, "check_float negative value")

    fn run_all(mut self) raises:
        print("=" * 60)
        print("L01_05_arg_checker Module Tests")
        print("=" * 60)
        
        self.test_check_string_valid()
        self.test_check_int_valid()
        self.test_check_int_with_min()
        self.test_check_int_at_min()
        self.test_check_int_at_max()
        self.test_check_float_valid()
        self.test_check_float_with_range()
        self.test_check_float_at_min()
        self.test_check_float_at_max()
        self.test_check_percentage_valid()
        self.test_check_percentage_zero()
        self.test_check_percentage_one()
        self.test_check_order_book_id_valid()
        self.test_check_order_book_id_with_exchange()
        self.test_check_int_negative()
        self.test_check_float_negative()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main() raises:
    var runner = TestRunner(0, 0)
    runner.run_all()
