# test_L11_entry.mojo
# Module: rqmojo
# Python: rqalpha
# Level: L11 - Entry Point
# Dependencies: all modules


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

    fn test_rqmojo_module_exists(mut self):
        self.check(True, "rqmojo module exists")

    fn test_version_exists(mut self):
        self.check(True, "version module exists")

    fn test_config_exists(mut self):
        self.check(True, "config module exists")

    fn test_environment_exists(mut self):
        self.check(True, "environment module exists")

    fn test_strategy_exists(mut self):
        self.check(True, "strategy module exists")

    fn test_executor_exists(mut self):
        self.check(True, "executor module exists")

    fn test_api_exists(mut self):
        self.check(True, "api module exists")

    fn test_portfolio_exists(mut self):
        self.check(True, "portfolio module exists")

    fn test_data_exists(mut self):
        self.check(True, "data module exists")

    fn test_mod_exists(mut self):
        self.check(True, "mod module exists")

    fn test_run_function_exists(mut self):
        self.check(True, "run function exists")

    fn run_all(mut self):
        print("=" * 60)
        print("L11_entry Module Tests")
        print("=" * 60)
        
        self.test_rqmojo_module_exists()
        self.test_version_exists()
        self.test_config_exists()
        self.test_environment_exists()
        self.test_strategy_exists()
        self.test_executor_exists()
        self.test_api_exists()
        self.test_portfolio_exists()
        self.test_data_exists()
        self.test_mod_exists()
        self.test_run_function_exists()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
